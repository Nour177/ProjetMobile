import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../config/api_config.dart';

class AppelScreen extends StatefulWidget {
  final Map<String, dynamic> seance;

  const AppelScreen({super.key, required this.seance});

  @override
  State<AppelScreen> createState() => _AppelScreenState();
}

class _AppelScreenState extends State<AppelScreen> {
  List students = [];
  Map<int, bool> presence = {};

  bool loading = true;
  bool submitting = false;
  String? error;

  int get absents {
    return presence.values.where((v) => v == false).length;
  }

  int id(dynamic v) {
    return int.parse(v.toString());
  }

  @override
  void initState() {
    super.initState();
    loadStudents();
  }

  Future<void> loadStudents() async {
    setState(() {
      loading = true;
      error = null;
    });

    final classeId = widget.seance['classe_id'];

    if (classeId == null) {
      setState(() {
        error = "classe_id manquant";
        loading = false;
      });
      return;
    }

    try {
      final res = await http.get(
        Uri.parse(
          "${ApiConfig.baseUrl}/enseignant/etudiants.php?classe_id=$classeId",
        ),
      );

      final data = jsonDecode(res.body);

      if (data['success'] == 1) {
        final list = data['data'];

        setState(() {
          students = list;
          presence = {for (var e in list) id(e['id']): true};
          loading = false;
        });
      } else {
        setState(() {
          error = data['message'];
          loading = false;
        });
      }
    } catch (e) {
      setState(() {
        error = "Erreur: $e";
        loading = false;
      });
    }
  }

  Future<void> submitAppel() async {
    setState(() => submitting = true);

    try {
      final res = await http.post(
        Uri.parse("${ApiConfig.baseUrl}/enseignant/absences.php"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "seance_id": widget.seance['id'],
          "appel": students.map((e) {
            final studentId = id(e['id']);
            return {
              "etudiant_id": e['id'],
              "statut": (presence[studentId] ?? true) ? "present" : "absent",
            };
          }).toList(),
        }),
      );

      final data = jsonDecode(res.body);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(data['message'] ?? ""),
          backgroundColor: data['success'] == 1 ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.error,
        ),
      );

      if (data['success'] == 1) Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur: $e"), backgroundColor: Theme.of(context).colorScheme.error),
      );
    }

    setState(() => submitting = false);
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.seance;

    if (loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (error != null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: loadStudents,
                child: const Text("Réessayer"),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Appel"),
      ),

      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            color: Theme.of(context).colorScheme.surfaceContainerLow,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  s['matiere'] ?? '',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text("${s['classe']} • ${s['date_seance']}"),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Total: ${students.length}"),
                    Text("Absents: $absents"),
                    Text("Présents: ${students.length - absents}"),
                  ],
                ),
              ],
            ),
          ),

          Expanded(
            child: ListView.builder(
              itemCount: students.length,
              itemBuilder: (context, i) {
                final e = students[i];
                final studentId = id(e['id']);
                final isPresent = presence[studentId] ?? true;

                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: isPresent
                        ? Theme.of(context).colorScheme.primaryContainer
                        : Theme.of(context).colorScheme.errorContainer,
                    child: Text(
                      "${e['prenom'][0]}${e['nom'][0]}".toUpperCase(),
                    ),
                  ),
                  title: Text("${e['prenom']} ${e['nom']}"),
                  subtitle: Text(
                    isPresent ? "Présent" : "Absent",
                    style: TextStyle(
                      color: isPresent ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.error,
                    ),
                  ),
                  trailing: Checkbox(
                    value: isPresent,
                    onChanged: (v) {
                      setState(() {
                        presence[studentId] = v ?? true;
                      });
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),

      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(10),
        child: ElevatedButton(
          onPressed: submitting ? null : submitAppel,
          child: Text(submitting ? "Envoi..." : "Valider l'appel"),
        ),
      ),
    );
  }
}
