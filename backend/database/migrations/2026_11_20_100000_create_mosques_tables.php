<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('mosques', function (Blueprint $table) {
            $table->ulid('id')->primary();
            $table->string('name');
            $table->string('slug')->unique();
            $table->string('address')->nullable();
            $table->string('city');
            $table->string('province')->nullable();
            $table->decimal('latitude', 9, 6);
            $table->decimal('longitude', 9, 6);
            $table->string('timezone', 64);
            $table->string('prayer_method', 32)->default('kemenag');
            $table->string('simas_id', 64)->nullable();
            $table->string('phone', 32)->nullable();
            $table->string('logo_path')->nullable();
            $table->text('facilities')->nullable();
            $table->jsonb('settings')->default('{}');
            $table->boolean('needs_review')->default(false);
            $table->unsignedBigInteger('storage_used_bytes')->default(0);
            $table->foreignId('created_by')->constrained('users');
            $table->timestamps();
            $table->index(['city']);
        });

        Schema::create('mosque_members', function (Blueprint $table) {
            $table->id();
            $table->foreignUlid('mosque_id')->constrained()->cascadeOnDelete();
            $table->foreignId('user_id')->constrained()->cascadeOnDelete();
            $table->string('role', 16);
            $table->string('status', 16)->default('active');
            $table->boolean('is_owner')->default(false);
            $table->foreignId('invited_by')->nullable()->constrained('users');
            $table->timestamp('activated_at')->nullable();
            $table->timestamp('deactivated_at')->nullable();
            $table->timestamps();
            $table->unique(['mosque_id', 'user_id']);
            $table->index(['mosque_id', 'status']);
        });

        Schema::create('subscriptions', function (Blueprint $table) {
            $table->id();
            $table->foreignUlid('mosque_id')->unique()->constrained()->cascadeOnDelete();
            $table->string('provider', 32)->default('manual');
            $table->string('plan_key', 32)->default('masjid_monthly');
            $table->string('state', 16);
            $table->unsignedInteger('price_idr')->default(59000);
            $table->timestamp('trial_ends_at')->nullable();
            $table->timestamp('current_period_ends_at')->nullable();
            $table->string('external_ref')->nullable();
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('subscriptions');
        Schema::dropIfExists('mosque_members');
        Schema::dropIfExists('mosques');
    }
};
