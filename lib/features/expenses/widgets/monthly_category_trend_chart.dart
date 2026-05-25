import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:money_manager/data/repositories/expense_repository.dart';
import 'package:money_manager/features/expenses/widgets/expenses_amount_format.dart';
import 'package:money_manager/share/share.dart';

class MonthlyCategoryTrendChart extends StatelessWidget {
  const MonthlyCategoryTrendChart({
    super.key,
    required this.dailyTotals,
  });

  final List<CategoryDayTotal> dailyTotals;

  @override
  Widget build(BuildContext context) {
    if (dailyTotals.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.s24),
          child: Text(
            AppStrings.expenseCategoryDetailTrendEmpty,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.onSurfaceVariant),
          ),
        ),
      );
    }

    final maxMinor = dailyTotals.fold<int>(0, (m, e) => e.totalMinor > m ? e.totalMinor : m);
    if (maxMinor == 0) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.s24),
          child: Text(
            AppStrings.expenseCategoryDetailTrendEmpty,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.onSurfaceVariant),
          ),
        ),
      );
    }

    final spots = <FlSpot>[
      for (var i = 0; i < dailyTotals.length; i++)
        FlSpot(i.toDouble(), dailyTotals[i].totalMinor.toDouble()),
    ];

    final lastDay = dailyTotals.length;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.only(
        left: AppSpacing.s8,
        right: AppSpacing.s8,
        top: AppSpacing.s16,
        bottom: AppSpacing.s8,
      ),
      child: LineChart(
        LineChartData(
          minY: 0,
          maxY: maxMinor * 1.08,
          /// Curved splines can visually dip below zero between spots even when
          /// all Y values are non-negative; clip + overshoot prevention fix that.
          clipData: const FlClipData.all(),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: maxMinor > 0 ? (maxMinor / 4).ceilToDouble() : 1,
            getDrawingHorizontalLine: (v) => FlLine(
              color: AppColors.outlineVariant.withValues(alpha: 0.35),
              strokeWidth: 1,
            ),
          ),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: AppSpacing.s24,
                interval: lastDay > 20 ? 6 : (lastDay > 10 ? 3 : 2),
                getTitlesWidget: (value, meta) {
                  final i = value.round();
                  if (i < 0 || i >= lastDay) return const SizedBox.shrink();
                  if ((value - i).abs() > 0.01) return const SizedBox.shrink();
                  final day = i + 1;
                  return Padding(
                    padding: const EdgeInsets.only(top: AppSpacing.s8),
                    child: Text(
                      '$day',
                      style: textTheme.labelSmall?.copyWith(color: AppColors.onSurfaceVariant),
                    ),
                  );
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: AppSpacing.s48,
                interval: maxMinor > 0 ? (maxMinor / 4).ceilToDouble() : 1,
                getTitlesWidget: (value, meta) {
                  final v = value.round();
                  if (v < 0) return const SizedBox.shrink();
                  return Text(
                    formatExpenseMinor(context, v),
                    style: textTheme.labelSmall?.copyWith(color: AppColors.onSurfaceVariant),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  );
                },
              ),
            ),
          ),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              preventCurveOverShooting: false,
              color: AppColors.primary,
              barWidth: 2.5,
              isStrokeCapRound: false,
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, percent, bar, index) => FlDotCirclePainter(
                  radius: 3,
                  color: AppColors.primary,
                  strokeWidth: 0,
                ),
              ),
              belowBarData: BarAreaData(
                show: false,
                color: AppColors.primary.withValues(alpha: 0.08),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
