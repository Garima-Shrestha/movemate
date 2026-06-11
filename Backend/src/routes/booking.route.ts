import { Router } from "express";
import { BookingController } from "../controllers/booking.controller";
import { authorizedMiddleware } from "../middlewares/authorization.middleware";
const router = Router();
const controller = new BookingController();

router.use(authorizedMiddleware);

router.post( "/estimate", controller.estimatePrice);
router.post("/", controller.createBooking);
router.get("/", controller.getMyBookings);
router.get("/:id", controller.getBookingById);
router.patch("/:id/cancel", controller.cancelBooking);

export default router;