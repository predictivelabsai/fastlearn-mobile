import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:carhero/config/theme.dart';
import 'package:carhero/providers/locale_provider.dart';
import 'package:carhero/screens/learning/fastlearn_home_screen.dart';

class FastLearnApp extends ConsumerWidget {
  const FastLearnApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localeCode = ref.watch(localeProvider);

    return MaterialApp(
      title: 'FastLearn',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      locale: Locale(localeCode),
      supportedLocales: const [
        Locale('en'),
        Locale('et'),
        Locale('lt'),
        Locale('es'),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: const FastLearnHomeScreen(),
    );
  }
}
