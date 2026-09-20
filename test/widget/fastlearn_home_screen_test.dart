import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:carhero/config/theme.dart';
import 'package:carhero/models/learning.dart';
import 'package:carhero/providers/learning_provider.dart';
import 'package:carhero/screens/learning/course_screen.dart';
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
      countryCode: 'EE',
      gradeCode: '8',
    ),
  ];

  @override
  Future<CourseCurriculum> fetchCurriculum(
    int courseId, {
    String language = 'en',
  }) async => const CourseCurriculum(
    course: Course(
      id: 1,
      title: 'Primary Science',
      slug: 'primary-science',
      description: 'Learn science.',
      category: 'Science',
      difficulty: 'beginner',
    ),
    modules: [
      CourseModule(
        id: 2,
        title: 'Working Scientifically',
        description: '',
        order: 0,
        lessons: [
          Lesson(
            id: 3,
            moduleId: 2,
            title: 'Fair Tests',
            contentMarkdown: '# Fair Tests\n\nChange one variable.',
            contentType: 'interactive',
            durationMinutes: 15,
            xpReward: 20,
            order: 0,
            exerciseCount: 1,
            visualizationCount: 0,
            lessonKind: 'prelude',
          ),
          Lesson(
            id: 4,
            moduleId: 2,
            title: 'Safety Symbols',
            contentMarkdown: '# Safety Symbols',
            contentType: 'interactive',
            durationMinutes: 15,
            xpReward: 20,
            order: 1,
            exerciseCount: 1,
            visualizationCount: 0,
            lessonKind: 'prelude',
            prerequisiteLessonId: 3,
          ),
        ],
      ),
    ],
  );

  @override
  Future<LessonActivities> fetchLessonActivities(
    int lessonId, {
    String language = 'en',
  }) async => const LessonActivities(exercises: [], visualizations: []);

  @override
  Future<ExerciseCheckResult> checkExercise(
    int exerciseId,
    Map<String, dynamic> answer, {
    String? language,
  }) async => const ExerciseCheckResult(
    correct: false,
    completed: false,
    optimal: false,
  );
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
    expect(find.text('EE · 8'), findsOneWidget);
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

    await tester.tap(find.text('More'));
    await tester.pump();

    expect(find.text('Dashboard'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Teacher workspace'),
      220,
      scrollable: find.byType(Scrollable).last,
    );
    expect(find.text('Teacher workspace'), findsOneWidget);
    expect(find.text('School workspace'), findsOneWidget);
  });

  testWidgets('science lessons expose Classic and lesson-grounded Chat modes', (
    tester,
  ) async {
    const course = Course(
      id: 1,
      title: 'Primary Science',
      slug: 'primary-science',
      description: 'Learn science.',
      category: 'Science',
      difficulty: 'beginner',
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          learningServiceProvider.overrideWithValue(_FakeLearningService()),
        ],
        child: MaterialApp(
          theme: AppTheme.light,
          home: const CourseScreen(course: course),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Fair Tests'), findsOneWidget);
    expect(find.byTooltip('Classic mode'), findsNWidgets(2));
    expect(find.byTooltip('Chat mode'), findsNWidgets(2));

    await tester.tap(
      find
          .descendant(
            of: find.byTooltip('Classic mode'),
            matching: find.byType(IconButton),
          )
          .first,
    );
    await tester.pumpAndSettle();

    expect(find.text('Classic mode'), findsOneWidget);
    expect(find.text('Chat'), findsOneWidget);
    expect(find.byTooltip('Open chat mode'), findsOneWidget);
  });

  testWidgets(
    'Estonian prelude locks the next lesson until mastery completion',
    (tester) async {
      const course = Course(
        id: 1,
        title: 'Eesti 8. klassi keemia',
        slug: 'ee-grade-8-chemistry',
        description: 'Nullteadmistega eelkursus.',
        category: 'Keemia',
        difficulty: 'intermediate',
        countryCode: 'EE',
        gradeCode: '8',
        canonicalLanguage: 'et',
      );
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            learningServiceProvider.overrideWithValue(_FakeLearningService()),
          ],
          child: MaterialApp(
            theme: AppTheme.light,
            home: const CourseScreen(course: course),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      final lockedRow = find.widgetWithText(ListTile, 'Safety Symbols');
      expect(lockedRow, findsOneWidget);
      expect(tester.widget<ListTile>(lockedRow).enabled, isFalse);
      expect(find.byIcon(Icons.lock_outline), findsOneWidget);
    },
  );
}
