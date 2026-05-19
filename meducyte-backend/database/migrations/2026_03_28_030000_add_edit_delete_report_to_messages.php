<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    public function up(): void
    {
        // Add is_edited to study_group_messages
        Schema::table('study_group_messages', function (Blueprint $table) {
            $table->boolean('is_edited')->default(false)->after('text');
        });

        // Create study_group_message_reports
        Schema::create('study_group_message_reports', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained()->onDelete('cascade');
            $table->foreignId('message_id')->constrained('study_group_messages')->onDelete('cascade');
            $table->string('reason');
            $table->string('status')->default('pending'); // pending, reviewed, dismissed
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('study_group_message_reports');
        Schema::table('study_group_messages', function (Blueprint $table) {
            $table->dropColumn('is_edited');
        });
    }
};
