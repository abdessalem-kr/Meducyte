<?php
// database/migrations/xxxx_xx_xx_xxxxxx_create_paragraph_notes_table.php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('paragraph_notes', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained()->cascadeOnDelete();
            $table->foreignId('paragraph_id')->constrained('lesson_paragraphs')->cascadeOnDelete();
            $table->text('text')->nullable();
            $table->string('google_drive_file_id')->nullable();
            $table->string('google_drive_web_view_link')->nullable();
            $table->string('thumbnail_url')->nullable();
            $table->timestamps();

            $table->unique(['user_id', 'paragraph_id']); // one note per user per paragraph
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('paragraph_notes');
    }
};