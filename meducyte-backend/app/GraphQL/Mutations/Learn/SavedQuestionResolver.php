<?php

namespace App\GraphQL\Mutations\Learn;

use App\Models\Learn\SavedQuestion;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Validator;
use Illuminate\Validation\ValidationException;
use Illuminate\Support\Facades\DB;

class SavedQuestionResolver
{
    public function mySavedQuestions($_, array $args)
    {
        return SavedQuestion::where('user_id', auth("sanctum")->id())->get();
    }

    public function debug()
    {
        $id = auth("sanctum")->id();
        $count = SavedQuestion::where('user_id', $id)->count();
        $total = SavedQuestion::count();
        $first = SavedQuestion::first();
        $firstUid = $first ? $first->user_id : 'NONE';
        return "AuthID: " . ($id ?? 'NULL') . ", MyCount: $count, Total: $total, FirstRecordUID: $firstUid";
    }

    public function save($_, array $args)
    {
        $user = auth("sanctum")->user();

        $v = Validator::make($args, [
            'question_id' => 'required|integer|exists:questions,id',
        ]);
        if ($v->fails())
            throw new ValidationException($v);

        $questionId = (int) $args['question_id'];

        return DB::transaction(function () use ($user, $questionId) {
            $existing = SavedQuestion::where('user_id', $user->id)
                ->where('question_id', $questionId)
                ->first();

            if ($existing)
                return $existing;

            return SavedQuestion::create([
                'user_id' => $user->id,
                'question_id' => $questionId,
            ]);
        });
    }

    public function unsave($_, array $args)
    {
        $user = auth("sanctum")->user();

        $v = Validator::make($args, [
            'question_id' => 'required|integer|exists:questions,id',
        ]);
        if ($v->fails())
            throw new ValidationException($v);

        $questionId = (int) $args['question_id'];

        return SavedQuestion::where('user_id', $user->id)
            ->where('question_id', $questionId)
            ->delete() > 0;
    }

    /**
     * Toggles the saved status of a question for the authenticated user.
     * 
     * @param  mixed  $_
     * @param  array  $args
     * @return bool  True if the question is now saved, false if unsaved.
     */
    public function toggle($_, array $args): bool
    {
        $user = auth("sanctum")->user();

        $v = Validator::make($args, [
            'questionId' => 'required|integer|exists:questions,id',
            'folderId' => 'nullable|integer|exists:question_folders,id',
        ]);

        if ($v->fails()) {
            throw new ValidationException($v);
        }

        $questionId = (int) $args['questionId'];
        $folderId = isset($args['folderId']) ? (int) $args['folderId'] : null;

        return DB::transaction(function () use ($user, $questionId, $folderId) {
            $question = \App\Models\Learn\Question::findOrFail($questionId);
            $clinicalCaseId = $question->clinical_case_id;

            // If it's part of a clinical case, we operate on all questions in that case
            $questionIds = $clinicalCaseId
                ? \App\Models\Learn\Question::where('clinical_case_id', $clinicalCaseId)->pluck('id')->toArray()
                : [$questionId];

            $existing = SavedQuestion::where('user_id', $user->id)
                ->whereIn('question_id', $questionIds)
                ->get();

            if ($existing->isNotEmpty()) {
                // If moving to a different folder
                if ($folderId !== null && (int) $existing->first()->folder_id !== $folderId) {
                    SavedQuestion::where('user_id', $user->id)
                        ->whereIn('question_id', $questionIds)
                        ->update(['folder_id' => $folderId]);
                    return true;
                }

                // If unstarring (toggle off)
                SavedQuestion::where('user_id', $user->id)
                    ->whereIn('question_id', $questionIds)
                    ->delete();
                return false;
            }

            // Save all questions in the case (or just the single question)
            foreach ($questionIds as $id) {
                SavedQuestion::create([
                    'user_id' => $user->id,
                    'question_id' => $id,
                    'folder_id' => $folderId,
                ]);
            }

            return true;
        });
    }

    /**
     * Field resolver for Question.saved_by_user
     */
    public function isSaved($root)
    {
        $user = auth("sanctum")->user();
        if (!$user)
            return false;

        $questionId = $root->id ?? ($root['id'] ?? null);
        if (!$questionId)
            return false;

        return (bool) SavedQuestion::where('user_id', $user->id)
            ->where('question_id', $questionId)
            ->exists();
    }
}