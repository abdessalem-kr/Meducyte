<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    public function up()
    {
        Schema::create('exam_events', function (Blueprint $row) {
            $row->id();
            $row->foreignId('user_id')->constrained()->onDelete('cascade');
            $row->string('title');
            $row->dateTime('date');
            $row->timestamps();
        });
    }

    public function down()
    {
        Schema::dropIfExists('exam_events');
    }
};
