import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../config/app_constants.dart';
import '../../providers/issue_provider.dart';

class AuthorityAnalyticsScreen extends StatelessWidget {
  const AuthorityAnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Analytics & Reports'),
        backgroundColor: AppColors.authorityColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Consumer<IssueProvider>(
        builder: (ctx, provider, _) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SummaryGrid(provider: provider),
                const SizedBox(height: 20),
                _ResolutionRateCard(provider: provider),
                const SizedBox(height: 16),
                _WeeklyTrendChart(provider: provider),
                const SizedBox(height: 16),
                _CategoryBreakdownChart(provider: provider),
                const SizedBox(height: 16),
                _StatusBreakdownCard(provider: provider),
                const SizedBox(height: 32),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ── Summary grid ──────────────────────────────────────────────────────────────

class _SummaryGrid extends StatelessWidget {
  final IssueProvider provider;
  const _SummaryGrid({required this.provider});

  @override
  Widget build(BuildContext context) {
    final items = [
      _Item(
        'Total',
        provider.totalIssues,
        Icons.assignment_outlined,
        AppColors.authorityColor,
      ),
      _Item(
        'Pending',
        provider.pendingCount,
        Icons.hourglass_empty,
        AppColors.warning,
      ),
      _Item(
        'Resolved',
        provider.resolvedCount,
        Icons.check_circle_outline,
        AppColors.success,
      ),
      _Item(
        'Assigned',
        provider.assignedCount,
        Icons.engineering_outlined,
        AppColors.workerColor,
      ),
    ];
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.9,
      children: items.map((i) => _SummaryTile(item: i)).toList(),
    );
  }
}

class _Item {
  final String label;
  final int value;
  final IconData icon;
  final Color color;
  const _Item(this.label, this.value, this.icon, this.color);
}

class _SummaryTile extends StatelessWidget {
  final _Item item;
  const _SummaryTile({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: item.color.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: item.color.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: item.color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(item.icon, color: item.color, size: 20),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '${item.value}',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: item.color,
                ),
              ),
              Text(
                item.label,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Resolution rate card ──────────────────────────────────────────────────────

class _ResolutionRateCard extends StatelessWidget {
  final IssueProvider provider;
  const _ResolutionRateCard({required this.provider});

  @override
  Widget build(BuildContext context) {
    final rate = provider.resolutionRate;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.authorityColor, Color(0xFF9F5CF5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.authorityColor.withValues(alpha: 0.3),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Resolution Rate',
                  style: TextStyle(color: Colors.white70, fontSize: 13),
                ),
                const SizedBox(height: 4),
                Text(
                  '${rate.toStringAsFixed(1)}%',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: rate / 100,
                    backgroundColor: Colors.white24,
                    valueColor: const AlwaysStoppedAnimation(Colors.white),
                    minHeight: 8,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${provider.resolvedCount} of ${provider.totalIssues} issues resolved',
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          SizedBox(
            width: 90,
            height: 90,
            child: Stack(
              alignment: Alignment.center,
              children: [
                PieChart(
                  PieChartData(
                    sectionsSpace: 0,
                    centerSpaceRadius: 28,
                    sections: [
                      PieChartSectionData(
                        value: rate,
                        color: Colors.white,
                        radius: 14,
                        showTitle: false,
                      ),
                      PieChartSectionData(
                        value: 100 - rate,
                        color: Colors.white24,
                        radius: 14,
                        showTitle: false,
                      ),
                    ],
                  ),
                ),
                Text(
                  '${rate.toStringAsFixed(0)}%',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Weekly trend bar chart ────────────────────────────────────────────────────

class _WeeklyTrendChart extends StatelessWidget {
  final IssueProvider provider;
  const _WeeklyTrendChart({required this.provider});

  @override
  Widget build(BuildContext context) {
    final data = provider.weeklyTrend;
    final maxY = (data.fold(0, (a, b) => a > b ? a : b) + 2).toDouble();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Issues Submitted (8 Weeks)',
            style: AppTextStyles.heading3,
          ),
          const Text(
            'Weekly trend of new complaints',
            style: AppTextStyles.caption,
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 180,
            child: BarChart(
              BarChartData(
                maxY: maxY,
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (_) =>
                      FlLine(color: AppColors.divider, strokeWidth: 1),
                ),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 24,
                      getTitlesWidget: (v, _) => Text(
                        '${v.toInt()}',
                        style: const TextStyle(
                          fontSize: 10,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (v, _) {
                        const labels = [
                          'W1',
                          'W2',
                          'W3',
                          'W4',
                          'W5',
                          'W6',
                          'W7',
                          'W8',
                        ];
                        final i = v.toInt();
                        return Text(
                          i < labels.length ? labels[i] : '',
                          style: const TextStyle(
                            fontSize: 10,
                            color: AppColors.textSecondary,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                barGroups: data.asMap().entries.map((e) {
                  return BarChartGroupData(
                    x: e.key,
                    barRods: [
                      BarChartRodData(
                        toY: e.value.toDouble(),
                        gradient: const LinearGradient(
                          colors: [AppColors.authorityColor, Color(0xFF9F5CF5)],
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                        ),
                        width: 22,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(8),
                        ),
                        backDrawRodData: BackgroundBarChartRodData(
                          show: true,
                          toY: maxY,
                          color: AppColors.authorityColor.withValues(
                            alpha: 0.05,
                          ),
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Category pie chart ────────────────────────────────────────────────────────

class _CategoryBreakdownChart extends StatelessWidget {
  final IssueProvider provider;
  const _CategoryBreakdownChart({required this.provider});

  static const _colors = [
    AppColors.citizenColor,
    AppColors.warning,
    AppColors.success,
    AppColors.danger,
    AppColors.secondary,
    AppColors.workerColor,
    AppColors.info,
    AppColors.authorityColor,
  ];

  @override
  Widget build(BuildContext context) {
    final breakdown = provider.categoryBreakdown;
    if (breakdown.isEmpty) return const SizedBox.shrink();
    final entries = breakdown.entries.toList();
    final total = breakdown.values.fold(0, (a, b) => a + b);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Issues by Category', style: AppTextStyles.heading3),
          const SizedBox(height: 20),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                width: 130,
                height: 130,
                child: PieChart(
                  PieChartData(
                    sectionsSpace: 2,
                    centerSpaceRadius: 32,
                    sections: entries.asMap().entries.map((e) {
                      final color = _colors[e.key % _colors.length];
                      return PieChartSectionData(
                        value: e.value.value.toDouble(),
                        color: color,
                        radius: 40,
                        showTitle: false,
                        badgeWidget: Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                            border: Border.all(color: color, width: 2),
                          ),
                        ),
                        badgePositionPercentageOffset: 1.1,
                      );
                    }).toList(),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  children: entries.asMap().entries.map((e) {
                    final color = _colors[e.key % _colors.length];
                    final pct = total > 0
                        ? (e.value.value / total * 100).toStringAsFixed(0)
                        : '0';
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 3),
                      child: Row(
                        children: [
                          Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              e.value.key,
                              style: const TextStyle(fontSize: 11),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            '$pct%',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: color,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Status breakdown ──────────────────────────────────────────────────────────

class _StatusBreakdownCard extends StatelessWidget {
  final IssueProvider provider;
  const _StatusBreakdownCard({required this.provider});

  @override
  Widget build(BuildContext context) {
    final breakdown = provider.statusBreakdown;
    final total = breakdown.values.fold(0, (a, b) => a + b);
    final colors = {
      'Pending': AppColors.warning,
      'Acknowledged': AppColors.info,
      'In Progress': AppColors.authorityColor,
      'Completed': AppColors.success,
    };

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Status Breakdown', style: AppTextStyles.heading3),
          const SizedBox(height: 16),
          ...breakdown.entries.map((e) {
            final color = colors[e.key] ?? AppColors.textSecondary;
            final pct = total > 0 ? e.value / total : 0.0;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(e.key, style: const TextStyle(fontSize: 13)),
                      Text(
                        '${e.value} (${(pct * 100).toStringAsFixed(0)}%)',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: Container(
                      height: 10,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [color.withValues(alpha: 0.6), color],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: LinearProgressIndicator(
                          value: pct,
                          backgroundColor: color.withValues(alpha: 0.1),
                          valueColor: const AlwaysStoppedAnimation(
                            Colors.transparent,
                          ),
                          minHeight: 10,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
          const Divider(),
          _kpiRow('Avg. Resolution Time', '4.2 days'),
          const SizedBox(height: 8),
          _kpiRow('Satisfaction Score', '4.1 ⭐'),
        ],
      ),
    );
  }

  Widget _kpiRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
        ),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
        ),
      ],
    );
  }
}
