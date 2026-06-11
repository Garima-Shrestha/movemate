import { BookingRepository } from "../repositories/booking.repository";
import { CreateBookingDto } from "../dtos/booking.dto";
import { HttpError } from "../errors/http-error";
import { getIO } from "../socket";
import { UserRepository } from "../repositories/user.repository";

const bookingRepository = new BookingRepository();
const userRepository = new UserRepository();

function calculateDistance(
    [lon1, lat1]: [number, number],
    [lon2, lat2]: [number, number]
): number {
    const R = 6371;
    const dLat = ((lat2 - lat1) * Math.PI) / 180;
    const dLon = ((lon2 - lon1) * Math.PI) / 180;
    const a =
        Math.sin(dLat / 2) ** 2 +
        Math.cos((lat1 * Math.PI) / 180) *
        Math.cos((lat2 * Math.PI) / 180) *
        Math.sin(dLon / 2) ** 2;
    return R * 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
}

function calculatePrice(distanceKm: number, vehicleType: string): number {
    const baseFare: Record<string, number> = {
        tempo: 100,
        pickup: 150,
        truck: 250,
    };
    const perKm: Record<string, number> = {
        tempo: 40,
        pickup: 60,
        truck: 100,
    };
    return Math.round((baseFare[vehicleType] ?? 100) + distanceKm * (perKm[vehicleType] ?? 40));
}

export class BookingService {

    async estimatePrice(
        pickupLocation: any,
        dropLocation: any
    ) {

        const distance = calculateDistance(
            pickupLocation.coordinates as [number, number],
            dropLocation.coordinates as [number, number]
        );

        return {
            distance: parseFloat(distance.toFixed(2)),
            tempo: calculatePrice(distance, "tempo"),
            pickup: calculatePrice(distance, "pickup"),
            truck: calculatePrice(distance, "truck"),
        };
    }

    async createBooking(userId: string, data: CreateBookingDto) {
        // a user should not be able to create a new booking if they already have one ongoing or pending
        const existingBookings = await bookingRepository.getBookingsByUserId(userId);
        const hasActiveBooking = existingBookings.some(     // .some() checks if at least one item in the array matches a condition
            b => b.status === "pending" || b.status === "accepted" || b.status === "ongoing"
        );
        if (hasActiveBooking) {
            throw new HttpError(400, "You already have an active booking");
        }

        // const booking = await bookingRepository.createBooking({
        //     ...data,
        //     userId: userId as any,
        //     status: "pending",
        // });
        // return booking;

        const distance = calculateDistance(
            data.pickupLocation.coordinates as [number, number],
            data.dropLocation.coordinates as [number, number]
        );
        const price = calculatePrice(distance, data.vehicleType);

        const booking = await bookingRepository.createBooking({
            ...data,
            userId: userId as any,
            status: "pending",
            distance: parseFloat(distance.toFixed(2)),
            price,
        });

        // notify nearby drivers instantly
        const nearbyDrivers = await userRepository.getNearbyDrivers(
            data.pickupLocation.coordinates[0],
            data.pickupLocation.coordinates[1],
            5000, // 5km radius
            data.vehicleType
        );

        nearbyDrivers.forEach(driver => {
            getIO().to(driver._id.toString()).emit("newBooking", booking);
        });

        setTimeout(async () => {
            const fresh = await bookingRepository.getBookingById(booking._id.toString());
            if (fresh && fresh.status === "pending") {
                await bookingRepository.updateBooking(fresh._id.toString(), {
                    status: "cancelled",
                });
                getIO().to(userId).emit("bookingTimeout", fresh);
            }
        }, 60000);

        return booking;
    }

    async getMyBookings(userId: string) {
        return await bookingRepository.getBookingsByUserId(userId);
    }

    async getBookingById(bookingId: string, userId: string) {
        const booking = await bookingRepository.getBookingById(bookingId);
        if (!booking) throw new HttpError(404, "Booking not found");

        // user can only view their own booking
        if ((booking.userId as any)._id.toString() !== userId) {
            throw new HttpError(403, "You are not authorized to view this booking");
        }
        return booking;
    }

    async cancelBooking(bookingId: string, userId: string) {
        const booking = await bookingRepository.getBookingById(bookingId);
        if (!booking) throw new HttpError(404, "Booking not found");

        if ((booking.userId as any)._id.toString() !== userId) {
            throw new HttpError(403, "You are not authorized to cancel this booking");
        }
        if (booking.status === "completed" || booking.status === "cancelled") {
            throw new HttpError(400, `Booking is already ${booking.status}`);
        }
        if (booking.status === "ongoing") {
            throw new HttpError(400, "Cannot cancel an ongoing booking");
        }

        const updated = await bookingRepository.updateBooking(bookingId, {
            status: "cancelled",
            cancelledBy: "user",
        });

        // notify driver if one was assigned
        if (booking.driverId) {
            const driverId = booking.driverId.toString();
            getIO().to(driverId).emit("bookingCancelled", updated);
        }

        return updated;
    }
}