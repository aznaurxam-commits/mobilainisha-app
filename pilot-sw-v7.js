/* MOBILAINISHA v7 demo: caches only the pilot shell. NOT multi-device synchronization.
   Do not use the cached demo as a real accounting system or for offline customer orders. */
const CACHE = 'mobilainisha-pilot-v7-shell-20261109';
const PAGE = new URL('./MOBILAINISHA_v7_FULL_PILOT.html', self.registration.scope).href;
const PRELOAD = ['./MOBILAINISHA_v7_FULL_PILOT.html','./icon-192.png','./icon-512.png','./apple-touch-icon.png','./manifest-v7.webmanifest'];
self.addEventListener('install', event => {
  event.waitUntil((async () => {
    const cache = await caches.open(CACHE);
    await cache.addAll(PRELOAD);
    await self.skipWaiting();
  })());
});
self.addEventListener('activate', event => {
  event.waitUntil((async () => {
    const keys = await caches.keys();
    await Promise.all(keys.filter(k => k.startsWith('mobilainisha-pilot-v7-') && k !== CACHE).map(k => caches.delete(k)));
    await self.clients.claim();
  })());
});
self.addEventListener('fetch', event => {
  if(event.request.method !== 'GET' || event.request.mode === 'navigate' && new URL(event.request.url).href !== PAGE) return;
  const u = new URL(event.request.url);
  if(u.href !== PAGE || u.origin !== self.location.origin) return;
  event.respondWith((async () => {
    try {
      const fresh = await fetch(event.request);
      if(fresh.ok) (await caches.open(CACHE)).put(event.request, fresh.clone());
      return fresh;
    } catch(error) {
      const cached = await caches.match(event.request);
      if(cached) return cached;
      throw error;
    }
  })());
});
