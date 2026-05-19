<?php

namespace App\GraphQL\Queries;

use App\Models\User;
use Illuminate\Support\Facades\Auth;

class UserResolver
{
    /**
     * Search for users by name or email.
     *
     * @param  mixed  $_
     * @param  array<string, mixed>  $args
     * @return \Illuminate\Database\Eloquent\Collection<int, \App\Models\User>
     */
    public function search($_, array $args)
    {
        $query = $args['query'] ?? '';
        $currentUser = Auth::user();

        $queryBuilder = User::where(function ($q) use ($query) {
            $q->where('name', 'like', "%{$query}%")
                ->orWhere('email', 'like', "%{$query}%");
        })
            ->where('id', '!=', $currentUser->id);

        // Only 7th year students can see everyone.
        // Others are restricted to their own year.
        if ($currentUser->year != 7) {
            $queryBuilder->where('year', $currentUser->year);
        }

        return $queryBuilder->limit(20)->get();
    }
}
