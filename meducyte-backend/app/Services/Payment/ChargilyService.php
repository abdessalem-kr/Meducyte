<?php

namespace App\Services\Payment;

use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;

class ChargilyService
{
    private $baseUrl;
    private $secretKey;

    public function __construct()
    {
        $mode = config('services.chargily.mode', 'test');
        $this->baseUrl = "https://pay.chargily.net/$mode/api/v2";
        $this->secretKey = config('services.chargily.secret_key');
    }

    /**
     * Create a checkout session
     */
    public function createCheckout($data)
    {
        $response = Http::withHeaders([
            'Authorization' => "Bearer {$this->secretKey}",
            'Accept' => 'application/json',
            'Content-Type' => 'application/json',
        ])->post("{$this->baseUrl}/checkouts", $data);

        if ($response->failed()) {
            $errorBody = $response->body();
            Log::error('Chargily API Error: ' . $errorBody);
            throw new \Exception('Chargily API Error: ' . ($response->json('message') ?? 'Unknown error'));
        }

        $responseData = $response->json();

        // Return a wrapper object with getId() and getUrl() for backward compatibility with existing controller
        return new class ($responseData) {
            private $data;
            public function __construct($data)
            {
                $this->data = $data; }
            public function getId()
            {
                return $this->data['id']; }
            public function getUrl()
            {
                return $this->data['checkout_url']; }
        };
    }

    /**
     * Get checkout session details
     */
    public function getCheckout($id)
    {
        $response = Http::withHeaders([
            'Authorization' => "Bearer {$this->secretKey}",
        ])->get("{$this->baseUrl}/checkouts/$id");

        return $response->json();
    }

    /**
     * Validate webhook signature
     */
    public function validateWebhookSignature($payload, $signature)
    {
        $webhookSecret = config('services.chargily.webhook_secret');
        if (!$signature || !$webhookSecret)
            return false;

        $computedSignature = hash_hmac('sha256', $payload, $webhookSecret);
        return hash_equals($computedSignature, $signature);
    }
}
