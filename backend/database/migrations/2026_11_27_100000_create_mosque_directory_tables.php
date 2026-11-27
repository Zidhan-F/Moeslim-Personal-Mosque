<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

/*
| Direktori masjid & musala untuk fitur "Masjid Terdekat" (Moeslim Personal).
| Terpisah dari tabel tenant `mosques`: berisi data publik dari OpenStreetMap, SIMAS (bila ada izin),
| laporan pengguna yang sudah dimoderasi, dan masjid terdaftar Moeslim Mosque (terverifikasi).
| `cell` = geohash 4 karakter (±39×20 km) — satuan paket wilayah yang diunduh aplikasi.
*/
return new class extends Migration
{
    public function up(): void
    {
        Schema::create('mosque_directory', function (Blueprint $t) {
            $t->id();
            $t->string('source', 16);              // osm | simas | user | moeslim
            $t->string('source_ref', 64)->nullable();
            $t->string('name', 200);
            $t->string('kind', 10)->default('masjid'); // masjid | musala
            $t->double('latitude');
            $t->double('longitude');
            $t->string('geohash', 12);
            $t->string('cell', 4)->index();
            $t->string('address', 255)->nullable();
            $t->string('city', 100)->nullable();
            $t->string('province', 100)->nullable();
            $t->string('simas_id', 64)->nullable();
            $t->foreignUlid('mosque_id')->nullable()->constrained('mosques')->nullOnDelete();
            $t->boolean('verified')->default(false);
            // locked = sudah dikoreksi moderator; impor berikutnya tidak menimpa nama/koordinat/status.
            $t->boolean('locked')->default(false);
            $t->string('status', 10)->default('active'); // active | hidden
            $t->timestamp('last_seen_at')->nullable(); // terakhir terlihat di impor sumbernya
            $t->timestamps();
            $t->unique(['source', 'source_ref']);
            $t->index(['latitude', 'longitude']);
        });

        Schema::create('directory_reports', function (Blueprint $t) {
            $t->id();
            $t->string('type', 20); // wrong_location | not_exists | wrong_name | new_mosque
            $t->foreignId('directory_id')->nullable()->constrained('mosque_directory')->cascadeOnDelete();
            $t->string('name', 200)->nullable();
            $t->string('kind', 10)->nullable();
            $t->double('latitude')->nullable();
            $t->double('longitude')->nullable();
            $t->string('note', 500)->nullable();
            $t->string('status', 10)->default('pending'); // pending | accepted | rejected
            $t->string('reporter_hash', 64)->nullable(); // hash IP (anti-spam), bukan IP mentah
            $t->timestamp('resolved_at')->nullable();
            $t->timestamps();
            $t->index(['status', 'created_at']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('directory_reports');
        Schema::dropIfExists('mosque_directory');
    }
};
