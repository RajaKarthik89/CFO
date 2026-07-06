import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/mock_data_service.dart';
import '../../core/services/ai_service.dart';

class ChatMessage {
  final String content;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({
    required this.content,
    required this.isUser,
    required this.timestamp,
  });
}

class ChatState {
  final List<ChatMessage> messages;
  final bool isLoading;

  ChatState({
    required this.messages,
    required this.isLoading,
  });

  ChatState copyWith({
    List<ChatMessage>? messages,
    bool? isLoading,
  }) {
    return ChatState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class ChatNotifier extends StateNotifier<ChatState> {
  ChatNotifier(this._mockData, this._aiService)
      : super(ChatState(
          messages: [
            ChatMessage(
              content: "Hi Karthik, I'm Finley. Ask me anything about your spending, goals, or budget. For instance, you could ask 'Can I afford an iPhone?' or 'What subscriptions can I cancel?'",
              isUser: false,
              timestamp: DateTime.now(),
            ),
          ],
          isLoading: false,
        ));

  final MockDataService _mockData;
  final AIService _aiService;

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty || state.isLoading) return;

    // 1. Add user message
    final userMsg = ChatMessage(
      content: text,
      isUser: true,
      timestamp: DateTime.now(),
    );

    state = state.copyWith(
      messages: [...state.messages, userMsg],
      isLoading: true,
    );

    try {
      // 2. Build history payload
      final List<Map<String, String>> historyPayload = state.messages.map((m) {
        return {
          'role': m.isUser ? 'user' : 'model',
          'content': m.content,
        };
      }).toList();

      // 3. Build data context
      final goals = _mockData.getGoals();
      final subs = _mockData.getSubscriptions();
      final balance = _mockData.getBalance();
      final profile = _mockData.getUserProfile();

      // Take last 15 transactions
      final recentTx = _mockData.getRecentTransactions(15);

      final contextMap = {
        'balance': '₹${balance.toStringAsFixed(0)}',
        'monthly_income_avg': '₹${profile.monthlyIncomeAvg.toStringAsFixed(0)}',
        'income_type': profile.incomeType,
        'goals': goals.map((g) => {
          'name': g.name,
          'targetAmount': g.targetAmount,
          'savedAmount': g.savedAmount,
          'progressPercent': g.progressPercentage,
        }).toList(),
        'subscriptions': subs.map((s) => {
          'name': s.name,
          'monthlyCost': s.monthlyCost,
          'status': s.status.name,
        }).toList(),
        'recent_transactions': recentTx,
      };

      // 4. Query AI service
      final replyContent = await _aiService.generateChatResponse(
        text,
        historyPayload,
        contextMap,
      );

      final replyMsg = ChatMessage(
        content: replyContent,
        isUser: false,
        timestamp: DateTime.now(),
      );

      state = state.copyWith(
        messages: [...state.messages, replyMsg],
        isLoading: false,
      );
    } catch (e) {
      final errorMsg = ChatMessage(
        content: "I'm sorry, I encountered an issue analyzing your request. Please try again.",
        isUser: false,
        timestamp: DateTime.now(),
      );
      state = state.copyWith(
        messages: [...state.messages, errorMsg],
        isLoading: false,
      );
    }
  }
}

final chatControllerProvider = StateNotifierProvider.autoDispose<ChatNotifier, ChatState>((ref) {
  // Ensure mockDataService is loaded before starting the chat controller
  final mockData = ref.read(mockDataServiceProvider).requireValue;
  final aiService = ref.read(aiServiceProvider);
  return ChatNotifier(mockData, aiService);
});
