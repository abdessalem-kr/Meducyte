<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up()
    {
        Schema::table('simulation_cases', function (Blueprint $table) {
            $table->string('module_name')->nullable()->after('pathology_id');
            $table->text('summary')->nullable()->after('occupation');
        });
    }

    public function down()
    {
        Schema::table('simulation_cases', function (Blueprint $table) {
            $table->dropColumn(['module_name', 'summary']);
        });
    }
};
