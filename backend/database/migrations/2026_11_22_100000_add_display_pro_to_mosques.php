<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('mosques', function (Blueprint $table) {
            $table->string('qris_image_path')->nullable()->after('logo_path');
            $table->unsignedBigInteger('qris_image_bytes')->default(0)->after('qris_image_path');
            $table->json('display_override')->nullable()->after('settings');
        });
    }

    public function down(): void
    {
        Schema::table('mosques', function (Blueprint $table) {
            $table->dropColumn(['qris_image_path', 'qris_image_bytes', 'display_override']);
        });
    }
};
