import { Router } from "express";
import { DriverController } from "../../controllers/driver/driver.controller";
import { authorizedMiddleware, driverOnlyMiddleware } from "../../middlewares/authorization.middleware";

const router = Router();
const controller = new DriverController();

router.use(authorizedMiddleware, driverOnlyMiddleware);

router.get("/profile", controller.getProfile);
router.get("/stats", controller.getStats);
router.put("/update-profile", controller.updateProfile);

router.put("/location", controller.updateLocation);
router.put("/availability", controller.updateAvailability);

router.get("/nearby", controller.getNearbyDrivers);

export default router;