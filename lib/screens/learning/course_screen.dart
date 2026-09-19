import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:carhero/config/theme.dart';
import 'package:carhero/models/learning.dart';
import 'package:carhero/providers/learning_provider.dart';
import 'package:carhero/widgets/learning/lesson_visualization.dart';

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
        error: (_, _) => Center(
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
                    subtitle: Text(_lessonSummary(module.lessons[index])),
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
          _LessonActivitiesSection(lesson: lesson),
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

class _LessonActivitiesSection extends ConsumerWidget {
  final Lesson lesson;

  const _LessonActivitiesSection({required this.lesson});

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
              'Explore and practise',
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
              GuidedExerciseCard(exercise: exercise),
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

  const GuidedExerciseCard({super.key, required this.exercise});

  @override
  ConsumerState<GuidedExerciseCard> createState() => _GuidedExerciseCardState();
}

class _GuidedExerciseCardState extends ConsumerState<GuidedExerciseCard> {
  int? _choice;
  bool _checking = false;
  String? _result;
  final _numberController = TextEditingController();
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
    if (exercise.exerciseType == 'mole_calculation') {
      final value = double.tryParse(_numberController.text);
      return value == null ? null : {'value': value};
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
          .checkExercise(widget.exercise.id, answer);
      if (mounted) {
        setState(() {
          _result = verdict.correct
              ? 'Correct — well done.'
              : 'Not quite. Re-read the lesson and try again.';
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
                  color: _result!.startsWith('Correct')
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
      return Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          for (var index = 0; index < exercise.choices.length; index++)
            ChoiceChip(
              label: Text(exercise.choices[index]),
              selected: _choice == index,
              onSelected: (_) => setState(() => _choice = index),
            ),
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
            if (index == 0) const Text('+', style: TextStyle(fontSize: 18)),
            if (index == 1) const Text('→', style: TextStyle(fontSize: 18)),
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
