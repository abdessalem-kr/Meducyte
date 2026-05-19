<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Carbon\Carbon;

class OTP extends Model
{
    use HasFactory;

    protected $table = 'otps';

    protected $fillable = [
        'email',
        'otp',
        'type',
        'used',
        'expires_at',
    ];

    protected $casts = [
        'used' => 'boolean',
        'expires_at' => 'datetime',
    ];

    /**
     * Generate a 6-digit OTP, invalidate previous unused OTPs for the same email/type,
     * store new otp and return model instance.
     *
     * @param string $email
     * @param string $type
     * @param int $ttlMinutes
     * @return static
     */
    public static function generateOTP(string $email, string $type, int $ttlMinutes = 5)
    {
        // Invalidate previous unused OTPs for the same email & type
        self::where('email', $email)
            ->where('type', $type)
            ->where('used', false)
            ->update(['used' => true]);

        $code = str_pad(random_int(0, 999999), 6, '0', STR_PAD_LEFT);

        return self::create([
            'email' => $email,
            'otp' => $code,
            'type' => $type,
            'expires_at' => Carbon::now()->addMinutes($ttlMinutes),
        ]);
    }

    /**
     * Check validity (not used and not expired)
     * @return bool
     */
    public function isValid(): bool
    {
        return ! $this->used && $this->expires_at && Carbon::now()->lessThan($this->expires_at);
    }

    /**
     * Mark OTP as used
     * @return void
     */
    public function markAsUsed(): void
    {
        $this->used = true;
        $this->save();
    }
}