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
        Schema::create('comment_reports', function (Blueprint $prefix) {
            $prefix->id();
            $prefix->foreignId('user_id')->constrained()->onDelete('cascade');
            $prefix->foreignId('comment_id')->constrained('question_comments')->onDelete('cascade');
            $prefix->text('reason');
            $prefix->string('status')->default('pending'); // pending, reviewed, dismissed
            $prefix->timestamps();

            $prefix->unique(['user_id', 'comment_id']);
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('comment_reports');
    }
};
