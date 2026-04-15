import 'package:flutter/material.dart';

import 'profil_screen.dart';
import 'absences_screen.dart';

class EtudiantHome extends StatefulWidget {
  const EtudiantHome({super.key});

  @override
  State<EtudiantHome> createState() => _EtudiantHomeState();
}

class _EtudiantHomeState extends State<EtudiantHome> {
  int _currentIndex = 0;
  final int _etudiantId = 1;

  @override
  Widget build(BuildContext context) {
    final pages = [
      ProfilScreen(etudiantId: _etudiantId),
      AbsencesScreen(etudiantId: _etudiantId),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestion des Absences: Etudiant'),
      ),
      body: pages[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (i) => setState(() => _currentIndex = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profil',
          ),
          NavigationDestination(
            icon: Icon(Icons.event_note_outlined),
            selectedIcon: Icon(Icons.event_note),
            label: 'Absences',
          ),
        ],
      ),
    );
  }
}