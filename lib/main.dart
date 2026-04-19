import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'screens/enseignant/enseignant_home.dart';
import 'screens/etudiant/etudiant_home.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      child: const GestAbsenceApp(),
    ),
  );
}

class GestAbsenceApp extends StatelessWidget {
  const GestAbsenceApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final seed = Colors.green;

    return MaterialApp(
      title: 'Gestion des absences',
      debugShowCheckedModeBanner: false,
      themeMode: themeProvider.themeMode,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: seed),
        appBarTheme: AppBarTheme(backgroundColor: seed),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: seed,
          brightness: Brightness.dark,
        ),
        appBarTheme: AppBarTheme(backgroundColor: seed),
      ),
      initialRoute: '/enseignant',
      routes: {
        '/enseignant': (context) => const EnseignantHome(),
        '/etudiant': (context) => const EtudiantHome(),
      },
    );
  }
}

class ThemeProvider extends ChangeNotifier {
  ThemeMode themeMode = ThemeMode.light;

  void toggle() {
    if (themeMode == ThemeMode.light) {
      themeMode = ThemeMode.dark;
    } else {
      themeMode = ThemeMode.light;
    }
    notifyListeners();
  }
}
