// app/Console/Kernel.php
protected function schedule(Schedule $schedule): void
{
    $schedule->command('otps:cleanup')
             ->dailyAt('03:00')        // Runs once per day at 3 AM
             ->withoutOverlapping();
}