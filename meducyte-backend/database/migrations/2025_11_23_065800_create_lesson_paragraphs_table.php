<?php
// database/migrations/2025_11_23_000001_create_lesson_paragraphs_table.php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('lesson_paragraphs', function (Blueprint $table) {
            $table->id(); // bigIncrements → bigint unsigned
            $table->foreignId('lesson_id')->constrained()->onDelete('cascade');
            $table->text('content');
            $table->integer('order')->default(0);
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('lesson_paragraphs');
    }
};