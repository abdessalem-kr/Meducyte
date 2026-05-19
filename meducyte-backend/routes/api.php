<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Api\AuthController;
use Nuwave\Lighthouse\Http\GraphQLController;

/*
|--------------------------------------------------------------------------
| API Routes
|--------------------------------------------------------------------------
| These routes are loaded by the RouteServiceProvider within a group which
| is assigned the "api" middleware group.
|--------------------------------------------------------------------------
*/

// ------------------ Public Routes ------------------
Route::post('/register', [AuthController::class, 'register']);
Route::post('/verify-otp', [AuthController::class, 'verifyOtp']);
Route::post('/resend-otp', [AuthController::class, 'resendOtp']);
Route::post('/login', [AuthController::class, 'login'])->middleware('throttle:5,1');
Route::post('/forgot-password', [AuthController::class, 'forgotPassword']);
Route::post('/reset-password', [AuthController::class, 'resetPassword']);

// ------------------ Protected Routes ------------------
Route::middleware('auth:sanctum')->group(function () {
    Route::get('/user', function (Request $request) {
        return $request->user();
    });

    // Chargily Checkout
    Route::post('/payment/chargily/checkout', [App\Http\Controllers\Api\Payment\ChargilyController::class, 'checkout']);

    Route::post('/logout', [AuthController::class, 'logout']);
    Route::post('/update-fcm-token', [AuthController::class, 'updateFcmToken']);
    // Profile Update Route
    Route::post('/profile/update', [AuthController::class, 'updateProfile']);
    Route::get('/me', [AuthController::class, 'me']);

    // Simulation Routes
    Route::prefix('simulation')->group(function () {
        Route::get('/cases', [App\Http\Controllers\Api\Simulation\SimulationController::class, 'cases']);
        Route::post('/start', [App\Http\Controllers\Api\Simulation\SimulationController::class, 'start']);
        Route::post('/chat', [App\Http\Controllers\Api\Simulation\SimulationController::class, 'chat']);
        Route::post('/action', [App\Http\Controllers\Api\Simulation\SimulationController::class, 'action']);
        Route::post('/evaluate', [App\Http\Controllers\Api\Simulation\SimulationController::class, 'evaluate']);
    });
});

// Chargily Webhook
Route::post('/payment/chargily/webhook', [App\Http\Controllers\Api\Payment\ChargilyController::class, 'webhook']);

// ------------------ GraphQL Route ------------------
// Use the correct namespace and array syntax
Route::post('/graphql', [GraphQLController::class, '__invoke'])
    ->middleware(['throttle:graphql'])
    ->name('graphql');

// old code if you ever need it
// use Illuminate\Http\Request;
// use Illuminate\Support\Facades\Route;
// use App\Http\Controllers\Api\AuthController;

// /*
// |--------------------------------------------------------------------------
// | API Routes
// |--------------------------------------------------------------------------
// | These routes are loaded by the RouteServiceProvider within a group which
// | is assigned the "api" middleware group.
// |--------------------------------------------------------------------------
// */

// // Public routes (no authentication required)
// Route::post('/register', [AuthController::class, 'register']);

// // Apply throttling to login route (max 5 attempts per minute)
// Route::middleware(['throttle:5,1'])->post('/login', [AuthController::class, 'login']);

// // Protected routes (require Sanctum authentication)
// Route::middleware(['auth:sanctum'])->group(function () {
//     Route::post('/logout', [AuthController::class, 'logout']);
//     Route::post('/refresh', [AuthController::class, 'refresh']); // Rotate token
//     Route::get('/me', [AuthController::class, 'me']);
// });

// Route::post('/send-otp', [AuthController::class, 'sendOtp']);
// Route::post('/verify-otp', [AuthController::class, 'verifyOtp']);
// Route::post('/resend-otp', [AuthController::class, 'resendOtp']);
// Route::post('/forgot-password', [AuthController::class, 'forgotPassword']);
// Route::post('/reset-password', [AuthController::class, 'resetPassword']);