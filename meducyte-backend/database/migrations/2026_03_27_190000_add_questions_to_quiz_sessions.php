<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    public function up(): void
    {
        if (!Schema::hasColumn('study_group_quiz_sessions', 'questions')) {
            Schema::table('study_group_quiz_sessions', function (Blueprint $table) {
                $table->json('questions')->nullable()->after('quiz_id');
            });
        }
    }

    public function down(): void
    {
        Schema::table('study_group_quiz_sessions', function (Blueprint $table) {
            $table->dropColumn('questions');
        });
    }
};
