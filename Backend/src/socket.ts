// import { Server } from "socket.io";
// import http from "http";
// import { BookingRepository } from "./repositories/booking.repository";

// let io: Server;

// const bookingRepository = new BookingRepository();

// export function initSocket(server: http.Server) {
//     io = new Server(server, {
//         cors: {
//             // origin: ["http://localhost:3000", "http://localhost:3003"],
//             origin: "*",
//             methods: ["GET", "POST"]
//         }
//     });

//     io.on("connection", (socket) => {
//         console.log("Connected:", socket.id);

//         socket.on("joinRoom", (data: { userId: string, role: string }) => {
//             socket.join(data.userId);
//             if (data.role === "driver") {
//                 socket.join("drivers");
//             }
//             console.log(`${data.userId} joined`);
//         });

//         // driver sends their location while a trip is active
//         // Flutter driver app emits: socket.emit("driverLocationUpdate", { bookingId, lat, lng })
//         socket.on("driverLocationUpdate", async (data: { bookingId: string, lat: number, lng: number }) => {
//             const booking = await bookingRepository.getBookingById(data.bookingId);
//             if (!booking) return;

//             // forward the location to the user who made this booking
//             const userId = (booking.userId as any)._id
//                 ? (booking.userId as any)._id.toString()
//                 : booking.userId.toString();

//             io.to(userId).emit("driverLocation", {
//                 lat: data.lat,
//                 lng: data.lng,
//             });
//         });

//         socket.on("disconnect", () => {
//             console.log("Disconnected:", socket.id);
//         });
//     });
// }

// export function getIO(): Server {
//     if (!io) throw new Error("Socket not initialized");
//     return io;
// }



import { Server } from "socket.io";
import http from "http";
import { BookingRepository } from "./repositories/booking.repository";

let io: Server;

const bookingRepository = new BookingRepository();

export function initSocket(server: http.Server) {
    io = new Server(server, {
        cors: {
            // origin: ["http://localhost:3000", "http://localhost:3003"],
            origin: "*",
            methods: ["GET", "POST"]
        }
    });

    io.on("connection", (socket) => {
        console.log("Connected:", socket.id);

        socket.on("joinRoom", (data: { userId: string, role: string }) => {
            socket.join(data.userId);
            if (data.role === "driver") {
                socket.join("drivers");
            }
            console.log(`${data.userId} joined`);
        });

        // driver sends their location while a trip is active
        // Flutter driver app emits: socket.emit("driverLocationUpdate", { bookingId, lat, lng })
        socket.on("driverLocationUpdate", async (data: { bookingId: string, lat: number, lng: number }) => {
            const booking = await bookingRepository.getBookingById(data.bookingId);
            if (!booking) return;

            // forward the location to the user who made this booking
            const userId = (booking.userId as any)._id
                ? (booking.userId as any)._id.toString()
                : booking.userId.toString();

            io.to(userId).emit("driverLocation", {
                lat: data.lat,
                lng: data.lng,
            });
        });

        socket.on("disconnect", () => {
            console.log("Disconnected:", socket.id);
        });

        socket.on("acceptBooking", async (data) => {
            console.log("Booking accepted", data);
        });

        socket.on("declineBooking", async (data) => {
            console.log("Booking declined", data);
        });
    });
}

export function getIO(): Server {
    if (!io) throw new Error("Socket not initialized");
    return io;
}