<?php

namespace App\Models\Learn;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use App\Models\User;

class SavedQuestion extends Model
{
    use HasFactory;

    protected $fillable = ['user_id', 'question_id', 'folder_id'];

    public function user()
    {
        return $this->belongsTo(User::class);
    }

    public function question()
    {
        return $this->belongsTo(Question::class);
    }

    public function folder()
    {
        return $this->belongsTo(QuestionFolder::class, 'folder_id');
    }
}