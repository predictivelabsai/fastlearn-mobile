import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:carhero/config/web_handoff.dart';
import 'package:carhero/config/theme.dart';
import 'package:carhero/models/learning.dart';
import 'package:carhero/providers/learning_provider.dart';
import 'package:carhero/widgets/learning/lesson_visualization.dart';

Future<void> _openLessonChat(int lessonId) async {
  final uri = fastLearnWebUri('/app/chat/new?lesson_id=$lessonId');
  if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
    throw StateError('Could not open $uri');
  }
}

class CourseScreen extends ConsumerWidget {
  final Course course;

  const CourseScreen({super.key, required this.course});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final curriculum = ref.watch(courseCurriculumProvider(course.id));
    final progress = ref.watch(lessonProgressProvider).value ?? <int>{};

    return Scaffold(
      appBar: AppBar(
        title: Text(curriculum.value?.course.title ?? course.title),
      ),
      body: curriculum.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => Center(
          child: FilledButton(
            onPressed: () =>
                ref.invalidate(courseCurriculumProvider(course.id)),
            child: const Text('Try again'),
          ),
        ),
        data: (data) {
          final lessonsById = {
            for (final lesson in data.lessons) lesson.id: lesson,
          };
          final effectiveCountry = data.course.countryCode?.isEmpty ?? true
              ? course.countryCode
              : data.course.countryCode;
          bool isLocked(Lesson lesson) {
            final prerequisite = lessonsById[lesson.prerequisiteLessonId];
            return effectiveCountry == 'EE' &&
                prerequisite?.lessonKind == 'prelude' &&
                !progress.contains(prerequisite!.id);
          }

          return ListView(
            padding: const EdgeInsets.fromLTRB(18, 12, 18, 28),
            children: [
              Text(
                data.course.description,
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
                      enabled: !isLocked(module.lessons[index]),
                      leading: CircleAvatar(
                        backgroundColor:
                            progress.contains(module.lessons[index].id)
                            ? AppTheme.accent
                            : AppTheme.tint,
                        foregroundColor:
                            progress.contains(module.lessons[index].id)
                            ? Colors.white
                            : AppTheme.accent,
                        child: isLocked(module.lessons[index])
                            ? const Icon(Icons.lock_outline, size: 18)
                            : progress.contains(module.lessons[index].id)
                            ? const Icon(Icons.check, size: 18)
                            : Text('${index + 1}'),
                      ),
                      title: Text(module.lessons[index].title),
                      subtitle: Text(_lessonSummary(module.lessons[index])),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Tooltip(
                            message: 'Classic mode',
                            child: IconButton(
                              icon: const Icon(Icons.menu_book_outlined),
                              onPressed: isLocked(module.lessons[index])
                                  ? null
                                  : () => Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) => LessonScreen(
                                          course: data.course,
                                          lesson: module.lessons[index],
                                        ),
                                      ),
                                    ),
                            ),
                          ),
                          Tooltip(
                            message: 'Chat mode',
                            child: IconButton(
                              icon: const Icon(Icons.chat_bubble_outline),
                              onPressed: isLocked(module.lessons[index])
                                  ? null
                                  : () => _openLessonChat(
                                      module.lessons[index].id,
                                    ),
                            ),
                          ),
                        ],
                      ),
                      onTap: isLocked(module.lessons[index])
                          ? null
                          : () => _openLessonChat(module.lessons[index].id),
                    ),
                  ),
                const SizedBox(height: 18),
              ],
            ],
          );
        },
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

String _lessonSummary(Lesson lesson) {
  final activities = <String>[];
  if (lesson.exerciseCount > 0) {
    activities.add('${lesson.exerciseCount} activity');
  }
  if (lesson.visualizationCount > 0) {
    activities.add('${lesson.visualizationCount} visual');
  }
  final suffix = activities.isEmpty ? '' : ' · ${activities.join(' · ')}';
  return '${lesson.durationMinutes} min · ${lesson.xpReward} XP$suffix';
}

class LessonScreen extends ConsumerWidget {
  final Course course;
  final Lesson lesson;

  const LessonScreen({super.key, required this.course, required this.lesson});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final completed =
        ref.watch(lessonProgressProvider).value?.contains(lesson.id) ?? false;
    final mastered =
        ref.watch(lessonMasteryProvider).value?.contains(lesson.id) ?? false;
    final needsMastery = lesson.lessonKind == 'prelude';
    final isEstonian = course.canonicalLanguage == 'et';

    return Scaffold(
      appBar: AppBar(
        title: Text(lesson.title),
        actions: [
          IconButton(
            tooltip: isEstonian ? 'Ava vestlusrežiim' : 'Open chat mode',
            onPressed: () => _openLessonChat(lesson.id),
            icon: const Icon(Icons.chat_bubble_outline),
          ),
        ],
      ),
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
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppTheme.tint,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.accent.withValues(alpha: 0.2)),
            ),
            child: Row(
              children: [
                Icon(Icons.menu_book_outlined, color: AppTheme.accent),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isEstonian ? 'Klassikaline režiim' : 'Classic mode',
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                      Text(
                        isEstonian
                            ? 'Loe, uuri ja lahenda kordamistegevus.'
                            : 'Read, explore, and complete the review activity.',
                      ),
                    ],
                  ),
                ),
                TextButton.icon(
                  onPressed: () => _openLessonChat(lesson.id),
                  icon: const Icon(Icons.chat_bubble_outline, size: 18),
                  label: Text(isEstonian ? 'Vestlus' : 'Chat'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          MarkdownBody(
            data: lesson.contentMarkdown,
            selectable: true,
            onTapLink: (_, href, _) async {
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
          const SizedBox(height: 28),
          _LessonActivitiesSection(
            lesson: lesson,
            language: course.canonicalLanguage,
            onMastered: () =>
                ref.read(lessonMasteryProvider.notifier).mark(lesson.id),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(18, 8, 18, 12),
        child: FilledButton.icon(
          onPressed: needsMastery && !mastered
              ? null
              : () =>
                    ref.read(lessonProgressProvider.notifier).toggle(lesson.id),
          icon: Icon(completed ? Icons.undo : Icons.check),
          label: Text(
            completed
                ? isEstonian
                      ? 'Märgi lõpetamata'
                      : 'Mark as not completed'
                : needsMastery && !mastered
                ? isEstonian
                      ? 'Lahenda tegevus, et tund lõpetada'
                      : 'Pass the activity to complete'
                : isEstonian
                ? 'Märgi tund lõpetatuks'
                : 'Mark lesson complete',
          ),
        ),
      ),
    );
  }
}

class _LessonActivitiesSection extends ConsumerWidget {
  final Lesson lesson;
  final String language;
  final VoidCallback onMastered;

  const _LessonActivitiesSection({
    required this.lesson,
    required this.language,
    required this.onMastered,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activities = ref.watch(lessonActivitiesProvider(lesson.id));
    return activities.when(
      loading: () => const Padding(
        padding: EdgeInsets.all(20),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (_, _) => Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Activities could not load on this connection.'),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () =>
                    ref.invalidate(lessonActivitiesProvider(lesson.id)),
                child: const Text('Try again'),
              ),
            ],
          ),
        ),
      ),
      data: (data) {
        if (data.exercises.isEmpty && data.visualizations.isEmpty) {
          return const SizedBox.shrink();
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              language == 'et' ? 'Uuri ja harjuta' : 'Explore and practise',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 10),
            for (final visualization in data.visualizations) ...[
              LessonVisualizationCard(visualization: visualization),
              const SizedBox(height: 12),
            ],
            for (final exercise in data.exercises) ...[
              GuidedExerciseCard(
                exercise: exercise,
                language: language,
                onMastered: onMastered,
              ),
              const SizedBox(height: 12),
            ],
          ],
        );
      },
    );
  }
}

class GuidedExerciseCard extends ConsumerStatefulWidget {
  final GuidedExercise exercise;
  final String language;
  final VoidCallback? onMastered;

  const GuidedExerciseCard({
    super.key,
    required this.exercise,
    this.language = 'en',
    this.onMastered,
  });

  @override
  ConsumerState<GuidedExerciseCard> createState() => _GuidedExerciseCardState();
}

class _GuidedExerciseCardState extends ConsumerState<GuidedExerciseCard> {
  int? _choice;
  bool _checking = false;
  String? _result;
  final _numberController = TextEditingController();
  final _textController = TextEditingController();
  final _protonController = TextEditingController(text: '0');
  final _neutronController = TextEditingController(text: '0');
  final _electronController = TextEditingController(text: '0');
  final List<TextEditingController> _coefficientControllers = [];

  @override
  void initState() {
    super.initState();
    _coefficientControllers.addAll([
      for (final _ in widget.exercise.equation)
        TextEditingController(text: '1'),
    ]);
  }

  @override
  void dispose() {
    _numberController.dispose();
    _textController.dispose();
    _protonController.dispose();
    _neutronController.dispose();
    _electronController.dispose();
    for (final controller in _coefficientControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  Map<String, dynamic>? _answer() {
    final exercise = widget.exercise;
    if (_choice != null) return {'choice': _choice};
    if (exercise.exerciseType == 'equation_balance') {
      final values = _coefficientControllers
          .map((controller) => int.tryParse(controller.text))
          .toList();
      return values.any((value) => value == null)
          ? null
          : {'coefficients': values.cast<int>()};
    }
    if (exercise.exerciseType == 'atom_builder') {
      final protons = int.tryParse(_protonController.text);
      final neutrons = int.tryParse(_neutronController.text);
      final electrons = int.tryParse(_electronController.text);
      return protons == null || neutrons == null || electrons == null
          ? null
          : {'protons': protons, 'neutrons': neutrons, 'electrons': electrons};
    }
    if (exercise.exerciseType == 'mole_calculation' ||
        exercise.exerciseType == 'numeric_calculation') {
      final value = double.tryParse(_numberController.text);
      return value == null ? null : {'value': value};
    }
    if (exercise.exerciseType == 'formula_builder' ||
        exercise.exerciseType == 'short_answer') {
      final value = _textController.text.trim();
      return value.isEmpty ? null : {'text': value};
    }
    return null;
  }

  Future<void> _check() async {
    final answer = _answer();
    if (answer == null) {
      setState(() => _result = 'Choose or enter an answer first.');
      return;
    }
    setState(() {
      _checking = true;
      _result = null;
    });
    try {
      final verdict = await ref
          .read(learningServiceProvider)
          .checkExercise(widget.exercise.id, answer, language: widget.language);
      if (mounted) {
        if (verdict.correct) widget.onMastered?.call();
        setState(() {
          final fallback = widget.language == 'et'
              ? verdict.correct
                    ? 'Õige — tubli töö.'
                    : 'Veel mitte päris. Vaata õppetund uuesti üle ja proovi veel.'
              : verdict.correct
              ? 'Correct — well done.'
              : 'Not quite. Re-read the lesson and try again.';
          _result = verdict.explanation.isEmpty
              ? fallback
              : '${verdict.correct ? (widget.language == 'et' ? 'Õige.' : 'Correct.') : (widget.language == 'et' ? 'Veel mitte päris.' : 'Not quite.')} ${verdict.explanation}';
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _result = 'Could not check this answer. Try again.');
      }
    } finally {
      if (mounted) {
        setState(() => _checking = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final exercise = widget.exercise;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              exercise.ui['level'] ?? 'Guided activity',
              style: TextStyle(
                color: AppTheme.accent,
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
            if (exercise.molecule != null) ...[
              const SizedBox(height: 12),
              _MoleculeDiagram(
                molecule: exercise.molecule!,
                scene: exercise.scene,
              ),
            ],
            if (exercise.chart == 'ir-oh') ...[
              const SizedBox(height: 12),
              const _SpectrumHint(),
            ],
            const SizedBox(height: 12),
            Text(
              exercise.prompt,
              style: const TextStyle(fontSize: 16, height: 1.4),
            ),
            const SizedBox(height: 10),
            _answerFields(exercise),
            if (_result != null) ...[
              const SizedBox(height: 12),
              Text(
                _result!,
                style: TextStyle(
                  color:
                      _result!.startsWith('Correct') ||
                          _result!.startsWith('Õige')
                      ? AppTheme.green600
                      : AppTheme.gray500,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
            const SizedBox(height: 14),
            FilledButton(
              onPressed: _checking ? null : _check,
              child: Text(
                _checking
                    ? 'Checking…'
                    : exercise.ui['check'] ?? 'Check answer',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _answerFields(GuidedExercise exercise) {
    if (exercise.choices.isNotEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var index = 0; index < exercise.choices.length; index++) ...[
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                alignment: Alignment.centerLeft,
                backgroundColor: _choice == index
                    ? AppTheme.accent
                    : Colors.white,
                foregroundColor: _choice == index ? Colors.white : AppTheme.ink,
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
              ),
              onPressed: () => setState(() => _choice = index),
              child: Row(
                children: [
                  Icon(
                    _choice == index
                        ? Icons.radio_button_checked
                        : Icons.radio_button_off,
                    size: 18,
                  ),
                  const SizedBox(width: 10),
                  Expanded(child: Text(exercise.choices[index])),
                ],
              ),
            ),
            if (index < exercise.choices.length - 1) const SizedBox(height: 8),
          ],
        ],
      );
    }
    if (exercise.exerciseType == 'equation_balance') {
      return Wrap(
        spacing: 8,
        runSpacing: 8,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          for (var index = 0; index < exercise.equation.length; index++) ...[
            SizedBox(
              width: 58,
              child: TextField(
                controller: _coefficientControllers[index],
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: exercise.ui['coefficient'] ?? 'Coefficient',
                ),
              ),
            ),
            Text(
              exercise.equation[index],
              style: const TextStyle(fontSize: 18),
            ),
            if (index < exercise.operators.length)
              Text(
                exercise.operators[index],
                style: const TextStyle(fontSize: 18),
              ),
          ],
        ],
      );
    }
    if (exercise.exerciseType == 'atom_builder') {
      return Row(
        children: [
          Expanded(
            child: _numberField(
              _protonController,
              exercise.ui['protons'] ?? 'Protons',
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _numberField(
              _neutronController,
              exercise.ui['neutrons'] ?? 'Neutrons',
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _numberField(
              _electronController,
              exercise.ui['electrons'] ?? 'Electrons',
            ),
          ),
        ],
      );
    }
    if (exercise.exerciseType == 'formula_builder' ||
        exercise.exerciseType == 'short_answer') {
      return TextField(
        controller: _textController,
        autocorrect: false,
        decoration: InputDecoration(
          labelText: exercise.ui['text_answer'] ?? 'Type your answer',
        ),
      );
    }
    return _numberField(
      _numberController,
      '${exercise.ui['answer'] ?? 'Answer'}${exercise.unit == null ? '' : ' (${exercise.unit})'}',
      decimal: true,
    );
  }

  Widget _numberField(
    TextEditingController controller,
    String label, {
    bool decimal = false,
  }) => TextField(
    controller: controller,
    keyboardType: TextInputType.numberWithOptions(decimal: decimal),
    decoration: InputDecoration(labelText: label),
  );
}

class _MoleculeDiagram extends StatelessWidget {
  final String molecule;
  final String? scene;

  const _MoleculeDiagram({required this.molecule, this.scene});

  @override
  Widget build(BuildContext context) => Container(
    height: 130,
    alignment: Alignment.center,
    decoration: BoxDecoration(
      color: AppTheme.tint,
      borderRadius: BorderRadius.circular(16),
    ),
    child: CustomPaint(
      size: const Size(220, 120),
      painter: _MoleculePainter(
        molecule: molecule,
        particleState: scene == 'particle-state',
      ),
      child: Semantics(
        label: molecule == 'water'
            ? 'A simple molecular model of water with one oxygen and two hydrogen atoms.'
            : 'A simple molecular model.',
      ),
    ),
  );
}

class _MoleculePainter extends CustomPainter {
  final String molecule;
  final bool particleState;

  const _MoleculePainter({required this.molecule, required this.particleState});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final hydrogens = [
      Offset(center.dx - 58, center.dy + 30),
      Offset(center.dx + 58, center.dy + 30),
    ];
    final bond = Paint()
      ..color = AppTheme.gray400
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;
    for (final hydrogen in hydrogens) {
      canvas.drawLine(center, hydrogen, bond);
    }
    canvas.drawCircle(center, 29, Paint()..color = AppTheme.red600);
    for (final hydrogen in hydrogens) {
      canvas.drawCircle(hydrogen, 20, Paint()..color = Colors.white);
      canvas.drawCircle(
        hydrogen,
        20,
        Paint()
          ..style = PaintingStyle.stroke
          ..color = AppTheme.gray200,
      );
    }
    final label = TextPainter(textDirection: TextDirection.ltr);
    for (final item in [
      (center, 'O'),
      (hydrogens[0], 'H'),
      (hydrogens[1], 'H'),
    ]) {
      final position = item.$1;
      label.text = TextSpan(
        text: item.$2,
        style: TextStyle(
          color: position == center ? Colors.white : AppTheme.ink,
          fontWeight: FontWeight.w900,
        ),
      );
      label.layout();
      label.paint(canvas, position - Offset(label.width / 2, label.height / 2));
    }
    if (particleState) {
      label.text = TextSpan(
        text: 'Tap an answer after exploring the particle model',
        style: TextStyle(color: AppTheme.gray500, fontSize: 11),
      );
      label.layout(maxWidth: size.width);
      label.paint(canvas, Offset((size.width - label.width) / 2, 4));
    }
  }

  @override
  bool shouldRepaint(covariant _MoleculePainter oldDelegate) =>
      molecule != oldDelegate.molecule ||
      particleState != oldDelegate.particleState;
}

class _SpectrumHint extends StatelessWidget {
  const _SpectrumHint();

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: AppTheme.tint,
      borderRadius: BorderRadius.circular(12),
    ),
    child: const Row(
      children: [
        Icon(Icons.show_chart),
        SizedBox(width: 10),
        Expanded(
          child: Text(
            'IR clue: a broad O–H absorption appears around 3200–3600 cm⁻¹.',
          ),
        ),
      ],
    ),
  );
}
