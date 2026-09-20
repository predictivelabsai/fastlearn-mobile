import 'package:dio/dio.dart';

import 'package:carhero/config/api_config.dart';
import 'package:carhero/models/learning.dart';

abstract class LearningService {
  Future<List<Course>> fetchCourses({String language = 'en'});

  Future<CourseCurriculum> fetchCurriculum(
    int courseId, {
    String language = 'en',
  });

  Future<LessonActivities> fetchLessonActivities(
    int lessonId, {
    String language = 'en',
  });

  Future<ExerciseCheckResult> checkExercise(
    int exerciseId,
    Map<String, dynamic> answer, {
    String? language,
  });
}

class HttpLearningService implements LearningService {
  final Dio _dio;

  HttpLearningService({Dio? dio})
    : _dio =
          dio ??
          Dio(
            BaseOptions(
              baseUrl: ApiConfig.baseUrl,
              connectTimeout: ApiConfig.connectTimeout,
              receiveTimeout: ApiConfig.receiveTimeout,
              headers: const {'Accept': 'application/json'},
            ),
          );

  @override
  Future<List<Course>> fetchCourses({String language = 'en'}) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/courses',
      queryParameters: {'limit': 100, 'lang': language},
    );
    final rows = response.data?['data'] as List<dynamic>? ?? const [];
    return rows
        .map((item) => Course.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<CourseCurriculum> fetchCurriculum(
    int courseId, {
    String language = 'en',
  }) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/courses/$courseId/curriculum',
      queryParameters: {if (language.isNotEmpty) 'lang': language},
    );
    return CourseCurriculum.fromJson(response.data!);
  }

  @override
  Future<LessonActivities> fetchLessonActivities(
    int lessonId, {
    String language = 'en',
  }) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/lessons/$lessonId/guided-content',
      queryParameters: {if (language.isNotEmpty) 'lang': language},
    );
    return LessonActivities.fromJson(response.data!);
  }

  @override
  Future<ExerciseCheckResult> checkExercise(
    int exerciseId,
    Map<String, dynamic> answer, {
    String? language,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/exercises/$exerciseId/check',
      queryParameters: {if (language?.isNotEmpty == true) 'lang': language},
      data: {'answer': answer},
    );
    return ExerciseCheckResult.fromJson(response.data!);
  }
}
