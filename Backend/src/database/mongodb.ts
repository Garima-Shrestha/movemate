import mongoose from "mongoose";
import { MONGODB_URI } from "../config";

export async function connectDatabase() {
    try{
        await mongoose.connect(MONGODB_URI);
        console.log("Database connected successfully");
    }catch(error){
        console.log("Database Error", error);
        process.exit(1);
    }
}