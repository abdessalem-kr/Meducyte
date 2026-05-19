<?php

namespace App\Models\Learn;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Lesson extends Model
{
    use HasFactory;

    protected $fillable = ['module_id', 'title', 'content'];

    public function module()
    {
        return $this->belongsTo(Module::class);
    }

    public function paragraphs()
    {
        return $this->hasMany(LessonParagraph::class);
    }

    public function questions()
    {
        return $this->hasMany(Question::class);
    }

    public function clinicalCases()
    {
        return $this->hasMany(ClinicalCase::class);
    }

    public function studiedByUsers()
    {
        return $this->belongsToMany(\App\Models\User::class, 'studied_lessons');
    }
}