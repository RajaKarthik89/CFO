import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app/theme.dart';
import '../../models/models.dart';
import 'goals_controller.dart';

// ── Preset icon options ────────────────────────────────────────────────────────

class _IconOption {
  const _IconOption(this.icon, this.key);
  final IconData icon;
  final String key;
}

const _presetIcons = [
  _IconOption(Icons.flag_rounded, 'flag'),
  _IconOption(Icons.laptop_mac_rounded, 'laptop_mac'),
  _IconOption(Icons.flight_takeoff_rounded, 'flight'),
  _IconOption(Icons.shield_rounded, 'shield'),
  _IconOption(Icons.home_rounded, 'home'),
  _IconOption(Icons.directions_car_rounded, 'car'),
  _IconOption(Icons.card_giftcard_rounded, 'gift'),
  _IconOption(Icons.school_rounded, 'education'),
];

// ── Helper ─────────────────────────────────────────────────────────────────────

double _percentSaved(double saved, double target) {
  if (target <= 0) return 0;
  return ((saved / target) * 100).clamp(0, 100);
}

// ── Public entry point ─────────────────────────────────────────────────────────

Future<void> showAddGoalSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const _AddGoalSheet(),
  );
}

// ── Sheet widget ───────────────────────────────────────────────────────────────

class _AddGoalSheet extends ConsumerStatefulWidget {
  const _AddGoalSheet();

  @override
  ConsumerState<_AddGoalSheet> createState() => _AddGoalSheetState();
}

class _AddGoalSheetState extends ConsumerState<_AddGoalSheet> {
  final _nameController = TextEditingController();
  final _targetController = TextEditingController();
  final _savedController = TextEditingController();
  DateTime? _targetDate;
  String _selectedIcon = 'flag';

  double get _target => double.tryParse(_targetController.text) ?? 0;
  double get _saved => double.tryParse(_savedController.text) ?? 0;
  bool get _isValid =>
      _nameController.text.trim().isNotEmpty && _target > 0;

  @override
  void dispose() {
    _nameController.dispose();
    _targetController.dispose();
    _savedController.dispose();
    super.dispose();
  }

  void _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now.add(const Duration(days: 365)),
      firstDate: now.add(const Duration(days: 1)),
      lastDate: DateTime(now.year + 20),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: ColorScheme.dark(
            primary: const Color(0xFFC9A44C),
            surface: const Color(0xFF141A2E),
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _targetDate = picked);
  }

  void _submit() {
    if (!_isValid) return;

    final now = DateTime.now();
    final date = _targetDate ?? now.add(const Duration(days: 365));
    final remaining = (_target - _saved).clamp(0.0, _target);
    final months = date.difference(now).inDays / 30.0;
    final monthly = months > 0 ? remaining / months : remaining;

    final goal = Goal(
      id: 'goal_${now.millisecondsSinceEpoch}',
      name: _nameController.text.trim(),
      targetAmount: _target,
      savedAmount: _saved.clamp(0.0, _target),
      targetDate: date,
      createdDate: now,
      category: 'Custom',
      priority: 'medium',
      monthlyContributionTarget: monthly.toDouble(),
      icon: _selectedIcon,
    );

    ref.read(goalsListProvider.notifier).addGoal(goal);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final cfo = context.cfoColors;
    final pct = _percentSaved(_saved, _target);
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
          // Handle
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
            'ADD GOAL',
            style: context.uiHeader.copyWith(letterSpacing: 1.2, fontSize: 15),
          ),
          const SizedBox(height: 24),

          // Goal name
          _FieldLabel('Goal name', cfo),
          const SizedBox(height: 8),
          _SheetTextField(
            controller: _nameController,
            hint: 'e.g. MacBook Air M3',
            cfo: cfo,
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 20),

          // Icon picker
          _FieldLabel('Icon', cfo),
          const SizedBox(height: 8),
          _IconPicker(
            selected: _selectedIcon,
            cfo: cfo,
            onSelect: (key) => setState(() => _selectedIcon = key),
          ),
          const SizedBox(height: 20),

          // Target amount
          _FieldLabel('Target amount', cfo),
          const SizedBox(height: 8),
          _SheetTextField(
            controller: _targetController,
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

          // Already saved
          _FieldLabel('Already saved (optional)', cfo),
          const SizedBox(height: 8),
          _SheetTextField(
            controller: _savedController,
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

          // Target date
          _FieldLabel('Target date (optional)', cfo),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: _pickDate,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              decoration: BoxDecoration(
                color: cfo.canvas,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFF1B2036), width: 0.5),
              ),
              child: Row(
                children: [
                  Icon(Icons.calendar_today_rounded,
                      size: 16, color: cfo.mutedSlate),
                  const SizedBox(width: 10),
                  Text(
                    _targetDate == null
                        ? 'Select date'
                        : '${_targetDate!.day}/${_targetDate!.month}/${_targetDate!.year}',
                    style: context.uiLabel.copyWith(
                      fontSize: 14,
                      color: _targetDate == null ? cfo.mutedSlate : cfo.warmWhite,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Live progress preview
          if (_target > 0) ...[
            const SizedBox(height: 28),
            _LiveProgressPreview(pct: pct, saved: _saved, target: _target, cfo: cfo, context: context),
          ] else
            const SizedBox(height: 28),

          // Add goal button
          AnimatedOpacity(
            duration: const Duration(milliseconds: 200),
            opacity: _isValid ? 1.0 : 0.4,
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isValid ? _submit : null,
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
                child: Text(
                  'Add goal',
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

// ── Live progress bar inside sheet ─────────────────────────────────────────────

class _LiveProgressPreview extends StatelessWidget {
  const _LiveProgressPreview({
    required this.pct,
    required this.saved,
    required this.target,
    required this.cfo,
    required this.context,
  });

  final double pct;
  final double saved;
  final double target;
  final CFOColors cfo;
  final BuildContext context;

  @override
  Widget build(BuildContext ctx) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Progress preview',
              style: context.uiLabel.copyWith(fontSize: 11),
            ),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              child: Text(
                '${pct.toStringAsFixed(1)}%',
                key: ValueKey(pct.toStringAsFixed(1)),
                style: context.numberMedium.copyWith(
                  color: cfo.brassGold,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: pct / 100),
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOutCubic,
          builder: (_, value, __) => ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: value,
              minHeight: 6,
              backgroundColor: cfo.canvas,
              valueColor: AlwaysStoppedAnimation<Color>(cfo.brassGold),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          '₹${saved.toStringAsFixed(0)} saved of ₹${target.toStringAsFixed(0)} target',
          style: context.uiLabel.copyWith(fontSize: 10, color: cfo.mutedSlate),
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}

// ── Reusable sub-widgets ───────────────────────────────────────────────────────

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.label, this.cfo);
  final String label;
  final CFOColors cfo;

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

class _IconPicker extends StatelessWidget {
  const _IconPicker({
    required this.selected,
    required this.cfo,
    required this.onSelect,
  });

  final String selected;
  final CFOColors cfo;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: _presetIcons.map((opt) {
        final isSelected = selected == opt.key;
        return Expanded(
          child: GestureDetector(
            onTap: () => onSelect(opt.key),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              margin: const EdgeInsets.only(right: 6),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFFC9A44C).withOpacity(0.15)
                    : cfo.canvas,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFFC9A44C)
                      : const Color(0xFF1B2036),
                  width: isSelected ? 1.0 : 0.5,
                ),
              ),
              child: Icon(
                opt.icon,
                size: 20,
                color: isSelected ? const Color(0xFFC9A44C) : cfo.mutedSlate,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
