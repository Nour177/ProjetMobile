import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:projet_mobile/config/api_config.dart';

class EtudiantsScreen extends StatefulWidget {
  const EtudiantsScreen({super.key});

  @override
  State<EtudiantsScreen> createState() => _EtudiantsScreenState();
}

class _EtudiantsScreenState extends State<EtudiantsScreen> {
  late Future<List> _etudiantsFuture;

  @override
  void initState() {
    super.initState();
    _refreshEtudiants();
  }

  void _refreshEtudiants() {
    setState(() {
      _etudiantsFuture = fetchEtudiants();
    });
  }

  Future<List> fetchEtudiants() async {
    try {
      var url = Uri.parse("${ApiConfig.baseUrl}/admin/etudiants.php");
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
        future: _etudiantsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("Aucun étudiant"));
          }

          var etudiants = snapshot.data!;

          return ListView.builder(
            itemCount: etudiants.length,
            itemBuilder: (context, index) {
              var e = etudiants[index];

              return Card(
                child: ListTile(
                  leading: const Icon(Icons.person),
                  title: Text("${e["nom"]} ${e["prenom"]}"),
                  subtitle: Text("${e["email"]}\nClasse: ${e["classe"] ?? ""}"),
                  onTap: () {
                    showEditDialog(context, e);
                  },
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.redAccent),
                    onPressed: (){
                      _confirmDelete(e);
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showAddDialog(context);
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  void showEditDialog(BuildContext context, dynamic e) {
    TextEditingController nom = TextEditingController(text: e["nom"]);
    TextEditingController prenom = TextEditingController(text: e["prenom"]);
    TextEditingController email = TextEditingController(text: e["email"]);
    TextEditingController passwor = TextEditingController();
    TextEditingController classe = TextEditingController(
      text: e["classe"]?.toString() ?? "",
    );

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Modifier étudiant"),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: nom,
                  decoration: const InputDecoration(labelText: "Nom"),
                ),
                SizedBox(height: 10),
                TextField(
                  controller: prenom,
                  decoration: const InputDecoration(labelText: "Prénom"),
                ),
                SizedBox(height: 10),
                TextField(
                  controller: email,
                  decoration: const InputDecoration(labelText: "Email"),
                ),
                SizedBox(height: 10),
                TextField(
                  controller: classe,
                  decoration: const InputDecoration(labelText: "Classe"),
                ),
                SizedBox(height: 10),
                TextField(
                  controller: passwor,
                  decoration: const InputDecoration(
                    labelText: "Nouveau mot de passe",
                  ),
                  obscureText: true,
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
                var url = Uri.parse(
                  "${ApiConfig.baseUrl}/admin/update_etudiant.php",
                );

                try {
                  var response = await http.put(
                    url,
                    headers: {"Content-Type": "application/json"},
                    body: jsonEncode({
                      "id": e["id"].toString(),
                      "nom": nom.text,
                      "prenom": prenom.text,
                      "email": email.text,
                      "classe": classe.text,
                      "NPD": passwor.text,
                    }),
                  );
                  var data = jsonDecode(response.body);
                  if (!context.mounted) return;

                  if (data["success"] == 1) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Modification réussie")),
                    );
                  }else{
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(data["message"])),
                    );
                  }
                } catch (error) {
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Erreur de connexion")),
                  );
                }

                Navigator.pop(context);
                _refreshEtudiants();
              },
              child: const Text("Modifier"),
            ),
          ],
        );
      },
    );
  }

  void showAddDialog(BuildContext context) {
    TextEditingController nom = TextEditingController();
    TextEditingController prenom = TextEditingController();
    TextEditingController email = TextEditingController();
    TextEditingController password = TextEditingController();
    TextEditingController classe = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Ajouter étudiant"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                TextField(
                  controller: nom,
                  decoration: InputDecoration(labelText: "Nom"),
                ),
                SizedBox(height: 10),
                TextField(
                  controller: prenom,
                  decoration: InputDecoration(labelText: "Prénom"),
                ),
                SizedBox(height: 10),
                TextField(
                  controller: email,
                  decoration: InputDecoration(labelText: "Email"),
                ),
                SizedBox(height: 10),
                TextField(
                  controller: password,
                  obscureText: true,
                  decoration: InputDecoration(labelText: "Mot de passe"),
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
                var url = Uri.parse(
                  "${ApiConfig.baseUrl}/admin/add_etudiant.php",
                );

                try {
                  var response = await http.post(
                    url,
                    body: {
                      "nom": nom.text,
                      "prenom": prenom.text,
                      "email": email.text,
                      "password": password.text,
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
                _refreshEtudiants();
              },
              child: const Text("Ajouter"),
            ),
          ],
        );
      },
    );
  }

  void _confirmDelete(dynamic e) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Suppression"),
        content: Text("Voulez-vous vraiment supprimer ${e["nom"]} ?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Annuler"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteEtudiant(e["id"]);
            },
            child: const Text("Supprimer", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteEtudiant(String id) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    var url = Uri.parse(
      "${ApiConfig.baseUrl}/admin/delete_etudiant.php?id=$id",
    );
    try {
      var response = await http.get(url);

      var data = jsonDecode(response.body);

      if (!context.mounted) return;

      if (data["success"] == 1) {
        scaffoldMessenger.showSnackBar(
          SnackBar(content: Text("Supression réussie")),
        );
        _refreshEtudiants();
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
  }
}
