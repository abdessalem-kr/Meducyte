<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    public function up(): void
    {
        if (!Schema::hasColumn('study_groups', 'type')) {
            Schema::table('study_groups', function (Blueprint $table) {
                $table->string('type')->default('focus')->after('color');
            });
        }
    }

    public function down(): void
    {
        Schema::table('study_groups', function (Blueprint $table) {
            $table->dropColumn('type');
        });
    }
};
