class Course {
  final int id;
  final String title;
  final String slug;
  final String description;
  final String category;
  final String difficulty;
  final String? thumbnailUrl;

  const Course({
    required this.id,
    required this.title,
    required this.slug,
    required this.description,
    required this.category,
    required this.difficulty,
    this.thumbnailUrl,
  });

  factory Course.fromJson(Map<String, dynamic> json) => Course(
    id: json['id'] as int,
    title: json['title'] as String? ?? 'Untitled course',
    slug: json['slug'] as String? ?? '',
    description: json['description'] as String? ?? '',
    category: json['category'] as String? ?? 'Learning',
    difficulty: json['difficulty'] as String? ?? 'beginner',
    thumbnailUrl: json['thumbnail_url'] as String?,
  );
}

class Lesson {
  final int id;
  final int moduleId;
  final String title;
  final String contentMarkdown;
  final String contentType;
  final String? videoUrl;
  final int durationMinutes;
  final int xpReward;
  final int order;
  final int exerciseCount;
  final int visualizationCount;

  const Lesson({
    required this.id,
    required this.moduleId,
    required this.title,
    required this.contentMarkdown,
    required this.contentType,
    required this.durationMinutes,
    required this.xpReward,
    required this.order,
    required this.exerciseCount,
    required this.visualizationCount,
    this.videoUrl,
  });

  factory Lesson.fromJson(Map<String, dynamic> json) => Lesson(
    id: json['id'] as int,
    moduleId: json['module_id'] as int,
    title: json['title'] as String? ?? 'Untitled lesson',
    contentMarkdown: json['content_md'] as String? ?? '',
    contentType: json['content_type'] as String? ?? 'text',
    videoUrl: json['video_url'] as String?,
    durationMinutes: json['duration_min'] as int? ?? 0,
    xpReward: json['xp_reward'] as int? ?? 0,
    order: json['order_idx'] as int? ?? 0,
    exerciseCount: json['exercise_count'] as int? ?? 0,
    visualizationCount: json['visualization_count'] as int? ?? 0,
  );
}

class CourseModule {
  final int id;
  final String title;
  final String description;
  final int order;
  final List<Lesson> lessons;

  const CourseModule({
    required this.id,
    required this.title,
    required this.description,
    required this.order,
    required this.lessons,
  });

  factory CourseModule.fromJson(Map<String, dynamic> json) => CourseModule(
    id: json['id'] as int,
    title: json['title'] as String? ?? 'Module',
    description: json['description'] as String? ?? '',
    order: json['order_idx'] as int? ?? 0,
    lessons: (json['lessons'] as List<dynamic>? ?? const [])
        .map((item) => Lesson.fromJson(item as Map<String, dynamic>))
        .toList(),
  );
}

class GuidedExercise {
  final int id;
  final String engine;
  final String exerciseType;
  final String prompt;
  final int difficultyBand;
  final List<String> choices;
  final List<String> equation;
  final String? molecule;
  final String? scene;
  final String? atom;
  final int? massNumber;
  final int? atomicNumber;
  final String? unit;
  final String? chart;
  final Map<String, String> ui;

  const GuidedExercise({
    required this.id,
    required this.engine,
    required this.exerciseType,
    required this.prompt,
    required this.difficultyBand,
    required this.choices,
    required this.equation,
    required this.ui,
    this.molecule,
    this.scene,
    this.atom,
    this.massNumber,
    this.atomicNumber,
    this.unit,
    this.chart,
  });

  factory GuidedExercise.fromJson(Map<String, dynamic> json) => GuidedExercise(
    id: json['id'] as int,
    engine: json['engine'] as String? ?? '',
    exerciseType: json['exercise_type'] as String? ?? '',
    prompt: json['prompt'] as String? ?? '',
    difficultyBand: json['difficulty_band'] as int? ?? 1,
    choices: _stringList(json['choices']),
    equation: _stringList(json['equation']),
    molecule: json['molecule'] as String?,
    scene: json['scene'] as String?,
    atom: json['atom'] as String?,
    massNumber: json['mass_number'] as int?,
    atomicNumber: json['atomic_number'] as int?,
    unit: json['unit'] as String?,
    chart: json['chart'] as String?,
    ui: _stringMap(json['ui']),
  );
}

class LessonVisualization {
  final String sourceKey;
  final String title;
  final String description;
  final String altText;
  final String sourceNote;
  final List<Map<String, dynamic>> data;
  final Map<String, dynamic> table;

  const LessonVisualization({
    required this.sourceKey,
    required this.title,
    required this.description,
    required this.altText,
    required this.sourceNote,
    required this.data,
    required this.table,
  });

  factory LessonVisualization.fromJson(Map<String, dynamic> json) =>
      LessonVisualization(
        sourceKey: json['source_key'] as String? ?? '',
        title: json['title'] as String? ?? 'Lesson visualization',
        description: json['description'] as String? ?? '',
        altText: json['alt_text'] as String? ?? '',
        sourceNote: json['source_note'] as String? ?? '',
        data: (json['data'] as List<dynamic>? ?? const [])
            .whereType<Map>()
            .map((item) => Map<String, dynamic>.from(item))
            .toList(),
        table: Map<String, dynamic>.from(json['table'] as Map? ?? const {}),
      );
}

class LessonActivities {
  final List<GuidedExercise> exercises;
  final List<LessonVisualization> visualizations;

  const LessonActivities({
    required this.exercises,
    required this.visualizations,
  });

  factory LessonActivities.fromJson(Map<String, dynamic> json) =>
      LessonActivities(
        exercises: (json['exercises'] as List<dynamic>? ?? const [])
            .whereType<Map>()
            .map(
              (item) =>
                  GuidedExercise.fromJson(Map<String, dynamic>.from(item)),
            )
            .toList(),
        visualizations: (json['visualizations'] as List<dynamic>? ?? const [])
            .whereType<Map>()
            .map(
              (item) =>
                  LessonVisualization.fromJson(Map<String, dynamic>.from(item)),
            )
            .toList(),
      );
}

class ExerciseCheckResult {
  final bool correct;
  final bool completed;
  final bool optimal;

  const ExerciseCheckResult({
    required this.correct,
    required this.completed,
    required this.optimal,
  });

  factory ExerciseCheckResult.fromJson(Map<String, dynamic> json) =>
      ExerciseCheckResult(
        correct: json['correct'] == true,
        completed: json['completed'] == true,
        optimal: json['optimal'] == true,
      );
}

List<String> _stringList(Object? value) =>
    (value as List<dynamic>? ?? const []).whereType<String>().toList();

Map<String, String> _stringMap(Object? value) {
  if (value is! Map) return const {};
  return value.map((key, item) => MapEntry('$key', '$item'));
}

class CourseCurriculum {
  final Course course;
  final List<CourseModule> modules;

  const CourseCurriculum({required this.course, required this.modules});

  List<Lesson> get lessons => [for (final module in modules) ...module.lessons];

  factory CourseCurriculum.fromJson(Map<String, dynamic> json) =>
      CourseCurriculum(
        course: Course.fromJson(json['course'] as Map<String, dynamic>),
        modules: (json['modules'] as List<dynamic>? ?? const [])
            .map((item) => CourseModule.fromJson(item as Map<String, dynamic>))
            .toList(),
      );
}
