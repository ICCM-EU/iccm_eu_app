const express = require('express');
const admin = require('firebase-admin');
const cors = require('cors'); // Important for PWA access
require('dotenv').config();

const app = express();
app.use(express.json());
app.use(cors()); // Allows the Flutter PWA access from other IPs

// Initialize Firebase locally
const serviceAccount = require('./serviceAccountKey.json');
admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

const ADMIN_SECRET = process.env.ADMIN_SECRET || "";

// Endpoint for PWA registration
app.post('/subscribe', async (req, res) => {
    const { token, streamName } = req.body;
    try {
        await admin.messaging().subscribeToTopic(token, streamName || 'announcements');
        res.status(200).json({ success: true });
    } catch (error) {
        res.status(500).send(error.toString());
    }
});

// Endpoint for Admin sending
app.post('/send', async (req, res) => {
    const { messageText, title, secret, targetStream } = req.body;
    if (secret !== "" && secret !== ADMIN_SECRET)
        return res.status(403).send('Unauthorized');

    const payload = {
        notification: { title: title || 'Conference Update', body: messageText },
        topic: targetStream || 'announcements'
    };

    try {
        await admin.messaging().send(payload);
        res.status(200).json({ success: true });
    } catch (error) {
        res.status(500).send(error.toString());
    }
});

app.listen(3000, () => console.log('Backend is running locally on port 3000'));