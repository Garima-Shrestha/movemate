import { RegisterUserDto, LoginUserDto, UpdateUserDto } from "../dtos/user.dto";
import { UserRepository } from "../repositories/user.repository";
import bcryptjs from "bcryptjs";
import { HttpError } from "../errors/http-error";
import jwt from 'jsonwebtoken';
import { JWT_SECRET } from "../config";

let userRepository = new UserRepository;

export class UserService {
    // For register
    async registerUser(data: RegisterUserDto) {
        const checkEmail = await userRepository.getUserByEmail(data.email);
        if (checkEmail){
            throw new HttpError(409, "Email already in use");
        }
        const checkPhone = await userRepository.getUserByPhone(data.phone);
        if (checkPhone) {
            throw new HttpError(409, "Phone number already in use");
        }

        if (data.role === 'driver') {
            if (!data.vehicleModel || !data.numberPlate || !data.licenseNumber) {
                throw new HttpError(400, "Drivers must provide vehicle model, number plate and license number");
            }

            const plateExists = await userRepository.getUserByNumberPlate(data.numberPlate);
            if (plateExists) throw new HttpError(409, "Number plate already registered");

            const licenseExists = await userRepository.getUserByLicenseNumber(data.licenseNumber);
            if (licenseExists) throw new HttpError(409, "License number already registered");
        }

        if (data.role === 'user') {
            // Delete standard optional driver fields from the incoming payload
            delete data.vehicleModel;
            delete data.vehicleColor;
            delete data.numberPlate;
            delete data.licenseNumber;
            delete data.location;
        }

        const hashedPassword = await bcryptjs.hash(data.password, 10);
        data.password = hashedPassword;
       
        const newUser = await userRepository.createUser(data);
        return newUser;
    }


    // For login
     async loginUser(data: LoginUserDto){
        const existingUser = await userRepository.getUserByEmail(data.email);
        if(!existingUser){
            throw new HttpError(404,"Email not found");
        }
        const isPasswordValid = await bcryptjs.compare(data.password, existingUser.password); // data.password → the plain password submitted by the use, existing.password → the hashed password stored in the database for that user
        if (!isPasswordValid){
            throw new HttpError(401,"Invalid credentials");
        }
        // generate JWT
        const payload = {
            id: existingUser._id,
            email: existingUser.email,
            role: existingUser.role
        }; 
        const token = jwt.sign(payload, JWT_SECRET, {expiresIn: '30d'}); 
        return{token,existingUser};
    }


    
    // Get a user by ID
    async getUserById(userId: string) {
        const user = await userRepository.getUserById(userId);
        if (!user) {
            throw new HttpError(404, "User not found");
        }
        return user;
    }

    // Update a user by ID
    async updateUser(userId: string, data: UpdateUserDto) {
        const user = await userRepository.getUserById(userId);
        if (!user) {
            throw new HttpError(404, "User not found");
        }
        if(data.email && user.email !== data.email){
            const emailExists = await userRepository.getUserByEmail(data.email!);
            if(emailExists){
                throw new HttpError(409, "Email already in use");
            }
        }

        if(data.phone && user.phone !== data.phone){
            const phoneExists = await userRepository.getUserByPhone(data.phone!);
            if(phoneExists){
                throw new HttpError(409, "Phone number already in use");
            }
        }
        if(data.password){
            const hashedPassword = await bcryptjs.hash(data.password, 10);
            data.password = hashedPassword;
        }
        const updatedUser = await userRepository.updateOneUser(userId, data);
        return updatedUser;
    }
}