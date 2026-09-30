// Install dependencies: express firebase-admin cors dotenv
// npm install
const express = require('express');
const admin = require('firebase-admin');
const cors = require('cors'); // Important for PWA access
require('dotenv').config();

const app = express();
app.use(express.json());
app.use(cors()); // Allows the Flutter PWA access from other IPs

// Setup port
const port = process.env.PORT || 3000;

// Setup debug messages in the console
const isDebug = true || process.env.NODE_ENV !== 'production';
const debug = isDebug
  ? console.log.bind(console)
  : () => {};

// Setup inhibition for test scenarios
const testMode = true;

const defaultTopic = 'announcements';

// Initialize Firebase locally with the private service account key
// Do not push this one to GitHub.
const serviceAccount = require('./serviceAccountKey.json');
admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

const ADMIN_SECRET = process.env.ADMIN_SECRET || "";

// ROOT-ENDPOINT ('/'): Digests the first request from the Flutter PWA Flutter-App
app.post('/', async (req, res) => {
    // 'token'-Field from Flutter
    const { token } = req.body;

    if (!token || token === "") {
        debug('Error: Missing Token.');
        res.status(400).json({ error: 'Missing token in request body' });
        return;
    }

    try {
        // Auto-connect to announcements topic
        const topic = defaultTopic;
        if (!testMode)) {
            debug('FCM admin requests inhibited.');
            await admin.messaging().subscribeToTopic(token, topic);
        }
        debug('Successfully registered and subscribed to topic ' + topic);
        res.status(200).json({ success: true });
    } catch (error) {
        console.error('FCM-Error on Topic-assignment during token registration:', error);
        res.status(500).send(error.toString());
    }
});

// Endpoint for PWA registration
app.post('/subscribe', async (req, res) => {
    const { token, topic } = req.body;
    if (!token || token === "") {
        debug('subscribe Error: Missing Token.');
        res.status(400).json({ error: 'Missing token in request body' });
        return;
    }
    if (!topic || topic === "") {
        debug('subscribe Error: Missing Topic.');
        res.status(400).json({ error: 'Missing topic in request body' });
        return;
    }

    try {
        if (!testMode)) {
            debug('FCM admin requests inhibited.');
            await admin.messaging().subscribeToTopic(token, topic);
        }
        debug('subscribe: Successfully subscribed to topic ' + topic);
        res.status(200).json({ success: true });
    } catch (error) {
        console.error('subscribe FCM-Error:', error.toString());
        res.status(500).send(error.toString());
    }
});

// Endpoint for unsubscribing
app.post('/unsubscribe', async (req, res) => {
    const { token, topic } = req.body;
    if (!token) {
        debug('unsubscribe Error: Missing Token.');
        res.status(400).json({ error: 'Missing token in request body' });
        return;
    }
    if (!topic) {
        debug('unsubscribe Error: Missing Topic.');
        res.status(400).json({ error: 'Missing topic in request body' });
        return;
    }

    try {
        if (!testMode)) {
            debug('FCM admin requests inhibited.');
            await admin.messaging().unsubscribeFromTopic(token, topic);
        }
        debug('unsubscribe: Successfully unsubscribed from topic ' + topic);
        res.status(200).json({ success: true });
    } catch (error) {
        console.error('unsubscribe: FCM-Error', error.toString());
        res.status(500).send(error.toString());
    }
});

// Endpoint for Admin sending
app.post('/send', async (req, res) => {
    const { messageText, author, title, secret, topic } = req.body;
    if (!topic || topic === "") {
        debug('send Error: Missing topic.');
        res.status(400).json({ error: 'Missing topic in request body' });
        return;
    }
    if (!secret || secret !== "" && secret !== ADMIN_SECRET) {
        debug('send Error: Missing secret.');
        res.status(403).send('Unauthorized');
        return;
    }
    if (!messageText || messageText === "") {
        debug('send Error: Missing message text.');
        res.status(400).send('Missing messageText');
        return;
    }
    if (!author || author === "") {
        debug('send Error: Missing author.');
        res.status(400).send('Missing author');
        return;
    }

    const payload = {
        notification:
            {
                title: title || 'Conference Announcement',
                body: messageText + "\n\n(" + author + ")",
            },
            topic: topic || 'announcements'
    };

    try {
        if (!testMode)) {
            debug('FCM admin requests inhibited.');
            await admin.messaging().send(payload);
        }
        debug("FCM-Message sent successfully.");
        res.status(200).json({ success: true });
    } catch (error) {
        console.error('FCM-Error on send:', error.toString());
        res.status(500).send(error.toString());
    }
});

app.listen(port,
    function (err) {
        if (err)
            console.log(err);
        console.log("FCM notification backend listening on port", port);
    }
);
