import 'package:flutter/material.dart';
import 'package:projet_mobile/services/auth_service.dart';
import 'mes_seances_screen.dart';

import 'package:projet_mobile/main.dart';
import 'package:provider/provider.dart';
class EnseignantHome extends StatefulWidget {
  const EnseignantHome({super.key, required this.enseignantId});
  final int enseignantId;

  @override
  State<EnseignantHome> createState() => _EnseignantHomeState();
}

class _EnseignantHomeState extends State<EnseignantHome> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const Icon(Icons.school),
        title: const Text("Gestion des absences: Enseignant"),
        actions: [
          IconButton(
            icon: Icon(
              context.watch<ThemeProvider>().themeMode == ThemeMode.dark
                  ? Icons.light_mode
                  : Icons.dark_mode,
            ),
            onPressed: () => context.read<ThemeProvider>().toggle(),
          ),
          IconButton(onPressed: () {
            AuthService.logout(context);
          }, icon: Icon(Icons.logout))
        ],
      ),

      body: MesSeancesScreen(enseignantId: widget.enseignantId),
    );
  }
}