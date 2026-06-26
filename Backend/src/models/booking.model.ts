import mongoose, { Document, Schema } from "mongoose";
import { BookingType } from "../types/booking.type";

const BookingSchema: Schema = new Schema({
    userId: { type: mongoose.Schema.Types.ObjectId, ref: "User", required: true },
    driverId: { type: mongoose.Schema.Types.ObjectId, ref: "User", default: null },

    vehicleType: { type: String, enum: ["tempo", "pickup", "truck"], required: true },

    pickupLocation: {
        type: { type: String, enum: ["Point"], required: true },
        coordinates: { type: [Number], required: true },
    },

    dropLocation: {
        type: { type: String, enum: ["Point"], required: true },
        coordinates: { type: [Number], required: true },
    },

    distance: { type: Number, default: null },
    price: { type: Number, default: null },

    status: {
        type: String,
        enum: ["pending", "accepted", "ongoing", "completed", "cancelled"],
        default: "pending",
    },

    goodsTypes: [{
        type: String,
        enum: [
            'furniture',
            'packages',
            'electronics',
            'construction',
            'others'
        ]
    }],

    pickupAddress: {
        type: String,
        required: true,
    },

    dropAddress: {
        type: String,
        required: true,
    },

    cancelledBy: { type: String, enum: ["user", "driver"], default: null },

    startedAt: { type: Date, default: null },
    completedAt: { type: Date, default: null },
    acceptedAt: { type: Date, default: null },
    estimatedArrival: { type: Number, default: null }, // minutes
    proofOfDeliveryImage: { type: String, default: null },
    proofUploadedAt: { type: Date, default: null },
}, {
    timestamps: true,
});

BookingSchema.index({ pickupLocation: "2dsphere" });
BookingSchema.index({ dropLocation: "2dsphere" });

export interface IBooking extends BookingType, Document {
    _id: mongoose.Types.ObjectId;
    createdAt: Date;
    updatedAt: Date;
}

export const BookingModel = mongoose.model<IBooking>("Booking", BookingSchema);