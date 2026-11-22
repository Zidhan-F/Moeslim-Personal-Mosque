<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('finance_transactions', function (Blueprint $table) {
            $table->string('donor_name', 120)->nullable()->after('description');
            $table->string('receipt_token', 40)->nullable()->unique()->after('donor_name');
        });

        Schema::create('donation_box_counts', function (Blueprint $table) {
            $table->id();
            $table->foreignUlid('mosque_id')->constrained()->cascadeOnDelete();
            $table->foreignId('transaction_id')->unique()->constrained('finance_transactions')->cascadeOnDelete();
            $table->date('date');
            $table->string('box_name', 120);
            $table->json('denominations');
            $table->unsignedBigInteger('total_amount');
            $table->string('witness_1_name', 100);
            $table->string('witness_2_name', 100);
            $table->string('notes', 255)->nullable();
            $table->foreignId('created_by')->constrained('users');
            $table->timestamps();
            $table->index(['mosque_id', 'date']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('donation_box_counts');
        Schema::table('finance_transactions', function (Blueprint $table) {
            $table->dropColumn(['donor_name', 'receipt_token']);
        });
    }
};
