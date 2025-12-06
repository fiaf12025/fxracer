// Versioned cache name to force updates when this file changes
const CACHE_VERSION = 'v2';
const CACHE_NAME = `fxracer-app-${CACHE_VERSION}`;

// Core resources to precache (app shell)
const PRECACHE_URLS = [
  '/',
  '/index.html',
  '/manifest.webmanifest',
  '/logo.svg',
  '/f1-background.jpg'
];

// Install: precache the app shell
self.addEventListener('install', event => {
  event.waitUntil(
    caches.open(CACHE_NAME).then(cache => cache.addAll(PRECACHE_URLS))
  );
  // Activate worker immediately after install
  self.skipWaiting();
});

// Activate: delete old caches
self.addEventListener('activate', event => {
  event.waitUntil(
    caches.keys().then(keys => Promise.all(
      keys.filter(k => k !== CACHE_NAME).map(k => caches.delete(k))
    ))
  );
  self.clients.claim();
});

// Message handler: allow clients to trigger skipWaiting
self.addEventListener('message', event => {
  if (!event.data) return;
  if (event.data === 'skipWaiting') {
    self.skipWaiting();
  }
});

// Notify clients when a new service worker has taken control
function notifyClientsAboutUpdate(){
  self.clients.matchAll({ type: 'window' }).then(clients => {
    for(const client of clients){
      client.postMessage({ type: 'SW_UPDATED' });
    }
  });
}

self.addEventListener('controllerchange', () => {
  // controllerchange is fired in clients, not in SW context reliably; keep for completeness
});

// Fetch strategy:
// - For navigation (HTML) use network-first with fallback to cache
// - For other resources use stale-while-revalidate (cache-first but update in background)
self.addEventListener('fetch', event => {
  const req = event.request;
  const url = new URL(req.url);

  // Only handle same-origin requests (avoid caching third-party APIs)
  if (url.origin !== location.origin) return;

  if (req.mode === 'navigate' || (req.method === 'GET' && req.headers.get('accept')?.includes('text/html'))){
    // Network-first for navigations
    event.respondWith(
      fetch(req).then(networkResp => {
        // update cache
        const copy = networkResp.clone();
        caches.open(CACHE_NAME).then(cache => cache.put(req, copy));
        return networkResp;
      }).catch(() => caches.match('/index.html'))
    );
    return;
  }

  // Stale-while-revalidate for other GET requests
  if (req.method === 'GET'){
    event.respondWith(
      caches.match(req).then(cachedResp => {
        const networkFetch = fetch(req).then(networkResp => {
          // update cache in background
          if(networkResp && networkResp.ok){
            const copy = networkResp.clone();
            caches.open(CACHE_NAME).then(cache => cache.put(req, copy));
          }
          return networkResp;
        }).catch(()=>undefined);
        // Return cached if exists, otherwise wait for network
        return cachedResp || networkFetch;
      })
    );
  }
});

// Inform clients when this SW activates (useful for update flow)
self.addEventListener('activate', event => {
  event.waitUntil((async () => {
    // small delay to ensure clients are claimable
    notifyClientsAboutUpdate();
  })());
});
