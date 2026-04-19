import 'package:flutter/material.dart';

import 'profil_screen.dart';
import 'absences_screen.dart';
import 'package:projet_mobile/main.dart';
import 'package:provider/provider.dart';

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
        leading: const Icon(Icons.home),
        title: const Text('Gestion des absences: Etudiant'),
        actions: [
          IconButton(
            icon: Icon(
              context.watch<ThemeProvider>().themeMode == ThemeMode.dark
                  ? Icons.light_mode
                  : Icons.dark_mode,
            ),
            onPressed: () => context.read<ThemeProvider>().toggle(),
          ),
        ],
      ),

      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        child: pages[_currentIndex],
      ),

      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
        child: NavigationBar(
          height: 65,
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
      ),
    );
  }
}
