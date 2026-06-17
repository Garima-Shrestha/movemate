import z from "zod";
import { UpdateUserDto } from "../../dtos/user.dto";
import { DriverService } from "../../services/driver/driver.service";
import { Request, Response } from "express";

const driverService = new DriverService();

export class DriverController {

    // Get own driver profile
    async getProfile(req: Request, res: Response) {
        try {
            const driverId = (req as any).user.id; // from JWT middleware
            const driver = await driverService.getDriverById(driverId);
            return res.status(200).json(
                { success: true, data: driver, message: "Driver profile fetched" }
            );
        } catch (error: any) {
            return res.status(error.statusCode || 500).json(
                { success: false, message: error.message || "Internal Server Error" }
            );
        }
    }

    // Update own driver profile
    async updateProfile(req: Request, res: Response) {
        try {
            const driverId = (req as any).user.id;
            const parsedData = UpdateUserDto.safeParse(req.body);
            if (!parsedData.success) {
                return res.status(400).json(
                    { success: false, message: z.prettifyError(parsedData.error) }
                );
            }
            const updated = await driverService.updateDriver(driverId, parsedData.data);
            return res.status(200).json(
                { success: true, data: updated, message: "Profile updated" }
            );
        } catch (error: any) {
            return res.status(error.statusCode || 500).json(
                { success: false, message: error.message || "Internal Server Error" }
            );
        }
    }

    // Update live location
    async updateLocation(req: Request, res: Response) {
        try {
            const driverId = (req as any).user.id;
            const { longitude, latitude } = req.body;
            if (longitude === undefined || latitude === undefined) {
                return res.status(400).json(
                    { success: false, message: "Longitude and latitude are required" }
                );
            }
            const updated = await driverService.updateLocation(driverId, longitude, latitude);
            return res.status(200).json(
                { success: true, data: updated, message: "Location updated" }
            );
        } catch (error: any) {
            return res.status(error.statusCode || 500).json(
                { success: false, message: error.message || "Internal Server Error" }
            );
        }
    }

    // Toggle online/offline availability
    async updateAvailability(req: Request, res: Response) {
        try {
            const driverId = (req as any).user.id;
            const { isAvailable } = req.body;
            if (typeof isAvailable !== 'boolean') {
                return res.status(400).json(
                    { success: false, message: "isAvailable must be a boolean" }
                );
            }
            const updated = await driverService.updateAvailability(driverId, isAvailable);
            return res.status(200).json(
                { success: true, data: updated, message: `You are now ${isAvailable ? 'online' : 'offline'}` }
            );
        } catch (error: any) {
            return res.status(error.statusCode || 500).json(
                { success: false, message: error.message || "Internal Server Error" }
            );
        }
    }

    // Get nearby available drivers (called by a passenger/user)
    async getNearbyDrivers(req: Request, res: Response) {
        try {
            const { longitude, latitude, radius } = req.query;
            const drivers = await driverService.getNearbyDrivers(
                parseFloat(longitude as string),
                parseFloat(latitude as string),
                parseFloat(radius as string) || 5000 // default 5km
            );
            return res.status(200).json(
                { success: true, data: drivers, message: "Nearby drivers fetched" }
            );
        } catch (error: any) {
            return res.status(error.statusCode || 500).json(
                { success: false, message: error.message || "Internal Server Error" }
            );
        }
    }

    async getStats(req: Request, res: Response) {
        try {
            const driverId = (req as any).user.id;

            const stats =
                await driverService.getDriverStats(driverId);

            return res.status(200).json({
                success: true,
                data: stats,
                message: "Driver stats fetched",
            });

        } catch (error: any) {
            return res.status(error.statusCode || 500).json({
                success: false,
                message:
                    error.message ||
                    "Internal Server Error",
            });
        }
    }
}