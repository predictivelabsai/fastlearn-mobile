import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:carhero/config/theme.dart';
import 'package:carhero/models/learning.dart';
import 'package:carhero/providers/learning_provider.dart';
import 'package:carhero/screens/learning/fastlearn_home_screen.dart';
import 'package:carhero/services/learning_service.dart';

class _FakeLearningService implements LearningService {
  @override
  Future<List<Course>> fetchCourses({String language = 'en'}) async => const [
    Course(
      id: 1,
      title: 'Python Fundamentals',
      slug: 'python-fundamentals',
      description: 'Learn the basics of Python.',
      category: 'Programming',
      difficulty: 'beginner',
    ),
  ];

  @override
  Future<CourseCurriculum> fetchCurriculum(
    int courseId, {
    String language = 'en',
  }) async => throw UnimplementedError();
}

void main() {
  testWidgets('shows FastLearn course catalogue and mobile navigation', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          learningServiceProvider.overrideWithValue(_FakeLearningService()),
        ],
        child: MaterialApp(
          theme: AppTheme.light,
          home: const FastLearnHomeScreen(),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Discover'), findsAtLeastNWidgets(1));
    expect(find.text('Python Fundamentals'), findsOneWidget);
    expect(
      find.text('Learn useful skills, one clear step at a time.'),
      findsOneWidget,
    );
    expect(find.text('Learning'), findsOneWidget);
    expect(find.text('Tutor'), findsOneWidget);

    await tester.tap(find.text('Tutor'));
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('Open voice tutor'), findsOneWidget);
    expect(find.text('Type with AI tutor'), findsOneWidget);
    expect(find.byKey(const Key('voice-sonogram')), findsNWidgets(2));
    expect(find.byIcon(Icons.mic_none_rounded), findsOneWidget);
  });
}
