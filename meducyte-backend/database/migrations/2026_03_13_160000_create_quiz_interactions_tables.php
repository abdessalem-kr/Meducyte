<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    public function up(): void
    {
        // 1. Question Comments (Public/Shared)
        Schema::create('question_comments', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained()->cascadeOnDelete();
            $table->foreignId('question_id')->constrained('questions')->cascadeOnDelete();
            $table->text('text');
            $table->boolean('is_edited')->default(false);
            $table->timestamps();

            $table->index(['question_id', 'created_at']);
        });

        // 2. Question Reports (Flagging)
        Schema::create('question_reports', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained()->cascadeOnDelete();
            $table->foreignId('question_id')->constrained('questions')->cascadeOnDelete();
            $table->string('reason'); // typo, wrong_answer, unclear, other
            $table->text('description')->nullable();
            $table->timestamps();
        });

        // 3. User Highlights & Personal Notes (Private)
        Schema::create('question_highlights', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained()->cascadeOnDelete();
            $table->foreignId('question_id')->constrained('questions')->cascadeOnDelete();
            $table->json('highlights'); // Store the list of HighlightModel objects
            $table->timestamps();

            $table->unique(['user_id', 'question_id']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('question_highlights');
        Schema::dropIfExists('question_reports');
        Schema::dropIfExists('question_comments');
    }
};
