<?php

namespace App\Http\Controllers\Api\Simulation;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\Simulation\SimulationCase;
use App\Models\Simulation\SimulationSession;
use App\Models\Simulation\SimulationMessage;
use Illuminate\Support\Str;

class SimulationController extends Controller
{
    public function cases()
    {
        return SimulationCase::all(['pathology_id', 'module_name', 'summary', 'target_pathology']);
    }

    public function start(Request $request)
    {
        $request->validate([
            'pathology_id' => 'required|string',
            'difficulty' => 'required|string',
            'setting' => 'required|string',
        ]);

        $case = SimulationCase::where('pathology_id', $request->pathology_id)->first();
        if (!$case) {
            return response()->json(['message' => 'Pathology not found'], 404);
        }

        $session = SimulationSession::create([
            'user_id' => $request->user()->id,
            'simulation_case_id' => $case->id,
            'difficulty' => $request->difficulty,
            'setting' => $request->setting,
            'current_vitals' => $case->initial_vitals,
        ]);

        $briefing = SimulationMessage::create([
            'session_id' => $session->id,
            'text' => "The patient is ready for your assessment in the " . Str::headline($request->setting) . ".",
            'is_from_user' => false,
            'timestamp' => now(),
        ]);

        return response()->json([
            'id' => $session->id,
            'patientCase' => $case,
            'messages' => [$briefing],
            'difficulty' => $session->difficulty,
            'setting' => $session->setting,
            'isFinished' => false,
        ]);
    }

    public function chat(Request $request)
    {
        $request->validate([
            'session_id' => 'required|uuid',
            'message' => 'required|string',
        ]);

        $session = SimulationSession::findOrFail($request->session_id);
        
        // Save user message
        SimulationMessage::create([
            'session_id' => $session->id,
            'text' => $request->message,
            'is_from_user' => true,
        ]);

        // Generate AI Response (Simulated logic for now, could call OpenAI/etc)
        $query = strtolower($request->message);
        $case = $session->case;
        $responseText = "I'm not sure I understand, doctor. I just feel very unwell.";

        if (str_contains($query, 'hello')) {
            $responseText = "Hello doctor. Thank you for seeing me.";
        } else if (str_contains($query, 'pain')) {
            $responseText = "It's a heavy pressure, right in the center of my chest.";
        } else if (str_contains($query, 'history')) {
            $responseText = "I have " . $case->medical_history . ".";
        }

        $aiMessage = SimulationMessage::create([
            'session_id' => $session->id,
            'text' => $responseText,
            'is_from_user' => false,
        ]);

        return response()->json($aiMessage);
    }

    public function action(Request $request)
    {
        $request->validate([
            'session_id' => 'required|uuid',
            'type' => 'required|string',
            'name' => 'required|string',
        ]);

        $session = SimulationSession::findOrFail($request->session_id);
        $case = $session->case;

        $rawResult = null;
        $media = null;
        $interpretation = null;

        if ($request->type == 'exam') {
            $rawResult = $case->physical_exam_results[$request->name] ?? "Physical examination performed.";
            $media = $case->media_findings[$request->name] ?? null;
            $interpretation = $this->getInterpretation($case, $request->name);
        } else {
            $rawResult = $case->lab_results[$request->name] ?? "Diagnostic tracing performed.";
            $media = $case->media_findings[$request->name] ?? null;
            $interpretation = $this->getInterpretation($case, $request->name);
        }

        return response()->json([
            'result' => $rawResult,
            'media' => $media,
            'finding' => $interpretation,
        ]);
    }

    private function getInterpretation($case, $action)
    {
        if ($case->pathology_id == 'stemi') {
            if ($action == 'ECG (12-Lead)') return "ST-elevation in leads V1-V4 consistent with Anterolateral MI.";

            if (str_contains($action, 'Troponin')) return "Markedly elevated Troponin levels indicating myocardial necrosis.";
        }
        if ($case->pathology_id == 'pneumonia') {
            if ($action == 'Chest X-Ray') return "Right lower lobe consolidation with air bronchograms.";
        }
        return "Results are within expected limits for this clinical context.";
    }

    public function evaluate(Request $request)
    {
        $request->validate([
            'session_id' => 'required|uuid',
            'diagnosis' => 'required|string',
        ]);

        $session = SimulationSession::findOrFail($request->session_id);
        $case = $session->case;

        $isCorrect = str_contains(strtolower($request->diagnosis), strtolower($case->target_pathology));
        
        $session->update([
            'is_finished' => true,
            'score' => $isCorrect ? 95 : 30,
            'feedback' => $isCorrect 
                ? "Excellent work. You correctly identified the {$case->target_pathology}."
                : "The clinical presentation was more consistent with {$case->target_pathology}.",
        ]);

        return response()->json([
            'score' => $session->score,
            'feedback' => $session->feedback,
        ]);
    }
}
