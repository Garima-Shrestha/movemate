import z from 'zod';

export const locationSchema = z.object({
    type: z.literal('Point'),
    coordinates: z.tuple([z.number(), z.number()])  // [longitude, latitude]
})

export const UserSchema = z.object ({
    username: z.string().min(2),
    email: z.string().email(),
    phone: z.string().regex(/^\d{10}$/, "Phone number must be exactly 10 digits"),
    password: z.string().min(8),
    role: z.enum(['admin', 'user', 'driver']).default('user'),
    accountStatus: z.enum(['active', 'suspended']).default('active'),
    imageUrl: z.string().optional(),
    
    // driver only field
    vehicleModel: z.string().optional(),
    vehicleColor: z.string().optional(),
    numberPlate: z.string().optional(),
    licenseNumber: z.string().optional(),
    isAvailable: z.boolean().optional(),
    location: locationSchema.optional(),

    // verification fields by admin
    licenseImageUrl: z.string().optional(),
    verificationStatus: z.enum(['pending', 'approved', 'rejected']).optional(),
    verificationNote: z.string().optional(), // admin's reason if rejected
})

export type UserType = z. infer<typeof UserSchema>;