import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class AIService {
  GenerativeModel? _model;
  bool _useFallback = false;

  AIService() {
    var apiKey = dotenv.env['GEMINI_API_KEY'];
    if (apiKey != null) {
      apiKey = apiKey.trim();
      if (apiKey.startsWith('"') && apiKey.endsWith('"')) {
        apiKey = apiKey.substring(1, apiKey.length - 1);
      } else if (apiKey.startsWith("'") && apiKey.endsWith("'")) {
        apiKey = apiKey.substring(1, apiKey.length - 1);
      }
      apiKey = apiKey.trim();
    }

    if (apiKey == null || apiKey.isEmpty || apiKey == 'your_api_key_here') {
      debugPrint('⚠️  GEMINI_API_KEY is not set or placeholder. Falling back to static insights.');
      _useFallback = true;
    } else {
      try {
        _model = GenerativeModel(
          model: 'gemini-2.5-flash',
          apiKey: apiKey,
          generationConfig: GenerationConfig(
            temperature: 0.2,
          ),
        );
      } catch (e) {
        debugPrint('Error initializing GenerativeModel: $e');
        _useFallback = true;
      }
    }
  }

  static const String _systemPrompt = '''
You are Finley, a calm, trustworthy, and empathetic personal financial advisor embedded in the CFO app.
Rules:
1. Only use the numbers and facts given to you in the context below. Never invent, extrapolate, or estimate numbers not provided.
2. Be concise: 2-4 sentences unless specifically asked for more detail.
3. Every recommendation should implicitly answer: what should the user do, why, and what happens if they follow it.
4. Never pressure the user into a financial decision. Acknowledge uncertainty if the data provided is incomplete.
5. Use simple, warm, plain language. No jargon unless the user's question uses it first.
6. Address the user by name (Karthik) if appropriate.
7. Speak in a helpful narrative voice.
''';

  /// Calls the Gemini model or returns fallback text on failure or when key is missing.
  Future<String> _generateResponse(String prompt, String fallback) async {
    if (_useFallback || _model == null) {
      // Simulate network delay for realistic feel even in fallback mode
      await Future.delayed(const Duration(milliseconds: 600));
      return fallback;
    }

    try {
      final response = await _model!.generateContent([
        Content.text('$_systemPrompt\n\n$prompt'),
      ]).timeout(const Duration(seconds: 8));

      final text = response.text;
      if (text != null && text.trim().isNotEmpty) {
        return text.trim();
      }
      return fallback;
    } catch (e) {
      debugPrint('Gemini API call failed: $e. Using fallback.');
      return fallback;
    }
  }

  // ── daily briefing ──────────────────────────────────────────
  Future<String> generateDailyBriefing(Map<String, dynamic> context) async {
    final name = context['name'] ?? 'Karthik';
    final balance = context['balance'] ?? '₹0';
    final budgetUsedPercent = context['budgetUsedPercent'] ?? '0%';
    final nearestGoalName = context['nearestGoalName'] ?? 'MacBook Air';
    final nearestGoalProgress = context['nearestGoalProgress'] ?? '0%';
    final urgentBillName = context['urgentBillName'] ?? 'Electricity Bill';
    final urgentBillAmount = context['urgentBillAmount'] ?? '₹0';
    final urgentBillDays = context['urgentBillDays'] ?? '3';
    final bestCard = context['bestCard'] ?? 'HDFC Millennia';

    final prompt = '''
Generate a morning briefing paragraph for the user.
Context:
- User: $name
- Available Balance: $balance
- Budget Used: $budgetUsedPercent of monthly limit
- Goal Progress: "$nearestGoalName" is $nearestGoalProgress complete
- Urgent Upcoming Outflow: "$urgentBillName" of $urgentBillAmount is due in $urgentBillDays days
- Card recommendation: Use $bestCard for shopping today for cashbacks

Write a warm, concise 3-sentence summary that highlights their balance, alerts them about the upcoming bill, and gives them a quick tip about using the right card.
''';

    final fallback = 'Good morning, Karthik. You have $balance available in your primary account. Your budget is $budgetUsedPercent used this month. Please keep in mind that your $urgentBillName of $urgentBillAmount is due in $urgentBillDays days; I recommend using your $bestCard to pay it or make shopping purchases to maximize reward points.';
    
    return _generateResponse(prompt, fallback);
  }

  // ── financial chat ──────────────────────────────────────────
  Future<String> generateChatResponse(
    String userMessage,
    List<Map<String, String>> history,
    Map<String, dynamic> context,
  ) async {
    final recentTx = (context['recent_transactions'] as List<dynamic>?)
            ?.map((t) => '- ${t.date.split("T").first}: ${t.merchant} (${t.category}) | ${t.type == "credit" ? "+" : "-"}₹${t.amount}')
            .join('\n') ?? 
        'No recent transactions found.';

    final goals = (context['goals'] as List<dynamic>?)
            ?.map((g) => '- ${g.name}: Target ₹${g.targetAmount}, Saved ₹${g.savedAmount} (${g.progressPercent.toStringAsFixed(1)}% done)')
            .join('\n') ?? 
        'No active goals.';

    final subs = (context['subscriptions'] as List<dynamic>?)
            ?.map((s) => '- ${s.name}: ₹${s.monthlyCost}/mo (${s.status} usage)')
            .join('\n') ?? 
        'No active subscriptions.';

    final historyText = history
        .map((m) => '${m['role'] == 'user' ? 'User' : 'Finley'}: ${m['content']}')
        .join('\n');

    final prompt = '''
User Question: "$userMessage"

Conversation History:
$historyText

Active Financial Data Context:
Current Balance: ${context['balance']}
Monthly Income Avg: ${context['monthly_income_avg']}
Income Type: ${context['income_type']}

Goals:
$goals

Active Subscriptions:
$subs

Recent 15 Transactions:
$recentTx

Answer the user's question directly and concisely. Ensure you ground your answer only in the facts and numbers above.
''';

    // Generative fallback logic based on query content
    String fallback = "I've analyzed your financial profile. You currently have a balance of ${context['balance']} with an average income of ${context['monthly_income_avg']}. If you're planning a purchase or wanting to optimize, we can look at cancelling underused subscriptions like Netflix, or adjust your categories.";
    
    final lower = userMessage.toLowerCase();
    if (lower.contains('afford') || lower.contains('buy')) {
      fallback = "Based on your current balance of ${context['balance']} and your upcoming bills due soon, you can afford smaller purchases. However, making a large purchase like an iPhone right now would set back your MacBook Air goal projection by approximately 45 days unless you increase your freelance income.";
    } else if (lower.contains('food') || lower.contains('swiggy') || lower.contains('zomato')) {
      fallback = "You spent ₹4,250 on Zomato and Swiggy in the last 30 days, showing a 15% increase compared to last month. Most of this spend occurs on weekend evenings. Trimming just two Swiggy orders a week would save you roughly ₹1,800 monthly.";
    } else if (lower.contains('subscription') || lower.contains('netflix')) {
      fallback = "You have 5 subscriptions costing ₹1,206 total per month. Netflix is flagged as underused because you've only watched 2 shows in the last 3 months. Cancelling it would instantly save you ₹649/mo (₹7,788/yr).";
    }

    return _generateResponse(prompt, fallback);
  }

  // ── spending analysis ──────────────────────────────────────
  Future<String> generateSpendingNarrative(Map<String, dynamic> context) async {
    final highestCategory = context['highestCategory'] ?? 'Shopping';
    final highestAmount = context['highestAmount'] ?? '₹12,450';
    final momChange = context['momChange'] ?? '12% increase';
    final swiggyCount = context['swiggyCount'] ?? '14';
    final swiggyTotal = context['swiggyTotal'] ?? '₹4,890';

    final prompt = '''
Generate a concise spending analysis narrative.
Context:
- Highest spending category: $highestCategory at $highestAmount
- Month-over-month change in highest category: $momChange
- Food delivery spikes: $swiggyCount Swiggy/Zomato orders totaling $swiggyTotal
- Focus: Weekend spending behavior

Write 2-4 sentences explaining this spending behavior to Karthik.
''';

    final fallback = 'Your highest spend this month was on $highestCategory at $highestAmount, which represents a $momChange. This was primarily driven by your food delivery habits, with $swiggyCount Swiggy and Zomato orders totaling $swiggyTotal. Shifting Zomato orders to home cooking on weekends could reduce this category by 20% and help fund your MacBook savings goal.';
    
    return _generateResponse(prompt, fallback);
  }

  // ── budget category tips ────────────────────────────────────
  Future<String> generateBudgetTips(String category, Map<String, dynamic> context) async {
    final spent = context['spent'] ?? '₹4,500';
    final budget = context['budget'] ?? '₹5,000';
    final percent = context['percent'] ?? '90%';

    final prompt = '''
The user has spent $spent out of their $budget budget ($percent) on the "$category" category.
Give them a one-sentence warning/tip.
''';

    final fallback = 'You have utilized $percent of your $category budget. I suggest avoiding further optional shopping until the next cycle to avoid overrunning your plan.';
    
    return _generateResponse(prompt, fallback);
  }

  // ── health score explanation ───────────────────────────────
  Future<String> generateHealthScoreReasoning(Map<String, dynamic> context) async {
    final score = context['score'] ?? '72';
    final weakFactor = context['weakFactor'] ?? 'Subscription Efficiency';
    final weakReason = context['weakReason'] ?? 'Underused Netflix subscription costing ₹649/mo';
    final strongFactor = context['strongFactor'] ?? 'Savings Rate';
    final strongReason = context['strongReason'] ?? 'Saved 25% of your freelance income';

    final prompt = '''
The user has a financial health score of $score/100.
Their strongest factor is $strongFactor ($strongReason).
Their weakest factor is $weakFactor ($weakReason).

Provide a concise 2-sentence explanation of what is holding their score back and how they can improve it.
''';

    final fallback = 'Your health score of $score/100 is anchored by a solid $strongFactor ($strongReason). However, your $weakFactor is holding you back due to $weakReason. Cancelling this subscription is the fastest way to boost your score and free up monthly cash.';

    return _generateResponse(prompt, fallback);
  }

  // ── goal impact explanation ─────────────────────────────────
  Future<String> generateGoalImpactExplanation(Map<String, dynamic> context) async {
    final goalName = context['goalName'] ?? 'MacBook Air';
    final amount = context['purchaseAmount'] ?? '₹10,000';
    final delay = context['daysDelayed'] ?? '15';
    final newMonthly = context['newMonthlyRequired'] ?? '₹8,200';

    final prompt = '''
The user is simulating a purchase of $amount.
Impact on goal "$goalName":
- Original target date is delayed by $delay days
- New required monthly savings to hit original target date is $newMonthly

Explain this impact in 2 sentences in simple, warm language.
''';

    final fallback = 'Spending $amount today will delay your "$goalName" target by $delay days. To still purchase it on your original timeline, you will need to save an extra ${newMonthly} per month going forward.';

    return _generateResponse(prompt, fallback);
  }

  // ── subscription manager advice ─────────────────────────────
  Future<String> generateSubscriptionAdvice(Map<String, dynamic> context) async {
    final name = context['name'] ?? 'Netflix';
    final cost = context['cost'] ?? '₹649/mo';
    final status = context['status'] ?? 'underused';
    final reason = context['reason'] ?? 'Watched only 2 shows in 3 months';
    final annualCost = context['annualCost'] ?? '₹7788';

    final prompt = '''
You are a financial advisor assistant. Give a one-sentence recommendation based on the subscription usage:
Subscription: $name
Cost: $cost
Annual Cost: $annualCost
Usage Status: $status ($reason)

Rules:
- If the Usage Status is 'active', recommend keeping or continuing the subscription. Do NOT suggest cancelling it. Example: "I recommend keeping your Spotify Premium subscription (₹119/mo) since you use it daily for music and podcasts."
- If the Usage Status is 'underused' or 'duplicate', recommend cancelling or downgrading it, and explicitly mention the annual savings. Example: "I recommend cancelling your Netflix subscription (₹649/mo) because you watched only 2 shows in the last 3 months. Doing so saves you $annualCost annually."
''';

    final isUsed = status.toLowerCase() == 'active';
    final doubleCostVal = double.tryParse(cost.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0.0;
    final calcAnnual = isUsed ? 0.0 : (double.tryParse(annualCost.replaceAll(RegExp(r'[^0-9.]'), '')) ?? (doubleCostVal * 12));
    final fallback = isUsed 
      ? 'I recommend keeping your $name subscription ($cost) because you have $reason.'
      : 'I recommend cancelling your $name subscription ($cost) because you have $reason. Doing so saves you ₹${calcAnnual.toStringAsFixed(0)} annually.';

    return _generateResponse(prompt, fallback);
  }

  // ── savings simulator summary ───────────────────────────────
  Future<String> generateSavingsSummary(Map<String, dynamic> context) async {
    final scenarios = context['scenarios'] ?? 'cancelling Netflix and cooking on weekends';
    final monthly = context['monthly'] ?? '₹1,500';
    final yearly = context['yearly'] ?? '₹18,000';
    final goalProgress = context['goalProgress'] ?? 'accelerating your MacBook Air goal by 45 days';

    final prompt = '''
User selected these savings strategies: $scenarios
Total simulated savings: $monthly/month ($yearly/year)
Impact: $goalProgress

Provide a concise 2-sentence summary of the impact.
''';

    final fallback = 'By implementing these adjustments ($scenarios), you will accumulate $monthly extra savings each month ($yearly/year). This immediately impacts your goals, $goalProgress.';

    return _generateResponse(prompt, fallback);
  }

  // ── natural language search parser ──────────────────────────
  Future<Map<String, dynamic>> parseSearchIntent(String query) async {
    if (_useFallback || _model == null) {
      return _fallbackSearchIntent(query);
    }

    final prompt = '''
You are a structured intent-parsing engine. Parse the user's natural language search query about their transactions and return a valid JSON object.
Return ONLY valid JSON. No Markdown formatting, no ```json, no extra text.

Fields to extract (all optional, use null if not mentioned):
- "category": String (e.g. "Food & Dining", "Shopping", "Bills & Utilities", "Transport", "Rent", "Subscriptions", "Entertainment", "Investments", "Income")
- "minAmount": Double
- "maxAmount": Double
- "startDate": String (ISO format YYYY-MM-DD)
- "endDate": String (ISO format YYYY-MM-DD)
- "merchant": String (partial match name)

Remember, today is 2026-07-04.
If they say "last month", it means June 2026.
If they say "this year", it means Jan 2026 to Jun 2026.

Query: "$query"
''';

    try {
      final response = await _model!.generateContent([
        Content.text(prompt),
      ]).timeout(const Duration(seconds: 4));

      var text = response.text?.trim() ?? '';
      // Remove any markdown code fence wrappers if present
      if (text.startsWith('```')) {
        final lines = text.split('\n');
        if (lines.first.startsWith('```')) lines.removeAt(0);
        if (lines.isNotEmpty && lines.last.startsWith('```')) lines.removeLast();
        text = lines.join('\n').trim();
      }

      final parsed = jsonDecode(text) as Map<String, dynamic>;
      return parsed;
    } catch (e) {
      debugPrint('Failed to parse search intent via Gemini: $e. Using static fallback parser.');
      return _fallbackSearchIntent(query);
    }
  }

  Map<String, dynamic> _fallbackSearchIntent(String query) {
    final lower = query.toLowerCase();
    final Map<String, dynamic> intent = {};

    // Match categories
    if (lower.contains('food') || lower.contains('restaurant') || lower.contains('swiggy') || lower.contains('zomato')) {
      intent['category'] = 'Food & Dining';
    } else if (lower.contains('shop') || lower.contains('amazon') || lower.contains('flipkart')) {
      intent['category'] = 'Shopping';
    } else if (lower.contains('bill') || lower.contains('utilities') || lower.contains('wifi') || lower.contains('electricity')) {
      intent['category'] = 'Bills & Utilities';
    } else if (lower.contains('travel') || lower.contains('transport') || lower.contains('uber') || lower.contains('ola')) {
      intent['category'] = 'Transport';
    } else if (lower.contains('rent')) {
      intent['category'] = 'Rent';
    } else if (lower.contains('sub')) {
      intent['category'] = 'Subscriptions';
    } else if (lower.contains('invest') || lower.contains('sip')) {
      intent['category'] = 'Investments';
    } else if (lower.contains('income') || lower.contains('salary') || lower.contains('freelance')) {
      intent['category'] = 'Income';
    }

    // Match amounts
    final doublePattern = RegExp(r'₹?\s*(\d+(?:,\d+)*(?:\.\d+)?)');
    final matches = doublePattern.allMatches(query).toList();
    if (matches.isNotEmpty) {
      final val1 = double.tryParse(matches[0].group(1)!.replaceAll(',', ''));
      if (val1 != null) {
        if (lower.contains('above') || lower.contains('greater') || lower.contains('more than') || lower.contains('>')) {
          intent['minAmount'] = val1;
        } else if (lower.contains('below') || lower.contains('less') || lower.contains('<')) {
          intent['maxAmount'] = val1;
        } else {
          intent['minAmount'] = val1;
          intent['maxAmount'] = val1;
        }
      }
    }

    // Match dates
    if (lower.contains('january') || lower.contains('jan')) {
      intent['startDate'] = '2026-01-01';
      intent['endDate'] = '2026-01-31';
    } else if (lower.contains('february') || lower.contains('feb')) {
      intent['startDate'] = '2026-02-01';
      intent['endDate'] = '2026-02-28';
    } else if (lower.contains('march') || lower.contains('mar')) {
      intent['startDate'] = '2026-03-01';
      intent['endDate'] = '2026-03-31';
    } else if (lower.contains('april') || lower.contains('apr')) {
      intent['startDate'] = '2026-04-01';
      intent['endDate'] = '2026-04-30';
    } else if (lower.contains('may')) {
      intent['startDate'] = '2026-05-01';
      intent['endDate'] = '2026-05-31';
    } else if (lower.contains('june') || lower.contains('jun')) {
      intent['startDate'] = '2026-06-01';
      intent['endDate'] = '2026-06-30';
    } else if (lower.contains('last month')) {
      intent['startDate'] = '2026-06-01';
      intent['endDate'] = '2026-06-30';
    }

    // Match merchant keyword
    final merchants = ['swiggy', 'zomato', 'amazon', 'flipkart', 'uber', 'ola', 'netflix', 'spotify', 'act fibernet', 'groww'];
    for (final m in merchants) {
      if (lower.contains(m)) {
        intent['merchant'] = m;
        break;
      }
    }

    return intent;
  }
}

// ── Riverpod Provider ─────────────────────────────────────────

final aiServiceProvider = Provider<AIService>((ref) {
  return AIService();
});
