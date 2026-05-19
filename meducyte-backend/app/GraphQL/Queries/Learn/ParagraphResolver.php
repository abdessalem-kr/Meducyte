<?php

namespace App\GraphQL\Queries\Learn;

use App\Models\Learn\LessonParagraph;

class ParagraphResolver
{
    public function hasQuiz($root, array $args)
    {
        return $root->questions()->exists();
    }

    public function myNote($root, array $args)
    {
        return $root->notes()->where('user_id', auth('sanctum')->id())->first();
    }
}
