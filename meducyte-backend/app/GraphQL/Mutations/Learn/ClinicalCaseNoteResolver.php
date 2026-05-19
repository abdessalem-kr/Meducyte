<?php

namespace App\GraphQL\Mutations\Learn;

use App\Models\Learn\ClinicalCaseNote;
use GraphQL\Type\Definition\ResolveInfo;
use Nuwave\Lighthouse\Support\Contracts\GraphQLContext;

class ClinicalCaseNoteResolver
{
    public function add($root, array $args, GraphQLContext $context, ResolveInfo $resolveInfo)
    {
        $user = auth('sanctum')->user();

        $note = ClinicalCaseNote::updateOrCreate(
            [
                'user_id' => $user->id,
                'clinical_case_id' => $args['clinical_case_id'],
            ],
            [
                'text' => $args['text'] ?? null,
                'thumbnail_url' => $args['thumbnail_url'] ?? null,
            ]
        );

        return $note;
    }

    public function delete($root, array $args, GraphQLContext $context, ResolveInfo $resolveInfo)
    {
        $user = auth('sanctum')->user();

        $deleted = ClinicalCaseNote::where('user_id', $user->id)
            ->where('id', $args['id'])
            ->delete();

        return $deleted > 0;
    }

    public function myNote($root)
    {
        $userId = auth('sanctum')->id();
        if (!$userId)
            return null;

        return ClinicalCaseNote::where('user_id', $userId)
            ->where('clinical_case_id', $root->id)
            ->first();
    }
}
