<?php
// app/GraphQL/Queries/Learn/ParagraphResolver.php

namespace App\GraphQL\Queries\Learn;

use App\Models\Learn\LessonParagraph;
use App\Models\Learn\ParagraphNote;
use Closure;
use GraphQL\Type\Definition\ResolveInfo;
use Nuwave\Lighthouse\Support\Contracts\GraphQLContext;

class ParagraphResolver
{
    /**
     * Returns true if the paragraph has at least one question.
     */
    public function hasQuiz(LessonParagraph $root, array $args, GraphQLContext $context, ResolveInfo $resolveInfo): bool
    {
        return $root->questions()->exists();
    }

    /**
     * Returns the current user's private note for this paragraph (or null).
     */
    public function myNote(LessonParagraph $root, array $args, GraphQLContext $context, ResolveInfo $resolveInfo): ?ParagraphNote
    {
        $user = auth('sanctum')->user();
        if (!$user) {
            return null;
        }

        return $root->notes()->where('user_id', $user->id)->first();
    }
}