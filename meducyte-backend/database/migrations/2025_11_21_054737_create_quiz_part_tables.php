<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        // 1. Standard Hierarchy
        Schema::create('modules', function (Blueprint $table) {
            $table->id();
            $table->string('name'); // e.g., "Cardiology"
            $table->text('description')->nullable();
            $table->timestamps();
        });

        Schema::create('lessons', function (Blueprint $table) {
            $table->id();
            $table->foreignId('module_id')->constrained('modules')->cascadeOnDelete();
            $table->string('title'); // e.g., "Mitral Stenosis"
            $table->integer('order')->default(0); // To sort lessons in a module
            $table->timestamps();
        });

        // 2. The Smart Content Engine (Replaces simple paragraphs)
        // Handles Text, Images, and Tables distinctly
        Schema::create('lesson_blocks', function (Blueprint $table) {
            $table->id();
            $table->foreignId('lesson_id')->constrained('lessons')->cascadeOnDelete();
            
            // Is this text, an image, or a table?
            $table->string('type')->default('TEXT'); 
            
            // The meat of the content. 
            // If TEXT: The text string.
            // If IMAGE: The URL path.
            // If TABLE: A JSON string containing rows/cols.
            $table->longText('content'); 
            
            // Extra data (e.g., Table Headers, Image Alt Text, Video Duration)
            $table->json('meta')->nullable(); 
            
            $table->integer('position')->default(0);
            $table->timestamps();

            $table->index(['lesson_id', 'position']); // Speed up loading lessons
        });

        // 3. The Semantic Brain (The "Neural Network" Connector)
        // This powers the "Smart Reader" popup features
        Schema::create('concepts', function (Blueprint $table) {
            $table->id();
            $table->string('name')->unique(); // e.g., "Dyspnea"
            $table->text('definition')->nullable(); // The text shown in the popup
            $table->timestamps();
            
            $table->index('name'); // Crucial for the "Highlight & Search" speed
        });

        // 4. Questions
        Schema::create('questions', function (Blueprint $table) {
            $table->id();
            // Keeps the general link to the lesson
            $table->foreignId('lesson_id')->constrained('lessons')->cascadeOnDelete();
            
            $table->longText('text');
            $table->string('source_exam')->nullable(); 
            $table->json('tags')->nullable(); // Keywords
            $table->integer('estimated_time')->nullable(); 
            $table->boolean('approved')->default(true);
            $table->timestamps();
        });

        Schema::create('propositions', function (Blueprint $table) {
            $table->id();
            $table->foreignId('question_id')->constrained('questions')->cascadeOnDelete();
            $table->char('label', 1); // A, B, C...
            $table->longText('text');
            $table->boolean('is_correct')->default(false);
            $table->timestamps();
        });

        // -------------------------------------------------------
        // THE NEURAL NETWORK CONNECTIONS (Pivot Tables)
        // -------------------------------------------------------

        // Link 1: Deep Linking (Question <-> Specific Block)
        // Allows a question to point to a specific Image or Table
        Schema::create('lesson_block_question', function (Blueprint $table) {
            $table->id();
            $table->foreignId('question_id')->constrained('questions')->cascadeOnDelete();
            $table->foreignId('lesson_block_id')->constrained('lesson_blocks')->cascadeOnDelete();
            $table->timestamps();
            $table->unique(['question_id', 'lesson_block_id']);
        });

        // Link 2: Concept Tagging (Block <-> Concept)
        // "This paragraph explains Dyspnea"
        Schema::create('concept_lesson_block', function (Blueprint $table) {
            $table->id();
            $table->foreignId('concept_id')->constrained('concepts')->cascadeOnDelete();
            $table->foreignId('lesson_block_id')->constrained('lesson_blocks')->cascadeOnDelete();
        });

        // Link 3: Concept Testing (Question <-> Concept)
        // "This question tests your knowledge of Dyspnea"
        Schema::create('concept_question', function (Blueprint $table) {
            $table->id();
            $table->foreignId('concept_id')->constrained('concepts')->cascadeOnDelete();
            $table->foreignId('question_id')->constrained('questions')->cascadeOnDelete();
        });

        // -------------------------------------------------------
        // USER INTERACTION & PROGRESS
        // -------------------------------------------------------

        // Track actual answers for "Weak Point" analysis
        Schema::create('user_answers', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained('users')->cascadeOnDelete();
            $table->foreignId('question_id')->constrained('questions')->cascadeOnDelete();
            $table->foreignId('proposition_id')->nullable()->constrained('propositions'); // Null if skipped
            $table->boolean('is_correct');
            $table->timestamps();

            $table->index(['user_id', 'is_correct']); // For fast stats calculation
        });

        Schema::create('user_notes', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained('users')->cascadeOnDelete();
            $table->foreignId('question_id')->constrained('questions')->cascadeOnDelete();
            $table->text('note');
            $table->timestamps();
        });

        Schema::create('saved_questions', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained('users')->cascadeOnDelete();
            $table->foreignId('question_id')->constrained('questions')->cascadeOnDelete();
            $table->timestamps();
        });
    }

    public function down(): void
    {
        // Drop in reverse order of dependency
        Schema::dropIfExists('saved_questions');
        Schema::dropIfExists('user_notes');
        Schema::dropIfExists('user_answers');
        Schema::dropIfExists('concept_question');
        Schema::dropIfExists('concept_lesson_block');
        Schema::dropIfExists('lesson_block_question');
        Schema::dropIfExists('propositions');
        Schema::dropIfExists('questions');
        Schema::dropIfExists('concepts');
        Schema::dropIfExists('lesson_blocks');
        Schema::dropIfExists('lessons');
        Schema::dropIfExists('modules');
    }
};