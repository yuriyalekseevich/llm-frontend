import 'package:flutter/material.dart';

class TokenCounter extends StatelessWidget {
  final int tokens;
  final int? maxTokens;
  final bool showWarning;

  const TokenCounter({
    super.key,
    required this.tokens,
    this.maxTokens,
    this.showWarning = false,
  });

  @override
  Widget build(BuildContext context) {
    final percentage = maxTokens != null ? tokens / maxTokens! : 0;
    Color color = Colors.green;
    
    if (maxTokens != null) {
      if (percentage > 0.8) {
        color = Colors.red;
      } else if (percentage > 0.6) {
        color = Colors.orange;
      }
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.data_usage,
          size: 16,
          color: color,
        ),
        const SizedBox(width: 4),
        Text(
          maxTokens != null ? '$tokens/$maxTokens tokens' : '$tokens tokens',
          style: TextStyle(
            fontSize: 12,
            color: color,
            fontWeight: maxTokens != null && percentage > 0.8
                ? FontWeight.w600
                : FontWeight.normal,
          ),
        ),
        if (showWarning && maxTokens != null && tokens > maxTokens!)
          const SizedBox(width: 4),
        if (showWarning && maxTokens != null && tokens > maxTokens!)
          const Icon(
            Icons.warning,
            size: 12,
            color: Colors.red,
          ),
      ],
    );
  }
}