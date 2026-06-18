import 'package:flutter/material.dart';
import '../../../core/constants.dart';
import '../../../core/responsive.dart';

class ChatPaperScreen extends StatefulWidget {
  const ChatPaperScreen({super.key});

  @override
  State<ChatPaperScreen> createState() => _ChatPaperScreenState();
}

class _ChatPaperScreenState extends State<ChatPaperScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, dynamic>> _messages = [
    {
      'isUser': false,
      'text': 'Hello! I\'ve analyzed "Attention Is All You Need". What would you like to know about it?',
    },
    {
      'isUser': true,
      'text': 'What is the main contribution of this paper?',
    },
    {
      'isUser': false,
      'text': 'The main contribution is the introduction of the Transformer, a new simple network architecture based solely on attention mechanisms, dispensing with recurrence and convolutions entirely. This allows for significantly more parallelization and reduced training time.',
    },
  ];

  void _sendMessage() {
    if (_controller.text.trim().isEmpty) return;
    setState(() {
      _messages.add({
        'isUser': true,
        'text': _controller.text.trim(),
      });
      final userText = _controller.text;
      _controller.clear();
      
      // Simulate AI response
      Future.delayed(const Duration(seconds: 1), () {
        if (!mounted) return;
        setState(() {
          _messages.add({
            'isUser': false,
            'text': 'That\'s an insightful question about "${userText}". Based on the paper\'s findings, this approach improves BLEU scores on translation tasks while being more efficient than previous state-of-the-art models.',
          });
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Chat with Paper', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              Text('Attention Is All You Need', style: TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
            onPressed: () => Navigator.pop(context),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh_rounded, size: 20),
              onPressed: () {
                setState(() {
                  _messages.removeRange(3, _messages.length);
                });
              },
            ),
          ],
        ),
        body: Column(
          children: [
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(AppSpacing.md),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final msg = _messages[index];
                  return _buildMessageBubble(msg['text'], msg['isUser']);
                },
              ),
            ),
            _buildInputArea(),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageBubble(String text, bool isUser) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.md),
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 12),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.8),
        decoration: BoxDecoration(
          color: isUser 
              ? AppColors.primary 
              : (isDark ? const Color(0xFF1E1E2C) : Colors.grey.shade100),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isUser ? 16 : 0),
            bottomRight: Radius.circular(isUser ? 0 : 16),
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isUser 
                ? Colors.white 
                : (isDark ? AppColors.textDarkPrimary : AppColors.textLightPrimary),
            fontSize: 14,
            height: 1.4,
          ),
        ),
      ),
    );
  }

  Widget _buildInputArea() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        border: Border(
          top: BorderSide(color: isDark ? Colors.white10 : Colors.grey.shade200),
        ),
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                style: const TextStyle(fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'Ask a question about this paper...',
                  hintStyle: const TextStyle(fontSize: 14),
                  filled: true,
                  fillColor: isDark ? const Color(0xFF12121A) : Colors.grey.shade100,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                ),
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
            const SizedBox(width: 10),
            Container(
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
                onPressed: _sendMessage,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
