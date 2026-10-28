const CACHE='nova-stream-shell-v2';
const SHELL=['./','./index.html','./config.js','./manifest.webmanifest','./icon.svg'];
self.addEventListener('install',event=>{
  event.waitUntil(caches.open(CACHE).then(cache=>cache.addAll(SHELL)).then(()=>self.skipWaiting()));
});
self.addEventListener('activate',event=>{
  event.waitUntil(caches.keys().then(keys=>Promise.all(keys.filter(k=>k.startsWith('nova-stream-shell-')&&k!==CACHE).map(k=>caches.delete(k)))).then(()=>self.clients.claim()));
});
self.addEventListener('fetch',event=>{
  const req=event.request;
  if(req.method!=='GET'||new URL(req.url).origin!==self.location.origin)return;
  const url=new URL(req.url);
  const isShell=['/','/index.html','/config.js','/manifest.webmanifest','/icon.svg'].some(path=>url.pathname.endsWith(path));
  if(!isShell)return;
  event.respondWith((async()=>{
    const cache=await caches.open(CACHE);
    const cached=await cache.match(req);
    const network=fetch(req).then(response=>{
      if(response.ok)cache.put(req,response.clone());
      return response;
    });
    if(cached){event.waitUntil(network.catch(()=>{}));return cached;}
    try{return await network;}catch{return new Response('Offline: reconnect to load NOVA STREAM.',{status:503,headers:{'Content-Type':'text/plain; charset=utf-8'}});}
  })());
});