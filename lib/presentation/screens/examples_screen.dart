import 'package:flutter/material.dart';

class ExamplesScreen extends StatefulWidget {
  final String personaId;
  final List<String> initialExamples;

  const ExamplesScreen({
    super.key,
    required this.personaId,
    this.initialExamples = const [],
  });

  @override
  State<ExamplesScreen> createState() => _ExamplesScreenState();
}

class _ExamplesScreenState extends State<ExamplesScreen> {
  late final TextEditingController _controller;
  late List<String> _examples;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _examples = List<String>.from(widget.initialExamples);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _addExample() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _examples.add(text);
      _controller.clear();
    });
  }

  void _removeExample(int idx) {
    setState(() => _examples.removeAt(idx));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Examples for Expert'),
        centerTitle: true,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context, _examples);
          },
          icon: const Icon(Icons.close),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              maxLines: 3,
              minLines: 1,
              decoration: const InputDecoration(
                hintText: 'Example assistant response (e.g. "Ah, Paris has endless magic...")',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: _addExample,
                  icon: const Icon(Icons.add),
                  label: const Text('Add Example'),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context, _examples);
                  },
                  child: const Text('Save'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Expanded(
              child: _examples.isEmpty
                  ? const Center(child: Text('No examples yet'))
                  : ListView.builder(
                      itemCount: _examples.length,
                      itemBuilder: (context, index) {
                        final text = _examples[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          child: ListTile(
                            title: Text(text),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.redAccent),
                              onPressed: () => _removeExample(index),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
