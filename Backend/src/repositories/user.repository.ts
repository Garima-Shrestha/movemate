import { QueryFilter } from "mongoose";
import { IUser, UserModel } from "../models/user.model";

export interface IUserRepository {
    createUser(data: Partial<IUser>): Promise<IUser>;
    getUserByEmail(email: string): Promise<IUser | null>;
    getUserByPhone(phone: string): Promise<IUser | null>;

    getUserById(id: string): Promise<IUser | null>;
    // getAllUsers(): Promise<IUser | null>;
    updateOneUser(id: string, data: Partial<IUser>): Promise<IUser | null>;
    deleteOneUser(id: string): Promise<boolean | null>;

    getAllUsersPaginated(page: number, size: number, searchTerm?: string): Promise<{ users: IUser[]; total: number }>;

    getNearbyDrivers(longitude: number, latitude: number, radiusInMeters: number, vehicleType?: string): Promise<IUser[]>;
    getAvailableDrivers(): Promise<IUser[]>;
    updateDriverLocation(id: string, longitude: number, latitude: number): Promise<IUser | null>;
    updateDriverAvailability(id: string, isAvailable: boolean): Promise<IUser | null>;

    getPendingDrivers(): Promise<IUser[]>;

    getUserByNumberPlate(numberPlate: string): Promise<IUser | null>;
    getUserByLicenseNumber(licenseNumber: string): Promise<IUser | null>;
    updateAccountStatus(id: string, status: 'active' | 'suspended'): Promise<IUser | null>;

    updateLicenseImage(id: string, licenseImageUrl: string): Promise<IUser | null>;
    clearLicenseImage(id: string): Promise<IUser | null>;
} 

export class UserRepository implements IUserRepository {
    async createUser(data: Partial<IUser>): Promise<IUser> {
        const user = new UserModel(data);
        return await user.save();
    }

    async getUserByEmail(email: string): Promise<IUser | null> {
        const user = await UserModel.findOne({ email: { $regex: `^${email}$`, $options: "i" } })
        return user;
    }

    async getUserByPhone(phone: string): Promise<IUser | null> {
        return await UserModel.findOne({ phone });
    } 

    async getUserById(id: string): Promise<IUser | null> {
        const user = await UserModel.findById(id);
        return user;
    }

    // async getAllUsers(): Promise<IUser[]> {
    //     const users = await UserModel.find();
    //     return users;
    // }

    async updateOneUser(id: string, data: Partial<IUser>): Promise<IUser | null> {
        const updateUser = await UserModel.findByIdAndUpdate(id, data, {new: true});
        return updateUser;
    }

    async deleteOneUser(id: string): Promise<boolean | null> {
        const result = await UserModel.findByIdAndDelete(id);
        return result ? true : null;
    }

    async getAllUsersPaginated(
        page: number,
        size: number,
        searchTerm?: string
    ): Promise<{ users: IUser[]; total: number }> {
        const filter: QueryFilter<IUser> = {};
        if (searchTerm) {
            filter.$or = [
                { username: { $regex: searchTerm, $options: "i" } },
                { email: { $regex: searchTerm, $options: "i" } },
                { phone: { $regex: searchTerm, $options: "i" } }
            ];
        }

        const [users, total] = await Promise.all([
            UserModel.find(filter)
                .skip((page - 1) * size)
                .limit(size),
            UserModel.countDocuments(filter)
        ]);

        return { users, total };
    }

    async getNearbyDrivers(longitude: number, latitude: number, radiusInMeters: number, vehicleType?: string): Promise<IUser[]> {
        return await UserModel.find({
            role: 'driver',
            isAvailable: true,
            ...(vehicleType && { vehicleType }),
            location: {
                $near: {
                    $geometry: { type: 'Point', coordinates: [longitude, latitude] },
                    $maxDistance: radiusInMeters
                }
            }
        });
    }

    async getAvailableDrivers(): Promise<IUser[]> {
        return await UserModel.find({ role: 'driver', isAvailable: true });
    }

    async updateDriverLocation(id: string, longitude: number, latitude: number): Promise<IUser | null> {
        return await UserModel.findByIdAndUpdate(
            id,
            { location: { type: 'Point', coordinates: [longitude, latitude] } },
            { new: true }
        );
    }

    async updateDriverAvailability(id: string, isAvailable: boolean): Promise<IUser | null> {
        return await UserModel.findByIdAndUpdate(id, { isAvailable }, { new: true });
    }

    async getPendingDrivers(): Promise<IUser[]> {
        return await UserModel.find({ 
            role: 'driver', 
            verificationStatus: 'pending' 
        });
    }

    async getUserByNumberPlate(numberPlate: string): Promise<IUser | null> {
        return await UserModel.findOne({ numberPlate });
    }

    async getUserByLicenseNumber(licenseNumber: string): Promise<IUser | null> {
        return await UserModel.findOne({ licenseNumber });
    }

    async updateAccountStatus(id: string, status: 'active' | 'suspended'): Promise<IUser | null> {
        return await UserModel.findByIdAndUpdate(id, { accountStatus: status }, { new: true });
    }

    async updateLicenseImage(id: string, licenseImageUrl: string): Promise<IUser | null> {
        return await UserModel.findByIdAndUpdate(id, { licenseImageUrl }, { new: true });
    }

    async clearLicenseImage(id: string): Promise<IUser | null> {
        return await UserModel.findByIdAndUpdate(
            id,
            { $unset: { licenseImageUrl: "" } },
            { new: true }
        );
    }
}