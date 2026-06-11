import z from 'zod';
import { BookingSchema } from '../types/booking.type';

export const CreateBookingDto = BookingSchema.pick({
    vehicleType: true,
    goodsTypes: true,
    pickupLocation: true,
    dropLocation: true,
    pickupAddress: true,
    dropAddress: true,
});

export type CreateBookingDto = z.infer<typeof CreateBookingDto>;

export const UpdateBookingStatusDto = BookingSchema.pick({
    status: true,
    cancelledBy: true,
});

export type UpdateBookingStatusDto = z.infer<typeof UpdateBookingStatusDto>;
