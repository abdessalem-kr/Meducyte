<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Offer extends Model
{
    use HasFactory;

    protected $fillable = [
        'code',
        'discount_percent',
        'valid_until',
        'type'
    ];

    protected $casts = [
        'valid_until' => 'datetime',
    ];
}
