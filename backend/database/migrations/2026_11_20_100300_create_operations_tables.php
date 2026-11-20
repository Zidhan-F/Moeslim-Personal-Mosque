<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('events', function (Blueprint $table) {
            $table->id();
            $table->foreignUlid('mosque_id')->constrained()->cascadeOnDelete();
            $table->string('title', 150);
            $table->text('description')->nullable();
            $table->string('category', 16);
            $table->string('location', 150)->nullable();
            $table->string('speaker', 150)->nullable();
            $table->timestamp('starts_at');
            $table->timestamp('ends_at')->nullable();
            $table->string('visibility', 16)->default('public');
            $table->string('status', 16)->default('active');
            $table->boolean('show_on_display')->default(true);
            $table->foreignId('created_by')->constrained('users');
            $table->timestamps();
            $table->index(['mosque_id', 'status', 'starts_at']);
        });

        Schema::create('announcements', function (Blueprint $table) {
            $table->id();
            $table->foreignUlid('mosque_id')->constrained()->cascadeOnDelete();
            $table->string('title', 150);
            $table->text('body');
            $table->string('visibility', 16)->default('public');
            $table->unsignedTinyInteger('priority')->default(1);
            $table->timestamp('publish_at')->nullable();
            $table->timestamp('expires_at')->nullable();
            $table->string('status', 16)->default('active');
            $table->boolean('show_on_display')->default(true);
            $table->foreignId('created_by')->constrained('users');
            $table->timestamps();
            $table->index(['mosque_id', 'status']);
        });

        Schema::create('staff_assignments', function (Blueprint $table) {
            $table->id();
            $table->foreignUlid('mosque_id')->constrained()->cascadeOnDelete();
            $table->string('duty_type', 16);
            $table->string('prayer', 16)->nullable();
            $table->date('date');
            $table->foreignId('user_id')->nullable()->constrained();
            $table->string('external_name', 150)->nullable();
            $table->string('notes', 255)->nullable();
            $table->timestamps();
            $table->index(['mosque_id', 'date']);
        });

        Schema::create('inventory_items', function (Blueprint $table) {
            $table->id();
            $table->foreignUlid('mosque_id')->constrained()->cascadeOnDelete();
            $table->string('code', 50)->nullable();
            $table->string('name', 150);
            $table->unsignedInteger('quantity')->default(1);
            $table->string('condition', 16);
            $table->string('location', 150)->nullable();
            $table->string('responsible', 150)->nullable();
            $table->text('notes')->nullable();
            $table->timestamps();
            $table->index(['mosque_id']);
        });

        Schema::create('inventory_maintenance', function (Blueprint $table) {
            $table->id();
            $table->foreignId('inventory_item_id')->constrained()->cascadeOnDelete();
            $table->date('date');
            $table->string('notes', 255);
            $table->unsignedBigInteger('cost')->nullable();
            $table->foreignId('created_by')->constrained('users');
            $table->timestamps();
        });
    }

    public function down(): void
    {
        foreach (['inventory_maintenance', 'inventory_items', 'staff_assignments', 'announcements', 'events'] as $t) {
            Schema::dropIfExists($t);
        }
    }
};
