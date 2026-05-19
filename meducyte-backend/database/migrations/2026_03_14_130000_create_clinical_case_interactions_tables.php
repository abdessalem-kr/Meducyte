<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    public function up(): void
    {
        // 1. Clinical Case Highlights (Private/JSON)
        Schema::create('clinical_case_highlights', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained()->cascadeOnDelete();
            $table->foreignId('clinical_case_id')->constrained('clinical_cases')->cascadeOnDelete();
            $table->json('highlights');
            $table->timestamps();

            $table->unique(['user_id', 'clinical_case_id'], 'cc_highlights_user_unique');
        });

        // 2. Clinical Case Notes (Private/Rich Text)
        Schema::create('clinical_case_notes', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained()->cascadeOnDelete();
            $table->foreignId('clinical_case_id')->constrained('clinical_cases')->cascadeOnDelete();
            $table->text('text')->nullable();
            $table->string('thumbnail_url')->nullable();
            $table->timestamps();

            $table->unique(['user_id', 'clinical_case_id'], 'cc_notes_user_unique');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('clinical_case_notes');
        Schema::dropIfExists('clinical_case_highlights');
    }
};
