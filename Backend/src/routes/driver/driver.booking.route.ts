import { Router } from "express";
import { DriverBookingController } from "../../controllers/driver/driver.booking.controller";
import { authorizedMiddleware, driverOnlyMiddleware } from "../../middlewares/authorization.middleware";

const router = Router();
const controller = new DriverBookingController();

router.use(authorizedMiddleware, driverOnlyMiddleware);

router.get("/pending", controller.getPendingBookings);
router.get("/my-bookings", controller.getMyBookings);
router.patch("/:id/accept", controller.acceptBooking);
router.patch("/:id/start", controller.startTrip);
router.post("/:id/arrived", controller.arrivedAtPickup);
router.post("/:id/picked-up", controller.goodsPickedUp);
router.patch("/:id/complete", controller.completeTrip);
router.patch("/:id/cancel", controller.cancelBooking);

export default router;