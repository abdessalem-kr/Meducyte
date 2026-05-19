<?php

namespace App\Providers;

use Illuminate\Foundation\Support\Providers\RouteServiceProvider as ServiceProvider;
use Illuminate\Support\Facades\Route;
use Illuminate\Http\Request;                    
use Illuminate\Cache\RateLimiting\Limit;        
use Illuminate\Support\Facades\RateLimiter;
use Nuwave\Lighthouse\Http\GraphQLController;

class RouteServiceProvider extends ServiceProvider
{
    public function boot(): void
    {
        $this->configureRateLimiting();

        $this->routes(function () {
            Route::prefix('api')
                ->middleware('api')
                ->group(base_path('routes/api.php'));

            Route::middleware('web')
                ->group(base_path('routes/web.php'));

            Route::post('/graphql', GraphQLController::class)
                ->middleware(['auth:sanctum', 'throttle:graphql'])
                ->name('graphql');
        });
    }

    protected function configureRateLimiting(): void
    {
        // GraphQL rate limiting (already there)
        RateLimiter::for('graphql', function (Request $request) {
            $user = $request->user();
            return $user
                ? Limit::perMinute(300)->by($user->id)
                : Limit::perMinute(60)->by($request->ip());
        });

        // ←←← OTP rate limiting (fixed & working)
        RateLimiter::for('send-otp', function (Request $request) {
            $key = 'otp:'.$request->ip().':'.($request->input('email') ?? $request->ip());

            return Limit::perMinute(3)
                ->by($key)
                ->response(function () {
                    return response()->json([
                        'message' => 'Too many OTP requests. Please try again later.'
                    ], 429);
                });
        });
    }
}