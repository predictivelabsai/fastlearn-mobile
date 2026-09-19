import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import 'package:carhero/config/theme.dart';
import 'package:carhero/models/learning.dart';

/// A small native subset of FastLMS's portable Plotly schema.  The full data
/// table remains available for every chart, including unsupported plot types.
class LessonVisualizationCard extends StatelessWidget {
  final LessonVisualization visualization;

  const LessonVisualizationCard({super.key, required this.visualization});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              visualization.title,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
            if (visualization.description.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                visualization.description,
                style: TextStyle(color: AppTheme.gray500, height: 1.4),
              ),
            ],
            const SizedBox(height: 16),
            Semantics(
              label: visualization.altText.isEmpty
                  ? visualization.title
                  : visualization.altText,
              child: _NativeChart(visualization: visualization),
            ),
            _AccessibleTable(table: visualization.table),
            if (visualization.sourceNote.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                visualization.sourceNote,
                style: TextStyle(color: AppTheme.gray500, fontSize: 12),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _NativeChart extends StatelessWidget {
  final LessonVisualization visualization;

  const _NativeChart({required this.visualization});

  @override
  Widget build(BuildContext context) {
    if (visualization.data.isEmpty) return const _ChartFallback();
    final type = visualization.data.first['type'] as String? ?? '';
    return switch (type) {
      'bar' => _BarVisualization(trace: visualization.data.first),
      'scatter' => _LineVisualization(traces: visualization.data),
      'pie' => _PieVisualization(trace: visualization.data.first),
      _ => const _ChartFallback(),
    };
  }
}

class _BarVisualization extends StatelessWidget {
  final Map<String, dynamic> trace;

  const _BarVisualization({required this.trace});

  @override
  Widget build(BuildContext context) {
    final labels = _values(trace['x']).map((item) => '$item').toList();
    final values = _values(trace['y']).map(_number).toList();
    if (labels.isEmpty ||
        values.length != labels.length ||
        values.any((v) => v == null)) {
      return const _ChartFallback();
    }
    final numbers = values.cast<double>();
    final maxY = numbers.reduce((a, b) => a > b ? a : b);
    return SizedBox(
      height: 230,
      child: BarChart(
        BarChartData(
          maxY: maxY == 0 ? 1 : maxY * 1.2,
          alignment: BarChartAlignment.spaceAround,
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
          barTouchData: const BarTouchData(enabled: true),
          titlesData: FlTitlesData(
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                getTitlesWidget: (value, _) {
                  final index = value.round();
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      index >= 0 && index < labels.length ? labels[index] : '',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 10),
                    ),
                  );
                },
              ),
            ),
          ),
          barGroups: [
            for (var index = 0; index < numbers.length; index++)
              BarChartGroupData(
                x: index,
                barRods: [
                  BarChartRodData(
                    toY: numbers[index],
                    color: _palette[index % _palette.length],
                    width: 26,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(5),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class _LineVisualization extends StatelessWidget {
  final List<Map<String, dynamic>> traces;

  const _LineVisualization({required this.traces});

  @override
  Widget build(BuildContext context) {
    final labels = _values(traces.first['x']).map((item) => '$item').toList();
    final lineBars = <LineChartBarData>[];
    var maxY = 0.0;
    for (var series = 0; series < traces.length; series++) {
      final values = _values(traces[series]['y']).map(_number).toList();
      if (values.length != labels.length ||
          values.any((value) => value == null)) {
        return const _ChartFallback();
      }
      final points = <FlSpot>[
        for (var index = 0; index < values.length; index++)
          FlSpot(index.toDouble(), values[index]!),
      ];
      for (final point in points) {
        if (point.y > maxY) maxY = point.y;
      }
      lineBars.add(
        LineChartBarData(
          spots: points,
          isCurved: false,
          color: _palette[series % _palette.length],
          barWidth: 3,
          dotData: const FlDotData(show: true),
        ),
      );
    }
    if (labels.isEmpty) return const _ChartFallback();
    return SizedBox(
      height: 230,
      child: LineChart(
        LineChartData(
          minX: 0,
          maxX: (labels.length - 1).toDouble(),
          minY: 0,
          maxY: maxY == 0 ? 1 : maxY * 1.15,
          gridData: const FlGridData(drawVerticalLine: false),
          borderData: FlBorderData(show: false),
          lineBarsData: lineBars,
          titlesData: FlTitlesData(
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                interval: 1,
                getTitlesWidget: (value, _) {
                  final index = value.round();
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      index >= 0 && index < labels.length ? labels[index] : '',
                      style: const TextStyle(fontSize: 10),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PieVisualization extends StatelessWidget {
  final Map<String, dynamic> trace;

  const _PieVisualization({required this.trace});

  @override
  Widget build(BuildContext context) {
    final labels = _values(trace['labels']).map((item) => '$item').toList();
    final values = _values(trace['values']).map(_number).toList();
    if (labels.isEmpty ||
        values.length != labels.length ||
        values.any((v) => v == null)) {
      return const _ChartFallback();
    }
    return SizedBox(
      height: 230,
      child: PieChart(
        PieChartData(
          sectionsSpace: 2,
          centerSpaceRadius: 36,
          sections: [
            for (var index = 0; index < labels.length; index++)
              PieChartSectionData(
                value: values[index]!,
                color: _palette[index % _palette.length],
                title: labels[index],
                radius: 76,
                titleStyle: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _AccessibleTable extends StatelessWidget {
  final Map<String, dynamic> table;

  const _AccessibleTable({required this.table});

  @override
  Widget build(BuildContext context) {
    final columns = _values(table['columns']).map((item) => '$item').toList();
    final rows = _values(table['rows']);
    if (columns.isEmpty || rows.isEmpty) return const SizedBox.shrink();
    return ExpansionTile(
      tilePadding: EdgeInsets.zero,
      title: const Text('View data table'),
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            columns: [
              for (final column in columns) DataColumn(label: Text(column)),
            ],
            rows: [
              for (final row in rows)
                DataRow(
                  cells: [
                    for (var index = 0; index < columns.length; index++)
                      DataCell(
                        Text(
                          index < _values(row).length
                              ? '${_values(row)[index]}'
                              : '',
                        ),
                      ),
                  ],
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ChartFallback extends StatelessWidget {
  const _ChartFallback();

  @override
  Widget build(BuildContext context) => const SizedBox(
    height: 72,
    child: Center(
      child: Text(
        'This visualization is available as an accessible data table.',
      ),
    ),
  );
}

List<dynamic> _values(Object? value) => value is List ? value : const [];

double? _number(Object? value) =>
    value is num ? value.toDouble() : double.tryParse('$value');

const _palette = [
  Color(0xFF256B62),
  Color(0xFF2563EB),
  Color(0xFFE76F51),
  Color(0xFFF2C94C),
  Color(0xFF8B5CF6),
];
