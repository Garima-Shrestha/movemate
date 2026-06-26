import z from 'zod';
import { UserSchema } from '../types/user.type';

// For register
export const RegisterUserDto = UserSchema.pick(
    {
        username: true,
        email: true,
        phone: true, 
        password: true,
        role: true,
        imageUrl: true,
        
        // driver only field
        vehicleModel: true,
        vehicleColor: true,
        numberPlate: true,
        licenseNumber: true,
        isAvailable: true,
        location: true,
        vehicleType: true,
    }
)
export type RegisterUserDto = z.infer<typeof RegisterUserDto>


// for login
export const LoginUserDto = z.object({
    email: z.string().email(),
    password: z.string().min(8),
});
export type LoginUserDto = z.infer<typeof LoginUserDto>;


export const UpdateUserDto = UserSchema.partial();
export type UpdateUserDto = z.infer<typeof UpdateUserDto>;
