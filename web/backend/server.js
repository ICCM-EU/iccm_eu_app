// Install dependencies: express firebase-admin cors dotenv
// npm install
const express = require('express');
const cors = require('cors'); // Important for PWA access
const crypto = require('crypto');
require('dotenv').config();

const { initializeApp, cert } = require('firebase-admin/app');
const { getMessaging } = require('firebase-admin/messaging');

const app = express();
app.use(express.json({ limit: '100kb' })); // Mitigate DoS via oversized payload bodies
app.use(cors()); // Allows the Flutter PWA access from other IPs

// Security headers and double-slash normalization middleware
app.use((req, res, next) => {
  res.setHeader('X-Content-Type-Options', 'nosniff');
  res.setHeader('X-Frame-Options', 'DENY');
  if (req.url) {
    req.url = req.url.replace(/\/{2,}/g, '/');
  }
  next();
});

// Setup port
const port = process.env.PORT || 3000;

// Setup inhibition for test scenarios
const testMode = process.env.NODE_ENV === 'test';

// Setup debug messages in the console
const isDebug = testMode || process.env.NODE_ENV !== 'production';
const debug = isDebug
  ? console.log.bind(console)
  : () => {};

const defaultTopic = 'announcements';

// Helper for timing-safe secret comparisons to mitigate timing attacks
function safeCompare(a, b) {
  if (typeof a !== 'string' || typeof b !== 'string') return false;
  const bufA = Buffer.from(a);
  const bufB = Buffer.from(b);
  if (bufA.length !== bufB.length) return false;
  return crypto.timingSafeEqual(bufA, bufB);
}

// Helper for FCM topic validation matching FCM topic specification: ^[a-zA-Z0-9-_.~%]+$
function isValidTopic(topic) {
  return typeof topic === 'string' && /^[a-zA-Z0-9-_.~%]{1,900}$/.test(topic);
}

// Initialize Firebase locally with the private service account key
let serviceAccount;
try {
  serviceAccount = require('./serviceAccountKey.json');
} catch (e) {
  serviceAccount = {
    type: "service_account",
    project_id: "iccmeu-app",
    private_key_id: "mock_key_id",
    private_key: "-----BEGIN PRIVATE KEY-----\nMIIEvgIBADANBgkqhkiG9w0BAQEFAASCBKgwggSkAgEAAoIBAQC...\n-----END PRIVATE KEY-----\n",
    client_email: "mock@iccmeu-app.iam.gserviceaccount.com",
    client_id: "123456789"
  };
}

let firebaseApp;
let messaging;
try {
  firebaseApp = initializeApp({
    credential: cert(serviceAccount)
  });
  messaging = getMessaging(firebaseApp);
} catch (e) {
  messaging = {
    subscribeToTopic: async () => ({ failureCount: 0 }),
    unsubscribeFromTopic: async () => ({ failureCount: 0 }),
    send: async () => 'mock_msg_id',
  };
}

const ADMIN_SECRET = process.env.ADMIN_SECRET || "";

// ROOT-ENDPOINT ('/'): Digests the first request from the Flutter PWA Flutter-App
app.post('/', async (req, res) => {
    const { token } = req.body || {};

    if (!token || typeof token !== 'string' || token.trim() === "") {
        debug('Error: Missing Token.');
        res.status(400).json({ error: 'Missing token in request body' });
        return;
    }

    try {
        const topic = defaultTopic;
        if (testMode) {
            debug('FCM admin requests inhibited.');
        } else {
            const response = await messaging.subscribeToTopic(token, topic);
            if (response && response.failureCount > 0) {
                const errMessage = response.errors.map(e => e.error ? e.error.message : JSON.stringify(e)).join('; ');
                console.error('FCM-Error on Topic-assignment during token registration:', errMessage);
                res.status(400).json({ error: errMessage, response });
                return;
            }
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
    const { token, topic } = req.body || {};
    if (!token || typeof token !== 'string' || token.trim() === "") {
        debug('subscribe Error: Missing Token.');
        res.status(400).json({ error: 'Missing token in request body' });
        return;
    }
    if (!topic || !isValidTopic(topic)) {
        debug('subscribe Error: Missing or invalid topic.');
        res.status(400).json({ error: 'Missing or invalid topic in request body' });
        return;
    }

    try {
        if (testMode) {
            debug('FCM admin requests inhibited.');
        } else {
            const response = await messaging.subscribeToTopic(token, topic);
            if (response && response.failureCount > 0) {
                const errMessage = response.errors.map(e => e.error ? e.error.message : JSON.stringify(e)).join('; ');
                console.error('subscribe FCM-Error:', errMessage);
                res.status(400).json({ error: errMessage, response });
                return;
            }
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
    const { token, topic } = req.body || {};
    if (!token || typeof token !== 'string' || token.trim() === "") {
        debug('unsubscribe Error: Missing Token.');
        res.status(400).json({ error: 'Missing token in request body' });
        return;
    }
    if (!topic || !isValidTopic(topic)) {
        debug('unsubscribe Error: Missing or invalid topic.');
        res.status(400).json({ error: 'Missing or invalid topic in request body' });
        return;
    }

    try {
        if (testMode) {
            debug('FCM admin requests inhibited.');
        } else {
            const response = await messaging.unsubscribeFromTopic(token, topic);
            if (response && response.failureCount > 0) {
                const errMessage = response.errors.map(e => e.error ? e.error.message : JSON.stringify(e)).join('; ');
                console.error('unsubscribe FCM-Error:', errMessage);
                res.status(400).json({ error: errMessage, response });
                return;
            }
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
    const { messageText, author, title, secret, topic } = req.body || {};
    if (!topic || !isValidTopic(topic)) {
        debug('send Error: Missing or invalid topic.');
        res.status(400).json({ error: 'Missing or invalid topic in request body' });
        return;
    }
    if (!secret || !safeCompare(secret, ADMIN_SECRET)) {
        debug('send Error: Unauthorized / invalid secret.');
        res.status(403).send('Unauthorized');
        return;
    }
    if (!messageText || typeof messageText !== 'string' || messageText.trim() === "") {
        debug('send Error: Missing message text.');
        res.status(400).send('Missing messageText');
        return;
    }
    if (!author || typeof author !== 'string' || author.trim() === "") {
        debug('send Error: Missing author.');
        res.status(400).send('Missing author');
        return;
    }

    const notificationTitle = title || 'Conference Announcement';
    const notificationBody = messageText + "\n\n(" + author + ")";

    const payload = {
        notification: {
            title: notificationTitle,
            body: notificationBody,
        },
        data: {
            title: notificationTitle,
            messageText: messageText,
            author: author,
            topic: topic || 'announcements',
        },
        webpush: {
            notification: {
                title: notificationTitle,
                body: notificationBody,
                icon: 'icons/Icon-192.png',
            },
            fcmOptions: {
                link: '/'
            }
        },
        topic: topic || 'announcements'
    };

    try {
        if (testMode) {
            debug('FCM admin requests inhibited.');
        } else {
            await messaging.send(payload);
        }
        debug("FCM-Message sent successfully on topic " + topic + ".");
        res.status(200).json({ success: true });
    } catch (error) {
        console.error('FCM-Error on send:', error.toString());
        res.status(500).send(error.toString());
    }
});

if (require.main === module) {
  app.listen(port, function (err) {
    if (err) console.log(err);
    console.log("FCM notification backend listening on port", port);
  });
}

module.exports = app;
