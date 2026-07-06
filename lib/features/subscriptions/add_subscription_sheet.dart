import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app/theme.dart';
import '../../models/models.dart';
import 'subscriptions_controller.dart';

Future<void> showAddSubscriptionSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const _AddSubscriptionSheet(),
  );
}

class _AddSubscriptionSheet extends ConsumerStatefulWidget {
  const _AddSubscriptionSheet();

  @override
  ConsumerState<_AddSubscriptionSheet> createState() => _AddSubscriptionSheetState();
}

class _AddSubscriptionSheetState extends ConsumerState<_AddSubscriptionSheet> {
  final _nameController = TextEditingController();
  final _costController = TextEditingController();
  final _notesController = TextEditingController();
  SubscriptionStatus _selectedStatus = SubscriptionStatus.active;
  bool _isLoading = false;

  double get _cost => double.tryParse(_costController.text) ?? 0.0;
  bool get _isValid =>
      _nameController.text.trim().isNotEmpty && _cost > 0.0;

  @override
  void dispose() {
    _nameController.dispose();
    _costController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _submit() async {
    if (!_isValid || _isLoading) return;

    setState(() => _isLoading = true);

    final now = DateTime.now();
    final nameStr = _nameController.text.trim();
    final notesStr = _notesController.text.trim().isNotEmpty
        ? _notesController.text.trim()
        : (_selectedStatus == SubscriptionStatus.active ? 'Used regularly' : 'Hardly used');

    final sub = Subscription(
      id: 'sub_${now.millisecondsSinceEpoch}',
      name: nameStr,
      monthlyCost: _cost,
      annualCost: _cost * 12,
      category: 'Other',
      billingCycle: 'monthly',
      nextBillingDate: now.add(const Duration(days: 30)),
      lastUsed: now.subtract(const Duration(days: 2)),
      usageFrequency: _selectedStatus == SubscriptionStatus.active ? 'daily' : 'rarely',
      status: _selectedStatus,
      notes: notesStr,
    );

    try {
      await ref.read(subscriptionsControllerProvider.notifier).addSubscription(sub);
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error adding subscription: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cfo = context.cfoColors;
    final bottomPad = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      decoration: BoxDecoration(
        color: cfo.cardSurface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border.all(color: const Color(0xFF1B2036), width: 0.5),
      ),
      padding: EdgeInsets.fromLTRB(24, 8, 24, 24 + bottomPad),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle bar
          Center(
            child: Container(
              width: 36,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: cfo.mutedSlate.withOpacity(0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Title
          Text(
            'ADD SUBSCRIPTION',
            style: context.uiHeader.copyWith(letterSpacing: 1.2, fontSize: 15),
          ),
          const SizedBox(height: 24),

          // Subscription name
          _FieldLabel('Subscription name'),
          const SizedBox(height: 8),
          _SheetTextField(
            controller: _nameController,
            hint: 'e.g. Netflix, Spotify',
            cfo: cfo,
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 20),

          // Monthly cost
          _FieldLabel('Monthly cost'),
          const SizedBox(height: 8),
          _SheetTextField(
            controller: _costController,
            hint: '0',
            prefix: '₹',
            cfo: cfo,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}'))
            ],
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 20),

          // Usage status selector
          _FieldLabel('Usage Status'),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _StatusSelectorOption(
                  label: 'Active (Frequently Used)',
                  isSelected: _selectedStatus == SubscriptionStatus.active,
                  cfo: cfo,
                  onTap: () => setState(() => _selectedStatus = SubscriptionStatus.active),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatusSelectorOption(
                  label: 'Underused / Duplicate',
                  isSelected: _selectedStatus == SubscriptionStatus.underused,
                  cfo: cfo,
                  onTap: () => setState(() => _selectedStatus = SubscriptionStatus.underused),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Usage details notes
          _FieldLabel('Usage Notes (Reason for recommendation)'),
          const SizedBox(height: 8),
          _SheetTextField(
            controller: _notesController,
            hint: _selectedStatus == SubscriptionStatus.active
                ? 'e.g. Used daily for music and podcasts'
                : 'e.g. Watched only 1 show this month',
            cfo: cfo,
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 28),

          // Submit button
          AnimatedOpacity(
            duration: const Duration(milliseconds: 200),
            opacity: _isValid && !_isLoading ? 1.0 : 0.4,
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isValid && !_isLoading ? _submit : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFC9A44C),
                  foregroundColor: const Color(0xFF0B0E1A),
                  disabledBackgroundColor: const Color(0xFFC9A44C),
                  disabledForegroundColor: const Color(0xFF0B0E1A),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Color(0xFF0B0E1A),
                        ),
                      )
                    : Text(
                        'Add subscription',
                        style: context.uiHeader.copyWith(
                          fontSize: 15,
                          color: const Color(0xFF0B0E1A),
                          letterSpacing: 0.4,
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.label);
  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label.toUpperCase(),
      style: context.uiLabel.copyWith(fontSize: 10, letterSpacing: 0.8),
    );
  }
}

class _SheetTextField extends StatelessWidget {
  const _SheetTextField({
    required this.controller,
    required this.hint,
    required this.cfo,
    required this.onChanged,
    this.prefix,
    this.keyboardType,
    this.inputFormatters,
  });

  final TextEditingController controller;
  final String hint;
  final String? prefix;
  final CFOColors cfo;
  final ValueChanged<String> onChanged;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      keyboardType: keyboardType ?? TextInputType.text,
      inputFormatters: inputFormatters,
      style: context.uiLabel.copyWith(fontSize: 15, color: cfo.warmWhite),
      decoration: InputDecoration(
        hintText: hint,
        prefixText: prefix,
        prefixStyle: context.uiLabel.copyWith(
            fontSize: 15, color: cfo.mutedSlate),
        hintStyle: context.uiLabel.copyWith(
            fontSize: 15, color: cfo.mutedSlate.withOpacity(0.6)),
        filled: true,
        fillColor: cfo.canvas,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFF1B2036), width: 0.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFF1B2036), width: 0.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide:
              const BorderSide(color: Color(0xFFC9A44C), width: 1.0),
        ),
      ),
    );
  }
}

class _StatusSelectorOption extends StatelessWidget {
  const _StatusSelectorOption({
    required this.label,
    required this.isSelected,
    required this.cfo,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final CFOColors cfo;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFFC9A44C).withOpacity(0.12)
              : cfo.canvas,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? const Color(0xFFC9A44C) : const Color(0xFF1B2036),
            width: isSelected ? 1.0 : 0.5,
          ),
        ),
        child: Center(
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: context.uiLabel.copyWith(
              fontSize: 11,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              color: isSelected ? const Color(0xFFC9A44C) : cfo.mutedSlate,
            ),
          ),
        ),
      ),
    );
  }
}
