import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:carhero/models/learning.dart';
import 'package:carhero/widgets/learning/lesson_visualization.dart';

void main() {
  testWidgets('renders a native chart and preserves the accessible table', (
    tester,
  ) async {
    const visualization = LessonVisualization(
      sourceKey: 'chemistry-sodium-atom',
      title: 'A sodium atom',
      description: 'Compare particles.',
      altText: 'Three bars compare particles.',
      sourceNote: '',
      data: [
        {
          'type': 'bar',
          'x': ['Protons', 'Neutrons', 'Electrons'],
          'y': [11, 12, 11],
        },
      ],
      table: {
        'columns': ['Particle', 'Count'],
        'rows': [
          ['Protons', 11],
        ],
      },
    );

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: LessonVisualizationCard(visualization: visualization),
        ),
      ),
    );

    expect(find.text('A sodium atom'), findsOneWidget);
    expect(find.byType(BarChart), findsOneWidget);
    expect(find.text('View data table'), findsOneWidget);
  });
}
