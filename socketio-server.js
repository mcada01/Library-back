const express = require('express');
const http = require('http')
const socketio = require('socket.io');
const MongoClient = require('mongodb').MongoClient;
require('dotenv').config();

const app = express();
const server = http.Server(app);
const websocket = socketio(server);

startMongoDBConnection();

function startMongoDBConnection() {
    MongoClient.connect(process.env.DB_CONNECTION_MONGO, function (err, client) {
        console.log("Connected successfully to server");
        const db = client.db(process.env.DB_DATABASE_MONGO);
        startWebSocketServer(db);
    });
}

function startWebSocketServer(db) {
    const clients = {};
    const users = {};

    const sendLocations = async () => {
        const cursor = db.collection("users").find(
            {
                latitude: { $exists: true, $ne: null },
                longitude: { $exists: true, $ne: null }
            }
        );
        const results = await cursor.toArray();
        websocket.emit('locations', results);
    }

    websocket.on('connection', function (socket) {
        clients[socket.id] = socket;

        console.log('client connect...', socket.id);

        socket.on('location', async (data) => {
            console.log('location %s', data);
            const { modifiedCount } = await db.collection("users").updateOne({ _id: users[socket.id] }, {
                $currentDate: {
                    lastModified: true,
                },
                $set: data
            });
            await sendLocations();

            console.log(`${modifiedCount} document(s) was/were updated.`);
        })

        socket.on('disconnect', async () => {
            console.log('client disconnect...', socket.id)
            const { deletedCount } = await db.collection("users").deleteOne({ _id: users[socket.id] });
            console.log(`${deletedCount} document(s) was/were deleted.`);
            delete users[socket.id];
            delete clients[socket.id]
            await sendLocations();
        })

        socket.on('error', (err) => {
            console.log('received error from client:', socket.id)
            console.log(err)
        })
    })

    websocket.on('connect', async (socket) => {
        const { insertedId } = await db.collection("users").insertOne({});
        console.log(`User created with the following id: ${insertedId}`);
        users[socket.id] = insertedId;
        await sendLocations();
    });
}


const port = process.env.PORT_SOCKET || 9999;
server.listen(port, function (err) {
    if (err) throw err
    console.log('Listening on port %d', port);
});