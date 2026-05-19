<?php

namespace App\GraphQL\Mutations\Learn;

use App\Models\Learn\Lesson;
use Nuwave\Lighthouse\Support\Contracts\GraphQLContext;

class LessonResolver
{
    public function toggleStudied($root, array $args, GraphQLContext $context)
    {
        /** @var \App\Models\User $user */
        $user = $context->user();
        if (!$user)
            return false;

        $lessonId = $args['lesson_id'];

        // Toggle the relationship
        if ($user->studiedLessons()->where('lesson_id', $lessonId)->exists()) {
            $user->studiedLessons()->detach($lessonId);
            return false;
        } else {
            $user->studiedLessons()->attach($lessonId);
            return true;
        }
    }
}
