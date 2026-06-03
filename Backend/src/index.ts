import app from "./app";
import { PORT } from "./config";
import { connectDatabase } from "./database/mongodb";
import http from "http";
import { initSocket } from "./socket";

async function start() {
    await connectDatabase();
    
    const server = http.createServer(app);
    initSocket(server);

    server.listen(PORT, () => {
        console.log(`Server: http://localhost:${PORT}`);
    })
}

start().catch((error) => console.log(error));