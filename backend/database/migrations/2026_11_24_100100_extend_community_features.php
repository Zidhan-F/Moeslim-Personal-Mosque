<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('family_shared_goals', function (Blueprint $t) {
            $t->uuid('id')->primary();
            $t->foreignUuid('family_id')->constrained()->cascadeOnDelete();
            $t->foreignId('created_by')->constrained('users')->cascadeOnDelete();
            $t->string('learning_path', 80);
            $t->string('title', 150);
            $t->string('target_description', 255)->nullable();
            $t->date('deadline')->nullable();
            $t->string('visibility', 30)->default('members');
            $t->timestamp('completed_at')->nullable();
            $t->timestamps();
            $t->index(['family_id', 'deadline']);
        });

        Schema::table('events', function (Blueprint $t) {
            $t->boolean('waitlist_enabled')->default(false);
        });

        Schema::table('event_registrations', function (Blueprint $t) {
            $t->string('participant_name', 120)->nullable();
            $t->string('contact_phone', 40)->nullable();
            $t->string('notes', 300)->nullable();
        });

        Schema::table('service_requests', function (Blueprint $t) {
            $t->string('reference_no', 32)->nullable()->unique();
        });

        Schema::create('service_request_attachments', function (Blueprint $t) {
            $t->uuid('id')->primary();
            $t->foreignUuid('service_request_id')->constrained()->cascadeOnDelete();
            $t->foreignId('uploaded_by')->constrained('users')->cascadeOnDelete();
            $t->string('disk', 30)->default('local');
            $t->string('path', 255);
            $t->string('original_name', 180);
            $t->string('mime_type', 100);
            $t->unsignedBigInteger('size_bytes');
            $t->timestamp('expires_at')->nullable();
            $t->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('service_request_attachments');
        Schema::table('service_requests', fn (Blueprint $t) => $t->dropColumn('reference_no'));
        Schema::table('event_registrations', fn (Blueprint $t) => $t->dropColumn(['participant_name', 'contact_phone', 'notes']));
        Schema::table('events', fn (Blueprint $t) => $t->dropColumn('waitlist_enabled'));
        Schema::dropIfExists('family_shared_goals');
    }
};
