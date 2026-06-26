import { Router } from "express";
import { BookingController } from "../controllers/booking.controller";
import { authorizedMiddleware } from "../middlewares/authorization.middleware";
import { proofUpload } from "../middlewares/upload.middleware";
const router = Router();
const controller = new BookingController();

router.use(authorizedMiddleware);

router.post( "/estimate", controller.estimatePrice);
router.post("/", controller.createBooking);
router.get("/", controller.getMyBookings);
router.get("/:id", controller.getBookingById);
router.post("/:id/proof",proofUpload.single("image"),controller.uploadProofOfDelivery);
router.patch("/:id/cancel", controller.cancelBooking);
router.delete("/:id", controller.deleteBookingHistory);

export default router;