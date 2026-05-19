<?php
// database/migrations/xxxx_xx_xx_xxxxxx_create_question_image_comments_table.php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('question_image_comments', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained()->cascadeOnDelete();
            $table->foreignId('question_id')->constrained('questions')->cascadeOnDelete();
            $table->string('google_drive_file_id');
            $table->string('google_drive_web_view_link');
            $table->string('thumbnail_url')->nullable();
            $table->text('caption')->nullable();
            $table->timestamps();

            $table->index(['question_id', 'created_at']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('question_image_comments');
    }
};