import express, { Application } from "express";
import bodyParser from 'body-parser';
import dotenv from "dotenv";
import cors from 'cors';
import path from "path";

import authRoutes from './routes/auth.route';
import adminRoutes from './routes/admin/admin.route';
import driverRoutes from './routes/driver/driver.route';
import bookingRoutes from './routes/booking.route';
import driverBookingRoutes from './routes/driver/driver.booking.route';
import adminBookingRoutes from './routes/admin/admin.booking.route';
import adminVerificationRoutes from './routes/admin/admin.verification.route';


dotenv.config();
console.log(process.env.PORT);

const app: Application = express();


let corsOptions = {
    origin: ["http://localhost:3000", "http://localhost:3003"],

}
app.use(cors(corsOptions));

app.use(bodyParser.json());

app.use("/uploads", express.static(path.join(__dirname, "../uploads")));

app.use('/api/auth', authRoutes);
app.use('/api/admin/users', adminRoutes);
app.use('/api/driver', driverRoutes);
app.use('/api/bookings', bookingRoutes);
app.use('/api/driver/bookings', driverBookingRoutes);
app.use('/api/admin/bookings', adminBookingRoutes);
app.use('/api/admin/verifications', adminVerificationRoutes);

export default app;