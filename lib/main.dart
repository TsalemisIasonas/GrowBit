import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/app_provider.dart';
import 'screens/dashboard_screen.dart';
import 'screens/category_screen.dart';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService().init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AppProvider()..load(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Goals & Habits',
        theme: ThemeData(
          
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF64FFDA),brightness: Brightness.dark,),
          useMaterial3: true,
          scaffoldBackgroundColor: const Color(0xFF0B0E14),
        ),
        initialRoute: '/',
        routes: {
          '/': (_) => const _RootShell(),
        },
        onGenerateRoute: (settings) {
          if (settings.name == CategoryScreen.routeName) {
            final args = settings.arguments as Map<String, dynamic>;
            return MaterialPageRoute(
              builder: (_) => CategoryScreen(categoryId: args['id'] as String),
            );
          }
          return null;
        },
      ),
    );
  }
}

class _RootShell extends StatelessWidget {
  const _RootShell();

  @override
  Widget build(BuildContext context) {
    return const DashboardScreen();
  }
}