import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:carhero/models/learning.dart';
import 'package:carhero/providers/locale_provider.dart';
import 'package:carhero/services/learning_service.dart';

String _apiLanguage(String locale) =>
    const {'en', 'et', 'lt', 'es'}.contains(locale) ? locale : 'en';

final learningServiceProvider = Provider<LearningService>(
  (ref) => HttpLearningService(),
);

final coursesProvider = FutureProvider<List<Course>>((ref) {
  final language = _apiLanguage(ref.watch(localeProvider));
  return ref.watch(learningServiceProvider).fetchCourses(language: language);
});

final courseCurriculumProvider = FutureProvider.family<CourseCurriculum, int>((
  ref,
  courseId,
) {
  final language = _apiLanguage(ref.watch(localeProvider));
  return ref
      .watch(learningServiceProvider)
      .fetchCurriculum(courseId, language: language);
});

final lessonProgressProvider =
    AsyncNotifierProvider<LessonProgressNotifier, Set<int>>(
      LessonProgressNotifier.new,
    );

class LessonProgressNotifier extends AsyncNotifier<Set<int>> {
  static const _storageKey = 'fastlearn.completed_lessons';

  @override
  Future<Set<int>> build() async {
    final preferences = await SharedPreferences.getInstance();
    return preferences
            .getStringList(_storageKey)
            ?.map(int.tryParse)
            .whereType<int>()
            .toSet() ??
        <int>{};
  }

  Future<void> toggle(int lessonId) async {
    final completed = {...(state.value ?? <int>{})};
    completed.contains(lessonId)
        ? completed.remove(lessonId)
        : completed.add(lessonId);
    state = AsyncData(Set.unmodifiable(completed));
    final preferences = await SharedPreferences.getInstance();
    await preferences.setStringList(
      _storageKey,
      completed.map((id) => id.toString()).toList()..sort(),
    );
  }
}
