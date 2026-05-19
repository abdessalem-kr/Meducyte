<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    public function up(): void
    {
        Schema::create('study_group_quiz_sessions', function (Blueprint $table) {
            $table->id();
            $table->foreignId('study_group_id')->constrained()->onDelete('cascade');
            $table->unsignedBigInteger('quiz_id');
            $table->json('scores')->nullable(); // Map of user_id -> score
            $table->string('status')->default('active'); // active, completed
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('study_group_quiz_sessions');
    }
};
