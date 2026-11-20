<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('funds', function (Blueprint $table) {
            $table->id();
            $table->foreignUlid('mosque_id')->constrained()->cascadeOnDelete();
            $table->string('code', 24);
            $table->string('name', 100);
            $table->boolean('restricted')->default(false);
            $table->boolean('is_active')->default(true);
            $table->unsignedSmallInteger('sort')->default(0);
            $table->timestamps();
            $table->unique(['mosque_id', 'code']);
        });

        Schema::create('cash_accounts', function (Blueprint $table) {
            $table->id();
            $table->foreignUlid('mosque_id')->constrained()->cascadeOnDelete();
            $table->string('name', 100);
            $table->string('type', 16); // cash | bank | donation_box
            $table->boolean('is_active')->default(true);
            $table->timestamps();
        });

        Schema::create('finance_categories', function (Blueprint $table) {
            $table->id();
            $table->foreignUlid('mosque_id')->constrained()->cascadeOnDelete();
            $table->string('name', 100);
            $table->string('flow', 8); // in | out
            $table->boolean('is_active')->default(true);
            $table->timestamps();
        });

        Schema::create('finance_transactions', function (Blueprint $table) {
            $table->id();
            $table->foreignUlid('mosque_id')->constrained()->cascadeOnDelete();
            $table->string('reference_no', 32);
            $table->string('flow', 8); // in | out | transfer
            $table->unsignedBigInteger('amount');
            $table->foreignId('fund_id')->constrained();
            $table->foreignId('cash_account_id')->constrained();
            $table->foreignId('to_cash_account_id')->nullable()->constrained('cash_accounts');
            $table->foreignId('category_id')->nullable()->constrained('finance_categories');
            $table->date('date');
            $table->string('description', 255);
            $table->foreignId('reversal_of_id')->nullable()->unique()->constrained('finance_transactions');
            $table->foreignId('created_by')->constrained('users');
            $table->string('idempotency_key', 100);
            $table->string('request_hash', 64);
            $table->timestamps();
            $table->unique(['mosque_id', 'reference_no']);
            $table->unique(['mosque_id', 'idempotency_key']);
            $table->index(['mosque_id', 'date']);
        });
        DB::statement('ALTER TABLE finance_transactions ADD CONSTRAINT finance_amount_positive CHECK (amount > 0)');

        Schema::create('finance_attachments', function (Blueprint $table) {
            $table->id();
            $table->foreignUlid('mosque_id')->constrained()->cascadeOnDelete();
            $table->foreignId('transaction_id')->constrained('finance_transactions')->cascadeOnDelete();
            $table->string('disk', 32);
            $table->string('path');
            $table->string('original_name');
            $table->string('mime', 100);
            $table->unsignedBigInteger('bytes');
            $table->foreignId('uploaded_by')->constrained('users');
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('finance_attachments');
        Schema::dropIfExists('finance_transactions');
        Schema::dropIfExists('finance_categories');
        Schema::dropIfExists('cash_accounts');
        Schema::dropIfExists('funds');
    }
};
