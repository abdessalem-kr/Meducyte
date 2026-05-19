<?php

namespace App\GraphQL\Resolvers;

use App\Models\User;
use App\Models\StudyGroup\StudyGroup;
use App\Models\StudyGroup\StudyGroupMessage;
use App\Models\StudyGroup\StudyGroupQuizSession;
use App\Models\Learn\Question;
use Illuminate\Support\Facades\Auth;
use Illuminate\Database\Eloquent\Collection;

class StudyGroupResolver
{
    public function join($_, array $args): bool
    {
        $group = StudyGroup::findOrFail($args['groupId']);
        $user = Auth::user();

        $group->members()->syncWithoutDetaching([$user->id => ['role' => 'member']]);

        return true;
    }

    public function sendMessage($_, array $args): StudyGroupMessage
    {
        $user = Auth::user();

        return StudyGroupMessage::create([
            'study_group_id' => $args['groupId'],
            'user_id' => $user->id,
            'text' => $args['text'],
            'type' => 'text',
        ]);
    }

    public function editMessage($_, array $args): StudyGroupMessage
    {
        $message = StudyGroupMessage::findOrFail($args['messageId']);
        $user = Auth::user();

        if ($message->user_id !== $user->id) {
            throw new \Exception('Vous ne pouvez modifier que vos propres messages.');
        }

        $message->update([
            'text' => $args['text'],
            'is_edited' => true,
        ]);

        return $message;
    }

    public function deleteMessage($_, array $args): bool
    {
        $message = StudyGroupMessage::find($args['messageId']);
        if (!$message) {
            throw new \Exception('Message introuvable.');
        }

        $user = Auth::user();
        if (!$user) {
            throw new \Exception('Non authentifié.');
        }

        // Allow deletion if it's your message OR if you're the group admin
        $isOwner = (int) $message->user_id === (int) $user->id;

        $group = $message->group;
        if (!$group) {
            throw new \Exception('Groupe associé au message introuvable.');
        }

        $isAdmin = $group->members()
            ->wherePivot('role', 'admin')
            ->where('user_id', $user->id)
            ->exists();

        if (!$isOwner && !$isAdmin) {
            throw new \Exception('Vous n\'avez pas la permission de supprimer ce message.');
        }

        return (bool) $message->delete();
    }

    public function reportMessage($_, array $args): bool
    {
        $user = Auth::user();

        \App\Models\StudyGroup\StudyGroupMessageReport::create([
            'user_id' => $user->id,
            'message_id' => $args['messageId'],
            'reason' => $args['reason'],
        ]);

        return true;
    }

    public function startQuiz($_, array $args): StudyGroupQuizSession
    {
        $group = StudyGroup::findOrFail($args['groupId']);
        $user = Auth::user();

        // Only the group admin can start a quiz session.
        $member = $group->members()->where('user_id', $user->id)->first();
        if (!$member || $member->pivot->role !== 'admin') {
            throw new \Exception('Seul l\'administrateur du groupe peut lancer un duel d\'étude.');
        }

        $quizId = $args['quizId'] ?? null;
        $lessonIds = $args['lessonIds'] ?? null;
        $limit = $args['limit'] ?? 10;

        // Questions are linked to modules via lessons (questions.lesson_id -> lessons.module_id).
        $query = Question::with(['propositions', 'clinical_case']);

        if ($lessonIds && !empty($lessonIds)) {
            $query->whereIn('lesson_id', $lessonIds);
        } elseif ($quizId && is_numeric($quizId)) {
            $query->whereHas('lesson', function ($q) use ($quizId) {
                $q->where('module_id', $quizId);
            });
        }

        if (isset($args['isClinicalQuiz'])) {
            if ($args['isClinicalQuiz']) {
                $query->whereNotNull('clinical_case_id');
            } else {
                $query->whereNull('clinical_case_id');
            }
        }

        $questions = $query->inRandomOrder()->limit($limit)->get();

        // Fallback: use any random questions if selection has none
        if ($questions->isEmpty()) {
            $questions = Question::with(['propositions', 'clinical_case'])
                ->inRandomOrder()
                ->limit($limit)
                ->get();
        }

        $mappedQuestions = $questions->map(function ($q) {
            $correctIndices = $q->propositions
                ->filter(fn($p) => (bool) $p->is_correct)
                ->keys()
                ->values()
                ->toArray();

            return [
                'id' => $q->id,
                'text' => $q->text,
                'options' => $q->propositions->pluck('text')->toArray(),
                'correctIndex' => empty($correctIndices) ? 0 : $correctIndices[0],
                'correctIndices' => $correctIndices,
                'explanation' => $q->explanation ?? 'Explication pour la question ' . $q->id,
                'clinical_case' => $q->clinical_case?->text,
                'source_exam' => $q->source_exam,
                'module_name' => $q->moduleName, // Computed attribute in Question model
                'year' => $q->year,             // Computed attribute in Question model
            ];
        });

        // Close any previous active sessions for this group
        StudyGroupQuizSession::where('study_group_id', $group->id)
            ->where('status', 'active')
            ->update(['status' => 'completed']);

        $session = StudyGroupQuizSession::create([
            'study_group_id' => $group->id,
            'title' => $args['title'] ?? 'Duel d\'étude',
            // quiz_id is unsignedBigInteger — store the numeric module ID (or 0 as fallback).
            'quiz_id' => is_numeric($quizId) ? (int) $quizId : 0,
            'questions' => $mappedQuestions->toArray(),
            'scores' => (object) [],
            'status' => 'active',
            'seconds_per_question' => $args['secondsPerQuestion'] ?? 15, // Default to 15s if not provided
        ]);

        $group->update(['active_quiz_session_id' => $session->id]);

        return $session;
    }

    public function updateQuizSession($_, array $args): StudyGroupQuizSession
    {
        $session = StudyGroupQuizSession::findOrFail($args['sessionId']);
        $group = $session->group;
        $user = Auth::user();

        // Check if user is admin of the group
        $member = $group->members()->where('user_id', $user->id)->first();
        if (!$member || $member->pivot->role !== 'admin') {
            throw new \Exception('Seul l\'administrateur peut modifier la session.');
        }

        $session->update(array_filter([
            'title' => $args['title'] ?? null,
            'seconds_per_question' => $args['secondsPerQuestion'] ?? null,
        ], fn($v) => !is_null($v)));

        // If limits or clinical filter changed, we might want to re-generate questions if requested.
        // For now, let's keep it simple: update title and timer.

        return $session;
    }

    public function submitScore($_, array $args): StudyGroupQuizSession
    {
        $session = StudyGroupQuizSession::findOrFail($args['sessionId']);
        $user = Auth::user();

        // scores is cast as 'object', so it's a stdClass. Convert to array,
        // update, then cast back to object so it stays serialized as {}.
        $scores = (array) ($session->scores ?? new \stdClass());
        $scores[$user->name] = $args['score'];


        $session->update(['scores' => $scores]);

        return $session;
    }

    public function messages($_, array $args): Collection
    {
        return StudyGroupMessage::where('study_group_id', $args['groupId'])
            ->with('user')
            ->latest()
            ->get();
    }

    public function create($_, array $args): StudyGroup
    {
        $user = Auth::user();

        $group = StudyGroup::create([
            'title' => $args['title'],
            'description' => $args['description'] ?? '',
            'color' => $args['color'],
            'type' => $args['type'] ?? 'focus',
        ]);

        // Creator is the first member and admin
        $group->members()->attach($user->id, ['role' => 'admin']);

        return $group;
    }

    public function update($_, array $args): StudyGroup
    {
        $group = StudyGroup::findOrFail($args['groupId']);
        $user = Auth::user();

        // Only admin can update
        $member = $group->members()->where('user_id', $user->id)->first();
        if (!$member || $member->pivot->role !== 'admin') {
            throw new \Exception('Seul l\'administrateur peut modifier le groupe.');
        }

        $group->update(array_filter([
            'title' => $args['title'] ?? null,
            'description' => $args['description'] ?? null,
            'color' => $args['color'] ?? null,
            'type' => $args['type'] ?? null,
        ]));

        return $group;
    }

    public function delete($_, array $args): bool
    {
        $group = StudyGroup::findOrFail($args['groupId']);
        $user = Auth::user();

        // Only the group admin (creator) can delete the group.
        $pivot = $group->members()->where('user_id', $user->id)->first();
        if (!$pivot || $pivot->pivot->role !== 'admin') {
            throw new \Exception('Seul le créateur du groupe peut le supprimer.');
        }

        $group->delete(); // Cascades to members, messages, and quiz sessions.
        return true;
    }

    /** Resolves the is_admin field on StudyGroup for the authenticated user. */
    public function isAdmin($root): bool
    {
        $group = $root;
        $user = Auth::user();
        if (!$user || !($group instanceof StudyGroup))
            return false;

        $member = $group->members()->where('user_id', $user->id)->first();
        return $member && $member->pivot->role === 'admin';
    }

    public function leave($_, array $args): bool
    {
        $group = StudyGroup::findOrFail($args['groupId']);
        $user = Auth::user();

        $group->members()->detach($user->id);

        return true;
    }

    public function invite($_, array $args): bool
    {
        $group = StudyGroup::findOrFail($args['groupId']);
        $user = Auth::user();
        $friendId = $args['friendId'] ?? null;

        $invitedName = "un ami";
        if ($friendId) {
            $friend = \App\Models\User::find($friendId);
            if ($friend) {
                $invitedName = $friend->name;
            }
        }

        // In a real app, we'd send a notification.
        // For now, we log a personalized system message.
        StudyGroupMessage::create([
            'study_group_id' => $group->id,
            'user_id' => $user->id,
            'text' => "A invité **{$invitedName}** à rejoindre la salle ! 🤝",
            'type' => 'system',
        ]);

        return true;
    }

    public function activeQuiz($_, array $args): ?StudyGroupQuizSession
    {
        return StudyGroupQuizSession::where('study_group_id', $args['groupId'])
            ->where('status', 'active')
            ->latest()
            ->first();
    }

    public function allActiveQuizzes($_, array $args): Collection
    {
        $user = Auth::user();
        if (!$user) {
            return new Collection();
        }

        return StudyGroupQuizSession::where('status', 'active')
            ->whereIn('study_group_id', $user->studyGroups()->pluck('id'))
            ->latest()
            ->get();
    }

    /** Resolves the is_mine field on StudyGroupMessage. */
    public function isMessageMine($root): bool
    {
        $user = Auth::user();
        return $user && $root instanceof StudyGroupMessage && (int) $root->user_id === (int) $user->id;
    }
}