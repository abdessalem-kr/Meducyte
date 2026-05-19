<?php

namespace App\GraphQL\Queries\Learn;

use App\Models\Learn\Lesson;
use Nuwave\Lighthouse\Support\Contracts\GraphQLContext;

class LessonResolver
{
    public function isStudied(Lesson $lesson, array $args, GraphQLContext $context)
    {
        /** @var \App\Models\User $user */
        $user = $context->user();
        if (!$user)
            return false;

        return $user->studiedLessons()->where('lesson_id', $lesson->id)->exists();
    }
}
