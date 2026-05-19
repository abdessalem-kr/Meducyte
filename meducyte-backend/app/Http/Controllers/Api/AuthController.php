<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\User;
use App\Models\OTP;
use App\Mail\OtpMail;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Validator;
use Illuminate\Support\Str;
use Illuminate\Support\Facades\Mail;
use Carbon\Carbon;
use App\Models\ExamEvent;

class AuthController extends Controller
{
    // Register with OTP
    public function register(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'name' => 'required|string|max:80',
            'email' => 'required|string|email|unique:users,email',
            'password' => 'required|string|min:8|confirmed',
            'year' => 'nullable|integer|min:1',
            'mobile' => 'nullable|string',
            'interests' => 'nullable|array',
            'learning_goal' => 'nullable|string',
            'heard_from' => 'nullable|string',
            'quiz_preference' => 'nullable|string',
            'study_time' => 'nullable|string',
            'study_duration' => 'nullable|string',
            'avatar_key' => 'nullable|string',
            'faculte' => 'nullable|string',
            'next_exam_date' => 'nullable|date',
            'enable_daily_challenge' => 'nullable|boolean',
            'show_to_faculty' => 'nullable|boolean',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'message' => 'Validation failed',
                'errors' => $validator->errors(),
            ], 422);
        }

        $data = $validator->validated();

        $user = User::create([
            'name' => $data['name'],
            'email' => $data['email'],
            'year' => $data['year'] ?? 1,
            'mobile' => $data['mobile'] ?? null,
            'password' => Hash::make($data['password']),
            'study_duration' => $data['study_duration'] ?? null,
            'avatar_key' => $data['avatar_key'] ?? 'avatar_1',
            'faculte' => $data['faculte'] ?? null,
            'enable_daily_challenge' => $data['enable_daily_challenge'] ?? true,
            'show_to_faculty' => $data['show_to_faculty'] ?? true,
        ]);

        if (isset($data['next_exam_date'])) {
            $user->examEvents()->create([
                'title' => 'Mon Examen',
                'date' => $data['next_exam_date'],
            ]);
        }

        // Generate OTP and store
        $otp = OTP::generateOTP($user->email, 'email_verification', 5);

        // Send OTP via SMTP (Mailable)
        try {
            Mail::to($user->email)->send(new OtpMail($otp->otp, 'email_verification', 5));
        } catch (\Throwable $e) {
            return response()->json([
                'message' => 'Registration created, but failed to send verification email.',
                'error' => $e->getMessage(),
                'requires_verification' => true,
                'user' => $user,
            ], 500);
        }

        // Show OTP in debug environments only
        $devOtp = null;
        if (app()->environment('local') || config('app.debug')) {
            $devOtp = $otp->otp;
        }

        $user->makeHidden(['password', 'remember_token']);

        return response()->json([
            'message' => 'Registration successful! OTP sent to your email.',
            'requires_verification' => true,
            'otp' => $devOtp,
            'user' => $user
        ], 201);
    }

    // Login (with email verification check)
    public function login(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'email' => 'required|email',
            'password' => 'required|string',
            'device_id' => 'nullable|string',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'message' => 'Validation failed',
                'errors' => $validator->errors(),
            ], 422);
        }

        $key = Str::lower($request->input('email')) . '|' . $request->ip();

        // Check if account is locked
        if (app('cache')->has('login:lock:' . $key)) {
            return response()->json([
                'message' => 'Too many login attempts. Please try again later.',
            ], 429);
        }

        $user = User::with(['activeSubscription.plan'])->where('email', $request->email)->first();

        // Check credentials
        if (!$user || !Hash::check($request->password, $user->password)) {
            $attempts = (int) app('cache')->get('login:attempts:' . $key, 0) + 1;
            app('cache')->put('login:attempts:' . $key, $attempts, 60 * 2);

            if ($attempts >= 5) {
                app('cache')->put('login:lock:' . $key, true, 60 * 2);
                return response()->json([
                    'message' => 'Too many failed login attempts. Account temporarily locked.',
                ], 429);
            }

            // Return JSON error for invalid credentials
            return response()->json([
                'message' => 'Invalid credentials.',
                'errors' => [
                    'email' => ['Invalid credentials.']
                ]
            ], 422);
        }

        // Check email verification
        if (!$user->hasVerifiedEmail()) {
            return response()->json([
                'message' => 'Please verify your email address before logging in.',
                'requires_verification' => true,
            ], 403);
        }

        // Clear login attempts on successful login
        app('cache')->forget('login:attempts:' . $key);
        app('cache')->forget('login:lock:' . $key);

        $deviceId = $request->input('device_id') ?? Str::random(16);
        $expiresAt = Carbon::now()->addDays(7);

        $tokenResult = $user->createToken($deviceId, ['*']);
        $plainToken = $tokenResult->plainTextToken;

        // Persist device_id & expires_at on token record
        $accessTokenModel = $tokenResult->accessToken ?? null;
        if ($accessTokenModel) {
            $accessTokenModel->device_id = $deviceId;
            $accessTokenModel->expires_at = $expiresAt;
            $accessTokenModel->save();
        } else {
            $pat = $user->tokens()->where('name', $deviceId)->latest()->first();
            if ($pat) {
                $pat->device_id = $deviceId;
                $pat->expires_at = $expiresAt;
                $pat->save();
            }
        }

        $user->makeHidden(['password', 'remember_token']);

        return response()->json([
            'user' => $user,
            'access_token' => $plainToken,
            'token_type' => 'Bearer',
            'expires_at' => $expiresAt->toDateTimeString(),
            'device_id' => $deviceId,
        ], 200);
    }

    // Send OTP (verification or password reset)
    public function sendOtp(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'email' => 'required|email',
            'type' => 'required|in:email_verification,password_reset',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'message' => 'Validation failed',
                'errors' => $validator->errors(),
            ], 422);
        }

        $user = User::where('email', $request->email)->first();

        // Check user exists for email verification
        if ($request->type === 'email_verification') {
            if (!$user) {
                return response()->json(['message' => 'User not found.'], 404);
            }
            if ($user->hasVerifiedEmail()) {
                return response()->json(['message' => 'Email already verified.'], 400);
            }
        }

        // Check user exists for password reset
        if ($request->type === 'password_reset' && !$user) {
            return response()->json(['message' => 'User not found.'], 404);
        }

        try {
            // Generate OTP
            $otp = OTP::generateOTP($request->email, $request->type, 5);

            // Log the attempt
            \Log::info('Attempting to send OTP', [
                'email' => $request->email,
                'type' => $request->type,
                'otp' => $otp->otp, // Only in development
            ]);

            // Send email
            Mail::to($request->email)->send(new OtpMail($otp->otp, $request->type, 5));

            // Log success
            \Log::info('OTP sent successfully', ['email' => $request->email]);

            // Return OTP in development/debug mode only
            $devOtp = null;
            if (app()->environment('local') || config('app.debug')) {
                $devOtp = $otp->otp;
            }

            return response()->json([
                'message' => 'OTP sent successfully.',
                'otp' => $devOtp,
                'expires_in' => 5,
            ], 200);

        } catch (\Throwable $e) {
            // Log the error with full details
            \Log::error('Failed to send OTP', [
                'email' => $request->email,
                'type' => $request->type,
                'error' => $e->getMessage(),
                'trace' => $e->getTraceAsString(),
            ]);

            return response()->json([
                'message' => 'Failed to send OTP. Please try again.',
                'error' => app()->environment('local') ? $e->getMessage() : 'An error occurred.',
            ], 500);
        }
    }

    // Verify OTP
    public function verifyOtp(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'email' => 'required|email',
            'otp' => 'required|string|size:6',
            'type' => 'required|in:email_verification,password_reset',
            'device_id' => 'nullable|string',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'message' => 'Validation failed',
                'errors' => $validator->errors(),
            ], 422);
        }

        $otpRecord = OTP::where('email', $request->email)
            ->where('otp', $request->otp)
            ->where('type', $request->type)
            ->where('used', false)
            ->first();

        if (!$otpRecord) {
            return response()->json(['message' => 'Invalid OTP. Please try again.'], 400);
        }

        if (!$otpRecord->isValid()) {
            return response()->json(['message' => 'OTP has expired. Please request a new one.'], 400);
        }

        $otpRecord->markAsUsed();

        if ($request->type === 'email_verification') {
            $user = User::with(['activeSubscription.plan'])->where('email', $request->email)->first();
            if ($user && !$user->hasVerifiedEmail()) {
                $user->markEmailAsVerified();

                // Auto-login after verification
                $deviceId = $request->input('device_id') ?? Str::random(16);
                $expiresAt = Carbon::now()->addDays(7);
                $tokenResult = $user->createToken($deviceId, ['*']);
                $token = $tokenResult->plainTextToken;

                // Persist token metadata
                $accessTokenModel = $tokenResult->accessToken ?? null;
                if ($accessTokenModel) {
                    $accessTokenModel->device_id = $deviceId;
                    $accessTokenModel->expires_at = $expiresAt;
                    $accessTokenModel->save();
                } else {
                    $pat = $user->tokens()->where('name', $deviceId)->latest()->first();
                    if ($pat) {
                        $pat->device_id = $deviceId;
                        $pat->expires_at = $expiresAt;
                        $pat->save();
                    }
                }

                $user->makeHidden(['password', 'remember_token']);

                return response()->json([
                    'message' => 'Email verified successfully!',
                    'user' => $user,
                    'access_token' => $token,
                    'token_type' => 'Bearer',
                    'expires_at' => $expiresAt->toDateTimeString(),
                    'device_id' => $deviceId,
                ], 200);
            }
        }

        // For password_reset verification
        return response()->json([
            'message' => 'OTP verified successfully.',
            'verified' => true,
        ], 200);
    }

    // Forgot password (send OTP)
    public function forgotPassword(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'email' => 'required|email',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'message' => 'Validation failed',
                'errors' => $validator->errors(),
            ], 422);
        }

        $user = User::where('email', $request->email)->first();
        if (!$user) {
            return response()->json(['message' => 'User not found.'], 404);
        }

        try {
            $otp = OTP::generateOTP($user->email, 'password_reset', 5);
            Mail::to($user->email)->send(new OtpMail($otp->otp, 'password_reset', 5));

            $devOtp = null;
            if (app()->environment('local') || config('app.debug')) {
                $devOtp = $otp->otp;
            }

            return response()->json([
                'message' => 'Password reset OTP sent to your email.',
                'otp' => $devOtp,
            ], 200);
        } catch (\Throwable $e) {
            return response()->json([
                'message' => 'Failed to send OTP. Please try again.',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    // Reset Password after OTP verification
    public function resetPassword(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'email' => 'required|email',
            'otp' => 'required|string|size:6',
            'password' => 'required|string|min:8|confirmed',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'message' => 'Validation failed',
                'errors' => $validator->errors(),
            ], 422);
        }

        $otpRecord = OTP::where('email', $request->email)
            ->where('otp', $request->otp)
            ->where('type', 'password_reset')
            ->where('used', false)
            ->first();

        if (!$otpRecord) {
            return response()->json(['message' => 'Invalid OTP.'], 400);
        }

        if (!$otpRecord->isValid()) {
            return response()->json(['message' => 'OTP has expired.'], 400);
        }

        $otpRecord->markAsUsed();

        $user = User::where('email', $request->email)->first();
        if (!$user) {
            return response()->json(['message' => 'User not found.'], 404);
        }

        $user->password = Hash::make($request->password);
        $user->save();

        return response()->json(['message' => 'Password reset successfully.'], 200);
    }

    // Refresh token
    public function refresh(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'device_id' => 'required|string',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'message' => 'Validation failed',
                'errors' => $validator->errors(),
            ], 422);
        }

        $user = $request->user();
        if (!$user) {
            return response()->json(['message' => 'Unauthenticated.'], 401);
        }

        $deviceId = $request->device_id;
        $oldToken = $user->tokens()->where('device_id', $deviceId)->latest()->first();

        if (!$oldToken) {
            return response()->json(['message' => 'No token found for this device.'], 404);
        }

        $expiresAt = Carbon::now()->addDays(7);
        $new = $user->createToken($deviceId);
        $plain = $new->plainTextToken;

        $newTokenModel = $user->tokens()->where('name', $deviceId)->latest()->first();
        if ($newTokenModel) {
            $newTokenModel->device_id = $deviceId;
            $newTokenModel->expires_at = $expiresAt;
            $newTokenModel->save();
        }

        $oldToken->delete();

        return response()->json([
            'access_token' => $plain,
            'token_type' => 'Bearer',
            'expires_at' => $expiresAt->toDateTimeString(),
        ], 200);
    }

    // resend otp

    public function resendOtp(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'email' => 'required|email',
            'type' => 'required|in:email_verification,password_reset',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'message' => 'Validation failed',
                'errors' => $validator->errors(),
            ], 422);
        }

        $user = User::where('email', $request->email)->first();

        // Check user exists for email verification
        if ($request->type === 'email_verification') {
            if (!$user) {
                return response()->json(['message' => 'User not found.'], 404);
            }
            if ($user->hasVerifiedEmail()) {
                return response()->json(['message' => 'Email already verified.'], 400);
            }
        }

        // Check user exists for password reset
        if ($request->type === 'password_reset' && !$user) {
            return response()->json(['message' => 'User not found.'], 404);
        }

        try {
            // Generate new OTP
            $otp = OTP::generateOTP($request->email, $request->type, 5);

            \Log::info('Resending OTP', [
                'email' => $request->email,
                'type' => $request->type,
            ]);

            // Send email
            Mail::to($request->email)->send(new OtpMail($otp->otp, $request->type, 5));

            // Return OTP in development/debug mode only
            $devOtp = null;
            if (app()->environment('local') || config('app.debug')) {
                $devOtp = $otp->otp;
            }

            return response()->json([
                'message' => 'OTP resent successfully.',
                'otp' => $devOtp,
                'expires_in' => 5,
            ], 200);

        } catch (\Throwable $e) {
            \Log::error('Failed to resend OTP', [
                'email' => $request->email,
                'type' => $request->type,
                'error' => $e->getMessage(),
            ]);

            return response()->json([
                'message' => 'Failed to resend OTP. Please try again.',
                'error' => app()->environment('local') ? $e->getMessage() : 'An error occurred.',
            ], 500);
        }
    }

    // Logout: delete current access token
    public function logout(Request $request)
    {
        $token = $request->user()->currentAccessToken();
        if ($token) {
            $token->delete();
        }

        return response()->json(['message' => 'Logged out successfully.'], 200);
    }

    // Update FCM token for a device
    public function updateFcmToken(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'device_id' => 'required|string',
            'fcm_token' => 'required|string',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'message' => 'Validation failed',
                'errors' => $validator->errors(),
            ], 422);
        }

        $user = $request->user();
        if (!$user) {
            return response()->json(['message' => 'Unauthenticated.'], 401);
        }

        $deviceId = $request->device_id;
        $fcmToken = $request->fcm_token;

        $tokenModel = $user->tokens()->where('device_id', $deviceId)->latest()->first();
        if (!$tokenModel && config('sanctum.personal_access_tokens')) {
            $tokenModel = $user->tokens()->where('name', $deviceId)->latest()->first();
        }

        if ($tokenModel) {
            $tokenModel->fcm_token = $fcmToken;
            $tokenModel->save();
            return response()->json(['message' => 'FCM token updated successfully.'], 200);
        }

        return response()->json(['message' => 'Device not found.'], 404);
    }

    // Update user profile
    public function updateProfile(Request $request)
    {
        $user = $request->user();
        if (!$user) {
            return response()->json(['message' => 'Unauthenticated.'], 401);
        }

        $validator = Validator::make($request->all(), [
            'name' => 'sometimes|required|string|max:80',
            'year' => 'sometimes|nullable|integer|min:1',
            'mobile' => 'sometimes|nullable|string',
            'interests' => 'sometimes|nullable|array',
            'specialty' => 'sometimes|nullable|string', // mapped from faculte in front
            'faculte' => 'sometimes|nullable|string',
            'learning_goal' => 'sometimes|nullable|string',
            'heard_from' => 'sometimes|nullable|string',
            'quiz_preference' => 'sometimes|nullable|string',
            'study_time' => 'sometimes|nullable|string',
            'study_duration' => 'sometimes|nullable|string',
            'avatar_key' => 'sometimes|nullable|string',
            'next_exam_date' => 'sometimes|nullable|date',
            'enable_daily_challenge' => 'sometimes|nullable|boolean',
            'show_to_faculty' => 'sometimes|nullable|boolean',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'message' => 'Validation failed',
                'errors' => $validator->errors(),
            ], 422);
        }

        $updateData = $validator->validated();
        $nextExamDate = $updateData['next_exam_date'] ?? null;
        unset($updateData['next_exam_date']);

        $user->update($updateData);

        if ($nextExamDate) {
            $examEvent = $user->examEvents()->latest('date')->first();
            if ($examEvent) {
                $examEvent->update(['date' => $nextExamDate]);
            } else {
                $user->examEvents()->create([
                    'title' => 'Mon Examen',
                    'date' => $nextExamDate,
                ]);
            }
        }

        return response()->json([
            'message' => 'Profile updated successfully!',
            'user' => $user->fresh(['activeSubscription.plan']),
        ], 200);
    }

    // Me endpoint
    public function me(Request $request)
    {
        $user = $request->user()->load(['activeSubscription.plan']);
        $user->makeHidden(['password', 'remember_token']);
        return response()->json(['user' => $user], 200);
    }
}