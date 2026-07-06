import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../app/theme.dart';
import '../../widgets/cfo_card.dart';
import '../../widgets/amount_text.dart';
import 'search_controller.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();

  static const _sampleQueries = [
    'Transactions above ₹10,000',
    'Swiggy in June',
    'Shopping in May',
    'Freelance income',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearch([String? text]) {
    final query = text ?? _searchController.text;
    if (text != null) {
      _searchController.text = text;
    }
    ref.read(searchControllerProvider.notifier).executeSearch(query);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(searchControllerProvider);
    final cfo = context.cfoColors;

    return Scaffold(
      backgroundColor: cfo.canvas,
      appBar: AppBar(
        title: Text(
          'NATURAL SEARCH',
          style: context.uiHeader.copyWith(letterSpacing: 1.0),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // ── Search Input ───────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: TextField(
                controller: _searchController,
                style: GoogleFonts.inter(color: cfo.warmWhite, fontSize: 15),
                cursorColor: cfo.brassGold,
                textInputAction: TextInputAction.search,
                onSubmitted: (_) => _onSearch(),
                decoration: InputDecoration(
                  hintText: 'Type to filter e.g., "Swiggy above ₹500"',
                  prefixIcon: Icon(Icons.search_rounded, color: cfo.brassGold, size: 20),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: Icon(Icons.clear_rounded, color: cfo.mutedSlate, size: 18),
                          onPressed: () {
                            _searchController.clear();
                            _onSearch('');
                          },
                        )
                      : null,
                ),
              ),
            ),

            // ── Suggestion Chips ────────────────────
            if (state.activeQuery.isEmpty && !state.isLoading)
              Container(
                height: 40,
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  itemCount: _sampleQueries.length,
                  itemBuilder: (context, index) {
                    final q = _sampleQueries[index];
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ActionChip(
                        label: Text(q),
                        onPressed: () => _onSearch(q),
                      ),
                    );
                  },
                ),
              ),

            // ── Filter Diagnostics Banner ───────────
            if (state.activeFilters.isNotEmpty && !state.isLoading)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _buildDiagnosticChips(state.activeFilters, cfo),
                ),
              ),

            // ── Search Results List ─────────────────
            Expanded(
              child: state.isLoading
                  ? const Center(child: CircularProgressIndicator(color: Color(0xFFC9A44C)))
                  : _buildResultsList(state.results),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultsList(List<dynamic> results) {
    if (_searchController.text.isEmpty) {
      return Center(
        child: Text(
          'Type a query to search transactions',
          style: context.uiLabel,
        ),
      );
    }

    if (results.isEmpty) {
      return Center(
        child: Text(
          'No matching transactions found.',
          style: context.uiLabel,
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      itemCount: results.length,
      itemBuilder: (context, index) {
        final tx = results[index];
        final formattedDate = DateFormat('MMM d, yyyy').format(tx.date);
        final isCredit = tx.type.name == 'credit';

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: CFOCard(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tx.merchant,
                        style: context.uiHeader.copyWith(fontSize: 14),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${tx.category} • $formattedDate',
                        style: context.uiLabel.copyWith(fontSize: 10),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    AmountText(
                      tx.amount,
                      size: AmountSize.medium,
                      type: isCredit ? AmountType.credit : AmountType.debit,
                      showSign: true,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      tx.paymentMethod,
                      style: context.uiLabel.copyWith(fontSize: 9),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  List<Widget> _buildDiagnosticChips(Map<String, dynamic> filters, CFOColors cfo) {
    final List<Widget> chips = [];
    filters.forEach((key, value) {
      if (value != null) {
        String label = '';
        if (key == 'category') label = 'Category: $value';
        if (key == 'merchant') label = 'Query: "$value"';
        if (key == 'minAmount') label = 'Min: ₹${(value as num).toStringAsFixed(0)}';
        if (key == 'maxAmount') label = 'Max: ₹${(value as num).toStringAsFixed(0)}';
        if (key == 'startDate') label = 'From: $value';
        if (key == 'endDate') label = 'To: $value';

        if (label.isNotEmpty) {
          chips.add(
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: cfo.cardSurface,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: cfo.brassGold.withValues(alpha: 0.3), width: 0.5),
              ),
              child: Text(
                label.toUpperCase(),
                style: context.uiLabel.copyWith(fontSize: 9, color: cfo.brassGold, fontWeight: FontWeight.bold),
              ),
            ),
          );
        }
      }
    });
    return chips;
  }
}
