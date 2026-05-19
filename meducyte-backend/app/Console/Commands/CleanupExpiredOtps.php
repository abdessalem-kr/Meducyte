<?php

namespace App\Console\Commands;

use Illuminate\Console\Command;
use App\Models\OTP;
use Carbon\Carbon;

class CleanupExpiredOtps extends Command
{
    /**
     * The name and signature of the console command.
     */
    protected $signature = 'otps:cleanup';

    /**
     * The console command description.
     */
    protected $description = 'Remove expired OTPs and used OTPs older than 1 hour';

    /**
     * Execute the console command.
     */
    public function handle(): int
    {
        $deleted = OTP::query()
            ->where('expires_at', '<', Carbon::now())
            ->orWhere(function ($query) {
                $query->where('used', true)
                      ->where('updated_at', '<', Carbon::now()->subHour());
            })
            ->delete();

        $this->info("Cleaned up {$deleted} expired/used OTPs.");

        return self::SUCCESS;
    }
}