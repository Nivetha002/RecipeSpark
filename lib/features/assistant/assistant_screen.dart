import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../ingredients/state/ingredient_selection_provider.dart';
import '../profile/state/profile_provider.dart';
import 'assistant_service.dart';
import 'local_cooking_assistant.dart';

class _Msg {
  final String text;
  final bool fromUser;
  final bool isError;
  final String? retryQuestion;
  const _Msg(this.text,
      {required this.fromUser, this.isError = false, this.retryQuestion});
}

class AssistantScreen extends StatefulWidget {
  /// Inject a different service (e.g. a future real AI backend or a test fake).
  final CookingAssistantService? service;
  const AssistantScreen({super.key, this.service});

  @override
  State<AssistantScreen> createState() => _AssistantScreenState();
}

class _AssistantScreenState extends State<AssistantScreen> {
  static const _suggestions = [
    'What can I cook with tomatoes?',
    'Give me a quick breakfast recipe',
    'How can I make pasta creamier?',
    'Suggest healthy dinner options',
  ];

  late final CookingAssistantService _service =
      widget.service ?? LocalCookingAssistant();
  final _controller = TextEditingController();
  final _scroll = ScrollController();
  final _messages = <_Msg>[];
  bool _loading = false;

  @override
  void dispose() {
    _controller.dispose();
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _send(String text) async {
    final q = text.trim();
    if (q.isEmpty || _loading) return;
    final pantry = context.read<IngredientSelectionProvider>().selected;
    setState(() {
      _messages.add(_Msg(q, fromUser: true));
      _loading = true;
      _controller.clear();
    });
    _scrollDown();

    _Msg reply;
    try {
      final r = await _service.ask(q, pantry: pantry);
      reply = _Msg(r.text, fromUser: false);
    } on AssistantException catch (e) {
      reply = _Msg(e.message,
          fromUser: false, isError: true, retryQuestion: q);
    } catch (_) {
      reply = _Msg('Something went wrong. Please try again.',
          fromUser: false, isError: true, retryQuestion: q);
    }
    if (!mounted) return;
    setState(() {
      _messages.add(reply);
      _loading = false;
    });
    _scrollDown();
  }

  void _scrollDown() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.animateTo(_scroll.position.maxScrollExtent,
            duration: const Duration(milliseconds: 250), curve: Curves.easeOut);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final name = context.watch<ProfileProvider>().name;
    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('AI Cooking Assistant',
                      style: Theme.of(context).textTheme.titleLarge),
                  Text('Ask anything about cooking',
                      style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ),
          ),
          if (_service.isDemo)
            Container(
              margin: const EdgeInsets.fromLTRB(16, 10, 16, 0),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.orangeSoft,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, size: 16, color: AppColors.orangeDeep),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Demo mode: answers come from built-in tips. No AI service is connected.',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          Expanded(
            child: _messages.isEmpty
                ? _Welcome(name: name)
                : ListView.builder(
                    controller: _scroll,
                    padding: const EdgeInsets.all(16),
                    itemCount: _messages.length + (_loading ? 1 : 0),
                    itemBuilder: (context, i) {
                      if (i == _messages.length) {
                        return const _Bubble(
                            text: 'Thinking…', fromUser: false, muted: true);
                      }
                      final m = _messages[i];
                      return _Bubble(
                        text: m.text,
                        fromUser: m.fromUser,
                        isError: m.isError,
                        onRetry: m.retryQuestion == null
                            ? null
                            : () => _send(m.retryQuestion!),
                      );
                    },
                  ),
          ),
          SizedBox(
            height: 44,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _suggestions.length,
              separatorBuilder: (_, i) => const SizedBox(width: 8),
              itemBuilder: (context, i) => ActionChip(
                backgroundColor: Colors.white,
                side: const BorderSide(color: AppColors.border),
                avatar: const Icon(Icons.auto_awesome,
                    size: 16, color: AppColors.orange),
                label: Text(_suggestions[i],
                    style: const TextStyle(fontSize: 12)),
                onPressed: _loading ? null : () => _send(_suggestions[i]),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    textInputAction: TextInputAction.send,
                    onSubmitted: _send,
                    decoration:
                        const InputDecoration(hintText: 'Type your question...'),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  tooltip: 'Send',
                  style: IconButton.styleFrom(
                    backgroundColor: AppColors.orange,
                    minimumSize: const Size(48, 48),
                  ),
                  onPressed: _loading ? null : () => _send(_controller.text),
                  icon: const Icon(Icons.send_rounded),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Welcome extends StatelessWidget {
  final String name;
  const _Welcome({required this.name});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 110,
              height: 110,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                  color: AppColors.orangeSoft, shape: BoxShape.circle),
              child: const Text('👨‍🍳', style: TextStyle(fontSize: 56)),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: AppTheme.softShadow,
              ),
              child: Text(
                'Hi ${name.isEmpty ? 'there' : name}! I\'m your cooking assistant. '
                'Ask me for recipe ideas, substitutions and cooking tips.',
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Bubble extends StatelessWidget {
  final String text;
  final bool fromUser;
  final bool isError;
  final bool muted;
  final VoidCallback? onRetry;

  const _Bubble({
    required this.text,
    required this.fromUser,
    this.isError = false,
    this.muted = false,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final bg = fromUser
        ? AppColors.orange
        : (isError ? const Color(0xFFFDECEC) : Colors.white);
    final fg = fromUser
        ? Colors.white
        : (isError ? AppColors.danger : AppColors.textDark);
    return Align(
      alignment: fromUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(12),
        constraints:
            BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.78),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(16),
          boxShadow: fromUser ? null : AppTheme.softShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(text,
                style: TextStyle(
                    color: muted ? AppColors.textMuted : fg, height: 1.35)),
            if (onRetry != null)
              TextButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}
