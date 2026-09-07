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
}
