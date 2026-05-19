<?php

namespace App\GraphQL\Mutations;

use App\Models\Offer;
use App\Models\Subscription;
use App\Models\SubscriptionPlan;
use Illuminate\Support\Facades\Auth;
use Carbon\Carbon;

class SubscriptionResolver
{
    public function subscribe($_, array $args)
    {
        $user = Auth::user();
        $plan = SubscriptionPlan::findOrFail($args['planId']);
        $offerCode = $args['offerCode'] ?? null;

        $discount = 0;
        if ($offerCode) {
            $offer = Offer::where('code', $offerCode)
                ->where(function ($query) {
                    $query->whereNull('valid_until')
                        ->orWhere('valid_until', '>', now());
                })
                ->first();

            if ($offer) {
                $discount = $offer->discount_percent;
            }
        }

        // Deactivate existing active subscriptions
        $user->subscriptions()->where('status', 'active')->update(['status' => 'cancelled']);

        $startsAt = now();
        $expiresAt = $startsAt->copy()->addMonths($plan->duration_months);

        return Subscription::create([
            'user_id' => $user->id,
            'plan_id' => $plan->id,
            'starts_at' => $startsAt,
            'expires_at' => $expiresAt,
            'status' => 'active'
        ]);
    }

    public function applyOffer($_, array $args)
    {
        return Offer::where('code', $args['code'])
            ->where(function ($query) {
                $query->whereNull('valid_until')
                    ->orWhere('valid_until', '>', now());
            })
            ->first();
    }
}
