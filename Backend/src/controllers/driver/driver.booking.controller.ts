import { Request, Response } from "express";
import { DriverBookingService } from "../../services/driver/driver.booking.service";

const driverBookingService = new DriverBookingService();

export class DriverBookingController {

    async getPendingBookings(req: Request, res: Response) {
        try {
            const bookings = await driverBookingService.getPendingBookings();
            return res.status(200).json(
                { success: true, data: bookings, message: "Pending bookings fetched" }
            );
        } catch (error: any) {
            return res.status(error.statusCode || 500).json(
                { success: false, message: error.message || "Internal Server Error" }
            );
        }
    }

    async getMyBookings(req: Request, res: Response) {
        try {
            const driverId = (req as any).user._id.toString();
            const bookings = await driverBookingService.getMyBookings(driverId);
            return res.status(200).json(
                { success: true, data: bookings, message: "Bookings fetched successfully" }
            );
        } catch (error: any) {
            return res.status(error.statusCode || 500).json(
                { success: false, message: error.message || "Internal Server Error" }
            );
        }
    }

    async acceptBooking(req: Request, res: Response) {
        try {
            const driverId = (req as any).user._id.toString();
            const bookingId = req.params.id as string;
            const updated = await driverBookingService.acceptBooking(bookingId, driverId);
            return res.status(200).json(
                { success: true, data: updated, message: "Booking accepted" }
            );
        } catch (error: any) {
            return res.status(error.statusCode || 500).json(
                { success: false, message: error.message || "Internal Server Error" }
            );
        }
    }

    async goodsPickedUp(req: Request, res: Response) {
        try {
            const driverId = (req as any).user._id.toString();
            const bookingId = req.params.id as string;
            await driverBookingService.goodsPickedUp(bookingId, driverId);
            return res.status(200).json(
                { success: true, message: "Goods picked up event emitted" }
            );
        } catch (error: any) {
            return res.status(error.statusCode || 500).json(
                { success: false, message: error.message || "Internal Server Error" }
            );
        }
    }

    async arrivedAtPickup(req: Request, res: Response) {
        try {
            const driverId = (req as any).user._id.toString();
            const bookingId = req.params.id as string;
            await driverBookingService.arrivedAtPickup(bookingId, driverId);
            return res.status(200).json(
                { success: true, message: "Arrived at pickup emitted" }
            );
        } catch (error: any) {
            return res.status(error.statusCode || 500).json(
                { success: false, message: error.message || "Internal Server Error" }
            );
        }
    }

    async startTrip(req: Request, res: Response) {
        try {
            const driverId = (req as any).user._id.toString();
            const bookingId = req.params.id as string;
            const updated = await driverBookingService.startTrip(bookingId, driverId);
            return res.status(200).json(
                { success: true, data: updated, message: "Trip started" }
            );
        } catch (error: any) {
            return res.status(error.statusCode || 500).json(
                { success: false, message: error.message || "Internal Server Error" }
            );
        }
    }

    async completeTrip(req: Request, res: Response) {
        try {
            const driverId = (req as any).user._id.toString();
            const bookingId = req.params.id as string;
            const updated = await driverBookingService.completeTrip(bookingId, driverId);
            return res.status(200).json(
                { success: true, data: updated, message: "Trip completed" }
            );
        } catch (error: any) {
            return res.status(error.statusCode || 500).json(
                { success: false, message: error.message || "Internal Server Error" }
            );
        }
    }

    async cancelBooking(req: Request, res: Response) {
        try {
            const driverId = (req as any).user._id.toString();
            const bookingId = req.params.id as string;
            const updated = await driverBookingService.cancelBooking(bookingId, driverId);
            return res.status(200).json(
                { success: true, data: updated, message: "Booking cancelled" }
            );
        } catch (error: any) {
            return res.status(error.statusCode || 500).json(
                { success: false, message: error.message || "Internal Server Error" }
            );
        }
    }
}