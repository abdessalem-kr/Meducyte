<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    public function up(): void
    {
        Schema::create('question_folders', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained('users')->cascadeOnDelete();
            $table->string('name');
            $table->string('color')->nullable();
            $table->timestamps();
        });

        Schema::table('saved_questions', function (Blueprint $table) {
            $table->foreignId('folder_id')->nullable()->after('question_id')->constrained('question_folders')->nullOnDelete();
        });
    }

    public function down(): void
    {
        Schema::table('saved_questions', function (Blueprint $table) {
            $table->dropForeign(['folder_id']);
            $table->dropColumn('folder_id');
        });
        Schema::dropIfExists('question_folders');
    }
};
