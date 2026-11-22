<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('display_pairing_sessions', function (Blueprint $table) {
            $table->id();
            $table->string('session_id', 36)->unique();
            $table->string('secret_hash', 64);
            $table->string('code', 6)->index();
            $table->foreignUlid('mosque_id')->nullable()->constrained()->nullOnDelete();
            $table->foreignId('display_device_id')->nullable()->constrained('display_devices')->nullOnDelete();
            $table->text('encrypted_token')->nullable();
            $table->timestamp('expires_at');
            $table->timestamp('approved_at')->nullable();
            $table->foreignId('approved_by')->nullable()->constrained('users')->nullOnDelete();
            $table->timestamp('claimed_at')->nullable();
            $table->timestamps();
            $table->index(['code', 'expires_at']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('display_pairing_sessions');
    }
};
