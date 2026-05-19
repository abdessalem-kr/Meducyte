<?php
# meducyte-backend/database/migrations/2026_03_29_050000_create_user_settings_table.php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    public function up()
    {
        Schema::create('user_settings', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->unique()->constrained()->onDelete('cascade');

            // Pomodoro Settings
            $table->integer('pomodoro_work_duration')->default(25);
            $table->integer('pomodoro_short_break')->default(5);
            $table->integer('pomodoro_long_break')->default(15);
            $table->integer('pomodoro_sessions_until_long_break')->default(4);

            // Other settings can be added here
            $table->timestamps();
        });
    }

    public function down()
    {
        Schema::dropIfExists('user_settings');
    }
};
