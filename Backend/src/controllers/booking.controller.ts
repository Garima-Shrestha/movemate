import { Request, Response } from "express";
import { CreateBookingDto } from "../dtos/booking.dto";
import { BookingService } from "../services/booking.service";
import z from "zod";

const bookingService = new BookingService();

export class BookingController {

    async estimatePrice(req: Request, res: Response) {
        try {
            const { pickupLocation, dropLocation } = req.body;

            const result =
                await bookingService.estimatePrice(
                    pickupLocation,
                    dropLocation,
                );

            return res.status(200).json({
                success: true,
                data: result,
            });

        } catch (error: any) {
            return res.status(
                error.statusCode || 500
            ).json({
                success: false,
                message:
                    error.message ||
                    "Internal Server Error",
            });
        }
    }

    async createBooking(req: Request, res: Response) {
        try {
            const userId = (req as any).user._id.toString();
            const parsedData = CreateBookingDto.safeParse(req.body);
            if (!parsedData.success) {
                return res.status(400).json(
                    { success: false, message: z.prettifyError(parsedData.error) }
                );
            }
            const booking = await bookingService.createBooking(userId, parsedData.data);
            return res.status(201).json(
                { success: true, data: booking, message: "Booking created successfully" }
            );
        } catch (error: any) {
            return res.status(error.statusCode || 500).json(
                { success: false, message: error.message || "Internal Server Error" }
            );
        }
    }

    async getMyBookings(req: Request, res: Response) {
        try {
            const userId = (req as any).user._id.toString();
            const bookings = await bookingService.getMyBookings(userId);
            return res.status(200).json(
                { success: true, data: bookings, message: "Bookings fetched successfully" }
            );
        } catch (error: any) {
            return res.status(error.statusCode || 500).json(
                { success: false, message: error.message || "Internal Server Error" }
            );
        }
    }

    async getBookingById(req: Request, res: Response) {
        try {
            const userId = (req as any).user._id.toString();
            const bookingId = req.params.id as string;
            const booking = await bookingService.getBookingById(bookingId, userId);
            return res.status(200).json(
                { success: true, data: booking, message: "Booking fetched successfully" }
            );
        } catch (error: any) {
            return res.status(error.statusCode || 500).json(
                { success: false, message: error.message || "Internal Server Error" }
            );
        }
    }

    async cancelBooking(req: Request, res: Response) {
        try {
            const userId = (req as any).user._id.toString();
            const bookingId = req.params.id as string;
            const updated = await bookingService.cancelBooking(bookingId, userId);
            return res.status(200).json(
                { success: true, data: updated, message: "Booking cancelled successfully" }
            );
        } catch (error: any) {
            return res.status(error.statusCode || 500).json(
                { success: false, message: error.message || "Internal Server Error" }
            );
        }
    }
}