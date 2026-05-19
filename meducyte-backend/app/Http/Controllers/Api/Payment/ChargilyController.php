<?php

namespace App\Http\Controllers\Api\Payment;

use App\Http\Controllers\Controller;
use App\Models\Payment;
use App\Models\SubscriptionPlan;
use App\Models\Subscription;
use App\Services\Payment\ChargilyService;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Log;
use Carbon\Carbon;

class ChargilyController extends Controller
{
    protected $chargily;

    public function __construct(ChargilyService $chargily)
    {
        $this->chargily = $chargily;
    }

    public function checkout(Request $request)
    {
        $request->validate([
            'plan_id' => 'required|exists:subscription_plans,id',
        ]);

        $user = $request->user();
        $plan = SubscriptionPlan::find($request->plan_id);

        // Create a pending payment record
        $payment = Payment::create([
            'user_id' => $user->id,
            'plan_id' => $plan->id,
            'amount' => $plan->price,
            'currency' => 'dzd',
            'status' => 'pending',
        ]);

        $checkoutData = [
            'amount' => $plan->price,
            'currency' => 'dzd',
            'success_url' => config('app.url') . '/payment/success',
            'failure_url' => config('app.url') . '/payment/failure',
            'locale' => $request->header('Accept-Language', 'fr'),
            'description' => "Abonnement Meducyte: " . $plan->name,
            'metadata' => [
                'user_id' => $user->id,
                'plan_id' => $plan->id,
                'payment_id' => $payment->id,
            ],
        ];

        try {
            $checkout = $this->chargily->createCheckout($checkoutData);

            // Store the Chargily ID in our payment record
            $payment->update(['chargily_id' => $checkout->getId()]);

            return response()->json([
                'checkout_url' => $checkout->getUrl(),
            ]);
        } catch (\Exception $e) {
            Log::error('Chargily Checkout Error: ' . $e->getMessage());
            $payment->update(['status' => 'failed']);
            return response()->json(['error' => 'Could not create checkout session'], 500);
        }
    }

    public function webhook(Request $request)
    {
        $payload = $request->getContent();
        $signature = $request->header('signature');

        if (!$this->chargily->validateWebhookSignature($payload, $signature)) {
            return response()->json(['error' => 'Invalid signature'], 403);
        }

        $event = json_decode($payload, true);
        Log::info('Chargily Webhook Received: ' . $event['type']);

        // Only process paid events
        if ($event['type'] === 'checkout.paid') {
            $data = $event['data'];
            $metadata = $data['metadata'];

            $paymentId = $metadata['payment_id'] ?? null;
            $payment = $paymentId ? Payment::find($paymentId) : null;

            if ($payment && $payment->status === 'paid') {
                return response()->json(['status' => 'already_processed']);
            }

            $userId = $metadata['user_id'];
            $planId = $metadata['plan_id'];
            $plan = SubscriptionPlan::find($planId);

            // Update payment status
            if ($payment) {
                $payment->update(['status' => 'paid']);
            }

            // Activate or Create Subscription
            Subscription::updateOrCreate(
                ['user_id' => $userId],
                [
                    'plan_id' => $planId,
                    'starts_at' => Carbon::now(),
                    'expires_at' => Carbon::now()->addMonths($plan->duration_months),
                    'status' => 'active',
                ]
            );

            Log::info("Subscription activated for user $userId with plan $planId via Payment $paymentId");
        }

        return response()->json(['status' => 'ok']);
    }
}
