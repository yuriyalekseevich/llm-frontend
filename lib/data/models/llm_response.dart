import 'package:equatable/equatable.dart';

class LlmResponse extends Equatable {
  final String output;
  final int tokensUsed;

  const LlmResponse({
    required this.output,
    required this.tokensUsed,
  });

  factory LlmResponse.fromJson(Map<String, dynamic> json) {
    return LlmResponse(
      output: json['output'] as String,
      tokensUsed: json['tokens_used'] as int,
    );
  }

  @override
  List<Object?> get props => [output, tokensUsed];
}