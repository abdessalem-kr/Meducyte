import 'package:meducyte_app/export.dart';
import 'package:meducyte_app/features/simulation/domain/models/simulation_models.dart';
import 'package:meducyte_app/features/simulation/data/repositories/simulation_repository.dart';

//Current active simulation session
final simSessionProvider =
    StateNotifierProvider<SimSessionNotifier, AsyncValue<SimSession>>((ref) {
      return SimSessionNotifier(ref);
    });

class SimSessionNotifier extends StateNotifier<AsyncValue<SimSession>> {
  final Ref ref;
  SimSessionNotifier(this.ref) : super(const AsyncValue.loading());

  Future<void> startNewSession({
    required String pathologyId,
    required SimulationDifficulty difficulty,
    required SimulationSetting setting,
  }) async {
    state = const AsyncValue.loading();
    try {
      final session = await ref
          .read(simulationRepositoryProvider)
          .startSession(
            pathologyId: pathologyId,
            difficulty: difficulty,
            setting: setting,
          );
      state = AsyncValue.data(session);
    } catch (e, s) {
      state = AsyncValue.error(e, s);
    }
  }

  Future<void> sendMessage(String text) async {
    final currentSession = state.value;
    if (currentSession == null || currentSession.isFinished) return;

    final userMessage = SimMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: text,
      isFromUser: true,
      timestamp: DateTime.now(),
    );

    final updatedMessages = [...currentSession.messages, userMessage];
    state = AsyncValue.data(
      currentSession.copyWith(messages: updatedMessages, isTyping: true),
    );

    try {
      final aiMessage = await ref
          .read(simulationRepositoryProvider)
          .sendMessage(currentSession.id, text);

      state = AsyncValue.data(
        currentSession.copyWith(
          messages: [...updatedMessages, aiMessage],
          isTyping: false,
        ),
      );
    } catch (e) {
      state = AsyncValue.data(currentSession.copyWith(isTyping: false));
      // Handle error (e.g., add an error message to the chat)
    }
  }

  void revealInterpretation(String messageId) {
    final currentSession = state.value;
    if (currentSession == null) return;

    final updatedMessages = currentSession.messages.map((m) {
      if (m.id == messageId) {
        return m.copyWith(isRevealed: true);
      }
      return m;
    }).toList();

    state = AsyncValue.data(currentSession.copyWith(messages: updatedMessages));
  }

  void performPhysicalExam(String maneuver) async {
    final currentSession = state.value;
    if (currentSession == null || currentSession.isFinished) return;

    state = AsyncValue.data(currentSession.copyWith(isTyping: true));

    try {
      final response = await ref
          .read(simulationRepositoryProvider)
          .performAction(currentSession.id, 'exam', maneuver);

      debugPrint('[SIM] performPhysicalExam response for "$maneuver": $response');
      var media = _extractMedia(response);

      // Fallback: look up media from the patient case definition (fuzzy match)
      media ??= _findMediaInCase(currentSession.patientCase, maneuver);
      debugPrint('[SIM] final media for "$maneuver": $media');

      // DATA INTEGRITY SAFEGUARD: Ensure Auscultation is always treated as Audio
      // This prevents the common bug where backend might return an ECG image for an auscultation request.
      if (maneuver.toLowerCase().contains("auscultation") && media != null) {
        if (media.type != MediaType.audio) {
          media = media.copyWith(type: MediaType.audio);
        }
      }

      final systemMsg = SimMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        text: "[EXAM] $maneuver",
        isFromUser: false,
        timestamp: DateTime.now(),
        media: media,
        rawResult:
            response['result'] ??
            "Clinical examination of $maneuver performed.",
        interpretation: response['finding'],
        isRevealed: false,
      );

      state = AsyncValue.data(
        currentSession.copyWith(
          messages: [...currentSession.messages, systemMsg],
          isTyping: false,
        ),
      );
    } catch (e) {
      state = AsyncValue.data(currentSession.copyWith(isTyping: false));
    }
  }

  void orderLabTest(String test) async {
    final currentSession = state.value;
    if (currentSession == null || currentSession.isFinished) return;

    state = AsyncValue.data(currentSession.copyWith(isTyping: true));

    try {
      final response = await ref
          .read(simulationRepositoryProvider)
          .performAction(currentSession.id, 'lab', test);

      debugPrint('[SIM] orderLabTest response for "$test": $response');
      var media = _extractMedia(response);

      // Fallback: look up media from the patient case definition (fuzzy match)
      media ??= _findMediaInCase(currentSession.patientCase, test);
      debugPrint('[SIM] final media for "$test": $media');

      final systemMsg = SimMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        text: "[LAB] $test",
        isFromUser: false,
        timestamp: DateTime.now(),
        media: media,
        rawResult:
            response['result'] ?? "Investigation results for $test ready.",
        interpretation: response['finding'],
        isRevealed: false,
      );

      state = AsyncValue.data(
        currentSession.copyWith(
          messages: [...currentSession.messages, systemMsg],
          isTyping: false,
        ),
      );
    } catch (e) {
      state = AsyncValue.data(currentSession.copyWith(isTyping: false));
    }
  }

  Future<void> submitDiagnosis(String diagnosis) async {
    final currentSession = state.value;
    if (currentSession == null) return;

    state = AsyncValue.data(currentSession.copyWith(isTyping: true));

    try {
      final response = await ref
          .read(simulationRepositoryProvider)
          .submitDiagnosis(currentSession.id, diagnosis);

      state = AsyncValue.data(
        currentSession.copyWith(
          isFinished: true,
          isTyping: false,
          userDiagnosis: diagnosis,
          score: response['score'] as int,
          feedback: response['feedback'] as String,
        ),
      );
    } catch (e) {
      state = AsyncValue.data(currentSession.copyWith(isTyping: false));
    }
  }

  /// Resilient media extraction that handles multiple backend response shapes:
  /// 1. Nested object: { "media": { "url": "...", "type": "ecg" } }
  /// 2. Top-level fields: { "media_url": "...", "media_type": "ecg" }
  /// 3. Top-level with 'url': { "url": "...", "type": "ecg", "result": "..." }
  ClinicalMedia? _extractMedia(Map<String, dynamic> response) {
    try {
      // Strategy 1: nested 'media' map
      final mediaValue = response['media'];
      if (mediaValue is Map<String, dynamic>) {
        debugPrint('[SIM] _extractMedia: found nested media map: $mediaValue');
        return ClinicalMedia.fromJson(mediaValue);
      }

      // Strategy 2: top-level media_url or image_url
      final topUrl = response['media_url'] ?? response['image_url'];
      if (topUrl is String && topUrl.isNotEmpty) {
        debugPrint('[SIM] _extractMedia: found top-level media_url: $topUrl');
        return ClinicalMedia.fromJson({
          'url': topUrl,
          'type': response['media_type'] ?? response['type'] ?? 'image',
          'title': response['title'],
        });
      }

      debugPrint('[SIM] _extractMedia: no media found in response');
      return null;
    } catch (e) {
      debugPrint('[SIM] _extractMedia ERROR: $e — response keys: ${response.keys.toList()}');
      return null;
    }
  }

  /// Fuzzy lookup of media from the patient case's mediaFindings map.
  /// Handles mismatches like "ECG (12-Lead)" vs "ECG", localized names, etc.
  ClinicalMedia? _findMediaInCase(PatientCase patientCase, String name) {
    final findings = patientCase.mediaFindings;
    if (findings.isEmpty) return null;

    // 1. Exact match
    if (findings.containsKey(name)) {
      debugPrint('[SIM] _findMediaInCase: exact match for "$name"');
      return findings[name];
    }

    // 2. Case-insensitive match
    final lower = name.toLowerCase();
    for (final entry in findings.entries) {
      if (entry.key.toLowerCase() == lower) {
        debugPrint('[SIM] _findMediaInCase: case-insensitive match "${entry.key}" for "$name"');
        return entry.value;
      }
    }

    // 3. Contains match: "ECG (12-Lead)" contains "ECG", "Chest X-Ray" contains "X-Ray"
    for (final entry in findings.entries) {
      final keyLower = entry.key.toLowerCase();
      if (lower.contains(keyLower) || keyLower.contains(lower)) {
        debugPrint('[SIM] _findMediaInCase: fuzzy match "${entry.key}" for "$name"');
        return entry.value;
      }
    }

    debugPrint('[SIM] _findMediaInCase: no match for "$name" in keys: ${findings.keys.toList()}');
    return null;
  }
}

//Sample cases(These would normally come from a repository/backend)
final samplePatientCasesProvider = Provider<List<PatientCase>>((ref) {
  return [
    const PatientCase(
      id: 'case_001',
      name: 'John Doe',
      age: 58,
      gender: 'M',
      mainComplaint: 'Chest pain and shortness of breath',
      occupation: 'Taxi Driver',
      medicalHistory: 'Hypertension, Smoker (20 years)',
      personality: 'Anxious',
      targetPathology: 'Acute Myocardial Infarction',
      secretDetails: 'The pain radiates to the left jaw and arm.',
      expectedFindings: ['ST-segment elevation', 'Troponin elevation'],
      initialVitals: Vitals(
        heartRate: 105,
        bloodPressure: '150/95',
        temperature: 37,
        spo2: 94,
        respiratoryRate: 22,
      ),
      physicalExamResults: {
        'Auscultation': 'Listen carefully to the heart sounds.',
        'Palpation': 'No chest wall tenderness.',
        'Jugular Venous Pressure': 'Mildly elevated.',
      },
      labResults: {
        'Troponin': 'Elevated (0.5 ng/mL)',
        'ECG': 'Inspect the ST segments.',
        'Chest X-Ray': 'Review lung fields.',
      },
      mediaFindings: {
        'Auscultation': ClinicalMedia(
          url:
              'https://www.med.umich.edu/lrc/psb_open/html/repo/sounds/s4_gallop.mp3',
          type: MediaType.audio,
          title: 'Heart Auscultation haha',
        ),
        'ECG': ClinicalMedia(
          url: 'https://upload.wikimedia.org/wikipedia/commons/thumb/b/bd/12_Lead_EKG_ST_Elevation_trridge.jpg/600px-12_Lead_EKG_ST_Elevation_trridge.jpg',
          type: MediaType.ecg,
          title: 'ECG Strip - 12 Lead',
        ),
        'Chest X-Ray': ClinicalMedia(
          url:
              'https://prod-images-static.radiopaedia.org/images/157210/66448301d00d463e26ca446d33f789_gallery.jpg',
          type: MediaType.image,
          title: 'Chest Radiograph (PA View)',
        ),
      },
    ),
  ];
});

final simCasesProvider = FutureProvider<List<SimCaseSummary>>((ref) async {
  return ref.watch(simulationRepositoryProvider).getCases();
});
