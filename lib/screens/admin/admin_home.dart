import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:projet_mobile/config/api_config.dart';
import 'package:projet_mobile/main.dart';
import 'package:projet_mobile/screens/admin/classes_screen.dart';
import 'package:projet_mobile/screens/admin/enseignnts_screen.dart';
import 'package:projet_mobile/screens/admin/etudiants_screen.dart';
import 'package:projet_mobile/screens/admin/seances_screen.dart';
import 'package:projet_mobile/services/auth_service.dart';
import 'package:provider/provider.dart';

class AdminHome extends StatefulWidget {
  const AdminHome({super.key});

  @override
  State<AdminHome> createState() => _AdminHomeState();
}

class _AdminHomeState extends State<AdminHome> {
  int _currentIndex = 0;
  List<dynamic> _resultats = [];
  bool _SearchAPI = false;
  bool _Searching = false;
  final TextEditingController _searchController = TextEditingController();

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
        leading: const Icon(Icons.admin_panel_settings),
        title: _Searching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                onChanged: _chercherUtilisateur,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
                decoration: InputDecoration(
                  hintText: "Chercher un utilisateur...",
                  border: InputBorder.none,
                  filled: false,
                ),
              )
            : const Text("Gestion des absences: Admin"),
        actions: [
          IconButton(
            icon: Icon(_Searching ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                if (_Searching) {
                  _Searching = false;
                  _searchController.clear();
                  _resultats.clear();
                } else {
                  _Searching = true;
                }
              });
            },
          ),
          IconButton(
            icon: Icon(
              context.watch<ThemeProvider>().themeMode == ThemeMode.dark
                  ? Icons.light_mode
                  : Icons.dark_mode,
            ),
            onPressed: () => context.read<ThemeProvider>().toggle(),
          ),
          IconButton(
            onPressed: () {
              AuthService.logout(context);
            },
            icon: Icon(Icons.logout),
          ),
        ],
      ),

      body: _Searching
          ? Column(
              children: [
                if (_SearchAPI)
                  const Padding(
                    padding: EdgeInsets.all(20.0),
                    child: CircularProgressIndicator(),
                  )
                else if (_resultats.isEmpty &&
                    _searchController.text.isNotEmpty)
                  const Padding(
                    padding: EdgeInsets.all(20.0),
                    child: Text("Aucun résultat trouvé."),
                  )
                else if (_resultats.isNotEmpty)
                  Expanded(
                    child: ListView.builder(
                      itemCount: _resultats.length,
                      itemBuilder: (context, index) {
                        final user = _resultats[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          child: ListTile(
                            leading: Icon(
                              user['role'] == 'etudiant'
                                  ? Icons.person
                                  : Icons.school,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            title: Text("${user['prenom']} ${user['nom']}"),
                            subtitle: Text(
                              "${user['email']} • Rôle: ${user['role']}",
                            ),
                            trailing: const Icon(
                              Icons.arrow_forward_ios,
                              size: 16,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
              ],
            )
          : _screens[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,

        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },

        destinations: const [
          NavigationDestination(icon: Icon(Icons.people), label: "Étudiants"),
          NavigationDestination(
            icon: Icon(Icons.assignment_ind),
            label: "Enseignants",
          ),
          NavigationDestination(icon: Icon(Icons.school), label: "Classes"),
          NavigationDestination(
            icon: Icon(Icons.calendar_month),
            label: "Séances",
          ),
        ],
      ),
    );
  }

  Future<void> _chercherUtilisateur(String query) async {
    if (query.isEmpty) {
      setState(() => _resultats = []);
      return;
    }

    setState(() => _SearchAPI = true);

    try {
      final url = Uri.parse(
        "${ApiConfig.baseUrl}/admin/recherche.php?query=$query",
      );
      final response = await http.get(url);
      final data = jsonDecode(response.body);

      if (data['success'] == 1) {
        setState(() {
          _resultats = data['data'];
        });
      }
    } catch (e) {
      debugPrint("Erreur de recherche : $e");
    } finally {
      setState(() => _SearchAPI = false);
    }
  }
}
