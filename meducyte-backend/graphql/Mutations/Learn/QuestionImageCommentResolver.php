<?php
// app/GraphQL/Mutations/Learn/QuestionImageCommentResolver.php

namespace App\GraphQL\Mutations\Learn;

use App\Models\Learn\QuestionImageComment;
use GraphQL\Type\Definition\ResolveInfo;
use Nuwave\Lighthouse\Support\Contracts\GraphQLContext;

class QuestionImageCommentResolver
{
    public function add($root, array $args, GraphQLContext $context, ResolveInfo $resolveInfo)
    {
        $user = auth('sanctum')->user();

        return QuestionImageComment::create([
            'user_id'                   => $user->id,
            'question_id'               => $args['question_id'],
            'google_drive_file_id'      => $args['google_drive_file_id'],
            'google_drive_web_view_link'=> $args['google_drive_web_view_link'],
            'thumbnail_url'             => $args['thumbnail_url'] ?? null,
            'caption'                   => $args['caption'] ?? null,
        ]);
    }

    public function delete($root, array $args, GraphQLContext $context, ResolveInfo $resolveInfo)
    {
        $user = auth('sanctum')->user();

        $deleted = QuestionImageComment::where('user_id', $user->id)
            ->where('id', $args['id'])
            ->delete();

        return $deleted > 0;
    }
}