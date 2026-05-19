<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    public function up(): void
    {
        Schema::table('study_group_quiz_sessions', function (Blueprint $table) {
            $table->integer('seconds_per_question')->nullable()->after('status');
        });
    }

    public function down(): void
    {
        Schema::table('study_group_quiz_sessions', function (Blueprint $table) {
            $table->dropColumn('seconds_per_question');
        });
    }
};
