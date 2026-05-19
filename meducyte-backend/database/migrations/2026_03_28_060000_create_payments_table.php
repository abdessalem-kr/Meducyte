<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::create('payments', function (Blueprint $blueprint) {
            $blueprint->id();
            $blueprint->foreignId('user_id')->constrained()->onDelete('cascade');
            $blueprint->foreignId('plan_id')->constrained('subscription_plans')->onDelete('cascade');
            $blueprint->string('chargily_id')->unique()->nullable();
            $blueprint->decimal('amount', 10, 2);
            $blueprint->string('currency')->default('dzd');
            $blueprint->string('status')->default('pending'); // pending, paid, failed, canceled
            $blueprint->json('metadata')->nullable();
            $blueprint->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('payments');
    }
};
