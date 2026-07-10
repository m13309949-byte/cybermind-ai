import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers.dart';
import '../../core/theme/app_theme.dart';

class ChatMessage {
  final String role; // 'user' | 'assistant'
  final String content;
  ChatMessage(this.role, this.content);
}

class ChatViewModel extends StateNotifier<List<ChatMessage>> {
  ChatViewModel(this._ref) : super([]);
  final Ref _ref;
  bool isLoading = false;

  Future<void> send(String text) async {
    if (text.trim().isEmpty) return;
    state = [...state, ChatMessage('user', text)];
    isLoading = true;
    _ref.state; // no-op to keep lints quiet in template

    try {
      final auth = _ref.read(authRepositoryProvider);
      final token = await auth.getIdToken();
      if (token == null) {
        state = [...state, ChatMessage('assistant', 'Please sign in to chat with the AI security assistant.')];
        return;
      }
      final reply = await _ref.read(aiServiceProvider).chat(message: text, userIdToken: token);
      state = [...state, ChatMessage('assistant', reply)];
    } catch (e) {
      state = [...state, ChatMessage('assistant', 'Error: $e')];
    } finally {
      isLoading = false;
    }
  }
}

final chatViewModelProvider =
    StateNotifierProvider.autoDispose<ChatViewModel, List<ChatMessage>>((ref) => ChatViewModel(ref));

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key});
  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    final messages = ref.watch(chatViewModelProvider);
    final vm = ref.read(chatViewModelProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('AI Security Assistant')),
      body: SafeArea(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.all(12),
              child: Text(
                'AI-generated guidance. Not a substitute for professional incident response.',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 11),
                textAlign: TextAlign.center,
              ),
            ),
            Expanded(
              child: messages.isEmpty
                  ? const Center(
                      child: Text('Ask me about phishing, malware, ransomware, or safe practices.',
                          style: TextStyle(color: AppColors.textSecondary)),
                    )
                  : ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: messages.length,
                      itemBuilder: (context, i) {
                        final m = messages[i];
                        final isUser = m.role == 'user';
                        return Align(
                          alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                          child: Container(
                            margin: const EdgeInsets.symmetric(vertical: 6),
                            padding: const EdgeInsets.all(14),
                            constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.78),
                            decoration: BoxDecoration(
                              color: isUser ? AppColors.neonCyan.withOpacity(0.15) : AppColors.surface,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: Text(m.content, style: const TextStyle(height: 1.4)),
                          ),
                        );
                      },
                    ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: const InputDecoration(hintText: 'Ask about phishing, malware, ransomware...'),
                      onSubmitted: (v) {
                        vm.send(v);
                        _controller.clear();
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    onPressed: () {
                      vm.send(_controller.text);
                      _controller.clear();
                    },
                    icon: const Icon(Icons.send_rounded),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
