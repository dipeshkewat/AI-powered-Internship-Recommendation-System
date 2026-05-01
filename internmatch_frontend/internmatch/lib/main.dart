import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:internmatch/theme/app_theme.dart';
import 'package:internmatch/utils/app_router.dart';

void main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();

    // Set orientation but catch errors
    try {
      await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    } catch (e) {
      debugPrint('Orientation error: $e');
    }

    runApp(const ProviderScope(child: InternMatchApp()));
  } catch (e, stack) {
    debugPrint('Fatal error in main: $e');
    debugPrint(stack.toString());
  }
}

class InternMatchApp extends ConsumerWidget {
  const InternMatchApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'InternMatch',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      routerConfig: router,
    );
  }
}
