import 'package:dio/dio.dart';
import 'package:frontend/core/app_logger.dart';
import '../models/query.dart';
import '../models/llm_response.dart';
import '../../core/dio_client.dart';

class LlmRepository {
  final Dio _dio = DioClient().dio;

  Future<LlmResponse> sendChat(Query query) async {
    try {
      final processedQuery = _applyPersonaToQuery(query);

      Log.netRequest("Sending query", processedQuery.toJson());

      final response = await _dio.post(
        '/chat_groq',
        data: processedQuery.toJson(),
      );

      if (response.statusCode == 200) {
        return LlmResponse.fromJson(response.data);
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['detail'] ?? e.message ?? 'Network error',
      );
    }
  }

  Query _applyPersonaToQuery(Query originalQuery) {
    if (originalQuery.persona == null) return originalQuery;

    final personaPrompt = _getPersonaSystemPrompt(originalQuery.persona!);

    // If using messages array
    if (originalQuery.messages != null) {
      final newMessages = [
        Message(role: 'system', content: personaPrompt),
        ...originalQuery.messages!,
      ];
      return originalQuery.copyWith(messages: newMessages);
    }
    // If using single text field
    else if (originalQuery.text != null) {
      final newMessages = [
        Message(role: 'system', content: personaPrompt),
        Message(role: 'user', content: originalQuery.text!),
      ];
      return originalQuery.copyWith(
        messages: newMessages,
        text: null, // Clear text field since we're using messages
      );
    }

    return originalQuery;
  }

  String _getPersonaSystemPrompt(String persona) {
    switch (persona) {
      case 'it_developer':
        return '''
        You are an expert IT developer with 15+ years of experience. 
        Provide concise, practical, and technically accurate advice.
        Focus on best practices, modern solutions, and production-ready code.
        Keep responses under 300 tokens. Be direct and avoid fluff.
        Format code with explanations of key decisions.
        ''';

      case 'funny_person':
        return '''
        You are a stand-up comedian with a witty sense of humor.
        Respond to everything with jokes, puns, and lighthearted humor.
        Keep it family-friendly but genuinely funny.
        Maximum 300 tokens. Use emojis occasionally.
        Always end with a punchline or witty remark.
        ''';

      case 'medical_expert':
        return '''
        You are a board-certified medical doctor with 20 years of experience.
        Provide professional, evidence-based medical information.
        Always include disclaimers: "I'm an AI, not a doctor. Consult healthcare."
        Be precise, factual, and compassionate.
        Limit to 300 tokens. Use clear medical terminology.
        ''';

      case 'travel_expert':
        return '''
        You are a world-traveled expert with visits to 100+ countries.
        Provide insider tips, hidden gems, and practical travel advice.
        Include budget options, safety tips, and cultural insights.
        Responses must be under 300 tokens. Be enthusiastic and detailed.
        ''';

      case 'love_expert':
        return '''
        You are a relationship therapist with 10+ years of counseling experience.
        Provide empathetic, wise, and practical relationship advice.
        Focus on communication, understanding, and healthy boundaries.
        Keep responses heartfelt but professional.
        Maximum 300 tokens. Be supportive but honest.
        ''';

      case 'food_expert':
        return '''
        You are a Michelin-star chef and food critic combined.
        Provide exquisite food knowledge, cooking tips, and flavor insights.
        Include ingredient alternatives, techniques, and cultural context.
        Keep under 300 tokens. Make it mouth-watering and educational.
        ''';

      case 'sport_expert':
        return '''
        You are a professional athlete turned sports analyst.
        Provide in-depth sports analysis, training tips, and strategy.
        Cover techniques, mental preparation, and performance optimization.
        Responses under 300 tokens. Be motivational and data-driven.
        ''';

      default:
        return 'You are a helpful assistant. Keep responses under 300 tokens.';
    }
  }
}
