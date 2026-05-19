import 'package:meducyte_app/export.dart';
import 'package:meducyte_app/shared/providers/network_provider.dart';

class NoteAiRepository {
  final Dio _dio;
  static const String _apiKey =
      "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";
  static const String _groqUrl =
      "https://api.groq.com/openai/v1/chat/completions";
  static const String _modelName = "llama-3.3-70b-versatile";

  NoteAiRepository(this._dio);

  Future<String> getAiResponse({
    required String action,
    required String contextText,
    required String language,
    String? currentNote,
  }) async {
    String languageName = (language == 'fr') ? "French" : "English";

    String systemPrompt =
        "You are Meducyte AI, a professional medical assistant. "
        "Your task is to generate high-yield, well-organized medical content. "
        "IMPORTANT: You MUST write your response in $languageName. "
        "FOR NOTES: return your response ONLY as a valid JSON array representing a Quill Delta. "
        "FOR QUESTIONS/TEXT: If the action involves 'generate_question', 'generate_recall_session', 'generate_answer', or 'generate_cloze_recall', return your response as plain text (or a structured list if multiple items), NOT as a JSON Delta. "
        "Example note format: [{\"insert\":\"Key info\\n\"}] "
        "Only return the required content. No other text, no intro, no outro.";

    String userPrompt = "";

    switch (action) {
      case 'explain':
        userPrompt = language == 'fr'
            ? "Générer une explication médicale structurée et à haut rendement pour : \"$contextText\". Utiliser des en-têtes pour 'Mécanisme' et 'Signification Clinique'."
            : "Generate a structured high-yield medical explanation for: \"$contextText\". Use headers for 'Mechanism' and 'Clinical Significance'.";
        break;
      case 'summarize':
        userPrompt = language == 'fr'
            ? "Résumer ce contenu médical à haut rendement : \"$contextText\". Utiliser une liste à puces et mettre en gras les termes médicaux clés."
            : "Summarize this high-yield medical content: \"$contextText\". Use a bulleted list and bold key medical terms.";
        break;
      case 'mnemonic':
        userPrompt = language == 'fr'
            ? "Créer un moyen mnémotechnique créatif pour : \"$contextText\". Insérer le moyen mnémotechnique dans un bloc formaté distinct ou en gras."
            : "Create a creative mnemonic for: \"$contextText\". Insert the mnemonic in a distinct formatted block or bold style.";
        break;
      case 'refine':
        userPrompt = language == 'fr'
            ? "Affiner ces notes médicales brutes : \"$currentNote\". Utiliser le contexte \"$contextText\" pour garantir l'exactitude et une mise en forme professionnelle."
            : "Refine these rough medical notes: \"$currentNote\". Use the context \"$contextText\" to ensure accuracy and professional formatting.";
        break;
      case 'generate_question':
        userPrompt = language == 'fr'
            ? "Générer une seule question d'étude de haut niveau à partir de ce contenu : \"$contextText\". La question doit tester la compréhension profonde, pas seulement le rappel de faits."
            : "Generate a single high-level study question from this content: \"$contextText\". The question should test deep understanding, not just fact recall.";
        break;
      case 'generate_recall_session':
        userPrompt = language == 'fr'
            ? "Générer 5 questions d'auto-évaluation à haut rendement pour cette leçon : \"$contextText\". Formater chaque question sur une nouvelle ligne commençant par '-'."
            : "Generate 5 high-yield self-assessment questions for this lesson: \"$contextText\". Format each question on a new line starting with '-'.";
        break;
      case 'generate_answer':
        userPrompt = language == 'fr'
            ? "En utilisant ce contenu médical : \"$contextText\", fournir une réponse concise et précise à cette question : \"$currentNote\"."
            : "Using this medical content: \"$contextText\", provide a concise and accurate answer to this question: \"$currentNote\".";
        break;
      case 'generate_cloze_recall':
        userPrompt = language == 'fr'
            ? "Générer EXACTEMENT 3 phrases clés POUR CHAQUE section séparée par '[SECTION]' dans ce contenu : \"$contextText\". Pour chaque phrase, remplacer un terme médical CRUCIAL par [blank]. Formater chaque ligne comme ceci : La [blank] est l'unité de base.|cellule"
            : "Generate EXACTLY 3 key sentences FOR EACH section separated by '[SECTION]' in this content: \"$contextText\". For each sentence, replace one CRUCIAL medical term with [blank]. Format each line like this: The [blank] is the basic unit.|cell";
        break;
      default:
        userPrompt = language == 'fr'
            ? "Organiser ces notes médicales professionnellement en français : \"$contextText\""
            : "Organize these medical notes professionally in English: \"$contextText\"";
    }

    final messages = [
      {"role": "system", "content": systemPrompt},
      {"role": "user", "content": userPrompt},
    ];

    try {
      final response = await _dio.post(
        _groqUrl,
        options: Options(
          headers: {
            "Authorization": "Bearer $_apiKey",
            "Content-Type": "application/json",
          },
        ),
        data: {
          "model": _modelName,
          "messages": messages,
          "temperature": 0.2, // Low temperature for consistent JSON structure
        },
      );

      if (response.statusCode == 200) {
        String content = response.data['choices'][0]['message']['content'];

        if (action == 'generate_question' ||
            action == 'generate_recall_session' ||
            action == 'generate_answer' ||
            action == 'generate_cloze_recall') {
          return content.trim();
        }

        // Robust JSON extraction for Delta actions
        final firstBracket = content.indexOf('[');
        final lastBracket = content.lastIndexOf(']');

        if (firstBracket != -1 &&
            lastBracket != -1 &&
            lastBracket > firstBracket) {
          content = content.substring(firstBracket, lastBracket + 1);
        } else if (content.contains('```json')) {
          content = content.split('```json').last.split('```').first.trim();
        } else if (content.contains('```')) {
          content = content.split('```').last.split('```').first.trim();
        }

        return content.trim();
      } else {
        throw Exception("AI Service Error: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("Groq API Error: $e");
      rethrow;
    }
  }
}

final noteAiRepositoryProvider = Provider<NoteAiRepository>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return NoteAiRepository(dioClient.dio);
});
