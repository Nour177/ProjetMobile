import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:projet_mobile/config/api_config.dart';
import 'package:http/http.dart' as http;

class SeancesScreen extends StatefulWidget {
  const SeancesScreen({super.key});

  @override
  State<SeancesScreen> createState() => _SeancesScreenState();
}

class _SeancesScreenState extends State<SeancesScreen> {
  late Future<List> _seancesFutur;

  @override
  void initState() {
    super.initState();
    _refreshSeances();
  }

  void _refreshSeances() {
    setState(() {
      _seancesFutur = fetchSeances();
    });
  }

  Future<List> fetchSeances() async {
    try {
      var url = Uri.parse("${ApiConfig.baseUrl}/admin/seances.php");
      var response = await http.get(url);
      var data = jsonDecode(response.body);

      if (data["success"] == 1) {
        return data["data"] ?? [];
      } else {
        return [];
      }
    } catch (e) {
      debugPrint("Erreur lors de la récupération : $e");
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<List>(
        future: _seancesFutur,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("Aucune séance trouvée"));
          }

          var seances = snapshot.data!;

          return ListView.builder(
            itemCount: seances.length,
            itemBuilder: (context, index) {
              var seance = seances[index];

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: ListTile(
                  onTap: () => showEditDialog(context, seance),
                  leading: const CircleAvatar(child: Icon(Icons.event)),
                  title: Text("${seance["matiere"]} - ${seance["classe"]}"),
                  subtitle: Text(
                    "M.${seance["enseignant"]} - le: ${seance["date_seance"]} de ${seance["heure_debut"]} à ${seance["heure_fin"]}",
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.redAccent),
                    onPressed: () => {_confirmDelete(seance)},
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showAddDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _confirmDelete(dynamic ens) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Suppression"),
        content: Text(
          "Voulez-vous vraiment supprimer la séance: ${ens["nom"]} ?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Annuler"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteSeance(ens["id"].toString());
            },
            child: const Text("Supprimer", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteSeance(String id) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    var url = Uri.parse("${ApiConfig.baseUrl}/admin/delete_seance.php?id=$id");

    try {
      var response = await http.get(url);
      var data = jsonDecode(response.body);

      if (data["success"] == 1) {
        scaffoldMessenger.showSnackBar(
          const SnackBar(content: Text("séance supprimée")),
        );
        _refreshSeances();
      } else {
        scaffoldMessenger.showSnackBar(
          SnackBar(content: Text(data["message"])),
        );
      }
    } catch (e) {
      scaffoldMessenger.showSnackBar(
        const SnackBar(content: Text("Erreur de connexion")),
      );
    }
  }

  void showAddDialog(BuildContext context) {
    TextEditingController matiere = TextEditingController();
    TextEditingController enseignant = TextEditingController();
    TextEditingController date = TextEditingController();
    TextEditingController heure_debut = TextEditingController();
    TextEditingController heure_fin = TextEditingController();
    TextEditingController classe = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Ajouter Séance"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                TextField(
                  controller: matiere,
                  decoration: InputDecoration(labelText: "Matiere"),
                ),
                SizedBox(height: 10),
                TextField(
                  controller: enseignant,
                  decoration: InputDecoration(labelText: "Enseignant"),
                ),
                SizedBox(height: 10),
                TextField(
                  controller: date,
                  readOnly: true,
                  onTap: () => _selectDate(context, date),
                  decoration: InputDecoration(labelText: "Date"),
                ),
                SizedBox(height: 10),
                TextField(
                  controller: heure_debut,
                  readOnly: true,
                  onTap: () => _selectTime(context, heure_debut),
                  decoration: InputDecoration(labelText: "Heure de début"),
                ),
                SizedBox(height: 10),
                TextField(
                  controller: heure_fin,
                  readOnly: true,
                  onTap: () => _selectTime(context, heure_fin),
                  decoration: InputDecoration(labelText: "Heure de fin"),
                ),
                SizedBox(height: 10),
                TextField(
                  controller: classe,
                  decoration: InputDecoration(labelText: "Classe"),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Annuler"),
            ),
            FilledButton(
              onPressed: () async {
                final scaffoldMessenger = ScaffoldMessenger.of(context);
                final navigator = Navigator.of(context);
                if (heure_debut.text.compareTo(heure_fin.text) >= 0) {
                  scaffoldMessenger.showSnackBar(
                    const SnackBar(
                      content: Text(
                        "L'heure de début doit être avant l'heure de fin !",
                      ),
                      backgroundColor: Colors.redAccent,
                    ),
                  );
                  return;
                }
                var url = Uri.parse(
                  "${ApiConfig.baseUrl}/admin/add_seance.php",
                );

                try {
                  var response = await http.post(
                    url,
                    body: {
                      "matiere": matiere.text,
                      "enseignant": enseignant.text,
                      "date_seance": date.text,
                      "heure_debut": heure_debut.text,
                      "heure_fin": heure_fin.text,
                      "classe": classe.text,
                    },
                  );

                  var data = jsonDecode(response.body);

                  if (!context.mounted) return;

                  if (data["success"] == 1) {
                    scaffoldMessenger.showSnackBar(
                      SnackBar(content: Text("Ajout réussi")),
                    );
                  } else {
                    scaffoldMessenger.showSnackBar(
                      SnackBar(content: Text(data["message"])),
                    );
                  }
                } catch (error) {
                  if (!context.mounted) return;
                  scaffoldMessenger.showSnackBar(
                    SnackBar(content: Text("Erreur de connexion")),
                  );
                }

                navigator.pop(context);
                _refreshSeances();
              },
              child: const Text("Ajouter"),
            ),
          ],
        );
      },
    );
  }

  void showEditDialog(BuildContext context, dynamic e) {
    TextEditingController matiere = TextEditingController(text: e["matiere"]);
    TextEditingController enseignant = TextEditingController(
      text: e["enseignant"],
    );
    TextEditingController date = TextEditingController(text: e["date_seance"]);
    TextEditingController heure_debut = TextEditingController(
      text: e["heure_debut"],
    );
    TextEditingController heure_fin = TextEditingController(
      text: e["heure_fin"],
    );
    TextEditingController classe = TextEditingController(text: e["classe"]);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Modifier séance"),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: matiere,
                  decoration: const InputDecoration(labelText: "Matière"),
                ),
                SizedBox(height: 10),
                TextField(
                  controller: enseignant,
                  decoration: const InputDecoration(labelText: "Enseignant"),
                ),
                SizedBox(height: 10),
                TextField(
                  controller: date,
                  readOnly: true,
                  onTap: () => _selectDate(context, date),
                  decoration: const InputDecoration(labelText: "Date"),
                ),
                SizedBox(height: 10),
                TextField(
                  controller: heure_debut,
                  readOnly: true,
                  onTap: () => _selectTime(context, heure_debut),
                  decoration: const InputDecoration(
                    labelText: "Heure de début",
                  ),
                ),
                SizedBox(height: 10),
                TextField(
                  controller: heure_fin,
                  readOnly: true,
                  onTap: () => _selectTime(context, heure_fin),
                  decoration: const InputDecoration(labelText: "Heure de fin"),
                ),
                SizedBox(height: 10),
                TextField(
                  controller: classe,
                  decoration: const InputDecoration(labelText: "Classe"),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Annuler"),
            ),
            FilledButton(
              onPressed: () async {
                if (heure_debut.text.compareTo(heure_fin.text) >= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        "L'heure de début doit être avant l'heure de fin !",
                      ),
                      backgroundColor: Colors.redAccent,
                    ),
                  );
                  return;
                }
                var url = Uri.parse(
                  "${ApiConfig.baseUrl}/admin/update_seance.php",
                );

                try {
                  var response = await http.put(
                    url,
                    headers: {"Content-Type": "application/json"},
                    body: jsonEncode({
                      "id": e["id"].toString(),
                      "matiere": matiere.text,
                      "enseignant": enseignant.text,
                      "date_seance": date.text,
                      "heure_debut": heure_debut.text,
                      "heure_fin": heure_fin.text,
                      "classe": classe.text,
                    }),
                  );
                  var data = jsonDecode(response.body);
                  if (!context.mounted) return;

                  if (data["success"] == 1) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Modification réussie")),
                    );
                  }
                } catch (error) {
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Erreur de connexion")),
                  );
                }

                Navigator.pop(context);
                _refreshSeances();
              },
              child: const Text("Modifier"),
            ),
          ],
        );
      },
    );
  }

  Future<void> _selectDate(
    BuildContext context,
    TextEditingController date,
  ) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2025),
      lastDate: DateTime(2030),
    );

    if (picked != null) {
      setState(() {
        date.text =
            "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      });
    }
  }

  Future<void> _selectTime(
    BuildContext context,
    TextEditingController controller,
  ) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (picked != null) {
      setState(() {
        final String hour = picked.hour.toString().padLeft(2, '0');
        final String minute = picked.minute.toString().padLeft(2, '0');
        controller.text = "$hour:$minute:00";
      });
    }
  }
}
