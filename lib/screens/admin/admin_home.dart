import 'package:flutter/material.dart';
import 'package:projet_mobile/screens/admin/classes_screen.dart';
import 'package:projet_mobile/screens/admin/enseignnts_screen.dart';
import 'package:projet_mobile/screens/admin/etudiants_screen.dart';
import 'package:projet_mobile/screens/admin/seances_screen.dart';

class AdminHome extends StatefulWidget {
  const AdminHome({super.key});

  @override
  State<AdminHome> createState() => _AdminHomeState();
}

class _AdminHomeState extends State<AdminHome> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    EtudiantsScreen(),
    EnseignantsScreen(),
    ClassessScreen(),
    SeancesScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Admin Home"),
      ),

      // 🔥 ICI on affiche la vraie page sélectionnée
      body: _screens[_currentIndex],

      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,

        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },

        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.people),
            label: "Étudiants",
          ),
          NavigationDestination(
            icon: Icon(Icons.assignment_ind),
            label: "Enseignants",
          ),
          NavigationDestination(
            icon: Icon(Icons.school),
            label: "Classes",
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_month),
            label: "Séances",
          ),
        ],
      ),
    );
  }
}