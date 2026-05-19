<?php

namespace App\GraphQL\Mutations\Learn;

use App\Models\Learn\QuestionComment;
use App\Models\Learn\QuestionReport;
use App\Models\Learn\QuestionHighlight;
use App\Models\Learn\Question;
use App\Models\Learn\ClinicalCaseHighlight;
use App\Models\Learn\ClinicalCase;
use App\Models\Learn\ParagraphHighlight;
use App\Models\Learn\LessonParagraph;
use App\Models\Learn\CommentVote;
use App\Models\Learn\CommentReport;
use Illuminate\Support\Facades\Auth;

class InteractionResolver
{
    public function addComment($root, array $args): QuestionComment
    {
        $comment = QuestionComment::create([
            'user_id' => auth("sanctum")->id(),
            'question_id' => $args['question_id'],
            'parent_id' => $args['parent_id'] ?? null,
            'text' => $args['text'],
        ]);

        $comment = $comment->fresh();

        // Notify parent comment author if this is a reply and not replying to themselves
        if (!empty($args['parent_id'])) {
            $parentComment = QuestionComment::find($args['parent_id']);
            \Log::info('Checking comment reply notification', [
                'parent_id' => $args['parent_id'],
                'parent_author_id' => $parentComment ? $parentComment->user_id : null,
                'comment_author_id' => $comment->user_id,
            ]);
            // Temporarily allow self-notifications for testing
            if ($parentComment /* && $parentComment->user_id !== $comment->user_id */) {
                $comment->load('user');
                if ($parentComment->user) {
                    \Log::info('Triggering CommentReplyNotification', [
                        'to_user_id' => $parentComment->user_id,
                    ]);
                    $parentComment->user->notify(new \App\Notifications\CommentReplyNotification($comment));
                }
            }
        }

        return $comment;
    }

    public function editComment($root, array $args): QuestionComment
    {
        $comment = QuestionComment::findOrFail($args['id']);
        if ($comment->user_id !== auth("sanctum")->id()) {
            throw new \Exception("Unauthorized to edit this comment.");
        }
        $comment->update([
            'text' => $args['text'],
            'is_edited' => true,
        ]);
        return $comment;
    }

    public function deleteComment($root, array $args): bool
    {
        $comment = QuestionComment::findOrFail($args['id']);
        if ($comment->user_id !== auth("sanctum")->id()) {
            throw new \Exception("Unauthorized to delete this comment.");
        }
        return (bool) $comment->delete();
    }

    public function voteComment($root, array $args): QuestionComment
    {
        $userId = auth("sanctum")->id();
        $commentId = $args['comment_id'];
        $voteValue = $args['vote']; // 1 or -1, or 0 to remove

        $comment = QuestionComment::findOrFail($commentId);

        $existingVote = CommentVote::where('user_id', $userId)
            ->where('comment_id', $commentId)
            ->first();

        // Revert previous vote counts
        if ($existingVote) {
            if ($existingVote->vote === 1) {
                $comment->decrement('upvotes');
            } elseif ($existingVote->vote === -1) {
                $comment->decrement('downvotes');
            }
            $existingVote->delete();
        }

        // Apply new vote if it's not simply removing
        if ($voteValue === 1 || $voteValue === -1) {
            CommentVote::create([
                'user_id' => $userId,
                'comment_id' => $commentId,
                'vote' => $voteValue,
            ]);

            if ($voteValue === 1) {
                $comment->increment('upvotes');
            } else {
                $comment->increment('downvotes');
            }
        }

        return $comment->fresh();
    }

    public function myVote(QuestionComment $parent, array $args): ?int
    {
        $userId = auth("sanctum")->id();
        if (!$userId)
            return null;

        $vote = CommentVote::where('user_id', $userId)
            ->where('comment_id', $parent->id)
            ->first();

        return $vote ? $vote->vote : null;
    }

    public function isMine(QuestionComment $parent, array $args): bool
    {
        return (int) $parent->user_id === (int) auth("sanctum")->id();
    }

    public function report($root, array $args): bool
    {
        QuestionReport::create([
            'user_id' => auth("sanctum")->id(),
            'question_id' => $args['question_id'],
            'reason' => $args['reason'],
            'description' => $args['description'] ?? null,
        ]);
        return true;
    }

    public function reportComment($root, array $args): bool
    {
        CommentReport::create([
            'user_id' => auth("sanctum")->id(),
            'comment_id' => $args['comment_id'],
            'reason' => $args['reason'],
        ]);
        return true;
    }

    public function syncHighlights($root, array $args): bool
    {
        QuestionHighlight::updateOrCreate(
            ['user_id' => auth("sanctum")->id(), 'question_id' => $args['question_id']],
            ['highlights' => $args['highlights']]
        );
        return true;
    }

    public function myHighlights(Question $parent, array $args)
    {
        $userId = auth("sanctum")->id();
        if (!$userId)
            return null;

        $highlight = QuestionHighlight::where('user_id', $userId)
            ->where('question_id', $parent->id)
            ->first();

        return $highlight ? $highlight->highlights : null;
    }

    public function syncClinicalCaseHighlights($root, array $args): bool
    {
        ClinicalCaseHighlight::updateOrCreate(
            ['user_id' => auth("sanctum")->id(), 'clinical_case_id' => $args['clinical_case_id']],
            ['highlights' => $args['highlights']]
        );
        return true;
    }

    public function myClinicalCaseHighlights(ClinicalCase $parent, array $args)
    {
        $userId = auth("sanctum")->id();
        if (!$userId)
            return null;

        $highlight = ClinicalCaseHighlight::where('user_id', $userId)
            ->where('clinical_case_id', $parent->id)
            ->first();

        return $highlight ? $highlight->highlights : null;
    }

    public function syncParagraphHighlights($root, array $args): bool
    {
        ParagraphHighlight::updateOrCreate(
            ['user_id' => auth("sanctum")->id(), 'paragraph_id' => $args['paragraph_id']],
            ['highlights' => $args['highlights']]
        );
        return true;
    }

    public function myParagraphHighlights(LessonParagraph $parent, array $args)
    {
        $userId = auth("sanctum")->id();
        if (!$userId)
            return null;

        $highlight = ParagraphHighlight::where('user_id', $userId)
            ->where('paragraph_id', $parent->id)
            ->first();

        return $highlight ? $highlight->highlights : null;
    }
}
