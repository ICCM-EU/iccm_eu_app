if ('serviceWorker' in navigator) {
    window.addEventListener('load', function () {
      navigator.serviceWorker.register('/service-worker.js')
        .then(function (registration) {
          console.log('Service worker registered:', registration);
        })
        .catch(function (error) {
          console.log('Service worker registration failed:', error);
        });
    });
}

self.addEventListener('install', function (event) {
  event.waitUntil(
    caches.open('iccm-eu-cache').then(function (cache) {
      return cache.addAll([
        '/',
        '/index.html',
        '/favicon.png',
        '/manifest.json',
        '/assets/icons/icon.png',
        '/icons/Icon-192.png',
        '/icons/Icon-512.png',
        '/icons/Icon-maskable-192.png',
        '/icons/Icon-maskable-512.png',
        '/js/local_notification.js',
        '/js/service-worker.js',
      ]);
    })
  );
});

self.addEventListener('fetch', function (event) {
  event.respondWith(
    caches.match(event.request).then(function (response) {
      return response || fetch(event.request);
    })
  );
});
