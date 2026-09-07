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
