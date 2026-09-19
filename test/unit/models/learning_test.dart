import 'package:flutter_test/flutter_test.dart';

import 'package:carhero/models/learning.dart';

void main() {
  test('course curriculum parses nested modules and lessons', () {
    final curriculum = CourseCurriculum.fromJson({
      'course': {
        'id': 7,
        'title': 'Mathematics',
        'slug': 'mathematics',
        'description': 'Learn mathematics',
        'category': 'Mathematics',
        'difficulty': 'beginner',
      },
      'modules': [
        {
          'id': 3,
          'title': 'Algebra',
          'order_idx': 0,
          'lessons': [
            {
              'id': 11,
              'module_id': 3,
              'title': 'Variables',
              'content_md': '# Variables',
              'duration_min': 12,
              'xp_reward': 25,
              'order_idx': 0,
              'exercise_count': 2,
            },
          ],
        },
      ],
    });

    expect(curriculum.course.title, 'Mathematics');
    expect(curriculum.modules.single.title, 'Algebra');
    expect(curriculum.lessons.single.title, 'Variables');
    expect(curriculum.lessons.single.exerciseCount, 2);
  });

  test(
    'guided lesson content parses answer-safe chemistry and chart payloads',
    () {
      final activities = LessonActivities.fromJson({
        'exercises': [
          {
            'id': 17,
            'engine': 'chemistry',
            'exercise_type': 'equation_balance',
            'prompt': 'Balance water.',
            'difficulty_band': 2,
            'equation': ['H₂', 'O₂', 'H₂O'],
            'ui': {'check': 'Check equation'},
          },
        ],
        'visualizations': [
          {
            'source_key': 'chemistry-sodium-atom',
            'title': 'A sodium atom',
            'description': 'Compare particles.',
            'alt_text': 'Three bars compare particles.',
            'data': [
              {
                'type': 'bar',
                'x': ['Protons', 'Neutrons', 'Electrons'],
                'y': [11, 12, 11],
              },
            ],
            'table': {
              'columns': ['Particle', 'Count'],
              'rows': [
                ['Protons', 11],
              ],
            },
          },
        ],
      });

      expect(activities.exercises.single.engine, 'chemistry');
      expect(activities.exercises.single.equation, ['H₂', 'O₂', 'H₂O']);
      expect(activities.visualizations.single.data.single['type'], 'bar');
      expect(activities.visualizations.single.table['columns'], [
        'Particle',
        'Count',
      ]);
    },
  );
}
