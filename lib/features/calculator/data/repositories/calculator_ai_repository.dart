import 'package:dio/dio.dart';

class CalculatorAiRepository {
  final Dio _dio;
  static const String _apiKey =
      "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";
  static const String _groqUrl =
      "https://api.groq.com/openai/v1/chat/completions";
  static const String _modelName = "llama-3.3-70b-versatile";

  CalculatorAiRepository(this._dio);

  Future<String> getClinicalInsight({
    required String calculatorName,
    required double score,
    required String interpretation,
    required String lang,
  }) async {
    final systemPrompt = lang == 'fr'
        ? "Vousêtes Meducyte AI,un expert médical.Fournissez une analyse clinique brève et professionnelle du résultat de ce score médical.Soyez concis,précis et basésur des preuves."
        : "You are Meducyte AI,a medical expert.Provide a brief,professional clinical analysis of this medical score result.Be concise,accurate,and evidence-based.";

    final userMessage = lang == 'fr'
        ? "Calculateur: $calculatorName\nScore obtenu: $score\nInterprétation standard: $interpretation\n\nDonnez-moi une analyse clinique approfondie de ce résultat."
        : "Calculator: $calculatorName\nScore obtained: $score\nStandard Interpretation: $interpretation\n\nGive me a deeper clinical analysis of this result.";

    try {
      final response = await _dio.post(
        _groqUrl,
        options: Options(
          headers: {
            "Authorization": "Bearer$_apiKey",
            "Content-Type": "application/json",
          },
        ),
        data: {
          "model": _modelName,
          "messages": [
            {"role": "system", "content": systemPrompt},
            {"role": "user", "content": userMessage},
          ],
          "temperature": 0.5,
          "max_tokens": 500,
        },
      );

      if (response.statusCode == 200) {
        return response.data['choices'][0]['message']['content'];
      } else {
        throw Exception("Failed to get AI insight");
      }
    } catch (e) {
      return "AI Insight currently unavailable: $e";
    }
  }

  Future<String> getCalculatorSummary({
    required String calculatorName,
    required String description,
    required String lang,
  }) async {
    final systemPrompt = lang == 'fr'
        ? "Vousêtes Meducyte AI.Résumez l'utilitéclinique,les indications et les limites de ce calculateur médical de manière professionnelle."
        : "You are Meducyte AI.Summarize the clinical utility,indications,and limitations of this medical calculator professionally.";

    final userMessage = "Name: $calculatorName\nDescription: $description";

    try {
      final response = await _dio.post(
        _groqUrl,
        options: Options(
          headers: {
            "Authorization": "Bearer$_apiKey",
            "Content-Type": "application/json",
          },
        ),
        data: {
          "model": _modelName,
          "messages": [
            {"role": "system", "content": systemPrompt},
            {"role": "user", "content": userMessage},
          ],
          "temperature": 0.3,
        },
      );

      if (response.statusCode == 200) {
        return response.data['choices'][0]['message']['content'];
      }
      return description;
    } catch (e) {
      return description;
    }
  }
}
