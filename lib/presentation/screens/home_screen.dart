import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/data/models/query.dart';
import 'package:frontend/presentation/cubits/chat_cubit/chat_cubit.dart';
import 'package:frontend/presentation/screens/examples_screen.dart';
import 'package:frontend/widgets/temperature_slider.dart';
import 'package:frontend/widgets/token_counter.dart';
import '../../data/repositories/llm_repository.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ChatCubit(repository: LlmRepository()),
      child: const HomeScreenWidget(),
    );
  }
}

class HomeScreenWidget extends StatefulWidget {
  const HomeScreenWidget({super.key});

  @override
  State<HomeScreenWidget> createState() => _HomeScreenWidgetState();
}

class _HomeScreenWidgetState extends State<HomeScreenWidget> {
  final TextEditingController _textController = TextEditingController();
  final FocusNode _textFocusNode = FocusNode();

  double _temperature = 0.2;
  int _maxTokens = 300;
  String? _selectedPersona;
  List<String> examples = [];

  // Available personas
  final List<Map<String, dynamic>> _personas = [
    {
      'id': 'it_developer',
      'title': 'IT Developer Expert',
      'icon': Icons.code,
      'color': Colors.blue,
      'gradient': [Colors.blue.shade400, Colors.blue.shade800],
    },
    {
      'id': 'funny_person',
      'title': 'Funny Person',
      'icon': Icons.emoji_emotions,
      'color': Colors.orange,
      'gradient': [Colors.orange.shade400, Colors.deepOrange],
    },
    {
      'id': 'medical_expert',
      'title': 'Medical Expert',
      'icon': Icons.medical_services,
      'color': Colors.red,
      'gradient': [Colors.red.shade400, Colors.red.shade800],
    },
    {
      'id': 'travel_expert',
      'title': 'Travel Expert',
      'icon': Icons.flight_takeoff,
      'color': Colors.green,
      'gradient': [Colors.green.shade400, Colors.green.shade800],
    },
    {
      'id': 'love_expert',
      'title': 'Love Expert',
      'icon': Icons.favorite,
      'color': Colors.pink,
      'gradient': [Colors.pink.shade300, Colors.pink.shade700],
    },
    {
      'id': 'food_expert',
      'title': 'Food Expert',
      'icon': Icons.restaurant,
      'color': Colors.amber,
      'gradient': [Colors.amber.shade500, Colors.orange.shade700],
    },
    {
      'id': 'sport_expert',
      'title': 'Sport Expert',
      'icon': Icons.sports_soccer,
      'color': Colors.purple,
      'gradient': [Colors.purple.shade400, Colors.purple.shade800],
    },
  ];

  @override
  void dispose() {
    _textController.dispose();
    _textFocusNode.dispose();
    super.dispose();
  }

  void _sendMessage() {
    if (_textController.text.trim().isEmpty) return;

    final cubit = context.read<ChatCubit>();
    final query = Query(
      text: _textController.text,
      temperature: _temperature,
      maxTokens: _maxTokens,
      persona: _selectedPersona,
      examples: examples.map((e) => Message(role: 'example', content: e)).toList(),
    );

    cubit.sendMessage(query);
    _textController.clear();
    _textFocusNode.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Expert AI Assistant'),
        centerTitle: true,
        elevation: 2,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: _showAdvancedSettings,
            tooltip: 'Advanced Settings',
          ),
        ],
      ),
      body: BlocConsumer<ChatCubit, ChatState>(
        listener: (context, state) {
          if (state is ChatFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error: ${state.error}'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          return Column(
            children: [
              // Selected Persona Badge
              if (_selectedPersona != null) _buildSelectedPersonaBadge(),

              // Chat History
              Expanded(
                child: _buildChatHistory(state),
              ),

              // Controls Section
              _buildControlsSection(state),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSelectedPersonaBadge() {
    final persona = _personas.firstWhere(
      (p) => p['id'] == _selectedPersona,
      orElse: () => _personas[0],
    );

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: persona['gradient'] as List<Color>,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(persona['icon'] as IconData, size: 16, color: Colors.white),
          const SizedBox(width: 8),
          Text(
            persona['title'] as String,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: () => setState(() => _selectedPersona = null),
            child: const Icon(Icons.close, size: 14, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildChatHistory(ChatState state) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: SingleChildScrollView(
        reverse: true,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Instructions
            if (state is ChatInitial) _buildInstructions(),

            // Loading State
            if (state is ChatLoading) _buildLoadingIndicator(),

            // Success State
            if (state is ChatSuccess) _buildResponse(state),
          ],
        ),
      ),
    );
  }

  Widget _buildInstructions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Card(
          color: Colors.blue.shade50,
          child: const Padding(
            padding: EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.lightbulb_outline, color: Colors.blue, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'How to get the best answers:',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Text('• Select an expert persona for specialized knowledge'),
                Text('• Adjust temperature for creativity (lower = more factual)'),
                Text('• Maximum 300 tokens ensures concise, focused responses'),
                Text('• Be specific in your questions for better answers'),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildLoadingIndicator() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(
            'Thinking like ${_selectedPersona != null ? _personas.firstWhere((p) => p['id'] == _selectedPersona)['title'] : 'an expert'}...',
            style: TextStyle(color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  Widget _buildResponse(ChatSuccess state) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.psychology,
                  color: Colors.deepPurple,
                  size: 20,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Expert Response:',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                const Spacer(),
                TokenCounter(tokens: state.response.tokensUsed ?? 0),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              state.response.output,
              style: const TextStyle(fontSize: 14, height: 1.5),
            ),
            const SizedBox(height: 8),
            Divider(color: Colors.grey.shade300),
            Row(
              children: [
                const Icon(Icons.info_outline, size: 14, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  'Tokens used: ${state.response.tokensUsed ?? 'N/A'}',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.content_copy, size: 16),
                  onPressed: () {
                    Clipboard.setData(
                      ClipboardData(text: state.response.output),
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Copied to clipboard')),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControlsSection(ChatState state) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade300)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Persona Selection
          _buildPersonaSelection(),

          const SizedBox(height: 16),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ExamplesScreen(
                    personaId: _selectedPersona ?? '',
                    initialExamples: examples,
                  ),
                ),
              ).then(
                (value) {
                  if (value != null && value is List<String>) {
                    setState(() {
                      examples = value;
                    });
                  }
                },
              );
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  examples.isEmpty ? Icons.add : Icons.edit,
                  size: 16,
                  color: Colors.purple,
                ),
                const SizedBox(width: 4),
                Text(
                  examples.isNotEmpty
                      ? 'Edit examples - ${examples.length} added examples'
                      : 'Preffer to add examples - tap here',
                  style: TextStyle(
                    color: Colors.purple.shade600,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Temperature Control
          TemperatureSlider(
            value: _temperature,
            onChanged: (value) => setState(() => _temperature = value),
          ),

          const SizedBox(height: 16),

          // Input Field
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _textController,
                  focusNode: _textFocusNode,
                  maxLines: 3,
                  minLines: 1,
                  decoration: InputDecoration(
                    hintText: _selectedPersona != null
                        ? 'Ask the ${_personas.firstWhere((p) => p['id'] == _selectedPersona)['title']}...'
                        : 'Ask anything...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.send),
                      onPressed: _sendMessage,
                      color: Colors.blue,
                    ),
                  ),
                  onSubmitted: (_) => _sendMessage(),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Token Counter and Send Button
          Row(
            children: [
              TokenCounter(
                tokens: _estimateTokens(_textController.text),
                maxTokens: _maxTokens,
                showWarning: true,
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: state is ChatLoading || _textController.text.isEmpty ? null : _sendMessage,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: state is ChatLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation(Colors.white),
                        ),
                      )
                    : const Row(
                        children: [
                          Text('Ask Expert'),
                          SizedBox(width: 8),
                          Icon(Icons.arrow_forward, size: 18),
                        ],
                      ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPersonaSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Select Expert Persona:',
          style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
        ),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: _personas.map((persona) {
              final isSelected = _selectedPersona == persona['id'];
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(persona['title'] as String),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      _selectedPersona = selected ? persona['id'] as String : null;
                    });
                  },
                  avatar: Icon(
                    persona['icon'] as IconData,
                    size: 16,
                    color: isSelected ? Colors.white : persona['color'] as Color,
                  ),
                  backgroundColor: Colors.grey.shade100,
                  selectedColor: persona['color'] as Color,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : Colors.black,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide(
                      color: isSelected ? persona['color'] as Color : Colors.grey.shade300,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  int _estimateTokens(String text) {
    // Rough estimation: ~4 characters per token for English text
    return (text.length / 4).ceil();
  }

  void _showAdvancedSettings() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Advanced Settings',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 20),

                  // Max Tokens Slider
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Text('Max Tokens:'),
                          const Spacer(),
                          Text(
                            '$_maxTokens',
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                      Slider(
                        value: _maxTokens.toDouble(),
                        min: 50,
                        max: 500,
                        divisions: 9,
                        label: _maxTokens.toString(),
                        onChanged: (value) {
                          setModalState(() {
                            _maxTokens = value.round();
                          });
                          setState(() {
                            _maxTokens = value.round();
                          });
                        },
                      ),
                      const Text(
                        'Lower values = more concise responses',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Reset Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _temperature = 0.2;
                          _maxTokens = 300;
                          _selectedPersona = null;
                        });
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey.shade100,
                        foregroundColor: Colors.black,
                      ),
                      child: const Text('Reset to Defaults'),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
