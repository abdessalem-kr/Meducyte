<?php

namespace App\GraphQL\Mutations\Learn;

use App\Models\Learn\QuestionFolder;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Validator;
use Illuminate\Validation\ValidationException;

class QuestionFolderResolver
{
    public function myFolders($_, array $args)
    {
        return QuestionFolder::where('user_id', auth("sanctum")->id())->get();
    }

    public function create($_, array $args)
    {
        $user = auth("sanctum")->user();

        $v = Validator::make($args, [
            'name' => 'required|string|max:255',
            'color' => 'nullable|string|max:20',
        ]);

        if ($v->fails()) {
            throw new ValidationException($v);
        }

        return QuestionFolder::create([
            'user_id' => $user->id,
            'name' => $args['name'],
            'color' => $args['color'] ?? null,
        ]);
    }

    public function delete($_, array $args)
    {
        $user = auth("sanctum")->user();

        $folder = QuestionFolder::where('id', $args['id'])
            ->where('user_id', $user->id)
            ->firstOrFail();

        return $folder->delete();
    }

    public function rename($_, array $args)
    {
        $user = auth("sanctum")->user();

        $v = Validator::make($args, [
            'id' => 'required|integer|exists:question_folders,id',
            'name' => 'required|string|max:255',
            'color' => 'nullable|string|max:20',
        ]);

        if ($v->fails()) {
            throw new ValidationException($v);
        }

        $folder = QuestionFolder::where('id', $args['id'])
            ->where('user_id', $user->id)
            ->firstOrFail();

        $folder->update([
            'name' => $args['name'],
            'color' => $args['color'] ?? $folder->color,
        ]);

        return $folder;
    }
}
