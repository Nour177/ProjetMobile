import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:projet_mobile/config/api_config.dart';


class ClassessScreen extends StatefulWidget {
    const ClassessScreen({super.key});

  @override
  State<ClassessScreen> createState() => _ClassesScreenState();
}

class _ClassesScreenState extends State<ClassessScreen>{
  
  late Future<List> _classeFutur;

  @override
  void initState() {
    super.initState();
    _refreshClasses();
  }

  void _refreshClasses() {
    setState(() {
      _classeFutur = fetchClasses();
    });
  }

  Future<List> fetchClasses() async {
    try {
      var url = Uri.parse("${ApiConfig.baseUrl}/admin/classes.php");
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
        future: _classeFutur,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("Aucun enseignant trouvé"));
          }

          var classes = snapshot.data!;

          return ListView.builder(
            itemCount: classes.length,
            itemBuilder: (context, index) {
              var classe = classes[index];

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: ListTile(
                  onTap: () => showEditDialog(context, classe),
                  leading: const CircleAvatar(child: Icon(Icons.school)),
                  title: Text("${classe["nom"]}"),
                  subtitle: Text("${classe["niveau"]}"),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.redAccent),
                    onPressed: () => { _confirmDelete(classe),}
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
        content: Text("Voulez-vous vraiment supprimer la classe: ${ens["nom"]} ?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Annuler")),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteClasse(ens["id"].toString());
            },
            child: const Text("Supprimer", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
  Future<void> _deleteClasse(String id) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    var url = Uri.parse("${ApiConfig.baseUrl}/admin/delete_classe.php?id=$id");

    try {
      var response = await http.get(url);
      var data = jsonDecode(response.body);

      if (data["success"] == 1) {
        scaffoldMessenger.showSnackBar(const SnackBar(content: Text("classe supprimée")));
        _refreshClasses();
      } else {
        scaffoldMessenger.showSnackBar(SnackBar(content: Text(data["message"])));
      }
    } catch (e) {
      scaffoldMessenger.showSnackBar(const SnackBar(content: Text("Erreur de connexion")));
    }
  }
  void showAddDialog(BuildContext context) {
    TextEditingController nom = TextEditingController();
    TextEditingController niveau = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Ajouter classe"),
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
                  controller: niveau,
                  decoration: InputDecoration(labelText: "Niveau"),
                ),
                SizedBox(height: 10)
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
                  "${ApiConfig.baseUrl}/admin/add_classes.php",
                );

                try {
                  var response = await http.post(
                    url,
                    body: {
                      "nom": nom.text,
                      "niveau": niveau.text,
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
                _refreshClasses();
              },
              child: const Text("Ajouter"),
            ),
          ],
        );
      },
    );
  }
   void showEditDialog(BuildContext context, dynamic e) {
    TextEditingController nom = TextEditingController(text: e["nom"]);
    TextEditingController niveau = TextEditingController(text: e["niveau"]);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Modifier classe"),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: nom,
                  decoration: const InputDecoration(labelText: "Nom"),
                ),
                SizedBox(height: 10),
                TextField(
                  controller: niveau,
                  decoration: const InputDecoration(labelText: "Niveau"),
                ),
                SizedBox(height: 10),
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
                  "${ApiConfig.baseUrl}/admin/update_classe.php",
                );

                try {
                  var response = await http.put(
                    url,
                    headers: {"Content-Type": "application/json"},
                    body: jsonEncode({
                      "id": e["id"].toString(),
                      "nom": nom.text,
                      "niveau": niveau.text,
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
                _refreshClasses();
              },
              child: const Text("Modifier"),
            ),
          ],
        );
      },
    );
  }

}
