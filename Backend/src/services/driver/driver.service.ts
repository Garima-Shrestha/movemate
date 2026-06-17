import { UserRepository } from "../../repositories/user.repository";
import { HttpError } from "../../errors/http-error";
import { UpdateUserDto } from "../../dtos/user.dto";
import { BookingRepository } from "../../repositories/booking.repository";
import { getIO } from "../../socket";

const userRepository = new UserRepository();
const bookingRepository = new BookingRepository();

export class DriverService {

    // Get driver profile
    async getDriverById(driverId: string) {
        const driver = await userRepository.getUserById(driverId);
        if (!driver) throw new HttpError(404, "Driver not found");
        if (driver.role !== 'driver') throw new HttpError(403, "User is not a driver");
        return driver;
    }

    // Update driver profile 
    async updateDriver(driverId: string, data: UpdateUserDto) {
        const driver = await userRepository.getUserById(driverId);
        if (!driver) throw new HttpError(404, "Driver not found");
        if (driver.role !== 'driver') throw new HttpError(403, "User is not a driver");

        if (
            ("vehicleModel" in data && !data.vehicleModel) ||
            ("numberPlate" in data && !data.numberPlate) ||
            ("licenseNumber" in data && !data.licenseNumber)
        ) {
            throw new HttpError(400, "Driver details cannot be empty");
        }

        if (data.email && driver.email !== data.email) {
            const emailExists = await userRepository.getUserByEmail(data.email);
            if (emailExists) throw new HttpError(409, "Email already in use");
        }

        if (data.phone && driver.phone !== data.phone) {
            const phoneExists = await userRepository.getUserByPhone(data.phone);
            if (phoneExists) throw new HttpError(409, "Phone number already in use");
        }

        const updatedDriver = await userRepository.updateOneUser(driverId, data);
        return updatedDriver;
    }

    // Update driver's live location
    async updateLocation(driverId: string, longitude: number, latitude: number) {
        const driver = await userRepository.getUserById(driverId);
        if (!driver) throw new HttpError(404, "Driver not found");
        if (driver.role !== 'driver') throw new HttpError(403, "User is not a driver");

        const updated = await userRepository.updateDriverLocation(driverId, longitude, latitude);

        // live tracking: push driver's new coordinates to the user during an ongoing trip
        const activeBookings = await bookingRepository.getBookingsByDriverId(driverId);
        const activeBooking = activeBookings.find(b => b.status === "ongoing");
        if (activeBooking) {
            const userId = activeBooking.userId.toString();
            getIO().to(userId).emit("driverLocationUpdated", {
                driverId,
                coordinates: [longitude, latitude]
            });
        }


        return updated;
    }

    // Toggle availability (online/offline)
    async updateAvailability(driverId: string, isAvailable: boolean) {
        const driver = await userRepository.getUserById(driverId);
        if (!driver) throw new HttpError(404, "Driver not found");
        if (driver.role !== 'driver') throw new HttpError(403, "User is not a driver");

        // Cannot go available without vehicle details
        if (isAvailable) {
            if (!driver.vehicleModel || !driver.numberPlate || !driver.licenseNumber) {
                throw new HttpError(400, "Complete your vehicle details before going available");
            }

            // Cannot go available without a location set
            // if (!driver.location) {
            //     throw new HttpError(400, "Location must be set before going available");
            // }
            if (!driver.location || !driver.location.coordinates || driver.location.coordinates.length !== 2) {
                throw new HttpError(400, "Location must be set before going available");
            }
        }

        const updated = await userRepository.updateDriverAvailability(driverId, isAvailable);
        return updated;
    }

    // Get all nearby available drivers (called by user/passenger)
    async getNearbyDrivers(longitude: number, latitude: number, radiusInMeters: number) {
        if (!longitude || !latitude) {
            throw new HttpError(400, "Longitude and latitude are required");
        }
        if (radiusInMeters > 50000) {
            throw new HttpError(400, "Search radius cannot exceed 50km");
        }
        const drivers = await userRepository.getNearbyDrivers(longitude, latitude, radiusInMeters);
        return drivers;
    }

    // Get all available drivers 
    async getAvailableDrivers() {
        const drivers = await userRepository.getAvailableDrivers();
        return drivers;
    }

    async getDriverStats(driverId: string) {
        return await bookingRepository.getDriverStats(driverId);
    }
}