<?php

namespace App\Http\Controllers;

use App\Http\Controllers\Api\PublicMosqueController;
use App\Models\Mosque;
use App\Services\FinanceService;
use Illuminate\View\View;

/** Microsite publik profil masjid SSR: GET /m/{slug} (hanya data publik & transparansi opt-in). */
class PublicMosqueWebController extends Controller
{
    public function show(string $slug, FinanceService $finance): View
    {
        $mosque = Mosque::where('slug', $slug)->firstOrFail();

        $events = $mosque->events()
            ->where('status', 'active')
            ->where('visibility', 'public')
            ->where('starts_at', '>=', now()->subHours(6))
            ->orderBy('starts_at')
            ->limit(6)
            ->get(['id', 'title', 'category', 'location', 'speaker', 'starts_at']);

        $announcements = $mosque->announcements()
            ->live()
            ->where('visibility', 'public')
            ->orderByDesc('priority')
            ->orderByDesc('id')
            ->limit(5)
            ->get(['id', 'title', 'body', 'priority', 'publish_at']);

        $fridayStaff = PublicMosqueController::upcomingFridayStaff($mosque);

        $publicFinance = null;
        if ($mosque->setting('public_show_finance')) {
            $publicFinance = $finance->fridayReport($mosque, $mosque->today());
        }

        $qrisUrl = ($mosque->setting('display_show_qris') && $mosque->qris_image_path)
            ? url("/api/public/mosques/{$mosque->slug}/qris")
            : null;

        return view('public.mosque', [
            'mosque' => $mosque,
            'events' => $events,
            'announcements' => $announcements,
            'fridayStaff' => $fridayStaff,
            'publicFinance' => $publicFinance,
            'qrisUrl' => $qrisUrl,
            'qrisLabel' => $mosque->setting('qris_label'),
            'iqamah' => $mosque->setting('iqamah_minutes') ?? [],
        ]);
    }
}
