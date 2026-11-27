<?php

use Illuminate\Foundation\Inspiring;
use Illuminate\Support\Facades\Artisan;
use Illuminate\Support\Facades\Schedule;

Artisan::command('inspire', function () {
    $this->comment(Inspiring::quote());
})->purpose('Display an inspiring quote');

/*
| Impor mingguan direktori Masjid Terdekat dari OpenStreetMap (ubin 2°, jeda sopan antar unduhan).
| Aktifkan di produksi dengan OVERPASS_SCHEDULE=true dan jalankan `php artisan schedule:work`/cron.
*/
if (config('services.overpass.schedule')) {
    Schedule::command('directory:import-osm --region=indonesia --prune')
        ->weeklyOn(1, '02:17')
        ->withoutOverlapping()
        ->runInBackground();
}
