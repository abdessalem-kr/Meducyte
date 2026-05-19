<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up()
    {
        Schema::create('simulation_cases', function (Blueprint $col) {
            $col->id();
            $col->string('pathology_id')->unique();
            $col->string('name');
            $col->integer('age');
            $col->string('gender');
            $col->string('occupation');
            $col->text('main_complaint');
            $col->text('medical_history');
            $col->string('personality');
            $col->string('target_pathology');
            $col->text('secret_details')->nullable();
            $col->json('initial_vitals');
            $col->json('physical_exam_results')->nullable();
            $col->json('lab_results')->nullable();
            $col->json('media_findings')->nullable();
            $col->json('expected_findings')->nullable();
            $col->timestamps();
        });
    }

    public function down()
    {
        Schema::dropIfExists('simulation_cases');
    }
};
