import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:carhero/config/theme.dart';
import 'package:carhero/models/learning.dart';
import 'package:carhero/providers/learning_provider.dart';

class CourseScreen extends ConsumerWidget {
  final Course course;

  const CourseScreen({super.key, required this.course});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final curriculum = ref.watch(courseCurriculumProvider(course.id));
    final progress = ref.watch(lessonProgressProvider).value ?? <int>{};

    return Scaffold(
      appBar: AppBar(title: Text(course.title)),
      body: curriculum.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => Center(
          child: FilledButton(
            onPressed: () =>
                ref.invalidate(courseCurriculumProvider(course.id)),
            child: const Text('Try again'),
          ),
        ),
        data: (data) => ListView(
          padding: const EdgeInsets.fromLTRB(18, 12, 18, 28),
          children: [
            Text(
              course.description,
              style: TextStyle(color: AppTheme.gray500, height: 1.45),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _CourseFact(
                  Icons.layers_outlined,
                  '${data.modules.length} modules',
                ),
                const SizedBox(width: 16),
                _CourseFact(
                  Icons.menu_book_outlined,
                  '${data.lessons.length} lessons',
                ),
              ],
            ),
            const SizedBox(height: 24),
            for (final module in data.modules) ...[
              Text(
                module.title,
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
              ),
              if (module.description.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  module.description,
                  style: TextStyle(color: AppTheme.gray500),
                ),
              ],
              const SizedBox(height: 10),
              for (var index = 0; index < module.lessons.length; index++)
                Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor:
                          progress.contains(module.lessons[index].id)
                          ? AppTheme.accent
                          : AppTheme.tint,
                      foregroundColor:
                          progress.contains(module.lessons[index].id)
                          ? Colors.white
                          : AppTheme.accent,
                      child: progress.contains(module.lessons[index].id)
                          ? const Icon(Icons.check, size: 18)
                          : Text('${index + 1}'),
                    ),
                    title: Text(module.lessons[index].title),
                    subtitle: Text(
                      '${module.lessons[index].durationMinutes} min · ${module.lessons[index].xpReward} XP',
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => LessonScreen(
                          course: course,
                          lesson: module.lessons[index],
                        ),
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: 18),
            ],
          ],
        ),
      ),
    );
  }
}

class _CourseFact extends StatelessWidget {
  final IconData icon;
  final String text;

  const _CourseFact(this.icon, this.text);

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Icon(icon, size: 18, color: AppTheme.accent),
      const SizedBox(width: 6),
      Text(text, style: const TextStyle(fontWeight: FontWeight.w600)),
    ],
  );
}

class LessonScreen extends ConsumerWidget {
  final Course course;
  final Lesson lesson;

  const LessonScreen({super.key, required this.course, required this.lesson});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final completed =
        ref.watch(lessonProgressProvider).value?.contains(lesson.id) ?? false;

    return Scaffold(
      appBar: AppBar(title: Text(lesson.title)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 110),
        children: [
          Text(
            course.title.toUpperCase(),
            style: TextStyle(
              color: AppTheme.accent,
              fontWeight: FontWeight.w800,
              fontSize: 11,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text('${lesson.durationMinutes} min'),
              const Text('  ·  '),
              Text('${lesson.xpReward} XP'),
            ],
          ),
          const SizedBox(height: 18),
          MarkdownBody(
            data: lesson.contentMarkdown,
            selectable: true,
            onTapLink: (_, href, __) async {
              if (href != null) {
                final uri = Uri.tryParse(href);
                if (uri != null &&
                    (uri.scheme == 'https' || uri.scheme == 'http')) {
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                }
              }
            },
            styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context))
                .copyWith(
                  h1: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                  h2: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                  p: const TextStyle(fontSize: 16, height: 1.55),
                  blockquoteDecoration: BoxDecoration(
                    color: AppTheme.tint,
                    border: Border(
                      left: BorderSide(color: AppTheme.accent, width: 4),
                    ),
                  ),
                  codeblockDecoration: BoxDecoration(
                    color: const Color(0xFF172321),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  code: const TextStyle(
                    color: Color(0xFFEAF5F2),
                    fontFamily: 'monospace',
                  ),
                ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(18, 8, 18, 12),
        child: FilledButton.icon(
          onPressed: () =>
              ref.read(lessonProgressProvider.notifier).toggle(lesson.id),
          icon: Icon(completed ? Icons.undo : Icons.check),
          label: Text(
            completed ? 'Mark as not completed' : 'Mark lesson complete',
          ),
        ),
      ),
    );
  }
}
