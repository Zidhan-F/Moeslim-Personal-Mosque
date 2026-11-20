<?php

namespace App\Notifications;

use Illuminate\Notifications\Messages\MailMessage;
use Illuminate\Notifications\Notification;

class EmailVerificationCode extends Notification
{
    public function __construct(public readonly string $code) {}

    public function via(object $notifiable): array
    {
        return ['mail'];
    }

    public function toMail(object $notifiable): MailMessage
    {
        return (new MailMessage)
            ->subject('Kode verifikasi Moeslim Masjid')
            ->line('Kode verifikasi Anda:')
            ->line($this->code)
            ->line('Kode berlaku 15 menit. Abaikan email ini jika Anda tidak mendaftar.');
    }
}
