console.log('[firebase-messaging-sw.js] Service worker script executing.');

// 1. Load Firebase Config & Scripts
try {
  importScripts("firebase-config.js");
  importScripts("https://www.gstatic.com/firebasejs/9.10.0/firebase-app-compat.js");
  importScripts("https://www.gstatic.com/firebasejs/9.10.0/firebase-messaging-compat.js");
  console.log('[firebase-messaging-sw.js] Firebase compat scripts imported successfully.');
} catch (e) {
  console.error('[firebase-messaging-sw.js] Error importing Firebase scripts:', e);
}

// 2. Initialize Firebase from shared configuration
if (self.firebaseConfig) {
  try {
    firebase.initializeApp(self.firebaseConfig);
    console.log('[firebase-messaging-sw.js] Firebase initialized for project:', self.firebaseConfig.projectId);
  } catch (e) {
    console.error('[firebase-messaging-sw.js] Firebase initializeApp error:', e);
  }
} else {
  console.error('[firebase-messaging-sw.js] self.firebaseConfig is not defined!');
}

// 3. Retrieve Messaging instance
let messaging = null;
try {
  messaging = firebase.messaging();
  console.log('[firebase-messaging-sw.js] Messaging instance retrieved successfully.');
} catch (e) {
  console.error('[firebase-messaging-sw.js] Error getting firebase.messaging():', e);
}

// Intercept low-level raw push event
self.addEventListener('push', (event) => {
  console.log('[firebase-messaging-sw.js] RAW PUSH EVENT RECEIVED:', event);
  if (event.data) {
    try {
      console.log('[firebase-messaging-sw.js] RAW PUSH DATA TEXT:', event.data.text());
    } catch (e) {
      console.log('[firebase-messaging-sw.js] Could not read push data text:', e);
    }
  } else {
    console.log('[firebase-messaging-sw.js] Raw push event has no data.');
  }
});

// 4. Intercept background messages (Background Message Handler)
if (messaging) {
  messaging.onBackgroundMessage((payload) => {
    console.log('[firebase-messaging-sw.js] onBackgroundMessage RECEIVED! Payload:', JSON.stringify(payload));

    const notificationTitle = payload.notification?.title || payload.data?.title || 'Conference Update';
    const notificationBody = payload.notification?.body || payload.data?.messageText || payload.data?.body || 'There is a new announcement.';

    const notificationOptions = {
      body: notificationBody,
      icon: 'icons/Icon-192.png',
      vibrate: [200, 100, 100, 100, 100, 100, 200],
      data: {
        click_action: payload.data?.click_action || '/'
      }
    };

    console.log(`[firebase-messaging-sw.js] Invoking showNotification("${notificationTitle}", "${notificationBody}")`);

    return self.registration.showNotification(notificationTitle, notificationOptions)
      .then(() => {
        console.log('[firebase-messaging-sw.js] self.registration.showNotification SUCCEEDED.');
      })
      .catch((err) => {
        console.error('[firebase-messaging-sw.js] self.registration.showNotification FAILED:', err);
      });
  });
}

// 5. Intercept click event on the notification
self.addEventListener('notificationclick', (event) => {
  console.log('[firebase-messaging-sw.js] Notification clicked:', event.notification);

  event.notification.close();

  const urlToOpen = event.notification.data?.click_action || '/';

  const promiseChain = clients.matchAll({
    type: 'window',
    includeUncontrolled: true
  }).then((windowClients) => {
    for (let i = 0; i < windowClients.length; i++) {
      const client = windowClients[i];
      if (client.url === urlToOpen && 'focus' in client) {
        console.log('[firebase-messaging-sw.js] Focusing existing browser window/tab.');
        return client.focus();
      }
    }
    if (clients.openWindow) {
      console.log('[firebase-messaging-sw.js] Opening new window for:', urlToOpen);
      return clients.openWindow(urlToOpen);
    }
  });

  event.waitUntil(promiseChain);
});
