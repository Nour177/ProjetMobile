import 'package:flutter/material.dart';

import 'screens/etudiant/etudiant_home.dart';

void main() {
  runApp(const GestAbsenceApp());
}

class GestAbsenceApp extends StatelessWidget {
  const GestAbsenceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gestion des Absences',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      ),
      home: const EtudiantHome(),
    );
  }
}