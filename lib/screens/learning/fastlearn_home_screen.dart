import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:carhero/config/theme.dart';
import 'package:carhero/config/web_handoff.dart';
import 'package:carhero/models/learning.dart';
import 'package:carhero/providers/learning_provider.dart';
import 'package:carhero/providers/locale_provider.dart';
import 'package:carhero/screens/learning/course_screen.dart';

Future<void> _openWeb(String path, {bool returnToMobile = false}) async {
  final uri = fastLearnWebUri(path, returnToMobile: returnToMobile);
  if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
    throw StateError('Could not open $uri');
  }
}

class FastLearnHomeScreen extends ConsumerStatefulWidget {
  const FastLearnHomeScreen({super.key});

  @override
  ConsumerState<FastLearnHomeScreen> createState() =>
      _FastLearnHomeScreenState();
}

class _FastLearnHomeScreenState extends ConsumerState<FastLearnHomeScreen> {
  var _index = 0;

  static const _titles = ['Discover', 'My learning', 'AI tutor', 'More'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 18,
        title: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppTheme.accent,
                borderRadius: BorderRadius.circular(11),
              ),
              child: const Text(
                'F',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 18,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Text(_titles[_index]),
          ],
        ),
        actions: [
          PopupMenuButton<String>(
            tooltip: 'Course language',
            icon: const Icon(Icons.language),
            initialValue: ref.watch(localeProvider),
            onSelected: (value) => ref.read(localeProvider.notifier).set(value),
            itemBuilder: (context) => const [
              PopupMenuItem(value: 'en', child: Text('English')),
              PopupMenuItem(value: 'et', child: Text('Eesti')),
              PopupMenuItem(value: 'lt', child: Text('Lietuvių')),
              PopupMenuItem(value: 'es', child: Text('Español')),
            ],
          ),
        ],
      ),
      body: IndexedStack(
        index: _index,
        children: const [
          _DiscoverPage(),
          _ProgressPage(),
          _TutorPage(),
          _MorePage(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (value) => setState(() => _index = value),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.explore_outlined),
            selectedIcon: Icon(Icons.explore),
            label: 'Discover',
          ),
          NavigationDestination(
            icon: Icon(Icons.check_circle_outline),
            selectedIcon: Icon(Icons.check_circle),
            label: 'Learning',
          ),
          NavigationDestination(
            icon: Icon(Icons.auto_awesome_outlined),
            selectedIcon: Icon(Icons.auto_awesome),
            label: 'Tutor',
          ),
          NavigationDestination(icon: Icon(Icons.more_horiz), label: 'More'),
        ],
      ),
    );
  }
}

class _DiscoverPage extends ConsumerWidget {
  const _DiscoverPage();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final courses = ref.watch(coursesProvider);
    return courses.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) =>
          _LoadError(onRetry: () => ref.invalidate(coursesProvider)),
      data: (items) => RefreshIndicator(
        onRefresh: () async => ref.refresh(coursesProvider.future),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 16, 18, 28),
          children: [
            _WelcomeCard(courseCount: items.length),
            const SizedBox(height: 24),
            Text(
              'Explore courses',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 6),
            Text(
              'Focused lessons from the live FastLearn catalogue.',
              style: TextStyle(color: AppTheme.gray500),
            ),
            const SizedBox(height: 14),
            for (final course in items) ...[
              _CourseCard(course: course),
              const SizedBox(height: 12),
            ],
          ],
        ),
      ),
    );
  }
}

class _WelcomeCard extends StatelessWidget {
  final int courseCount;

  const _WelcomeCard({required this.courseCount});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.tint,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.accent.withValues(alpha: 0.18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Learn useful skills, one clear step at a time.',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w900,
              height: 1.15,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            '$courseCount courses across technology, science, language, creativity, and chess.',
            style: TextStyle(color: AppTheme.gray500, height: 1.45),
          ),
          const SizedBox(height: 18),
          FilledButton.icon(
            onPressed: () => _openWeb('/auth/login', returnToMobile: true),
            icon: const Icon(Icons.login, size: 18),
            label: const Text('Sign in to FastLearn'),
          ),
        ],
      ),
    );
  }
}

class _CourseCard extends StatelessWidget {
  final Course course;

  const _CourseCard({required this.course});

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => CourseScreen(course: course))),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppTheme.tint,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  _courseIcon(course.category),
                  color: AppTheme.accent,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      course.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      course.description,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: AppTheme.gray500, height: 1.35),
                    ),
                    const SizedBox(height: 11),
                    Wrap(
                      spacing: 8,
                      children: [
                        _Label(course.category),
                        _Label(_titleCase(course.difficulty)),
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}

class _Label extends StatelessWidget {
  final String text;

  const _Label(this.text);

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
    decoration: BoxDecoration(
      color: AppTheme.gray50,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: AppTheme.gray200),
    ),
    child: Text(text, style: const TextStyle(fontSize: 11)),
  );
}

class _ProgressPage extends ConsumerWidget {
  const _ProgressPage();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = ref.watch(lessonProgressProvider);
    return progress.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => const Center(child: Text('Could not load progress.')),
      data: (completed) => ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppTheme.tint,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              children: [
                Icon(Icons.verified, size: 48, color: AppTheme.accent),
                const SizedBox(height: 12),
                Text(
                  '${completed.length}',
                  style: const TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const Text('lessons completed on this device'),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Keep your full learning record',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          Text(
            'Sign in on FastLearn to sync course enrolments, XP, quizzes, streaks, and AI tutor conversations.',
            style: TextStyle(color: AppTheme.gray500, height: 1.45),
          ),
          const SizedBox(height: 18),
          FilledButton(
            onPressed: () => _openWeb('/auth/login', returnToMobile: true),
            child: const Text('Open my FastLearn account'),
          ),
        ],
      ),
    );
  }
}

class _TutorPage extends StatelessWidget {
  const _TutorPage();

  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.all(20),
    children: [
      Container(
        padding: const EdgeInsets.all(26),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppTheme.accent, AppTheme.accentStrong],
          ),
          borderRadius: BorderRadius.circular(24),
        ),
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _SonogramIcon(color: Colors.white),
                SizedBox(width: 12),
                Icon(Icons.mic_none_rounded, color: Colors.white, size: 28),
              ],
            ),
            SizedBox(height: 18),
            Text(
              'Ask your AI tutor',
              style: TextStyle(
                color: Colors.white,
                fontSize: 26,
                fontWeight: FontWeight.w900,
              ),
            ),
            SizedBox(height: 10),
            Text(
              'Get an explanation grounded in the lesson you are studying, without losing context.',
              style: TextStyle(color: Colors.white, height: 1.45),
            ),
          ],
        ),
      ),
      const SizedBox(height: 22),
      FilledButton.icon(
        onPressed: () => _openWeb('/app/chat?voice=1'),
        icon: const _SonogramIcon(color: Colors.white, compact: true),
        label: const Text('Open voice tutor'),
      ),
      const SizedBox(height: 10),
      OutlinedButton.icon(
        onPressed: () => _openWeb('/app/chat'),
        icon: const Icon(Icons.keyboard_alt_outlined),
        label: const Text('Type with AI tutor'),
      ),
      const SizedBox(height: 10),
      Text(
        'The secure xAI voice tutor opens on fastlearn.fun, then asks for microphone access. Sign in if needed.',
        textAlign: TextAlign.center,
        style: TextStyle(color: AppTheme.gray500, fontSize: 12),
      ),
    ],
  );
}

class _SonogramIcon extends StatelessWidget {
  final Color color;
  final bool compact;

  const _SonogramIcon({required this.color, this.compact = false});

  @override
  Widget build(BuildContext context) {
    final heights = compact
        ? const <double>[8, 14, 20, 13, 7]
        : const <double>[12, 23, 34, 21, 10];
    return Semantics(
      label: 'Voice waveform',
      child: SizedBox(
        key: const Key('voice-sonogram'),
        width: compact ? 27 : 43,
        height: compact ? 22 : 36,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            for (final height in heights)
              Container(
                width: compact ? 3 : 5,
                height: height,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _MorePage extends StatelessWidget {
  const _MorePage();

  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.all(18),
    children: [
      const ListTile(
        contentPadding: EdgeInsets.zero,
        title: Text('FastLearn Mobile'),
        subtitle: Text('Early access 0.1.4'),
        leading: Icon(Icons.school_outlined),
      ),
      const Divider(),
      ListTile(
        contentPadding: EdgeInsets.zero,
        leading: const Icon(Icons.public),
        title: const Text('FastLearn on the web'),
        trailing: const Icon(Icons.open_in_new, size: 18),
        onTap: () => _openWeb('/'),
      ),
      ListTile(
        contentPadding: EdgeInsets.zero,
        leading: const Icon(Icons.menu_book_outlined),
        title: const Text('Platform guide'),
        trailing: const Icon(Icons.open_in_new, size: 18),
        onTap: () => _openWeb('/developers'),
      ),
      const SizedBox(height: 18),
      Text(
        'Powered by the open-source FastLMS platform.',
        style: TextStyle(color: AppTheme.gray500),
      ),
    ],
  );
}

class _LoadError extends StatelessWidget {
  final VoidCallback onRetry;

  const _LoadError({required this.onRetry});

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.cloud_off_outlined, size: 44),
          const SizedBox(height: 12),
          const Text(
            'Could not load the course catalogue.',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 14),
          OutlinedButton(onPressed: onRetry, child: const Text('Try again')),
        ],
      ),
    ),
  );
}

IconData _courseIcon(String category) {
  final value = category.toLowerCase();
  if (value.contains('program') || value.contains('web')) return Icons.code;
  if (value.contains('science') || value.contains('physics')) {
    return Icons.science_outlined;
  }
  if (value.contains('art') || value.contains('music')) return Icons.palette;
  if (value.contains('chess')) return Icons.extension;
  if (value.contains('language') || value.contains('english')) {
    return Icons.translate;
  }
  return Icons.school_outlined;
}

String _titleCase(String value) => value.isEmpty
    ? value
    : '${value[0].toUpperCase()}${value.substring(1).toLowerCase()}';
