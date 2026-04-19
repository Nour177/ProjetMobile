import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:projet_mobile/config/api_config.dart';
import 'package:http/http.dart' as http;

class EnseignantsScreen extends StatefulWidget {
  const EnseignantsScreen({super.key});

  @override
  State<EnseignantsScreen> createState() => _EnseignantsScreenState();
}

class _EnseignantsScreenState extends State<EnseignantsScreen> {
  late Future<List> _enseignantsFuture;

  @override
  void initState() {
    super.initState();
    _refreshEnseignants();
  }

  void _refreshEnseignants() {
    setState(() {
      _enseignantsFuture = fetchEnseignants();
    });
  }

  Future<List> fetchEnseignants() async {
    try {
      var url = Uri.parse("${ApiConfig.baseUrl}/admin/enseigants.php");
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
        future: _enseignantsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("Aucun enseignant trouvé"));
          }

          var enseignants = snapshot.data!;

          return ListView.builder(
            itemCount: enseignants.length,
            itemBuilder: (context, index) {
              var ens = enseignants[index];

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: ListTile(
                  onTap: () => showEditDialog(context,ens),
                  leading: const CircleAvatar(child: Icon(Icons.school)),
                  title: Text("${ens["nom"]} ${ens["prenom"]}"),
                  subtitle: Text("${ens["email"]}\nSpécialité: ${ens["specialite"] ?? "N/A"}"),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.redAccent),
                    onPressed: () => _confirmDelete(ens),
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

  void _confirmDelete(dynamic ens) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Suppression"),
        content: Text("Voulez-vous vraiment supprimer M. ${ens["nom"]} ?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Annuler")),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteEnseignant(ens["id"].toString());
            },
            child: const Text("Supprimer", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteEnseignant(String id) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    var url = Uri.parse("${ApiConfig.baseUrl}/admin/delete_enseignant.php?id=$id");

    try {
      var response = await http.get(url);
      var data = jsonDecode(response.body);

      if (data["success"] == 1) {
        scaffoldMessenger.showSnackBar(const SnackBar(content: Text("Enseignant supprimé")));
        _refreshEnseignants();
      } else {
        scaffoldMessenger.showSnackBar(SnackBar(content: Text(data["message"])));
      }
    } catch (e) {
      scaffoldMessenger.showSnackBar(const SnackBar(content: Text("Erreur de connexion")));
    }
  }
  void showEditDialog(BuildContext context, dynamic e) {
    TextEditingController nom = TextEditingController(text: e["nom"]);
    TextEditingController prenom = TextEditingController(text: e["prenom"]);
    TextEditingController email = TextEditingController(text: e["email"]);
    TextEditingController passwor = TextEditingController();
    TextEditingController specialite = TextEditingController(text: e["specialite"]?.toString() ?? "",);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Modifier enseignant"),
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
                  controller: specialite,
                  decoration: const InputDecoration(labelText: "specialité"),
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
                  "${ApiConfig.baseUrl}/admin/update_enseignant.php",
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
                      "specialite": specialite.text,
                      "NPD": passwor.text,
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
                _refreshEnseignants();
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
    TextEditingController specialite = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Ajouter enseignant"),
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
                  controller: specialite,
                  decoration: InputDecoration(labelText: "Specialité"),
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
                  "${ApiConfig.baseUrl}/admin/add_enseignant.php",
                );

                try {
                  var response = await http.post(
                    url,
                    body: {
                      "nom": nom.text,
                      "prenom": prenom.text,
                      "email": email.text,
                      "password": password.text,
                      "specialite": specialite.text,
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
                _refreshEnseignants();
              },
              child: const Text("Ajouter"),
            ),
          ],
        );
      },
    );
  }
}