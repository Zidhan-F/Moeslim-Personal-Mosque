<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('display_pairing_codes', function (Blueprint $table) {
            $table->id();
            $table->foreignUlid('mosque_id')->constrained()->cascadeOnDelete();
            $table->string('code_hash', 64)->index();
            $table->string('name', 100)->nullable();
            $table->foreignId('created_by')->constrained('users');
            $table->timestamp('expires_at');
            $table->timestamp('used_at')->nullable();
            $table->timestamps();
        });

        Schema::create('display_devices', function (Blueprint $table) {
            $table->id();
            $table->foreignUlid('mosque_id')->constrained()->cascadeOnDelete();
            $table->string('name', 100);
            $table->string('token_hash', 64)->unique();
            $table->string('status', 16)->default('active');
            $table->jsonb('config')->default('{}');
            $table->timestamp('paired_at');
            $table->timestamp('last_seen_at')->nullable();
            $table->timestamp('revoked_at')->nullable();
            $table->timestamps();
            $table->index(['mosque_id', 'status']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('display_devices');
        Schema::dropIfExists('display_pairing_codes');
    }
};
