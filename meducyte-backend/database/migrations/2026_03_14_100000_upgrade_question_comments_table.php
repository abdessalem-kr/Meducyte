<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    public function up(): void
    {
        Schema::table('question_comments', function (Blueprint $table) {
            $table->foreignId('parent_id')->nullable()->constrained('question_comments')->cascadeOnDelete()->after('question_id');
            $table->integer('upvotes')->default(0)->after('is_edited');
            $table->integer('downvotes')->default(0)->after('upvotes');
        });
    }

    public function down(): void
    {
        Schema::table('question_comments', function (Blueprint $table) {
            $table->dropForeign(['parent_id']);
            $table->dropColumn(['parent_id', 'upvotes', 'downvotes']);
        });
    }
};
