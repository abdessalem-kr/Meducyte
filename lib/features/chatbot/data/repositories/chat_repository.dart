import 'package:dio/dio.dart';
import 'package:meducyte_app/core/config/env.dart';
import 'package:meducyte_app/features/chatbot/domain/models/chat_models.dart';
import 'package:uuid/uuid.dart';

class ChatRepository {
  final Dio _dio;
  static const String _apiKey = Env.groqApiKey;
  static const String _groqUrl =
      "https://api.groq.com/openai/v1/chat/completions";
  static const String _modelName = "llama-3.3-70b-versatile";

  ChatRepository(this._dio);

  Future<Response> _postWithRetry(
    String url, {
    required Map<String, dynamic> data,
    required Options options,
  }) async {
    int retryCount = 0;
    while (true) {
      try {
        final response = await _dio.post(
          url,
          data: data,
          options: options,
        );
        return response;
      } on DioException catch (e) {
        final statusCode = e.response?.statusCode;
        if (statusCode == 429 && retryCount < 3) {
          retryCount++;
          final delay = Duration(seconds: retryCount * 2);
          await Future.delayed(delay);
          continue;
        }
        rethrow;
      }
    }
  }

  Future<ChatMessage> sendMessage(
    List<ChatMessage> history,
    String message,
  ) async {
    final messages = [
      {
        "role": "system",
        "content":
            "You are Meducyte AI, a professional medical assistant. "
            "STRICT GUIDELINES:\n"
            "1. ONLY answer questions related to medicine, pharmacology, health, or the Meducyte app.\n"
            "2. LANGUAGES: ONLY respond in English or French.\n"
            "3. OFF-SCOPE: If asked about non-medical topics, politely decline.\n"
            "4. PREMIUM LAYOUT & TEXT DESIGN RULES:\n"
            "   - Structure responses using elegant markdown: use descriptive, emoji-prefixed headers (e.g., '### 💡 Signes Cliniques').\n"
            "   - Break information down into bulleted lists or comparison tables rather than dense text paragraphs.\n"
            "   - Bold key medical concepts, medication names, and diagnostic terms for readability.\n"
            "   - Highlight critical alerts, warnings, or 'pearls' using markdown blockquotes (e.g., '> ⚠️ **Alerte:** ...' or '> 💡 **Perle Clinique:** ...').\n"
            "5. ACCURACY: Provide evidence-based medical information.",
      },
      ...history.map(
        (msg) => {
          "role": msg.isUser ? "user" : "assistant",
          "content": msg.text,
        },
      ),
      {"role": "user", "content": message},
    ];

    try {
      final response = await _postWithRetry(
        _groqUrl,
        options: Options(
          headers: {
            "Authorization": "Bearer $_apiKey",
            "Content-Type": "application/json",
          },
        ),
        data: {"model": _modelName, "messages": messages, "temperature": 0.7},
      );

      if (response.statusCode == 200) {
        final data = response.data;
        final content = data['choices'][0]['message']['content'];
        return ChatMessage(
          id: const Uuid().v4(),
          text: content,
          isUser: false,
          timestamp: DateTime.now(),
        );
      } else {
        throw Exception("Failed to get response from AI");
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<ChatMessage> sendObservationChatMessage({
    required List<ChatMessage> history,
    required String message,
    required String observationContext,
  }) async {
    final messages = [
      {
        "role": "system",
        "content":
            "You are Meducyte AI, a clinical tutor and assistant. "
            "Your main role is to analyze the medical data currently entered by the student in their observation report and guide them on how to proceed.\n\n"
            "Current state of the observation report:\n$observationContext\n\n"
            "STRICT GUIDELINES:\n"
            "1. TUTOR & COACH ROLE: Based on the current inputs (vitals, history, exam fields, paraclinical data), identify what is missing or requires further investigation. Guide the student on which clinical signs to check next, which paraclinical exams are indicated, and how to refine their clinical reasoning.\n"
            "2. DATA-DRIVEN FEEDBACK: Actively point out any abnormal values (e.g., severe fever, hypotension, abnormal breath sounds) and recommend immediate steps or checks.\n"
            "3. Keep answers concise, practical, and highly relevant to the provided data. Write in French.\n"
            "4. PREMIUM LAYOUT & TEXT DESIGN RULES:\n"
            "   - Structure responses using elegant markdown: use descriptive, emoji-prefixed headers (e.g., '### 💡 Étapes Suivantes').\n"
            "   - Use comparison tables or structured lists to organize symptoms, signs, and choices.\n"
            "   - Bold key medical concepts, medication names, and diagnostic terms for readability.\n"
            "   - Highlight critical alerts, warnings, or 'pearls' using markdown blockquotes (e.g., '> ⚠️ **Alerte:** ...' or '> 💡 **Perle Clinique:** ...').\n"
            "5. Provide evidence-based medical information.",
      },
      ...history.map(
        (msg) => {
          "role": msg.isUser ? "user" : "assistant",
          "content": msg.text,
        },
      ),
      {"role": "user", "content": message},
    ];

    try {
      final response = await _postWithRetry(
        _groqUrl,
        options: Options(
          headers: {
            "Authorization": "Bearer $_apiKey",
            "Content-Type": "application/json",
          },
        ),
        data: {"model": "llama-3.1-8b-instant", "messages": messages, "temperature": 0.5},
      );

      if (response.statusCode == 200) {
        final data = response.data;
        final content = data['choices'][0]['message']['content'];
        return ChatMessage(
          id: const Uuid().v4(),
          text: content,
          isUser: false,
          timestamp: DateTime.now(),
        );
      } else {
        throw Exception("Failed to get response from AI");
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<ChatMessage> sendDrugInteractionChatMessage({
    required List<ChatMessage> history,
    required String message,
    required String drugContext,
  }) async {
    final messages = [
      {
        "role": "system",
        "content":
            "You are Meducyte AI, a clinical pharmacology assistant. "
            "Your role is to help a medical student analyze drug interactions for the selected medications.\n\n"
            "Currently selected drugs and interactions context:\n$drugContext\n\n"
            "STRICT GUIDELINES:\n"
            "1. PHARMACOLOGY TUTOR ROLE: Help the student understand the pharmacokinetic/pharmacodynamic mechanisms behind these interactions. Suggest safer alternatives or therapeutic modifications.\n"
            "2. CLINICAL QUESTIONS: Answer student queries regarding side effects, contraindications, dosage adjustments, or monitoring parameters.\n"
            "3. Keep answers concise, highly structured, and written in French.\n"
            "4. PREMIUM LAYOUT & TEXT DESIGN RULES:\n"
            "   - Structure responses using elegant markdown: use descriptive, emoji-prefixed headers (e.g., '### 🔬 Mécanisme d'Action').\n"
            "   - Use comparison tables or structured lists to organize symptoms, signs, and choices.\n"
            "   - Bold key medical concepts, medication names, and diagnostic terms for readability.\n"
            "   - Highlight critical alerts, warnings, or 'pearls' using markdown blockquotes (e.g., '> ⚠️ **Alerte:** ...' or '> 💡 **Perle Clinique:** ...').\n"
            "5. Provide evidence-based medical information.",
      },
      ...history.map(
        (msg) => {
          "role": msg.isUser ? "user" : "assistant",
          "content": msg.text,
        },
      ),
      {"role": "user", "content": message},
    ];

    try {
      final response = await _postWithRetry(
        _groqUrl,
        options: Options(
          headers: {
            "Authorization": "Bearer $_apiKey",
            "Content-Type": "application/json",
          },
        ),
        data: {"model": "llama-3.1-8b-instant", "messages": messages, "temperature": 0.5},
      );

      if (response.statusCode == 200) {
        final data = response.data;
        final content = data['choices'][0]['message']['content'];
        return ChatMessage(
          id: const Uuid().v4(),
          text: content,
          isUser: false,
          timestamp: DateTime.now(),
        );
      } else {
        throw Exception("Failed to get response from AI");
      }
    } catch (e) {
      rethrow;
    }
  }
}
