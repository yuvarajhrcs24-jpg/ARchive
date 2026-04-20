const CACHE_NAME = "archive-smart-tour-shell-v1";
const APP_SHELL = ["./", "index.html", "styles.css", "app.js", "manifest.webmanifest", "data/places.json"];
const OFFLINE_CITY_CACHE_NAME = "archive-offline-city-data-v1";
const ACTIVE_MANAGED_CACHES = new Set([CACHE_NAME, OFFLINE_CITY_CACHE_NAME]);
const MANAGED_CACHE_PATTERNS = [/^archive-smart-tour-shell-v\d+$/, /^archive-offline-city-data-v\d+$/];

self.addEventListener("install", (event) => {
  event.waitUntil(caches.open(CACHE_NAME).then((cache) => cache.addAll(APP_SHELL)));
});

self.addEventListener("activate", (event) => {
  event.waitUntil(
    caches.keys().then((keys) => {
      const staleManagedCaches = keys.filter((key) => {
        const isManaged = MANAGED_CACHE_PATTERNS.some((pattern) => pattern.test(key));
        return isManaged && !ACTIVE_MANAGED_CACHES.has(key);
      });
      return Promise.all(staleManagedCaches.map((key) => caches.delete(key)));
    })
  );
});

self.addEventListener("fetch", (event) => {
  event.respondWith(
    caches.match(event.request).then((cached) => {
      if (cached) return cached;
      return fetch(event.request)
        .then((response) => {
          const copy = response.clone();
          caches.open(CACHE_NAME).then((cache) => cache.put(event.request, copy));
          return response;
        })
        .catch(() => caches.match("index.html"));
    })
  );
});
