Firebase Cloud Messaging (FCM) combined with a lightweight serverless backend (such as Firebase Cloud Functions or Cloud Run) is the optimal technology for this use case. Since you do not have user logins, you can perfectly rely on FCM Topic Pub/Sub (topic subscription).
In this setup, every installed instance of the Flutter PWA automatically subscribes to a global topic (e.g., announcements), without the user needing to identify themselves.
Here is the detailed architecture and technology selection, broken down into the three required core areas:
------------------------------
## 1. Push Technology & Client (Flutter PWA)
Since this is a Progressive Web App (PWA), the technical limitations of Web Push (especially under iOS Safari) must be taken into account.

* Firebase Cloud Messaging (FCM): FCM is the industry standard for Flutter. It supports web push protocols natively. [1]
* FCM Topics: Upon the first launch of the app, the FCM SDK generates an anonymous device token. The app calls FirebaseMessaging.instance.subscribeToTopic('announcements') in the background. No registration or user login is required. [2]
* PWA Prerequisites: For push notifications to be received even when the app is closed, a Web Service Worker (firebase-messaging-sw.js) must be registered in your Flutter app. In addition, iOS users are strictly required to install the PWA via "Add to Home Screen", as Safari only allows push notifications for installed PWAs. [3, 4]

------------------------------
## 2. Admin Backend (Secure Sending)
Since the admins do not have a login in the Google Sheet and the sheet is public, sending push notifications must never happen directly from the frontend or via unprotected client keys. Anyone who extracts the FCM server key from the frontend could otherwise send spam to all participants.

* Technology: Firebase Cloud Functions (Node.js/TypeScript) or a small FastAPI/Node.js app on Google Cloud Run.
* Admin Authentication: Since there is no global login, you can work with an admin token (API key / shared secret). This token is shared with the admins once (e.g., as a secret URL parameter like https://admin-app.de or as a password field in the admin interface).
* Workflow: The admin interface (which can be a separate, hidden page in your Flutter app) sends the message + the secret to your backend. The backend verifies the secret. If it is valid, the backend uses the secure Firebase Admin SDK to send the message to the announcements topic.

------------------------------
## 3. Data Flow & Architecture Overview
The following diagram illustrates how the components work together securely without user logins:

[ Admin Interface ] --(Message + Admin Token)--> [ Serverless Backend (Cloud Function) ]
|
(Verifies token & uses Admin SDK)
|
v
[ Flutter PWA Client ] <-- (Push Notification) -------- [ FCM Topic: 'announcements' ]
|
(Subscribes to topic anonymously at app launch)

------------------------------
## Alternative Technologies (Comparison)
If you prefer not to use Firebase for privacy or infrastructure reasons, there are two solid alternatives:

| Technology | Advantage | Disadvantage / PWA Limitation |
|---|---|---|
| VAPID / Web Push (Direct) | Completely independent of Firebase; open-source libraries available in Node.js, Go, or Python. | Higher implementation effort in Flutter; token management for topic streaming must be built from scratch in the backend. |
| Supabase Edge Functions | Excellent open-source alternative to Firebase with an integrated PostgREST database. | Push notifications must ultimately still be routed through FCM/Web Push gateways. |

------------------------------
## Recommended Implementation Roadmap

1. Set up FCM in the Flutter project: Add the firebase_messaging package and configure firebase-messaging-sw.js for the PWA background service.
2. Automate subscription: Integrate the anonymous topic subscription call directly into main.dart after app initialization.
3. Create backend endpoint: Create an HTTP Cloud Function that accepts a POST request with text and admin_token. Use environment variables in the backend to store the admin token securely.
4. Build admin input mask: Create a simple, password-protected view within or outside the PWA that triggers this endpoint.

Would you like more detailed information on setting up the Service Worker in Flutter for PWAs or a concrete code example for the secure Cloud Function (Node.js)?

[1] [https://web.dev](https://web.dev/articles/push-notifications-faq?hl=de)
[2] [https://firebase.google.com](https://firebase.google.com/docs/cloud-messaging/android/get-started?hl=de)
[3] [https://sendbird.com](https://sendbird.com/de/developer/tutorials/web-app-push-notifications-with-firebase)
[4] [https://webscraft.org](https://webscraft.org/blog/pwa-pushspovischennya-na-ios-u-2026-scho-realno-pratsyuye?lang=de)

***

That is an excellent and technically very precise point: The official JavaScript/Web SDK from [Firebase](https://firebase.google.com/docs/cloud-messaging/manage-tokens) indeed does not support the direct subscribeToTopic() method on the web client. [1, 2]
However, since you need to set up a backend for your admins anyway, you can bypass this limitation very elegantly. There are essentially two established architectures to solve this problem in a Flutter PWA without a user login. [3]
------------------------------
## Alternative 1: Server-Side Topic Subscription (Recommended)
While the PWA cannot join a topic itself, the Firebase Admin SDK on your server is fully allowed to do so. Since you can generate app tokens and pass them to a backend anyway, you simply shift the subscription to the server level. [1, 4]

[ Flutter PWA ] --(1. Generates Web Token)--> [ Your Backend ] --(2. subscribeToTopic(token))--> [ FCM ]

## Detailed Workflow:

1. Token Generation on the Client: Upon app launch, the Flutter PWA generates its anonymous FCM token as usual via FirebaseMessaging.instance.getToken(). [5]
2. Registration at the Backend: The app sends this token via an anonymous HTTP POST request to your new serverless backend (e.g., /register-device).
3. Server Handles the Subscription: Your backend uses the Firebase Admin SDK, accepts the token, and adds it to the global topic on the server side:

// Example in the Node.js Cloud Function
await admin.messaging().subscribeToTopic(deviceToken, 'announcements');

[1]
4. Result: When admins send a message to the announcements topic, the PWA receives it as usual through its service worker. You retain all the benefits of resource-efficient topic broadcasts. [6]

------------------------------
## Alternative 2: Token Directory in the Backend (The Classic Web Push Approach)
If you want to bypass FCM topics completely, you can simply simulate a "topic" using a minimal, anonymous database table in the backend. This is particularly suitable if you want to offer different days or event rooms (sub-channels) later on.
## Detailed Workflow:

1. Token Storage: Every time the Flutter PWA starts, it sends its current Web FCM token to your backend. The backend stores this token in a simple list (e.g., in a Firestore database or a Supabase/PostgreSQL instance). [7, 8]
2. No Logins: The table only requires two columns: fcm_token and last_seen (a timestamp used to automatically clean up obsolete tokens). [7]
3. The Multicast Sending Process: When an admin composes a message, the backend retrieves all registered tokens from the database and sends the push notification as a multicast (sending to a list of tokens) via the Admin SDK.

Note on limits: Firebase allows up to 500 tokens per individual multicast request. If there are more than 500 conference participants, your backend simply needs to split the tokens into packages of 500 (chunks) and send them in parallel.
------------------------------
## Summary & Recommendation

| Criterion | Alternative 1: Server-Side Topics | Alternative 2: Token Directory |
|---|---|---|
| Backend Database Required? | No, Firebase manages the topic list internally. | Yes, you need to store the tokens somewhere. |
| Scaling | Extremely high (millions of users via FCM fanout). | Good (backend must process chunks). |
| PWA Code Effort | Minimal (send token to API). | Minimal (send token to API). |
| Flexibility | Rigid (FCM structures). | Very high (you can filter tokens). |

Conclusion for your project:
Use Alternative 1 (Server-Side Subscription). Since you need to provide a secure Cloud Function (or Cloud Run) for the admins anyway, it will only cost you a few extra lines of code to provide a /subscribe endpoint for anonymous PWA clients there. This saves you from setting up and cleaning up your own token database. [1, 7]
Would you like to see what the Dart code in Flutter looks like to read the web token and transfer it to the backend, or are you interested in the corresponding Node.js code for server-side registration? [4]

[1] [https://stackoverflow.com](https://stackoverflow.com/questions/64768812/flutter-web-with-firebase-notifications-subscribetotopic)
[2] [https://github.com](https://github.com/firebase/flutterfire/issues/11084)
[3] [https://blog.logrocket.com](https://blog.logrocket.com/using-firebase-cloud-messaging-as-a-pub-sub-service/)
[4] [https://www.youtube.com](https://www.youtube.com/watch?v=d1eM9zBVChE&t=15)
[5] [https://firebase.google.com](https://firebase.google.com/docs/cloud-messaging/flutter/get-started)
[6] [https://www.youtube.com](https://www.youtube.com/watch?v=Tdi0ElVENnk&t=365)
[7] [https://firebase.google.com](https://firebase.google.com/docs/cloud-messaging/manage-tokens)
[8] [https://amal-krishna.medium.com](https://amal-krishna.medium.com/scalable-notification-system-for-a-pwa-using-fcm-6a4b8aa093af)

***

Since this is a very specific architectural pattern (Flutter PWA without login + serverless backend + FCM topic bridge), there is no single, turnkey "monolith" repository that provides exactly this setup out of the box.
Instead, you build this architecture from two proven open-source building blocks (boilerplates) that you can use directly as a foundation (fork):
------------------------------
## Building Block 1: The Backend (Node.js / Express on Cloud Functions or Docker)
For the backend that validates the admin token and adds the PWA web tokens to FCM topics, a lightweight Node.js repository is ideal.

### The Open-Source Foundation:
An excellent foundation is the official repository for Firebase functions: [Firebase Functions Samples (GitHub)](https://github.com/firebase/functions-samples). In the fcm-notifications subfolder, you will find pre-built Node.js code for communicating with FCM.
You can use this code as a template and adjust it to the following minimal script to cover both of your requirements (register device & send message):

```javascript
const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp();

const ADMIN_SECRET = "Your_Secret_Conference_Password_2026"; // Store in ENV variables!

// 1. ENDPOINT FOR THE PWA: Bind anonymous web token to a topic
exports.subscribeDevice = functions.https.onRequest(async (req, res) => {
    const { token } = req.body;
    if (!token) return res.status(400).send('Missing token');

    try {
        // The crucial server-side bridge for the Web FCM token
        await admin.messaging().subscribeToTopic(token, 'announcements');
        res.status(200).send({ success: true, message: 'Subscribed successfully' });
    } catch (error) {
        res.status(500).send(error.toString());
    }
});

// 2. ENDPOINT FOR ADMINS: Send push notification to all
exports.sendAnnouncement = functions.https.onRequest(async (req, res) => {
    const { messageText, title, secret } = req.body;

    // Simple, login-less authentication via shared secret
    if (secret !== ADMIN_SECRET) {
        return res.status(403).send('Unauthorized: Invalid Secret');
    }

    const payload = {
        notification: { title: title || 'Conference Update', body: messageText },
        topic: 'announcements'
    };

    try {
        await admin.messaging().send(payload);
        res.status(200).send({ success: true, message: 'Broadcast sent' });
    } catch (error) {
        res.status(500).send(error.toString());
    }
});
```

------------------------------
## Building Block 2: The Client (Flutter PWA Integration)
On the client side, you need to generate the token and send it to the backend above. [1]

### The Open-Source Foundation:
Use the official Google Codelab repository: Firebase FCM Flutter Codelab (GitHub). This project shows exactly how to initialize FCM and, crucially, how to configure the Web Service Worker so that push notifications work in the browser. [2]

### Customization in the Flutter code (main.dart):
Instead of calling subscribeToTopic directly in Dart as is typical for mobile apps, you send the token to your backend via an HTTP request: [2]

```dart
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// Called directly at app start without login
Future<void> initializeNotifications() async {
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  // 1. Request permission (Important for PWA in the browser!)
  NotificationSettings settings = await messaging.requestPermission();

  if (settings.authorizationStatus == AuthorizationStatus.authorized) {
    // 2. Generate anonymous Web Push token
    // The VAPID key certificate is generated in the Firebase Console Web tab
    String? token = await messaging.getToken(
      vapidKey: "YOUR_PUBLIC_WEB_PUSH_VAPID_KEY"
    );

    if (token != null) {
      // 3. Send token to your server endpoint (Building Block 1)
      final url = Uri.parse('https://cloudfunctions.net');
      await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'token': token}),
      );
    }
  }
}
```

------------------------------
## Alternative: Fully Featured Open-Source "Notification-as-a-Service" Platforms
If you do not want to write and maintain the serverless functions yourself at all, there are powerful self-hosted open-source platforms that offer exactly these token-based API architectures out of the box:

1. Novu (GitHub: novuhq/novu): The "Stripe for Notifications". It provides a ready-made dashboard, APIs, and workflows. You simply integrate your Firebase FCM key in the background. Admins can broadcast messages there via the API or the Novu dashboard without their own app login. [3]
2. Appwrite Messaging (GitHub: appwrite/appwrite): A comprehensive open-source alternative to Firebase. It features built-in anonymous token and topic management that harmonizes perfectly with Web Push, without requiring you to program your own backend routes. [4]

### Next Step for Implementation
Which setup do you choose? If you want to go the lean, serverless route, I can show you what the file structure for firebase-messaging-sw.js in Flutter should look like so that Chrome and Safari display notifications correctly even in the background. [5, 6]

[1] [https://www.informatik-aktuell.de](https://www.informatik-aktuell.de/betrieb/sicherheit/token-exchange-mit-keycloak.html)
[2] [https://firebase.google.com](https://firebase.google.com/codelabs/firebase-fcm-flutter)
[3] https://www.magicbell.com
[4] [https://appwrite.io](https://appwrite.io/blog/post/open-source-firebase-alternative-messaging-fcm)
[5] [https://www.youtube.com](https://www.youtube.com/watch?v=iz5arafmatc&t=64)
[6] [https://blog.coffeeinc.in](https://blog.coffeeinc.in/complete-guide-push-notifications-in-pwa-with-firebase-cloud-messaging-a515965372f7)

***

To offer additional channels (such as different presentation streams, rooms, or program items), simply expand the communication between your Flutter PWA and the Node.js backend. Since the PWA itself is still not allowed to trigger direct subscriptions, pass the desired stream name as a parameter to your backend.
Here is the exact workflow and code adjustment for the client and the server:
------------------------------
## 1. Backend Customization (Node.js)
Your Node.js endpoint must be adjusted so that it dynamically accepts the name of the desired stream (the topic) in addition to the web token. To avoid errors, the backend should validate the topic names (e.g., only accept allowed streams).
Extend your Cloud Function or Vercel endpoint as follows:

```javascript
// Dynamic endpoint for topic subscriptions
exports.subscribeToStream = functions.https.onRequest(async (req, res) => {
    const { token, streamName } = req.body;

    if (!token || !streamName) {
        return res.status(400).send('Missing token or streamName');
    }

    // Security check: Only allow approved streams (prevents spam topics)
    const allowedStreams = ['main_hall', 'room_1', 'room_2', 'workshops', 'announcements'];
    if (!allowedStreams.includes(streamName)) {
        return res.status(400).send('Invalid stream name');
    }
    
    try {
        // The Admin SDK subscribes the passed topic for this device
        await admin.messaging().subscribeToTopic(token, streamName);
        res.status(200).send({ 
            success: true, 
            message: `Successfully subscribed to stream: ${streamName}` 
        });
    } catch (error) {
        res.status(500).send(error.toString());
    }
});
```

------------------------------
## 2. Client Customization (Flutter PWA)
In your Flutter app, you can now offer toggles (Switches) or checkboxes in the settings area to visitors (e.g., "Enable notifications for Room 1").
As soon as a user selects or deselects a topic, the app triggers the HTTP request:

```dart
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// Universal function to subscribe to a specific conference stream
Future<void> subscribeToConferenceStream(String streamName) async {
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  // 1. Retrieve token
  String? token = await messaging.getToken(
    vapidKey: "YOUR_PUBLIC_WEB_PUSH_VAPID_KEY"
  );

  if (token != null) {
    // 2. Call the new endpoint and pass along the stream name
    final url = Uri.parse('https://your-backend.com');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'token': token,
        'streamName': streamName, // e.g., 'room_1'
      }),
    );

    if (response.statusCode == 200) {
      print("Successfully subscribed to $streamName!");
    }
  }
}
```

------------------------------
## 3. Unsubscribing from Streams (Unsubscribe)
A complete system must also allow visitors to turn off notifications for a stream when they change rooms. To do this, simply add an analogous counterpart endpoint to your Node.js backend that calls unsubscribeFromTopic:

```javascript
// Endpoint to unsubscribe from a stream
exports.unsubscribeFromStream = functions.https.onRequest(async (req, res) => {
    const { token, streamName } = req.body;

    try {
        // The Admin SDK removes the token from the topic
        await admin.messaging().unsubscribeFromTopic(token, streamName);
        res.status(200).send({ success: true, message: `Unsubscribed from ${streamName}` });
    } catch (error) {
        res.status(500).send(error.toString());
    }
});
```

In Flutter, you invoke this endpoint in exactly the same way as soon as the user unchecks the option in the app.
------------------------------
## 4. How the Admin Sends a Message to a Specific Stream
When admins create a message via the admin interface, they now use a dropdown menu to select who the message should go to (e.g., "All" or "Room 1"). The backend then sends the message to the corresponding topic:

```javascript
// Admin send endpoint (simplified)
const payload = {
    notification: {
        title: 'Next talk is starting soon!',
        body: 'Keynote B begins in 5 minutes.'
    },
    topic: req.body.targetStream // e.g., 'room_1' instead of a hardcoded 'announcements'
};
await admin.messaging().send(payload);
```

### Local Storage in the PWA
Since there is no user login in a database, you should store the user's selected streams locally on the device using Flutter's shared_preferences. When the app opens, the UI will immediately know which checkboxes should be displayed as "checked".
If you would like, I can show you how to keep the UI states synchronized using shared_preferences in Flutter, or we can extend the sending endpoint for the admins so that it processes the different rooms in the dropdown.

***

Yes, you can do that without any problems. Hosting the Node.js backend in the local conference network (LAN/WLAN) gives you maximum data privacy and ensures that the admin interface and the registration interface are physically inaccessible from the outside.
Crucial for understanding here is the separation between registration (local) and delivery (over the internet):

1. Local: The PWA and the admins communicate only with your local server (e.g., at http://192.168.1.50:3000) to register tokens or compose messages.
2. Global (Internet): Your local server absolutely requires an outbound internet connection to the Firebase servers. As soon as the admin presses "Send" locally, your local server sends the request to FCM. Google then delivers the push notification over cellular data or Wi-Fi to the visitors' smartphones.

Here is the guide on how to set up the Node.js backend locally and secure it with Nginx.

------------------------------
## 1. Local Network Architecture

[ Visitor Smartphone / PWA ]  ──(Venue Wi-Fi)──> [ Local IP: e.g., 192.168.1.50 ]
|
(Nginx Reverse Proxy)
|
v
[ Google FCM Server (Internet) ] <──(Sends via WAN)── [ Local Node.js App (Port 3000) ]

------------------------------
## 2. Step 1: Prepare the Local Node.js Backend
Since you are outside the Google Cloud environment, you must set up the project as a standard Express.js app. Additionally, you need to manually load the Firebase credentials (Service Account JSON).

1. Download the serviceAccountKey.json from the Firebase Console and place it on the local server.
2. Create the server.js file:

```javascript
const express = require('express');
const admin = require('firebase-admin');
const cors = require('cors'); // Important for PWA access
require('dotenv').config();

const app = express();
app.use(express.json());
app.use(cors()); // Allows the Flutter PWA to access from other IPs

// Initialize Firebase locally
const serviceAccount = require('./serviceAccountKey.json');
admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

const ADMIN_SECRET = process.env.ADMIN_SECRET || "Local_Secret_2026";

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
  if (secret !== ADMIN_SECRET) return res.status(403).send('Unauthorized');

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

app.listen(3000, () => console.log('Backend running locally on port 3000'));
```

------------------------------
## 3. Step 2: Configure Nginx as a Reverse Proxy & Force HTTPS
*Crucial PWA Note:* Web browsers (Chrome, Safari, Firefox) allow Web Push registrations strictly over HTTPS (encrypted connections) for security reasons. The only exception is localhost.
Since your PWA is hosted on GitHub Pages via HTTPS, your local backend must also be requested via HTTPS, otherwise browsers will block the request due to Mixed Content. Therefore, you must configure Nginx with an SSL certificate.

### Option A: With a Real (Sub)domain (Recommended)
If you own a domain (e.g., conference-api.yourcompany.com), point its DNS record (Type A) to the local IP of the server (e.g., 192.168.1.50). This works perfectly! You can then use Let's Encrypt / Certbot to generate a genuine, free SSL certificate on the local server, as long as the server is briefly accessible from the internet over port 80 during verification (or via a DNS challenge).

### Option B: With a Self-Signed Certificate (Higher Maintenance Effort)
You generate a local SSL certificate for the IP address (e.g., https://192.168.1.50). Disadvantage: Visitors' smartphones will display a red warning message ("Unsecure Connection"). Visitors would have to manually bypass the warning for the PWA notifications to work.

### Nginx Configuration File (/etc/nginx/sites-available/default):

```nginx
server {
    listen 80;
    server_name conference-api.yourcompany.com 192.168.1.50;
    # Automatic redirection from HTTP to HTTPS
    return 301 https://$host$request_uri;
}

server {
    listen 443 ssl;
    server_name conference-api.yourcompany.com 192.168.1.50;

    # Paths to your SSL certificates (e.g., from Let's Encrypt)
    ssl_certificate /etc/letsencrypt/live/conference-api.yourcompany.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/conference-api.yourcompany.com/privkey.pem;

    location / {
        # Forwarding to the local Node.js App
        proxy_pass http://localhost:3000; 
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

------------------------------
## 4. What Changes in the Flutter PWA?
In your Flutter code on GitHub Pages, you only need to change your backend URL to the local address (or the local domain):

```dart
// The PWA on GitHub Pages now calls your local server inside the conference Wi-Fi
final url = Uri.parse('https://yourcompany.com');
// OR (with the mentioned SSL limitations for IPs):
// final url = Uri.parse('https://192.168.1.50:3000');
```

### Summary of the Pros and Cons of This Local Setup

* Advantages: The admin password resides exclusively on a single physical machine in the room. Attackers from the internet have no way to compromise the /send or /subscribe endpoints.
* Challenge: You must resolve HTTPS encryption within the local network (preferably via the described combination of a local subdomain + a real SSL certificate), since mobile browsers will otherwise reject the service.

Should I show you how to create a valid Let's Encrypt SSL certificate for a local network via DNS challenge, without having your server permanently exposed to the internet?

***

Here you will learn step-by-step how to secure the local Node.js backend using the Apache web server as a reverse proxy and create a valid, free SSL certificate with Let's Encrypt for the local conference Wi-Fi.

------------------------------
## Part 1: Creating the SSL Certificate (DNS Challenge)
Since your server is inside a local network and cannot be reached via the internet, the normal Let's Encrypt validation (HTTP on port 80) will fail.
The solution is the DNS Challenge (dns-01). Here, you prove ownership of the domain to Let's Encrypt by adding a temporary TXT record in the DNS settings of your domain provider (e.g., Strato, Ionos, GoDaddy). The Let's Encrypt server never needs to contact your conference server directly.

### 1. Install Certbot on the Server
Install Certbot (the Let's Encrypt client) on your Linux server (e.g., Ubuntu/Debian):

```bash
sudo apt update
sudo apt install certbot python3-certbot-apache
```

### 2. Manually Generate the Certificate
Run the following command. Replace api.your-conference.com with the subdomain pointing to the server's IP (e.g., 192.168.1.50) in your local DNS:

```bash
sudo certbot certonly --manual --preferred-challenges dns -d api.your-conference.com
```

### 3. Set the DNS Record

* Certbot will pause at this point and output some text (e.g., _acme-challenge.api.your-conference.com with the value pX78...).
* Log in to the control panel of your domain provider.
* Create a new TXT record using the data provided by Certbot.
* Wait 60 seconds (for the record to propagate globally) and press Enter in the terminal.

Certbot validates the record and safely stores the keys on your server under:
* Certificate: /etc/letsencrypt/live/api.your-conference.com/fullchain.pem
* Private Key: /etc/letsencrypt/live/api.your-conference.com/privkey.pem

------------------------------
## Part 2: Apache Configuration (Reverse Proxy & HTTPS)
By default, Apache does not forward requests to internal Node.js processes. To allow this, the proxy modules must first be enabled, followed by configuring the virtual host.

### 1. Enable Apache Proxy Modules
Run these commands in the terminal to load the required forwarding and SSL modules into Apache:

```bash
sudo a2enmod proxy
sudo a2enmod proxy_http
sudo a2enmod ssl
sudo a2enmod rewrite
```

### 2. Create the Configuration File
Create a new Apache configuration file for your conference API:

```bash
sudo nano /etc/apache2/sites-available/conference-api.conf
```

Insert the following content there. Apache listens on port 80 (HTTP) and securely redirects all traffic to port 443 (HTTPS). From there, requests are passed through to the local Node.js app (port 3000):

```apache
<VirtualHost *:80>
    ServerName api.your-conference.com

    # Automatic redirection from HTTP to HTTPS
    RewriteEngine On
    RewriteCond %{HTTPS} off
    RewriteRule ^(.*)$ https://%{HTTP_HOST}%{REQUEST_URI} [R=301,L]
</VirtualHost>

<VirtualHost *:443>
    ServerName api.your-conference.com

    # SSL Activation and paths to the Let's Encrypt certificate
    SSLEngine on
    SSLCertificateFile /etc/letsencrypt/live/api.your-conference.com/fullchain.pem
    SSLCertificateKeyFile /etc/letsencrypt/live/api.your-conference.com/privkey.pem

    # Proxy settings: Forwards requests to the Node.js backend on port 3000
    ProxyRequests Off
    ProxyPreserveHost On
    
    <Location />
        ProxyPass http://localhost:3000/
        ProxyPassReverse http://localhost:3000/
    </Location>

    # Extra security measure: Prevents the server from being abused as an open proxy
    <Proxy *>
        Order deny,allow
        Allow from all
    </Proxy>

    # Log files for potential troubleshooting
    ErrorLog ${APACHE_LOG_DIR}/conference_api_error.log
    CustomLog ${APACHE_LOG_DIR}/conference_api_access.log combined
</VirtualHost>
```

### 3. Enable Site and Restart Apache
Enable the configuration and restart the Apache service to apply the changes:

```bash
sudo a2ensite conference-api.conf
sudo systemctl restart apache2
```

------------------------------
## Important Checklist for Conference Day
To ensure participants can resolve the api.your-conference.com domain within the local Wi-Fi network, you must make sure that the local router or DNS server in the conference network resolves this domain to the internal IP of your Apache server (e.g., 192.168.1.50). Otherwise, smartphones will route requests to the public internet, where they will fail.

I would be happy to help you set up the matching systemd service for your Node.js backend so the app automatically starts in the background and comes back online on its own after a power outage or server reboot. Would that be helpful to you?

***

It is absolutely correct that the Node.js code must run as an independent, permanently active background service.
Simply dropping an index.js file into the Apache directory (as is traditionally done with PHP files) does not work for Node.js.
Here is the technical reason for this difference and the simplest solution for it:

## Why Node.js Requires a Background Service

* PHP is stateless: With every click from a PWA user, Apache launches the PHP interpreter fresh, reads the file, outputs the result, and terminates.
* Node.js, on the other hand, is a full web server itself: The script must be started once and then runs permanently in RAM to accept incoming connections on port 3000. Apache acts here only as a "doorman" (Reverse Proxy) that hands off external HTTPS requests to this internal Node.js server.

------------------------------
## The Simplest Solution: PM2 (Process Manager)
You don't need to write a complicated Linux system service. There is an open-source tool called PM2 specifically built to keep Node.js applications running in the background with a single command.

### 1. Install PM2 Globally
Navigate to your Node.js project directory on your server and install PM2 via npm:

```bash
sudo npm install pm2 -g
```

### 2. Start the App in the Background
Instead of running the script with node server.js (which would close as soon as you close your server terminal session), use PM2:

```bash
pm2 start server.js --name "conference-backend"
```

Your API now runs stably in the background on port 3000, and Apache can forward requests error-free.

### 3. Automatic Restart on Server Crashes
To ensure that the backend automatically boots back up after a power outage or server restart at the venue, these two commands are sufficient:

```bash
pm2 startup
# (Copy the command PM2 displays in the terminal and execute it)

pm2 save
```

With this combination of Apache as a proxy and PM2 as a process manager, you have an extremely stable, production-ready setup for the conference.

Would you like me to show you how to monitor your app's status with PM2 (e.g., to view live error logs), or is the Node.js server already running on your system?

***

The assumption that the code could theoretically act entirely stateless is completely correct: Verifying the admin password and passing the token to Firebase do not require persistent memory (like an open database connection). Each request stands entirely on its own.
The reason it still doesn't work via a simple file in the Apache directory comes down to the runtime architecture of Node.js compared to PHP.
This reason can be broken into two core points:

## 1. The Technical Reason: Apache Does Not Understand Node.js
Apache has a built-in module (mod_php) to read and execute PHP files directly. When a request for index.php arrives, Apache knows exactly how to interpret the PHP code.
For JavaScript (Node.js), Apache has no such module. Apache cannot just "start" an index.js file on every request and return the result to the browser. Apache absolutely requires a communication partner that talks to it over a network protocol (HTTP on port 3000). And for that partner to answer on port 3000, it must run permanently.

## 2. Node.js Is Designed as a Persistent Server
In the Node.js world, the script itself is the web server.

* When you execute node index.js, Node.js loads the entire Firebase Admin SDK into memory once, sets up cryptographic operations, and binds itself to a port.
* This startup process takes a relatively long time (often 1–2 seconds) compared to PHP because complex asynchronous loops (the Event Loop) are initialized in the background.
* If you forced Apache to restart the entire Node.js process including the heavy Firebase SDK from scratch for every single click made by a conference attendee, the server would immediately crash under the load if multiple requests arrived simultaneously.

------------------------------
## Is There a "File-Based" Alternative Without PM2?
If you want to keep the architecture as simple as possible—meaning you just drop files into a folder and Apache handles the rest—you have two options where you can skip a permanent Node.js background service:

### Option A: Switching to PHP (The Simplest Local Alternative)
Since the logic (checking password + sending HTTP request to Google FCM) is completely stateless, you can write the backend in a single index.php file. Apache executes this freshly on every request. While Firebase doesn't offer an official PHP Admin SDK, the FCM interface is a standard HTTP REST API that can be completely targeted via PHP (curl).

### Option B: CGI (Common Gateway Interface) with Node.js
You can configure Apache via the mod_cgi module to execute any shell script on every request. You could place an index.js as an executable CGI script. However, this is strongly discouraged for a conference due to extremely poor performance and high RAM usage caused by constantly restarting the Node.js V8 engine for every user.

## Summary
A permanently running service (via PM2) is not necessary because of data states, but because Node.js is inherently not designed to be spun up as a short-lived script by a separate web server.

Would you like to estimate the expected traffic (number of attendees) at the conference to see if switching to a simple PHP script would make local development and maintenance easier for your team?

***

Here is the configuration for a robust systemd service. This is the cleanest way to run your Node.js backend natively in the background on a Linux server (such as Ubuntu or Debian) without needing to install additional tools like PM2.

------------------------------
## Step 1: Create the Service File
Create a new configuration file in your server's systemd directory:

```bash
sudo nano /etc/systemd/system/conference-backend.service
```

------------------------------
## Step 2: Add the Configuration
Insert the following contents into the file.
Important: Replace /path/to/your/project with the actual path where your server.js resides (e.g., /var/www/conference-backend). Also replace your_linux_user with your actual Linux username (e.g., www-data or ubuntu).

```ini
[Unit]
Description=Node.js Backend for Conference PWA (FCM Bridge)
After=network.target

[Service]
# The user and group under which the app will execute
User=your_linux_user
Group=your_linux_user

# The directory containing your package.json and .env
WorkingDirectory=/path/to/your/project

# The command that starts the backend (locates the installed Node.js binary)
ExecStart=/usr/bin/node server.js

# Automatic restart if the app crashes due to an error
Restart=always
RestartSec=10

# Define environment variables directly in the service (if not using a .env file)
Environment=NODE_ENV=production PORT=3000 ADMIN_SECRET=Local_Secret_2026

# Resource security: Limits log size in RAM
StandardOutput=journal
StandardError=journal
SyslogIdentifier=conference-backend

[Install]
WantedBy=multi-user.target
```

------------------------------
## Step 3: Enable and Start the Service
After saving the file, inform systemd that a new configuration exists, and start the service.

```bash
# 1. Reload the systemd manager to read the new file
sudo systemctl daemon-reload
# 2. Enable the service (ensures it starts automatically upon server reboot)
sudo systemctl enable conference-backend.service
# 3. Start the backend immediately
sudo systemctl start conference-backend.service
```

------------------------------
## Helpful Commands for Management
Since your backend is now firmly anchored within the operating system, you can control it with standard Linux commands:

* Check status: (Active: active (running) indicates everything is operating correctly)

```bash
sudo systemctl status conference-backend.service
```

* Restart (e.g., after making changes to your JavaScript code):

```bash
sudo systemctl restart conference-backend.service
```

* View live logs (to see if PWA clients are registering successfully or if any errors occur):

```bash
sudo journalctl -u conference-backend.service -f
```

With this systemd service and the Apache reverse proxy configured earlier, your local conference server is now fully automated. If a power outage occurs or the server reboots, Apache and your Node.js backend will spin back up entirely automatically in the correct order.

Should I show you how to structure the package.json for this Node.js project so that all required dependencies (such as firebase-admin and express) load correctly via npm install?

***

Here is the structured summary and step-by-step development guide for your project. This overview serves as a master plan for implementation in Android Studio (supported by Gemini), taking you from the initial concept to deployment on your own local web server.

------------------------------
## 📌 Architecture & Process Overview

```
[ Flutter PWA ] (GitHub Pages, HTTPS)
       │
(Local Wi-Fi) ➔ Requests https://your-conference.com
       │
       ▼
[ Apache / Nginx ] (Reverse Proxy, SSL via DNS Challenge)
       │
   (Port 3000)
       │
       ▼
[ Node.js Backend ] (Managed via systemd service)
       │
(Outbound Internet)
       │
       ▼
[ Google FCM Server ] ──(Push Delivery)──> [ Visitors' Mobile Devices ]
```

------------------------------
## 🛠️ Development Guide & Steps in Android Studio
Use this sequence to set up the project in Android Studio. You can directly pass the individual code snippets to Gemini to request modifications or bug fixes.

### Step 1: Flutter PWA Frontend (Android Studio)

1. Create the Project: Generate a new Flutter project and add web support.
2. Dependencies: Add firebase_messaging and http to your pubspec.yaml.
3. PWA & Service Worker: Set up firebase-messaging-sw.js in the web/ directory so push notifications can be received in the background.
4. Gemini Prompt for Logic (main.dart):
   > "Create a Flutter function for Web/PWA that generates a web token at app launch via FirebaseMessaging.instance.getToken(vapidKey: '...') and sends it via http.post to our local backend URL https://your-conference.com. Integrate a streamName parameter to allow users to subscribe to different conference channels."
5. Deployment: Build the app (flutter build web) and upload the output to GitHub Pages.

### Step 2: Node.js Backend & API (Separate Directory)

1. Initialize Project: Create a separate folder (e.g., conference-backend) and run npm init -y followed by npm install express firebase-admin cors dotenv.
2. Firebase Credentials: Download the serviceAccountKey.json from your Firebase Console and place it in this folder (Make sure to add this file to your .gitignore!).
3. Gemini Prompt for Backend (server.js):
   > "Write an Express.js app in Node.js that uses the firebase-admin SDK. Two POST endpoints are required: 1. /subscribe accepts a token and streamName and calls admin.messaging().subscribeToTopic. 2. /send accepts messageText, title, targetStream, and a secret. If the secret matches the password from process.env.ADMIN_SECRET, send a notification to the FCM topic."

### Step 3: Server Infrastructure & SSL (Local Network)
Since Web Push strictly requires HTTPS, secure your local server:

1. DNS Challenge for SSL: Use Certbot on the server to generate a genuine Let's Encrypt certificate for your subdomain (e.g., api.your-conference.com) without requiring the server to be accessible from the public internet:
```bash
sudo certbot certonly --manual --preferred-challenges dns -d api.your-conference.com
```
2. Configure Web Server as Reverse Proxy:
* Apache: Enable proxy and proxy_http. Create a VirtualHost on port 443 that includes the SSL certificates and uses ProxyPass / http://localhost:3000/ to forward all requests internally to Node.js.
* Nginx: Alternatively, use a server block on port 443 with proxy_pass http://localhost:3000;.
3. Local DNS: Configure your router or DNS server within the conference Wi-Fi network so that api.your-conference.com points directly to the internal IP (e.g., 192.168.1.50) of the server.

### Step 4: Automation with systemd Service
To ensure the Node.js app runs permanently in the background and survives server reboots, configure it as a Linux system service:

1. Create the Service File: /etc/systemd/system/notification-backend.service
2. Configuration: Provide the paths to node and your server.js, specify the system user, and pass the admin password as an environment variable (Environment=ADMIN_SECRET=...).
3. Enable & Start:
```bash
sudo systemctl daemon-reload
sudo systemctl enable notification-backend.service
sudo systemctl start notification-backend.service
```

------------------------------
## 🎯 Summary of Key Development Benefits

* No User Logins: Device identification is handled fully automatically and anonymously via the web tokens generated by FCM.
* Maximum Security in the LAN: The sensitive admin password used to send messages never leaves the local conference network.
* Fault Tolerance: Thanks to the combination of Apache/Nginx and systemd, the entire infrastructure reboots completely autonomously after a local power failure.

You can now use this blueprint as a guide in Android Studio. Would you like Gemini to generate the full content for firebase-messaging-sw.js next so that the service worker is ready for action in the browser?

-------------------------------

Here is the detailed guide on how to set up a Google Developer / Firebase project, generate the Service Account (for your Node.js backend), and securely store all credentials in your development environment.
------------------------------
## Part 1: Create a Project in the Firebase Console
Since you are using Firebase Cloud Messaging (FCM), the easiest way is to create the project directly in the [Firebase Console](https://console.firebase.google.com/) (this automatically creates the corresponding Google Cloud project in the background).

1. Go to the [Firebase Console](https://console.firebase.google.com/) and sign in with your Google account.
2. Click on **Add project** and give it a name (e.g., `conference-app-2026`).
3. Enable or disable Google Analytics (it is not strictly necessary for this pure push system) and click **Create project**.

## 1.1 Add a Web App (for the Flutter PWA Frontend)

1. Click the **Add app** and select the **Web symbol (</>)** in the dashboard to register a web app.
2. Provide an app nickname (e.g., `Flutter PWA`). Leave the checkbox for "Firebase Hosting" unchecked since you are hosting on GitHub Pages.
3. Click **Register app**. You will now see the `firebaseConfig` object. Copy these values into your `firebase-messaging-sw.js` (as prepared in the previous step) and into your Flutter initialization.

## 1.2 Generate a Web Push (VAPID) Key

1. Click the **gear icon** next to "Project Overview" at the top left ➔ **Project settings**.
2. Switch to the **Cloud Messaging** tab.
3. Scroll down to the **Web configuration** section under **Web Push certificates**.
4. Click **Generate key pair**.
5. Copy the generated long key. This is your **Public VAPID Key**, which your Flutter PWA needs to generate web tokens.

------------------------------
## Part 2: Create a Service Account for the Node.js Backend
The Service Account is the "master key" that grants your local Node.js backend permission to send messages to Google FCM on behalf of your project.

1. Remain in the **Project settings** of the Firebase Console.
2. Switch to the **Service accounts** tab.
3. Select the **Node.js** option and click the blue **Generate new private key** button at the bottom.
4. Confirm the warning. A `.json` file will be automatically downloaded to your computer.
5. **Important:** Rename this file to `serviceAccountKey.json` for easier handling in the code.

------------------------------
## Part 3: Secure Storage of Credentials (Structure & Best Practices)
Since your frontend is public (GitHub Pages) and your backend is private (local server), the files must be kept strictly separate.
## 1. In the Flutter Frontend Project (Android Studio)
Only non-critical, public identifiers are stored here.

* **FCM Configuration:** The parameters from the web app registration (`apiKey`, `messagingSenderId`, etc.) stay directly in the source code of `firebase-messaging-sw.js` and in your Flutter initialization. They are visible to anyone in the browser – this is normal and secure for PWAs, as these keys cannot be used to send messages, only to register as a recipient.
* **VAPID Key:** Store the VAPID key as a constant in your Dart code (e.g., `static const String vapidKey = "BLA_BLA_..."`) to pass it when calling `messaging.getToken()`.

## 2. In the Node.js Backend Project (Local Server)
The highly sensitive administrator keys are stored here. They must **never** be uploaded to a public GitHub repository.

* **The `.gitignore` file:** Create a file named `.gitignore` in the root directory of your Node.js project and add the following entries:

node_modules/
.env
serviceAccountKey.json

* **The Private Key (`serviceAccountKey.json`):** Copy the downloaded JSON file directly into the root directory of your Node.js project (next to your `server.js`). Thanks to the entry in `.gitignore`, it will never be accidentally committed.
* **Environment Variables (`.env`):** Create a file named `.env` in the root directory of the backend to manage passwords and ports locally:

PORT=3000
ADMIN_SECRET="MySuperSecureConferencePassword2026"
NODE_ENV=production


------------------------------
## 🚀 Development Workflow in Android Studio
When working on the project in Android Studio, the following folder structure is recommended to keep frontend and backend cleanly separated and provide Gemini with precise context:

```
my-conference-project/
│
├── conference_pwa/               <── Flutter project (Public Repo)
│   ├── lib/
│   │   └── main.dart            <── Uses the public VAPID Key
│   └── web/
│       └── firebase-messaging-sw.js <── Contains public firebaseConfig
│
└── conference_backend/           <── Node.js project (Private Repo)
    ├── .env                     <── Contains the ADMIN_SECRET (Local)
    ├── .gitignore               <── Protects secrets from Git
    ├── serviceAccountKey.json   <── Google Service Account Key (Local)
    └── server.js                <── Loads the key & .env
```

Would you like me to create a shell script for your local server that automatically downloads this Node.js backend from your private repository, installs the dependencies, and links it to the systemd service?



