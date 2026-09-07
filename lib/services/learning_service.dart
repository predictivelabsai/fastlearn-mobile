import 'package:dio/dio.dart';

import 'package:carhero/config/api_config.dart';
import 'package:carhero/models/learning.dart';

abstract class LearningService {
  Future<List<Course>> fetchCourses({String language = 'en'});

  Future<CourseCurriculum> fetchCurriculum(
    int courseId, {
    String language = 'en',
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
      queryParameters: {'lang': language},
    );
    return CourseCurriculum.fromJson(response.data!);
  }
}
