// 1. Load Firebase Scripts (Using stable Web v9 compatibility libraries)
importScripts("https://www.gstatic.com/firebasejs/9.10.0/firebase-app-compat.js");
importScripts("https://www.gstatic.com/firebasejs/9.10.0/firebase-messaging-compat.js");

// 2. Initialize Firebase
// NOTE: This configuration data is publicly visible and non-critical.
// Use exactly the same values as in your normal frontend app.
firebase.initializeApp({
  apiKey: "YOUR_API_KEY",
  authDomain: "YOUR_PROJECT_://firebaseapp.com",
  projectId: "YOUR_PROJECT_ID",
  storageBucket: "YOUR_PROJECT_://appspot.com",
  messagingSenderId: "YOUR_SENDER_ID",
  appId: "YOUR_APP_ID"
});

// 3. Retrieve Messaging instance
const messaging = firebase.messaging();

// 4. Intercept background messages (Background Message Handler)
// This function is called when a message arrives and the PWA is closed/in the background.
messaging.onBackgroundMessage((payload) => {
  console.log('[firebase-messaging-sw.js] Background message received: ', payload);

  // Extracting data from the FCM payload
  const notificationTitle = payload.notification?.title || 'Conference Update';
  const notificationOptions = {
    body: payload.notification?.body || 'There is a new announcement.',
    // Icon displayed in the notification (must be in the web/ folder)
    icon: '/icons/Icon-192.png',
    // Ensures the notification vibrates (if supported by the device)
    vibrate: [200, 100, 200],
    // Additional metadata, e.g., for click actions
    data: {
      click_action: payload.data?.click_action || '/'
    }
  };

  // Display the native browser notification
  return self.registration.showNotification(notificationTitle, notificationOptions);
});

// 5. Intercept click event on the notification
self.addEventListener('notificationclick', (event) => {
  //console.log('[firebase-messaging-sw.js] Notification clicked.');

  // Closes the visible notification on the smartphone
  event.notification.close();

  // Retrieves the target URL from metadata (default is the root directory '/')
  const urlToOpen = event.notification.data.click_action;

  // Checks if the PWA is already open in the browser and brings it into focus,
  // otherwise a new window is opened.
  const promiseChain = clients.matchAll({
    type: 'window',
    includeUncontrolled: true
  }).then((windowClients) => {
    for (let i = 0; i < windowClients.length; i++) {
      const client = windowClients[i];
      if (client.url === urlToOpen && 'focus' in client) {
        return client.focus();
      }
    }
    if (clients.openWindow) {
      return clients.openWindow(urlToOpen);
    }
  });

  event.waitUntil(promiseChain);
});
