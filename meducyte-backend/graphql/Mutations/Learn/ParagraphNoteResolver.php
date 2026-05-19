<?php
// app/GraphQL/Mutations/Learn/ParagraphNoteResolver.php

namespace App\GraphQL\Mutations\Learn;

use App\Models\Learn\ParagraphNote;
use GraphQL\Type\Definition\ResolveInfo;
use Nuwave\Lighthouse\Support\Contracts\GraphQLContext;

class ParagraphNoteResolver
{
    public function add($root, array $args, GraphQLContext $context, ResolveInfo $resolveInfo)
    {
        $user = auth('sanctum')->user();

        $note = ParagraphNote::updateOrCreate(
            [
                'user_id'      => $user->id,
                'paragraph_id' => $args['paragraph_id'],
            ],
            [
                'text'                   => $args['text'] ?? null,
                'google_drive_file_id'   => $args['google_drive_file_id'] ?? null,
                'google_drive_web_view_link' => $args['google_drive_web_view_link'] ?? null,
                'thumbnail_url'          => $args['thumbnail_url'] ?? null,
            ]
        );

        return $note;
    }

    public function delete($root, array $args, GraphQLContext $context, ResolveInfo $resolveInfo)
    {
        $user = auth('sanctum')->user();

        $deleted = ParagraphNote::where('user_id', $user->id)
            ->where('id', $args['id'])
            ->delete();

        return $deleted > 0;
    }
}