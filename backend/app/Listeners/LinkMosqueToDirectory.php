<?php

namespace App\Listeners;

use App\Events\MosqueRegistered;
use App\Services\Directory\DirectoryService;

/** Masjid yang mendaftar Moeslim Mosque otomatis muncul (terverifikasi) di Masjid Terdekat. */
class LinkMosqueToDirectory
{
    public function __construct(private DirectoryService $directory) {}

    public function handle(MosqueRegistered $event): void
    {
        $this->directory->linkMosque($event->mosque);
    }
}
