import { BookingRepository } from "../../repositories/booking.repository";
import { UserRepository } from "../../repositories/user.repository";
import { HttpError } from "../../errors/http-error";
import { getIO } from "../../socket";

const bookingRepository = new BookingRepository();
const userRepository = new UserRepository();

export class DriverBookingService {

    // driver sees all pending bookings
    async getPendingBookings() {
        return await bookingRepository.getPendingBookings();
    }

    // driver sees their own booking history
    async getMyBookings(driverId: string) {
        return await bookingRepository.getBookingsByDriverId(driverId);
    }

    async acceptBooking(bookingId: string, driverId: string) {
        const booking = await bookingRepository.getBookingById(bookingId);
        if (!booking) throw new HttpError(404, "Booking not found");
        if (booking.status !== "pending") {
            throw new HttpError(400, "Booking is no longer available");
        }

        // driver should not be able to accept if they already have an active booking
        const myBookings = await bookingRepository.getBookingsByDriverId(driverId);
        const hasActiveBooking = myBookings.some(
            b => b.status === "accepted" || b.status === "ongoing"
        );
        if (hasActiveBooking) {
            throw new HttpError(400, "You already have an active booking");
        }

        const driver = await userRepository.getUserById(driverId);
        if (!driver) throw new HttpError(404, "Driver not found");

        if (!driver.isAvailable) {
            throw new HttpError(400, "You must toggle yourself online before accepting bookings");
        }

        // const updated = await bookingRepository.updateBooking(bookingId, {
        //     driverId: driverId as any,
        //     status: "accepted",
        // });
        // return updated;

        const updated = await bookingRepository.acceptBookingAtomic(bookingId, driverId);

        if (!updated) {
            throw new HttpError(400, "Booking was just taken by another driver");
        }

        const populatedBooking =
            await bookingRepository.getBookingById(
                updated._id.toString()
        );
            

        // Calculate ETA from driver's current location to pickup point
        let estimatedArrival: number | null = null;
        if (driver.location?.coordinates) {
            const [dLon, dLat] = driver.location.coordinates;
            const [pLon, pLat] = updated.pickupLocation.coordinates;
            const R = 6371;
            const dLat2 = ((pLat - dLat) * Math.PI) / 180;
            const dLon2 = ((pLon - dLon) * Math.PI) / 180;
            const a = Math.sin(dLat2/2)**2 + Math.cos(dLat*Math.PI/180)*Math.cos(pLat*Math.PI/180)*Math.sin(dLon2/2)**2;
            const distKm = R * 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1-a));
            // estimatedArrival = Math.round((distKm / 30) * 60); // assumes 30 km/h average city speed
            estimatedArrival = Math.max(  // assumes 30 km/h average city speed
                1,
                Math.round((distKm / 30) * 60)
            );
        }

        await bookingRepository.updateBooking(bookingId, {
            acceptedAt: new Date(),
            estimatedArrival,
        });

        // notify only the specific user whose booking was accepted
        const userId = updated.userId.toString();
        const tripCount = await bookingRepository.getDriverTripCount(driverId);
        const payload = { ...populatedBooking!.toObject(), estimatedArrival, tripCount, driverLocation: driver.location, };
        getIO().to(userId).emit("bookingAccepted", payload);
        getIO().to(driverId).emit("bookingAccepted", payload);
        
        // getIO().to(userId).emit("bookingAccepted", { ...updated.toObject(), estimatedArrival });
        // getIO().to(driverId).emit("bookingAccepted", { ...updated.toObject(), estimatedArrival });

        await userRepository.updateDriverAvailability(driverId, false);

        return updated;

        // const updated = await bookingRepository.acceptBookingAtomic(bookingId, driverId);
        // if (!updated) {
        //     throw new HttpError(400, "Booking was just taken by another driver");
        // }

        // // notify only the specific user whose booking was accepted
        // const userId = updated.userId.toString();
        // getIO().to(userId).emit("bookingAccepted", updated); // notify users
        // getIO().to(driverId).emit("bookingAccepted", updated); // notify drivers

        // await userRepository.updateDriverAvailability(driverId, false);

        // return updated;

    }

    async goodsPickedUp(bookingId: string, driverId: string) {
        const booking = await bookingRepository.getBookingById(bookingId);
        if (!booking) throw new HttpError(404, "Booking not found");

        if ((booking.driverId as any)?._id.toString() !== driverId) {
            throw new HttpError(403, "You are not assigned to this booking");
        }

        const userId =
            (booking.userId as any)?._id?.toString()
            ?? booking.userId.toString();

        getIO().to(userId).emit("goodsPickedUp", {
            bookingId: booking._id,
        });
    }

    async arrivedAtPickup(bookingId: string, driverId: string) {
        const booking = await bookingRepository.getBookingById(bookingId);
        if (!booking) throw new HttpError(404, "Booking not found");

        if ((booking.driverId as any)?._id.toString() !== driverId) {
            throw new HttpError(403, "You are not assigned to this booking");
        }
        if (booking.status !== "ongoing") {
            throw new HttpError(400, "Trip must be ongoing for driver to arrive");
        }

        const userId =
            (booking.userId as any)?._id?.toString()
            ?? booking.userId.toString();

        getIO().to(userId).emit("arrivedAtPickup", {
            bookingId: booking._id,
        });
    }

    async startTrip(bookingId: string, driverId: string) {
        const booking = await bookingRepository.getBookingById(bookingId);
        if (!booking) throw new HttpError(404, "Booking not found");

        if ((booking.driverId as any)?._id.toString() !== driverId) {
            throw new HttpError(403, "You are not assigned to this booking");
        }
        if (booking.status !== "accepted") {
            throw new HttpError(400, "Booking must be accepted before starting");
        }

        const updated = await bookingRepository.updateBooking(bookingId, {
            status: "ongoing",
            startedAt: new Date(),
        });

        if (!updated) {
            throw new HttpError(404, "Booking not found");
        }

        const driver = await userRepository.getUserById(driverId);
        const userId =
            (booking.userId as any)?._id?.toString()
            ?? booking.userId.toString();

        getIO().to(userId).emit("tripStarted", {
            ...updated.toObject(),
            driverLocation: driver?.location,
        });

        return updated;
    }

    async completeTrip(bookingId: string, driverId: string) {
        const booking = await bookingRepository.getBookingById(bookingId);
        if (!booking) throw new HttpError(404, "Booking not found");

        if ((booking.driverId as any)?._id.toString() !== driverId) {
            throw new HttpError(403, "You are not assigned to this booking");
        }
        if (booking.status !== "ongoing") {
            throw new HttpError(400, "Booking must be ongoing before completing");
        }

        const updated = await bookingRepository.updateBooking(bookingId, {
            status: "completed",
            completedAt: new Date(),
        });

        // const userId = booking.userId.toString();
        // getIO().to(userId).emit("tripCompleted", updated);
        
        const userId =
            (booking.userId as any)?._id?.toString()
            ?? booking.userId.toString();

        const populatedCompleted = await bookingRepository.getBookingById(bookingId);
        getIO().to(userId).emit("tripCompleted", populatedCompleted?.toObject() ?? updated?.toObject());

        await userRepository.updateDriverAvailability(driverId, true);

        return updated;
    }


    async cancelBooking(bookingId: string, driverId: string) {
        const booking = await bookingRepository.getBookingById(bookingId);
        if (!booking) throw new HttpError(404, "Booking not found");

        if ((booking.driverId as any)?._id.toString() !== driverId) {
            throw new HttpError(403, "You are not assigned to this booking");
        }
        if (booking.status === "completed" || booking.status === "cancelled") {
            throw new HttpError(400, `Booking is already ${booking.status}`);
        }

        // CHANGED: ongoing trip → permanent cancellation, store who cancelled
        if (booking.status === "ongoing") {
            const updated = await bookingRepository.updateBooking(bookingId, {
                status: "cancelled",
                cancelledBy: "driver",
            });
            const userId = (booking.userId as any)?._id?.toString() ?? booking.userId.toString();

            getIO().to(userId).emit("bookingCancelled", updated);
            await userRepository.updateDriverAvailability(driverId, true);
            return updated;
        }

        // accepted but not yet started → back to pending for another driver
        const updated = await bookingRepository.updateBooking(bookingId, {
            status: "pending",
            cancelledBy: null,
            driverId: null as any,
        });

        const userId = (booking.userId as any)?._id?.toString() ?? booking.userId.toString();

        getIO().to(userId).emit("bookingReopened", updated);
        await userRepository.updateDriverAvailability(driverId, true);
        return updated;
    }
}