<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('families', function (Blueprint $t) {
            $t->uuid('id')->primary();
            $t->foreignId('owner_user_id')->constrained('users')->cascadeOnDelete();
            $t->string('name', 100);
            $t->string('timezone')->default('Asia/Jakarta');
            $t->timestamps();
        });
        Schema::create('family_members', function (Blueprint $t) {
            $t->id();
            $t->foreignUuid('family_id')->constrained()->cascadeOnDelete();
            $t->foreignId('user_id')->constrained()->cascadeOnDelete();
            $t->string('role')->default('member');
            $t->timestamps();
            $t->unique(['family_id', 'user_id']);
        });
        Schema::create('family_invitations', function (Blueprint $t) {
            $t->uuid('id')->primary();
            $t->foreignUuid('family_id')->constrained()->cascadeOnDelete();
            $t->string('token_hash', 64)->unique();
            $t->timestamp('expires_at');
            $t->timestamp('revoked_at')->nullable();
            $t->unsignedInteger('max_uses')->default(1);
            $t->unsignedInteger('used_count')->default(0);
            $t->timestamps();
        });
        Schema::create('family_events', function (Blueprint $t) {
            $t->uuid('id')->primary();
            $t->foreignUuid('family_id')->constrained()->cascadeOnDelete();
            $t->foreignId('created_by')->constrained('users')->cascadeOnDelete();
            $t->string('title', 150);
            $t->string('location')->nullable();
            $t->timestamp('starts_at');
            $t->string('recurrence')->default('none');
            $t->string('learning_path')->nullable();
            $t->unsignedInteger('version')->default(1);
            $t->softDeletes();
            $t->timestamps();
        });
        Schema::create('family_audits', function (Blueprint $t) {
            $t->id();
            $t->foreignUuid('family_id')->constrained()->cascadeOnDelete();
            $t->foreignId('actor_id')->nullable()->constrained('users')->nullOnDelete();
            $t->string('action');
            $t->timestamp('created_at');
        });
        Schema::table('events', function (Blueprint $t) {
            $t->string('publication_status')->default('published');
            $t->unsignedInteger('hijri_year')->nullable();
            $t->unsignedInteger('capacity')->nullable();
            $t->timestamp('registration_closes_at')->nullable();
            $t->boolean('registration_enabled')->default(false);
            $t->string('learning_path')->nullable();
            $t->unsignedInteger('version')->default(1);
        });
        Schema::create('event_registrations', function (Blueprint $t) {
            $t->uuid('id')->primary();
            $t->foreignId('event_id')->constrained()->cascadeOnDelete();
            $t->foreignId('user_id')->constrained()->cascadeOnDelete();
            $t->string('status')->default('confirmed');
            $t->timestamps();
            $t->unique(['event_id', 'user_id']);
        });
        Schema::create('service_definitions', function (Blueprint $t) {
            $t->uuid('id')->primary();
            $t->foreignUlid('mosque_id')->constrained()->cascadeOnDelete();
            $t->string('title', 150);
            $t->string('type');
            $t->text('description');
            $t->text('privacy_notice');
            $t->json('fields');
            $t->unsignedInteger('form_version')->default(1);
            $t->unsignedInteger('capacity')->nullable();
            $t->timestamp('closes_at')->nullable();
            $t->boolean('active')->default(false);
            $t->unsignedInteger('retention_days')->default(90);
            $t->timestamps();
        });
        Schema::create('service_requests', function (Blueprint $t) {
            $t->uuid('id')->primary();
            $t->foreignUuid('service_definition_id')->constrained()->cascadeOnDelete();
            $t->foreignId('user_id')->constrained()->cascadeOnDelete();
            $t->string('idempotency_key', 100);
            $t->unsignedInteger('form_version');
            $t->json('answers');
            $t->string('status')->default('submitted');
            $t->timestamps();
            $t->unique(['user_id', 'idempotency_key']);
        });
        Schema::create('service_request_history', function (Blueprint $t) {
            $t->id();
            $t->foreignUuid('service_request_id')->constrained()->cascadeOnDelete();
            $t->foreignId('actor_id')->nullable()->constrained('users')->nullOnDelete();
            $t->string('status');
            $t->text('message')->nullable();
            $t->timestamp('created_at');
        });
    }

    public function down(): void
    {
        foreach (['service_request_history', 'service_requests', 'service_definitions', 'event_registrations'] as $table) {
            Schema::dropIfExists($table);
        }
        Schema::table('events', fn (Blueprint $t) => $t->dropColumn(['publication_status', 'hijri_year', 'capacity', 'registration_closes_at', 'registration_enabled', 'learning_path', 'version']));
        foreach (['family_audits', 'family_events', 'family_invitations', 'family_members', 'families'] as $table) {
            Schema::dropIfExists($table);
        }
    }
};
