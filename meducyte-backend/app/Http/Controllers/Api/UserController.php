<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Validation\Rule;

class UserController extends Controller
{
    public function updateProfile(Request $request)
    {
        $user = $request->user();

        $validated = $request->validate([
            'name' => 'sometimes|string|max:80',
            'year' => 'sometimes|integer|min:1|max:6',
            'mobile' => 'sometimes|string|nullable',
            'interests' => 'sometimes|array',
            'learning_goal' => 'sometimes|string|nullable',
            'heard_from' => 'sometimes|string|nullable',
            'quiz_preference' => 'sometimes|string|nullable',
            'study_time' => 'sometimes|string|nullable',
            'study_duration' => 'sometimes|string|nullable',
        ]);

        $user->update($validated);
        $user->makeHidden(['password', 'remember_token']);

        return response()->json([
            'message' => 'Profile updated successfully.',
            'user' => $user->refresh()
        ]);
    }

    public function changePassword(Request $request)
    {
        $request->validate([
            'current_password' => 'required|string',
            'password' => 'required|string|min:8|confirmed',
        ]);

        $user = $request->user();

        if (!Hash::check($request->current_password, $user->password)) {
            return response()->json([
                'message' => 'Current password is incorrect.'
            ], 422);
        }

        $user->password = Hash::make($request->password);
        $user->save();

        // Optional: Revoke all tokens on password change (very secure)
        // $user->tokens()->delete();

        return response()->json(['message' => 'Password changed successfully.']);
    }

    public function logoutAllDevices(Request $request)
    {
        $request->user()->tokens()->delete();

        return response()->json(['message' => 'Logged out from all devices.']);
    }

    public function deleteAccount(Request $request)
    {
        $request->validate([
            'password' => 'required|string'
        ]);

        $user = $request->user();

        if (!Hash::check($request->password, $user->password)) {
            return response()->json(['message' => 'Incorrect password.'], 422);
        }

        $user->tokens()->delete();
        $user->delete();

        return response()->json(['message' => 'Account deleted permanently.']);
    }
}