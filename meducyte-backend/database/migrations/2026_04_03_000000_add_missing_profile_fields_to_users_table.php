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
        Schema::table('users', function (Blueprint $table) {
            $table->string('avatar_key')->nullable()->after('study_duration');
            $table->string('faculte')->nullable()->after('avatar_key');
            $table->boolean('enable_daily_challenge')->default(true)->after('faculte');
            $table->boolean('show_to_faculty')->default(true)->after('enable_daily_challenge');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('users', function (Blueprint $table) {
            $table->dropColumn([
                'avatar_key',
                'faculte',
                'enable_daily_challenge',
                'show_to_faculty'
            ]);
        });
    }
};
