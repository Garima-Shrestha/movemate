import mongoose, { Document, Schema } from "mongoose";
import { UserType } from "../types/user.type";

const UserSchema: Schema = new Schema ({
    username: { type: String, required: true, minLength:2 },
    email: { type: String, required: true, unique: true },
    phone: { type: String, required: true, match: [/^\d{10}$/, "Invalid phone number"]},
    password: { type: String, required: true, minLength:8 },
    role: { type: String, enum: ["user", "driver"], default: "user"},
    accountStatus: { type: String, enum: ["active", "suspended"], default: "active" },
    imageUrl: { type: String, required: false },
    vehicleModel: { type: String, required: false },
    vehicleColor: { type: String, required: false },
    numberPlate: { type: String, required: false, unique: true, sparse: true },
    licenseNumber: { type: String, required: false, unique: true, sparse: true },
    isAvailable: { 
        type: Boolean, 
        required: false, 
        // Only apply 'false' fallback if this signing up is a driver
        default: function(this: any) {
            return this.role === 'driver' ? false : undefined;
        }
    },
    location: {
        type: {
            type: String,
            enum: ["Point"],    // GeoJSON requires this to be literally "Point"
        },
        coordinates: {
            type: [Number],     // MongoDB stores as array of numbers [longitude, latitude]
        },
    },
}, {
    timestamps: true,
});

// This index is required for MongoDB geospatial queries (finding nearby drivers)
UserSchema.index({ location: "2dsphere" });

export interface IUser extends UserType, Document {
    _id: mongoose.Types.ObjectId;
    createdAt: Date;
    updatedAt: Date;
}

export const UserModel = mongoose.model<IUser>("User", UserSchema);