import { RegisterUserDto, LoginUserDto, UpdateUserDto } from "../dtos/user.dto";
import { UserService } from "../services/auth.service";
import { Request, Response } from "express";
import z from "zod";

let userService = new UserService();
export class AuthController {
    // For register
    async register(req: Request, res: Response){
        try {
            const parsedData = RegisterUserDto.safeParse(req.body);
            if(!parsedData.success){
                return res.status(400).json (
                    { success: false, message: z.prettifyError(parsedData.error) }
                );
            }
            const newUser = await userService.registerUser(parsedData.data);
            return res.status(201).json( // 201 Created
                { success: true, data: newUser, message: "Register success" }
            );
        }catch(error: Error | any) {
            return res.status(error.statusCode || 500).json(
                { success: false, message: error.message || "Internal Server Error"}
            );
        }
    }


    // For login
    async login(req: Request, res: Response) {
        try {
            const parsedData = LoginUserDto.safeParse(req.body);
            if(!parsedData.success) {
                return res.status(400).json(
                    { success: false, message: z.prettifyError(parsedData.error) }
                );
            }
            const { token, existingUser } = await userService.loginUser(parsedData.data);
            return res.status(200).json(
                { success: true, data: existingUser, token, message: "Login success" }
            );
        } catch (error: Error | any ) {
            return res.status(error.statusCode || 500).json(
                { success: false, message: error.message || "Internal Server Error"}
            );
        }
    }
} 