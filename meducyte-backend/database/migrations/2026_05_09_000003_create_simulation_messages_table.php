<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up()
    {
        Schema::create('simulation_messages', function (Blueprint $col) {
            $col->id();
            $col->uuid('session_id');
            $col->foreign('session_id')->references('id')->on('simulation_sessions')->onDelete('cascade');
            $col->text('text');
            $col->boolean('is_from_user');
            $col->json('media')->nullable();
            $col->text('raw_result')->nullable();
            $col->text('interpretation')->nullable();
            $col->boolean('is_revealed')->default(false);
            $col->timestamp('timestamp')->useCurrent();
            $col->timestamps();
        });
    }

    public function down()
    {
        Schema::dropIfExists('simulation_messages');
    }
};
