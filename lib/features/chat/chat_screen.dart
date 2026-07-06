import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../app/theme.dart';
import 'chat_controller.dart';

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  static const _suggestionChips = [
    'Can I afford an iPhone?',
    'Where is my money going?',
    'How much did I spend on food?',
    'What subscriptions can I cancel?',
  ];

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _sendMessage([String? text]) {
    final msg = text ?? _textController.text;
    if (msg.trim().isEmpty) return;

    ref.read(chatControllerProvider.notifier).sendMessage(msg);
    if (text == null) {
      _textController.clear();
    }
    
    // Allow list view to render new user bubble before scrolling
    Future.delayed(const Duration(milliseconds: 50), _scrollToBottom);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(chatControllerProvider);
    final cfo = context.cfoColors;

    // Scroll to bottom when Finley responds
    ref.listen<ChatState>(chatControllerProvider, (prev, next) {
      if (prev?.messages.length != next.messages.length || next.isLoading) {
        Future.delayed(const Duration(milliseconds: 100), _scrollToBottom);
      }
    });

    return Scaffold(
      backgroundColor: cfo.canvas,
      appBar: AppBar(
        title: Text(
          'ASK FINLEY',
          style: context.uiHeader.copyWith(letterSpacing: 1.0),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // ── Messages list ───────────────────────
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                itemCount: state.messages.length,
                itemBuilder: (context, index) {
                  final msg = state.messages[index];
                  return _buildMessageBubble(msg);
                },
              ),
            ),

            // ── Typing Indicator ────────────────────
            if (state.isLoading)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                child: Row(
                  children: [
                    Icon(Icons.auto_awesome_rounded, size: 14, color: cfo.brassGold),
                    const SizedBox(width: 8),
                    Text(
                      'Finley is analyzing your ledger...',
                      style: context.aiQuoteItalic.copyWith(
                        color: cfo.mutedSlate,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),

            // ── Suggestion Chips ────────────────────
            if (state.messages.length == 1 && !state.isLoading)
              Container(
                height: 40,
                margin: const EdgeInsets.only(bottom: 8),
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: _suggestionChips.length,
                  itemBuilder: (context, index) {
                    final chipText = _suggestionChips[index];
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ActionChip(
                        label: Text(chipText),
                        onPressed: () => _sendMessage(chipText),
                      ),
                    );
                  },
                ),
              ),

            // ── Input box ───────────────────────────
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: cfo.canvas,
                border: Border(
                  top: BorderSide(
                    color: cfo.mutedSlate.withValues(alpha: 0.15),
                    width: 1.0,
                  ),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _textController,
                      style: GoogleFonts.inter(color: cfo.warmWhite, fontSize: 15),
                      cursorColor: cfo.brassGold,
                      onSubmitted: (_) => _sendMessage(),
                      decoration: InputDecoration(
                        hintText: 'Ask Finley a question...',
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        filled: false,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: state.isLoading ? null : () => _sendMessage(),
                    icon: Icon(
                      Icons.arrow_upward_rounded,
                      color: state.isLoading ? cfo.mutedSlate : cfo.brassGold,
                    ),
                    style: IconButton.styleFrom(
                      backgroundColor: cfo.cardSurface,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage msg) {
    final cfo = context.cfoColors;

    if (msg.isUser) {
      // User message: right aligned, cardSurface, Inter
      return Align(
        alignment: Alignment.centerRight,
        child: Container(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.sizeOf(context).width * 0.75,
          ),
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: cfo.cardSurface,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(12),
              bottomLeft: Radius.circular(12),
              topRight: Radius.circular(12),
            ),
          ),
          child: Text(
            msg.content,
            style: GoogleFonts.inter(
              color: cfo.warmWhite,
              fontSize: 14,
              height: 1.4,
            ),
          ),
        ),
      );
    } else {
      // Finley message: left aligned, transparent with gold bar, Fraunces serif
      return Container(
        margin: const EdgeInsets.only(bottom: 24),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 2, right: 12),
              child: Icon(Icons.auto_awesome_rounded, size: 16, color: cfo.brassGold),
            ),
            Expanded(
              child: Container(
                padding: const EdgeInsets.only(left: 12),
                decoration: BoxDecoration(
                  border: Border(
                    left: BorderSide(
                      color: cfo.brassGold.withValues(alpha: 0.3),
                      width: 2.0,
                    ),
                  ),
                ),
                child: Text(
                  msg.content,
                  style: context.aiBody.copyWith(
                    fontSize: 15,
                    height: 1.6,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }
  }
}
