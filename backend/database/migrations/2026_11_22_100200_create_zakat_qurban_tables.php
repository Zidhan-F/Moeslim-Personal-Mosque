<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('zakat_collections', function (Blueprint $table) {
            $table->id();
            $table->foreignUlid('mosque_id')->constrained()->cascadeOnDelete();
            $table->string('type', 24); // fitrah_money, fitrah_rice, maal, fidyah
            $table->unsignedSmallInteger('hijri_year');
            $table->date('date');
            $table->string('muzakki_name', 120);
            $table->string('muzakki_phone', 32)->nullable();
            $table->unsignedSmallInteger('souls_count')->default(1);
            $table->unsignedBigInteger('money_amount')->default(0);
            $table->decimal('rice_kg', 8, 2)->default(0);
            $table->foreignId('transaction_id')->nullable()->constrained('finance_transactions')->nullOnDelete();
            $table->string('notes', 255)->nullable();
            $table->foreignId('created_by')->constrained('users');
            $table->timestamps();
            $table->index(['mosque_id', 'hijri_year', 'type']);
        });

        Schema::create('zakat_mustahiks', function (Blueprint $table) {
            $table->id();
            $table->foreignUlid('mosque_id')->constrained()->cascadeOnDelete();
            $table->unsignedSmallInteger('hijri_year');
            $table->string('name', 120);
            $table->string('asnaf', 32); // fakir, miskin, amil, muallaf, riqab, gharimin, fisabilillah, ibnu_sabil
            $table->string('address', 200)->nullable();
            $table->unsignedBigInteger('money_amount')->default(0);
            $table->decimal('rice_kg', 8, 2)->default(0);
            $table->string('status', 24)->default('planned'); // planned, distributed
            $table->timestamp('distributed_at')->nullable();
            $table->string('notes', 255)->nullable();
            $table->foreignId('created_by')->constrained('users');
            $table->timestamps();
            $table->index(['mosque_id', 'hijri_year', 'status']);
        });

        Schema::create('qurban_animals', function (Blueprint $table) {
            $table->id();
            $table->foreignUlid('mosque_id')->constrained()->cascadeOnDelete();
            $table->unsignedSmallInteger('hijri_year');
            $table->string('code', 24);
            $table->string('species', 24); // sapi, kambing, domba, kerbau, unta
            $table->unsignedTinyInteger('capacity')->default(1);
            $table->decimal('weight_kg', 7, 2)->nullable();
            $table->unsignedBigInteger('price_idr')->default(0);
            $table->string('slaughter_status', 24)->default('registered'); // registered, slaughtered, skinned, packaged, distributed
            $table->timestamp('slaughtered_at')->nullable();
            $table->unsignedInteger('meat_packs_count')->default(0);
            $table->string('notes', 255)->nullable();
            $table->foreignId('created_by')->constrained('users');
            $table->timestamps();
            $table->unique(['mosque_id', 'hijri_year', 'code']);
        });

        Schema::create('qurban_participants', function (Blueprint $table) {
            $table->id();
            $table->foreignUlid('mosque_id')->constrained()->cascadeOnDelete();
            $table->foreignId('animal_id')->constrained('qurban_animals')->cascadeOnDelete();
            $table->string('name', 120);
            $table->string('phone', 32)->nullable();
            $table->unsignedTinyInteger('shares')->default(1);
            $table->unsignedBigInteger('amount_idr')->default(0);
            $table->string('payment_status', 24)->default('unpaid'); // unpaid, dp, paid
            $table->boolean('meat_taken')->default(false);
            $table->string('notes', 255)->nullable();
            $table->timestamps();
            $table->index(['mosque_id', 'animal_id']);
        });

        Schema::create('distribution_coupons', function (Blueprint $table) {
            $table->id();
            $table->foreignUlid('mosque_id')->constrained()->cascadeOnDelete();
            $table->string('program', 24); // qurban, zakat, baksos
            $table->unsignedSmallInteger('hijri_year');
            $table->string('code', 36)->unique();
            $table->string('recipient_name', 120);
            $table->string('recipient_address', 200)->nullable();
            $table->string('status', 24)->default('issued'); // issued, redeemed, void
            $table->timestamp('redeemed_at')->nullable();
            $table->foreignId('redeemed_by')->nullable()->constrained('users')->nullOnDelete();
            $table->foreignId('created_by')->constrained('users');
            $table->timestamps();
            $table->index(['mosque_id', 'program', 'hijri_year', 'status']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('distribution_coupons');
        Schema::dropIfExists('qurban_participants');
        Schema::dropIfExists('qurban_animals');
        Schema::dropIfExists('zakat_mustahiks');
        Schema::dropIfExists('zakat_collections');
    }
};
