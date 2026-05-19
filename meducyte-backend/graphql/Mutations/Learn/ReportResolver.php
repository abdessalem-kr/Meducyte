<?php

namespace App\GraphQL\Mutations\Learn;

use App\Models\Learn\Report;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Validator;
use Illuminate\Validation\ValidationException;
use Illuminate\Support\Facades\DB;

class ReportResolver
{
    public function store($_, array $args)
    {
        $user = Auth::user();

        $v = Validator::make($args, [
            'question_id' => 'required|integer|exists:questions,id',
            'message' => 'required|string|min:5|max:1000',
        ]);
        if ($v->fails()) throw new ValidationException($v);

        $questionId = (int) $args['question_id'];
        $message = strip_tags($args['message']);

        // Limit reports per user per question per day
        $count = Report::where('user_id', $user->id)
            ->where('question_id', $questionId)
            ->whereDate('created_at', now()->toDateString())
            ->count();

        if ($count >= 3) {
            abort(429, 'Daily report limit reached (3 per question).');
        }

        return DB::transaction(function () use ($user, $questionId, $message) {
            return Report::create([
                'user_id' => $user->id,
                'question_id' => $questionId,
                'message' => $message,
            ]);
        });
    }
}