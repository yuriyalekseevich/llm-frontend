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
    // Early return if no persona → nothing to change
    if (originalQuery.persona == null) {
      return originalQuery;
    }

    final personaPrompt = _getPersonaSystemPrompt(originalQuery.persona!);

    // We'll always build a messages list (it's more powerful and consistent)
    List<Message> messages = [];

    // 1. Always start with system prompt (persona instructions)
    messages.add(
      Message(role: 'system', content: personaPrompt),
    );

    // 2. If user provided examples → add them as a single assistant message
    //    with clear instruction so the model understands it's few-shot examples
    if (originalQuery.examples?.isNotEmpty == true) {
      final rawExamples = originalQuery.examples!.map((e) => e.content.trim()).join('\n---\n');

final assistantContent = '''
**Examples of the exact response style I want you to strictly imitate** (short, condition-based, reasons, no fluff):

$rawExamples

--- END OF EXAMPLES ---

**Now answer the following user question using exactly this format and tone:**
''';

      messages.add(
        Message(role: 'assistant', content: assistantContent.trim()),
      );
    }

    // 3. Add the actual user input (prefer messages > text)
    if (originalQuery.messages != null && originalQuery.messages!.isNotEmpty) {
      // Append existing messages after examples (user might have already added some history)
      messages.addAll(originalQuery.messages!);
    } else if (originalQuery.text != null && originalQuery.text!.trim().isNotEmpty) {
      messages.add(
        Message(role: 'user', content: originalQuery.text!.trim()),
      );
    } else {
      // Edge case: no real user input at all → don't break, but log/warn in real app
      messages.add(
        const Message(role: 'user', content: '[No question provided]'),
      );
    }

    // Return updated query using messages (clear text field to avoid confusion)
    return originalQuery.copyWith(
      messages: messages,
      text: null,
    );
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
