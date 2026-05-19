<?php

namespace App\Mail;

use Illuminate\Bus\Queueable;
use Illuminate\Mail\Mailable;
use Illuminate\Queue\SerializesModels;

class OtpMail extends Mailable
{
    use Queueable, SerializesModels;
    
    public $otp;
    public $type;
    public $expiresInMinutes;

    public function __construct(string $otp, string $type, int $expiresInMinutes = 5)
    {
        $this->otp = $otp;
        $this->type = $type;
        $this->expiresInMinutes = $expiresInMinutes;
    }

    public function build()
    {
        $subject = $this->type === 'email_verification'
            ? 'Verify your Meducyte account'
            : 'Meducyte — Password reset code';

        return $this->subject($subject)
                    ->view('emails.otp')
                    ->with([
                        'otp' => $this->otp,
                        'type' => $this->type,
                        'expiresIn' => $this->expiresInMinutes,
                    ]);
    }
}