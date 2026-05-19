<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::create('question_reviews', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained()->cascadeOnDelete();
            $table->foreignId('question_id')->constrained('questions')->cascadeOnDelete();
            
            $table->integer('interval')->default(0); // in days (or 0 for <1d)
            $table->double('ease_factor')->default(2.5);
            $table->integer('repetition_count')->default(0);
            
            $table->dateTime('next_review');
            $table->dateTime('last_review')->nullable();
            
            $table->timestamps();

            $table->index(['user_id', 'next_review']);
            $table->unique(['user_id', 'question_id']);
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('question_reviews');
    }
};
