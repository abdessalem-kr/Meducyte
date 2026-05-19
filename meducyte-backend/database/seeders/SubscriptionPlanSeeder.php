<?php

namespace Database\Seeders;

use App\Models\SubscriptionPlan;
use Illuminate\Database\Seeder;

class SubscriptionPlanSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        $plans = [
            // RESIDENCY - PREMIER ACCESS
            [
                'name' => 'Residency Premium (Yearly)',
                'sku' => 'residency_premium_yearly',
                'price' => 8000.00,
                'description' => 'Full access to all modules, quizzes, and AI features for one year.',
                'duration_months' => 12,
                'has_ai_access' => true,
                'access_level' => 'residency',
            ],
            [
                'name' => 'Residency Premium (Monthly)',
                'sku' => 'residency_premium_monthly',
                'price' => 1000.00,
                'description' => 'Monthly full access to all modules and AI features.',
                'duration_months' => 1,
                'has_ai_access' => true,
                'access_level' => 'residency',
            ],
            [
                'name' => 'Residency Basic (Yearly)',
                'sku' => 'residency_basic_yearly',
                'price' => 3500.00,
                'description' => 'Access to all quizzes and basic features for one year.',
                'duration_months' => 12,
                'has_ai_access' => false,
                'access_level' => 'residency',
            ],
            [
                'name' => 'Residency Basic (Monthly)',
                'sku' => 'residency_basic_monthly',
                'price' => 450.00,
                'description' => 'Monthly access to quizzes and basic features.',
                'duration_months' => 1,
                'has_ai_access' => false,
                'access_level' => 'residency',
            ],

            // STUDENT - YEAR SPECIFIC ACCESS
            [
                'name' => 'Student Premium (Yearly)',
                'sku' => 'student_premium_yearly',
                'price' => 2500.00,
                'description' => 'Full access to your academic year and AI features for one year.',
                'duration_months' => 12,
                'has_ai_access' => true,
                'access_level' => 'student',
            ],
            [
                'name' => 'Student Premium (Monthly)',
                'sku' => 'student_premium_monthly',
                'price' => 750.00,
                'description' => 'Monthly full access to your academic year and AI features.',
                'duration_months' => 1,
                'has_ai_access' => true,
                'access_level' => 'student',
            ],
            [
                'name' => 'Student Basic (Yearly)',
                'sku' => 'student_basic_yearly',
                'price' => 1500.00,
                'description' => 'Access to academic year quizzes and basic features for one year.',
                'duration_months' => 12,
                'has_ai_access' => false,
                'access_level' => 'student',
            ],
            [
                'name' => 'Student Basic (Monthly)',
                'sku' => 'student_basic_monthly',
                'price' => 350.00,
                'description' => 'Monthly access to academic year quizzes and basic features.',
                'duration_months' => 1,
                'has_ai_access' => false,
                'access_level' => 'student',
            ],

            // 3 MONTHS OFFERS (Adjusted)
            [
                'name' => 'Residency Premium (3 Months)',
                'sku' => 'residency_premium_3months',
                'price' => 2000.00,
                'description' => 'Full app access for 3 months at a discounted rate.',
                'duration_months' => 3,
                'has_ai_access' => true,
                'access_level' => 'residency',
            ],
            [
                'name' => 'Student Premium (3 Months)',
                'sku' => 'student_premium_3months',
                'price' => 1800.00,
                'description' => 'Full academic year access for 3 months.',
                'duration_months' => 3,
                'has_ai_access' => true,
                'access_level' => 'student',
            ],
            [
                'name' => 'Residency Basic (3 Months)',
                'sku' => 'residency_basic_3months',
                'price' => 1200.00,
                'description' => 'Quiz access for 3 months.',
                'duration_months' => 3,
                'has_ai_access' => false,
                'access_level' => 'residency',
            ],
            [
                'name' => 'Student Basic (3 Months)',
                'sku' => 'student_basic_3months',
                'price' => 800.00,
                'description' => 'Academic year quiz access for 3 months.',
                'duration_months' => 3,
                'has_ai_access' => false,
                'access_level' => 'student',
            ],
        ];

        foreach ($plans as $plan) {
            SubscriptionPlan::updateOrCreate(['sku' => $plan['sku']], $plan);
        }
    }
}
