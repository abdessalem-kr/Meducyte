<?php

namespace Database\Seeders;

use App\Models\User;
// use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;

class DatabaseSeeder extends Seeder
{
    public function run(): void
    {
        $this->call([
            ModuleSeeder::class,
            SubscriptionPlanSeeder::class,
            SimulationCaseSeeder::class,
            StudyGroupSeeder::class,
            // To seed 40,000 dummy load-testing questions, uncomment the line below:
            // DummyQuestionSeeder::class,
        ]);
    }
}
