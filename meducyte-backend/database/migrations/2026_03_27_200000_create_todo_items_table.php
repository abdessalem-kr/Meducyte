<?php
# meducyte-backend/database/migrations/2026_03_27_200000_create_todo_items_table.php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    public function up()
    {
        Schema::create('todo_items', function (Blueprint $row) {
            $row->id();
            $row->foreignId('user_id')->constrained()->onDelete('cascade');
            $row->string('title');
            $row->enum('priority', ['optional', 'exam', 'urgent'])->default('optional');
            $row->dateTime('deadline')->nullable();
            $row->boolean('is_completed')->default(false);
            $row->string('module_id')->nullable();
            $row->integer('estimated_pomodoros')->default(1);
            $row->integer('completed_pomodoros')->default(0);
            $row->timestamps();
        });
    }

    public function down()
    {
        Schema::dropIfExists('todo_items');
    }
};
