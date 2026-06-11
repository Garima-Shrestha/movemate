import { QueryFilter } from "mongoose";
import { IBooking, BookingModel } from "../models/booking.model";

export interface IBookingRepository {
    createBooking(data: Partial<IBooking>): Promise<IBooking>;
    getBookingById(id: string): Promise<IBooking | null>;
    updateBooking(id: string, data: Partial<IBooking>): Promise<IBooking | null>;

    getBookingsByUserId(userId: string): Promise<IBooking[]>;
    getBookingsByDriverId(driverId: string): Promise<IBooking[]>;
    getPendingBookings(): Promise<IBooking[]>;
    acceptBookingAtomic(bookingId: string, driverId: string): Promise<IBooking | null>;

    getAllBookingsPaginated(page: number, size: number, status?: string): Promise<{ bookings: IBooking[]; total: number }>;
    getDriverStats(driverId: string): Promise<{ todayEarning: number; totalEarning: number; todayDelivery: number; totalDelivery: number;}>;
}

export class BookingRepository implements IBookingRepository {
    async createBooking(data: Partial<IBooking>): Promise<IBooking> {
        const booking = new BookingModel(data);
        return await booking.save();
    }

    async getBookingById(id: string): Promise<IBooking | null> {
        return await BookingModel.findById(id)
            .populate("userId", "username email phone")
            .populate("driverId", "username phone vehicleModel numberPlate");
    }

    async updateBooking(id: string, data: Partial<IBooking>): Promise<IBooking | null> {
        return await BookingModel.findByIdAndUpdate(id, data, { new: true });
    }

    async getBookingsByUserId(userId: string): Promise<IBooking[]> {
        return await BookingModel.find({ userId })
            .populate("driverId", "username phone vehicleModel numberPlate")
            .sort({ createdAt: -1 });
    }

    async getBookingsByDriverId(driverId: string): Promise<IBooking[]> {
        return await BookingModel.find({ driverId })
            .populate("userId", "username email phone")
            .sort({ createdAt: -1 });
    }

    async getPendingBookings(): Promise<IBooking[]> {
        return await BookingModel.find({ status: "pending" })
            .populate("userId", "username phone")
            .sort({ createdAt: 1 });
    }

    async acceptBookingAtomic(bookingId: string, driverId: string): Promise<IBooking | null> {
        return await BookingModel.findOneAndUpdate(
            { _id: bookingId, status: "pending" },  // only updates if STILL pending
            { driverId: driverId, status: "accepted" },
            { new: true }
        );
    }

    async getAllBookingsPaginated(
        page: number,
        size: number,
        status?: string
    ): Promise<{ bookings: IBooking[]; total: number }> {
        const filter: QueryFilter<IBooking> = {};
        if (status) {
            filter.status = status;
        }

        const [bookings, total] = await Promise.all([
            BookingModel.find(filter)
                .populate("userId", "username email phone")
                .populate("driverId", "username phone vehicleModel numberPlate")
                .sort({ createdAt: -1 })
                .skip((page - 1) * size)
                .limit(size),
            BookingModel.countDocuments(filter)
        ]);

        return { bookings, total };
    }

    async getDriverStats(driverId: string): Promise<{
        todayEarning: number;
        totalEarning: number;
        todayDelivery: number;
        totalDelivery: number;
    }> {

        const startOfToday = new Date();
        startOfToday.setHours(0, 0, 0, 0);

        const completedBookings = await BookingModel.find({
            driverId,
            status: "completed",
        });

        const todayBookings = completedBookings.filter(
            booking =>
                booking.completedAt &&
                booking.completedAt >= startOfToday
        );

        return {
            todayEarning: todayBookings.reduce(
                (sum, booking) => sum + (booking.price || 0),
                0
            ),

            totalEarning: completedBookings.reduce(
                (sum, booking) => sum + (booking.price || 0),
                0
            ),

            todayDelivery: todayBookings.length,

            totalDelivery: completedBookings.length,
        };
    }
}