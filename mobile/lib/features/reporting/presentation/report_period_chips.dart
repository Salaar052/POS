import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos_mobile/app/providers/reporting_providers.dart';
import 'package:pos_mobile/app/theme/app_spacing.dart';
import 'package:pos_mobile/features/reporting/domain/pakistan_time.dart';
import 'package:pos_mobile/features/reporting/domain/report_period.dart';

class ReportPeriodChips extends ConsumerWidget {
  const ReportPeriodChips({super.key});

  static const _presets = [
    ReportPeriodPreset.today,
    ReportPeriodPreset.yesterday,
    ReportPeriodPreset.last7Days,
    ReportPeriodPreset.last30Days,
    ReportPeriodPreset.thisMonth,
    ReportPeriodPreset.lastMonth,
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(reportPeriodPresetProvider);
    return Wrap(
      spacing: AppSpacing.xs,
      runSpacing: AppSpacing.xs,
      children: [
        for (final preset in _presets)
          ChoiceChip(
            label: Text(ReportPeriod.fromPreset(preset).label),
            selected: selected.preset == preset,
            onSelected: (_) {
              ref.read(reportPeriodPresetProvider.notifier).setPreset(preset);
            },
          ),
        ChoiceChip(
          label: const Text('Custom range'),
          selected: selected.preset == ReportPeriodPreset.custom,
          onSelected: (_) => _pickCustomRange(context, ref),
        ),
      ],
    );
  }

  Future<void> _pickCustomRange(BuildContext context, WidgetRef ref) async {
    final now = PakistanTime.nowPakistan();
    final initialStart = DateTime(now.year, now.month, now.day);
    final range = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(now.year + 1),
      initialDateRange: DateTimeRange(start: initialStart, end: initialStart),
    );
    if (range == null) {
      return;
    }
    ref
        .read(reportPeriodPresetProvider.notifier)
        .setCustomRange(startPakistan: range.start, endPakistan: range.end);
  }
}
