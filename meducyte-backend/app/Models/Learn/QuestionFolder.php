<?php

namespace App\Models\Learn;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use App\Models\User;

class QuestionFolder extends Model
{
    use HasFactory;

    protected $fillable = ['user_id', 'name', 'color'];

    public function user()
    {
        return $this->belongsTo(User::class);
    }

    public function savedQuestions()
    {
        return $this->hasMany(SavedQuestion::class, 'folder_id');
    }
}
