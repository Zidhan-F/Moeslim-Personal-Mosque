<?php

namespace App\Http\Controllers;

use Illuminate\Http\JsonResponse;
use Illuminate\Http\Response;
use Illuminate\View\View;

/** Zero-install Web TV Display Pro (/tv): pairing via QR tanpa install APK tambahan. */
class WebDisplayController extends Controller
{
    public function show(): View
    {
        return view('public.tv');
    }

    public function manifest(): JsonResponse
    {
        return response()->json([
            'name' => 'Moeslim Mosque TV Display',
            'short_name' => 'Moeslim TV',
            'description' => 'Layar jadwal salat, iqamah, layar hening, petugas Jumat, dan QRIS masjid.',
            'start_url' => '/tv',
            'scope' => '/tv',
            'display' => 'fullscreen',
            'orientation' => 'landscape',
            'background_color' => '#041F1A',
            'theme_color' => '#07372F',
            'icons' => [
                [
                    'src' => '/moeslim-icon.png?v=2',
                    'sizes' => '512x512',
                    'type' => 'image/png',
                    'purpose' => 'any',
                ],
            ],
        ])->header('Content-Type', 'application/manifest+json');
    }

    public function serviceWorker(): Response
    {
        $js = <<<'JS'
const CACHE = 'moeslim-tv-v3';
const SHELL = ['/tv', '/tv/manifest.json', '/moeslim-icon.png?v=2', '/favicon.svg?v=2'];

self.addEventListener('install', (e) => {
  e.waitUntil(caches.open(CACHE).then((c) => c.addAll(SHELL)).then(() => self.skipWaiting()));
});

self.addEventListener('activate', (e) => {
  e.waitUntil(
    caches.keys()
      .then((keys) => Promise.all(keys.filter((k) => k !== CACHE).map((k) => caches.delete(k))))
      .then(() => self.clients.claim())
  );
});

self.addEventListener('fetch', (e) => {
  const url = new URL(e.request.url);
  if (e.request.method !== 'GET') return;
  if (url.pathname === '/tv' || url.pathname === '/tv/manifest.json') {
    e.respondWith(
      fetch(e.request)
        .then((res) => {
          const copy = res.clone();
          caches.open(CACHE).then((c) => c.put(e.request, copy));
          return res;
        })
        .catch(() => caches.match(e.request))
    );
  }
});
JS;

        return response($js, 200, [
            'Content-Type' => 'application/javascript; charset=utf-8',
            'Cache-Control' => 'no-cache',
            'Service-Worker-Allowed' => '/tv',
        ]);
    }
}
