<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up()
    {
        Schema::create('simulation_sessions', function (Blueprint $col) {
            $col->uuid('id')->primary();
            $col->foreignId('user_id')->constrained()->onDelete('cascade');
            $col->foreignId('simulation_case_id')->constrained()->onDelete('cascade');
            $col->enum('difficulty', ['junior', 'resident', 'consultant'])->default('junior');
            $col->enum('setting', ['emergencyRoom', 'outpatientClinic', 'intensiveCare'])->default('emergencyRoom');
            $col->boolean('is_finished')->default(false);
            $col->integer('score')->nullable();
            $col->text('feedback')->nullable();
            $col->json('current_vitals')->nullable();
            $col->timestamps();
        });
    }

    public function down()
    {
        Schema::dropIfExists('simulation_sessions');
    }
};
