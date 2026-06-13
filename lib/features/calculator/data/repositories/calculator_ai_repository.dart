import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:meducyte_app/core/config/env.dart';
import 'package:meducyte_app/features/calculator/domain/models/medical_score_model.dart';

class CalculatorAiRepository {
  final Dio _dio;
  static const String _apiKey = Env.groqApiKey;
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
        ? "Vous êtes Meducyte AI, un expert médical. Fournissez une analyse clinique brève et professionnelle du résultat de ce score médical. Soyez concis, précis et basé sur des preuves."
        : "You are Meducyte AI, a medical expert. Provide a brief, professional clinical analysis of this medical score result. Be concise, accurate, and evidence-based.";

    final userMessage = lang == 'fr'
        ? "Calculateur: $calculatorName\nScore obtenu: $score\nInterprétation standard: $interpretation\n\nDonnez-moi une analyse clinique approfondie de ce résultat."
        : "Calculator: $calculatorName\nScore obtained: $score\nStandard Interpretation: $interpretation\n\nGive me a deeper clinical analysis of this result.";

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
        ? "Vous êtes Meducyte AI. Résumez l'utilité clinique, les indications et les limites de ce calculateur médical de manière professionnelle."
        : "You are Meducyte AI. Summarize the clinical utility, indications, and limitations of this medical calculator professionally.";

    final userMessage = "Name: $calculatorName\nDescription: $description";

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

  Future<Map<int, int>> autoFillFromClinicalNote({
    required String calculatorName,
    required List<ScoreCriterion> criteria,
    required String clinicalNote,
  }) async {
    final criteriaBuffer = StringBuffer();
    for (int i = 0; i < criteria.length; i++) {
      final c = criteria[i];
      final label = c.question.isNotEmpty ? c.question : c.section;
      criteriaBuffer.writeln("Index $i - Label: '$label'");
      criteriaBuffer.writeln("  Options:");
      for (int j = 0; j < c.options.length; j++) {
        criteriaBuffer.writeln("    Index j=$j: '${c.options[j].label}' (${c.options[j].points} points)");
      }
    }

    final systemPrompt =
        "You are an expert clinical AI. Analyze the patient note and fill out the medical calculator '$calculatorName'.\n"
        "Map each criterion index to the selected option index (integer j).\n\n"
        "Rules:\n"
        "- Select the most appropriate option index (integer j) based on clinical signs. If not mentioned or normal/0, select the appropriate default/baseline index.\n"
        "- Return ONLY a JSON map of index strings to option indexes. Do not include markdown code block formatting or any other text.\n\n"
        "Format Example:\n"
        "{\"0\": 1, \"1\": 0, \"2\": 2}";

    final userMessage =
        "Criteria list:\n"
        "${criteriaBuffer.toString()}\n\n"
        "Patient Clinical Note:\n"
        "\"$clinicalNote\"";

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
          "messages": [
            {"role": "system", "content": systemPrompt},
            {"role": "user", "content": userMessage},
          ],
          "temperature": 0.1,
          "max_tokens": 600,
        },
      );

      if (response.statusCode == 200) {
        final content = response.data['choices'][0]['message']['content'].toString().trim();
        final cleanContent = content.replaceAll(RegExp(r'^```json\s*|```$'), '').trim();
        final Map<String, dynamic> parsed = jsonDecode(cleanContent);

        final Map<int, int> result = {};
        parsed.forEach((key, val) {
          final idx = int.tryParse(key);
          final optVal = int.tryParse(val.toString());
          if (idx != null && optVal != null) {
            result[idx] = optVal;
          }
        });
        return result;
      } else {
        throw Exception("Failed to query AI for score auto-fill");
      }
    } catch (e) {
      throw Exception("AI clinical extraction failed: $e");
    }
  }

  Future<CalculatorEngineSchema> generateSchemaForCalculator({
    required String calculatorName,
    String? description,
    String? url,
  }) async {
    String? htmlContent;
    if (url != null && url.isNotEmpty) {
      try {
        final htmlResponse = await _dio.get(
          url,
          options: Options(
            responseType: ResponseType.plain,
            headers: {
              "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36",
            },
          ),
        );
        if (htmlResponse.statusCode == 200) {
          htmlContent = htmlResponse.data?.toString();
          htmlContent = htmlContent?.replaceAll(RegExp(r'<script\b[^<]*(?:(?!<\/script>)<[^<]*)*<\/script>', caseSensitive: false), '');
          htmlContent = htmlContent?.replaceAll(RegExp(r'<style\b[^<]*(?:(?!<\/style>)<[^<]*)*<\/style>', caseSensitive: false), '');
          if (htmlContent != null && htmlContent.length > 15000) {
            htmlContent = htmlContent.substring(0, 15000);
          }
        }
      } catch (e) {
        // Fallback silently if fetching fails
      }
    }

    final systemPrompt =
        "You are an expert clinical informatics system. Your task is to generate a structured medical calculator schema (CalculatorEngineSchema) for the calculator named '$calculatorName'.\n"
        "If HTML page content from a medical calculator page (such as medicalcul.free.fr) is provided below, inspect it carefully to extract the exact criteria, options, point allocations, calculations, and interpretations.\n"
        "Generate all the standard clinical criteria (with options/points/numeric values) and standard score interpretations.\n\n"
        "Rules:\n"
        "- The 'criteria' list contains the inputs. Each criterion has: 'label', 'type' (must be 'radio', 'checkbox', or 'numeric'), and:\n"
        "  * For 'radio': an 'options' array, where each option has 'label' and 'points' (number).\n"
        "  * For 'checkbox': a 'points' number (points added if checked).\n"
        "  * For 'numeric': a 'unit' string and 'default_value' number.\n"
        "- The 'interpretations' list contains the scoring ranges: each has 'min' (number), 'max' (number), 'label' (string), and 'color' (one of: 'green', 'orange', 'red').\n"
        "- Include 'interpretation_text' explaining the clinical usage or guidelines.\n\n"
        "Format: Return ONLY a raw JSON object. Do not include markdown code block formatting (like ```json ... ```) or any other text. Example:\n"
        "{\n"
        "  \"criteria\": [\n"
        "    {\n"
        "      \"label\": \"Systolic Blood Pressure\",\n"
        "      \"type\": \"radio\",\n"
        "      \"options\": [\n"
        "        {\"label\": \"< 90 mmHg\", \"points\": 3},\n"
        "        {\"label\": \"90-100 mmHg\", \"points\": 1},\n"
        "        {\"label\": \"> 100 mmHg\", \"points\": 0}\n"
        "      ]\n"
        "    }\n"
        "  ],\n"
        "  \"interpretations\": [\n"
        "    {\"min\": 0, \"max\": 0, \"label\": \"Low Risk\", \"color\": \"green\"},\n"
        "    {\"min\": 1, \"max\": 3, \"label\": \"High Risk\", \"color\": \"red\"}\n"
        "  ],\n"
        "  \"interpretation_text\": \"Use with caution in elderly patients...\"\n"
        "}";

    final userMessageBuffer = StringBuffer();
    userMessageBuffer.writeln("Calculator Name: $calculatorName");
    if (description != null && description.isNotEmpty) {
      userMessageBuffer.writeln("Description: $description");
    }
    if (htmlContent != null && htmlContent.isNotEmpty) {
      userMessageBuffer.writeln("\nHere is the scraped HTML content of the calculator webpage on medicalcul.free.fr:\n");
      userMessageBuffer.writeln(htmlContent);
    } else {
      userMessageBuffer.writeln("\n(No scraped HTML content available, generate based on medical knowledge/literature for '$calculatorName')");
    }

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
          "messages": [
            {"role": "system", "content": systemPrompt},
            {"role": "user", "content": userMessageBuffer.toString()},
          ],
          "temperature": 0.2,
          "max_tokens": 1500,
        },
      );

      if (response.statusCode == 200) {
        final content = response.data['choices'][0]['message']['content'].toString().trim();
        final cleanContent = content.replaceAll(RegExp(r'^```json\s*|```$'), '').trim();
        final Map<String, dynamic> jsonMap = jsonDecode(cleanContent);
        return CalculatorEngineSchema.fromJson(jsonMap);
      } else {
        throw Exception("Failed to query AI for calculator schema");
      }
    } catch (e) {
      throw Exception("AI schema generation failed: $e");
    }
  }
}

class CalculatorEngineSchema {
  final List<CalculatorCriterion> criteria;
  final List<ScoreInterpretation> interpretations;
  final String? interpretationText;

  CalculatorEngineSchema({
    required this.criteria,
    required this.interpretations,
    this.interpretationText,
  });

  factory CalculatorEngineSchema.fromJson(Map<String, dynamic> json) {
    return CalculatorEngineSchema(
      criteria: (json['criteria'] as List)
          .map((c) => CalculatorCriterion.fromJson(c))
          .toList(),
      interpretations: (json['interpretations'] as List)
          .map((i) => ScoreInterpretation.fromJson(i))
          .toList(),
      interpretationText: json['interpretation_text'],
    );
  }
}

class CalculatorCriterion {
  final String label;
  final String type;
  final double? points;
  final List<CriterionOption>? options;
  final String? unit;
  final double? defaultValue;
  final String? value;

  CalculatorCriterion({
    required this.label,
    required this.type,
    this.points,
    this.options,
    this.unit,
    this.defaultValue,
    this.value,
  });

  factory CalculatorCriterion.fromJson(Map<String, dynamic> json) {
    return CalculatorCriterion(
      label: json['label'] ?? '',
      type: json['type'] ?? '',
      points: json['points']?.toDouble(),
      unit: json['unit'],
      defaultValue: json['default_value']?.toDouble(),
      value: json['value'],
      options: json['options'] != null
          ? (json['options'] as List)
                .map((o) => CriterionOption.fromJson(o))
                .toList()
          : null,
    );
  }
}

class CriterionOption {
  final String label;
  final double points;

  CriterionOption({required this.label, required this.points});

  factory CriterionOption.fromJson(Map<String, dynamic> json) {
    return CriterionOption(
      label: json['label'] ?? '',
      points: (json['points'] ?? 0).toDouble(),
    );
  }
}

class ScoreInterpretation {
  final double min;
  final double max;
  final String label;
  final String? color;

  ScoreInterpretation({
    required this.min,
    required this.max,
    required this.label,
    this.color,
  });

  factory ScoreInterpretation.fromJson(Map<String, dynamic> json) {
    return ScoreInterpretation(
      min: (json['min'] ?? 0).toDouble(),
      max: (json['max'] ?? 0).toDouble(),
      label: json['label'] ?? '',
      color: json['color'],
    );
  }
}
