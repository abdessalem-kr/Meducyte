import 'package:dio/dio.dart';
import 'package:meducyte_app/features/chatbot/domain/models/chat_models.dart';
import 'package:uuid/uuid.dart';

class ChatRepository {
  final Dio _dio;
  static const String _apiKey =
      "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";
  static const String _groqUrl =
      "https://api.groq.com/openai/v1/chat/completions";
  static const String _modelName = "llama-3.3-70b-versatile";

  ChatRepository(this._dio);

  Future<ChatMessage> sendMessage(
    List<ChatMessage> history,
    String message,
  ) async {
    final messages = [
      {
        "role": "system",
        "content":
            "You are Meducyte AI,a professional medical assistant. "
            "STRICT GUIDELINES: "
            "1.ONLY answer questions related to medicine,pharmacology,health,or the Meducyte app itself. "
            "2.LANGUAGES:ONLY respond in English or French.If asked in another language,politely explain in French or English that you only support these two languages. "
            "3.OFF-SCOPE:If a user asks about non-medical topics(politics,entertainment,general trivia,etc.),politely decline and remind them that you are a medical assistant. "
            "4.ACCURACY:Provide evidence-based information.Use Markdown for clarity(tables,lists,bold text).",
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
      final response = await _dio.post(
        _groqUrl,
        options: Options(
          headers: {
            "Authorization": "Bearer$_apiKey",
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
}
