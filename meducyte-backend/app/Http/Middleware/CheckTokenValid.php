<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Carbon\Carbon;

class CheckTokenValid
{
    public function handle(Request $request, Closure $next)
    {
        $token = $request->user()?->currentAccessToken();
        if (! $token) {
            return response()->json(['message' => 'Invalid token'], 401);
        }

        // check expiry
        if ($token->expires_at && Carbon::now()->greaterThan($token->expires_at)) {
            // expired -> delete token
            $token->delete();
            return response()->json(['message' => 'Token expired'], 401);
        }

        // optional: check device id header matches
        $deviceHeader = $request->header('X-Device-ID') ?? $request->input('device_id');
        if ($token->device_id && $deviceHeader && $token->device_id !== $deviceHeader) {
            return response()->json(['message' => 'Device mismatch'], 401);
        }

        return $next($request);
    }
}