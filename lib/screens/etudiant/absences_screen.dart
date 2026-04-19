import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../config/api_config.dart';

class AbsencesScreen extends StatefulWidget {
  final int etudiantId;

  const AbsencesScreen({super.key, required this.etudiantId});

  @override
  State<AbsencesScreen> createState() => _AbsencesScreenState();
}

class _AbsencesScreenState extends State<AbsencesScreen> {
  List absences = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    fetchAbsences();
  }

  Future<void> fetchAbsences() async {
    try {
      final url = Uri.parse(
        "${ApiConfig.baseUrl}/etudiant/absences.php?id=1",
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        setState(() {
          absences = data["data"];
          loading = false;
        });
      } else {
        setState(() {
          loading = false;
        });
      }
    } catch (e) {
      setState(() {
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (absences.isEmpty) {
      return const Center(child: Text("Aucune absence trouvée"));
    }

    int totalAbsences = absences.where((a) => a['statut'] == 'absent').length;

    return Scaffold(
      body: Column(
        children: [
          const SizedBox(height: 10),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Text("Total: ${absences.length}"),
              Text("Absents: $totalAbsences"),
              Text("Présents: ${absences.length - totalAbsences}"),
            ],
          ),

          const Divider(),

          Expanded(
            child: ListView.builder(
              itemCount: absences.length,
              itemBuilder: (context, i) {
                final a = absences[i];
                final isAbsent = a['statut'] == 'absent';

                return ListTile(
            
                  title: Text(a['matiere']),
                  subtitle: Text(
                    "${a['date_seance']} (${a['heure_debut']} - ${a['heure_fin']})",
                  ),
                  trailing: Text(
                    isAbsent ? "Absent" : "Présent",
                    style: TextStyle(
                      color: isAbsent ? Colors.red : Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}