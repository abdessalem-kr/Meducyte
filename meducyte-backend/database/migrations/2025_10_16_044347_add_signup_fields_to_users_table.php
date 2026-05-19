<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up()
    {
        Schema::table('users', function (Blueprint $table) {
            $table->json('interests')->nullable()->after('mobile');
            $table->string('learning_goal')->nullable()->after('interests');
            $table->string('heard_from')->nullable()->after('learning_goal');
            $table->string('quiz_preference')->nullable()->after('heard_from');
            $table->string('study_time')->nullable()->after('quiz_preference');
            $table->string('study_duration')->nullable()->after('study_time');
        });
    }

    public function down()
    {
        Schema::table('users', function (Blueprint $table) {
            $table->dropColumn([
                'interests',
                'learning_goal',
                'heard_from', 
                'quiz_preference',
                'study_time',
                'study_duration'
            ]);
        });
    }
};