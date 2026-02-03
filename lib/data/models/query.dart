import 'package:equatable/equatable.dart';

class Query extends Equatable {
  final String? text;
  final List<Message>? messages;
  final double temperature;
  final double topP;
  final int maxTokens;
  final String? persona; // Add persona field
  final String reasoningEffort;
  final int? seed;
  final List<String>? stop;

  const Query({
    this.text,
    this.messages,
    this.temperature = 0.2,
    this.topP = 0.95,
    this.maxTokens = 300, // Set default to 300 as requested
    this.persona, // Add persona
    this.reasoningEffort = 'none',
    this.seed,
    this.stop,
  });

  Map<String, dynamic> toJson() => {
        if (text != null) 'text': text,
        if (messages != null)
          'messages': messages?.map((m) => m.toJson()).toList(),
        'temperature': temperature,
        'top_p': topP,
        'max_tokens': maxTokens,
        if (persona != null) '_persona': persona, // Include persona in payload
        'reasoning_effort': reasoningEffort,
        if (seed != null) 'seed': seed,
        if (stop != null) 'stop': stop,
      };

  Query copyWith({
    String? text,
    List<Message>? messages,
    double? temperature,
    double? topP,
    int? maxTokens,
    String? persona,
    String? reasoningEffort,
    int? seed,
    List<String>? stop,
  }) {
    return Query(
      text: text ?? this.text,
      messages: messages ?? this.messages,
      temperature: temperature ?? this.temperature,
      topP: topP ?? this.topP,
      maxTokens: maxTokens ?? this.maxTokens,
      persona: persona ?? this.persona,
      reasoningEffort: reasoningEffort ?? this.reasoningEffort,
      seed: seed ?? this.seed,
      stop: stop ?? this.stop,
    );
  }

  @override
  List<Object?> get props => [
        text,
        messages,
        temperature,
        topP,
        maxTokens,
        persona,
        reasoningEffort,
        seed,
        stop,
      ];
}

class Message extends Equatable {
  final String role;
  final String content;

  const Message({
    required this.role,
    required this.content,
  });

  Map<String, dynamic> toJson() => {
        'role': role,
        'content': content,
      };

  @override
  List<Object?> get props => [role, content];
}