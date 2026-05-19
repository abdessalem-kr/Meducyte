<?php
# meducyte-backend/database/migrations/2026_03_27_210000_create_pomodoro_sessions_table.php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    public function up()
    {
        Schema::create('pomodoro_sessions', function (Blueprint $row) {
            $row->id();
            $row->foreignId('user_id')->constrained()->onDelete('cascade');
            $row->string('type'); // 'work', 'shortBreak', 'longBreak'
            $row->integer('duration_minutes');
            $row->dateTime('started_at');
            $row->dateTime('completed_at')->nullable();
            $row->string('status')->default('completed'); // 'completed', 'interrupted'
            $row->foreignId('todo_item_id')->nullable()->constrained('todo_items')->onDelete('set null');
            $row->timestamps();
        });
    }

    public function down()
    {
        Schema::dropIfExists('pomodoro_sessions');
    }
};
