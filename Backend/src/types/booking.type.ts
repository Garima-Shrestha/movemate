import z from 'zod';
import { locationSchema } from './user.type';

export const BookingSchema = z.object({
    userId: z.string(),
    driverId: z.string().nullable().default(null),

    vehicleType: z.enum(['tempo', 'pickup', 'truck']),

    pickupLocation: locationSchema,
    dropLocation: locationSchema,

    distance: z.number().positive().optional(), // in km
    price: z.number().positive().optional(),

    status: z.enum(['pending', 'accepted', 'ongoing', 'completed', 'cancelled'])
             .default('pending'),

    cancelledBy: z.enum(['user', 'driver']).nullable().default(null),

    goodsTypes: z.array(
        z.enum([
            'furniture',
            'packages',
            'electronics',
            'construction',
            'others'
        ])
    ).min(1),

    pickupAddress: z.string(),
    dropAddress: z.string(),

    startedAt: z.date().nullable().default(null),
    completedAt: z.date().nullable().default(null),
    acceptedAt: z.date().nullable().default(null),
    estimatedArrival: z.number().nullable().default(null), // minutes

    proofOfDeliveryImage: z.string().nullable().optional(),
    proofUploadedAt: z.date().nullable().optional(),
});

export type BookingType = z.infer<typeof BookingSchema>;