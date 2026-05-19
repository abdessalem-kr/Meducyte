<?php

namespace Tests\Feature; // <--- This line was missing

use Tests\TestCase;
use App\Models\Learn\Question;
use App\Models\Learn\LessonBlock;
use Illuminate\Foundation\Testing\RefreshDatabase; // Recommended for feature tests

class QuestionTest extends TestCase
{
    use RefreshDatabase; // Ensures a clean database for every test

    /** @test */
    public function a_question_can_be_deep_linked_to_multiple_blocks()
    {
        // 1. Setup
        $question = Question::factory()->create();
        $blockA = LessonBlock::factory()->create(['type' => 'TEXT']);
        $blockB = LessonBlock::factory()->create(['type' => 'IMAGE']);

        // Attach the blocks (testing the lesson_block_question pivot)
        $question->relatedBlocks()->attach([$blockA->id, $blockB->id]);

        // 2. The GraphQL Query Contract
        $query = '
            query TestQuestion($id: ID!) {
                question(id: $id) {
                    id
                    relatedBlocks {
                        id
                        type
                    }
                }
            }
        ';

        // 3. Execution and Assertions
        $response = $this->graphQL($query, ['id' => $question->id]);

        $response->assertStatus(200); // Check for a successful HTTP response first

        $response->assertJson([
            'data' => [
                'question' => [
                    'relatedBlocks' => [
                        // Order is not guaranteed, so we check content exists
                        ['type' => 'TEXT'], 
                        ['type' => 'IMAGE'],
                    ]
                ]
            ]
        ])
        ->assertJsonCount(2, 'data.question.relatedBlocks');
    }
}