import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../config/api_config.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class AbsencesScreen extends StatefulWidget {
  final int etudiantId;

  const AbsencesScreen({super.key, required this.etudiantId});

  @override
  State<AbsencesScreen> createState() => _AbsencesScreenState();
}

class _AbsencesScreenState extends State<AbsencesScreen> {
  List _absences = [];
bool _loading = true;
  String? _error; 

  @override
  void initState() {
    super.initState();
    _fetchAbsences();
  }

  Future<void> _fetchAbsences() async {
    try {
      final url = Uri.parse("${ApiConfig.baseUrl}/etudiant/absences.php?id=${widget.etudiantId}");

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);

        if (body['success'] == 1) {
          setState(() {
            _absences = body['data'];
            _loading = false;
          });
        } else {
          setState(() {
            _error = body['message'] ?? "Erreur serveur";
            _loading = false;
          });
        }
      } else {
        setState(() {
          _error = "Erreur HTTP ${response.statusCode}";
          _loading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = "Impossible de joindre le serveur";
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

if (_error != null) {
      return Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 50,
                  color: Theme.of(context).colorScheme.error,
                ),
                const SizedBox(height: 10),
                Text(_error!),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: _fetchAbsences,
                  child: const Text("Réessayer"),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (_absences.isEmpty) {
      return const Scaffold(
        body: Center(child: Text("Aucune absence trouvée")),
      );
    }

    int totalAbsences = _absences.where((a) => a['statut'] == 'absent').length;

    return Scaffold(
      appBar: AppBar(
        leading: const Icon(Icons.calendar_today),
        title: const Text("Absences"),
        actions: [
          TextButton.icon(
            onPressed: exportPDF,
            icon: Icon(Icons.picture_as_pdf, color: Theme.of(context).colorScheme.primary),
            label: Text(
              "Export PDF",
              style: TextStyle(color: Theme.of(context).colorScheme.primary),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                _summaryBox("Total", _absences.length.toString()),
                const SizedBox(width: 10),
                _summaryBox("Absents", totalAbsences.toString()),
                const SizedBox(width: 10),
                _summaryBox(
                  "Présents",
                  (_absences.length - totalAbsences).toString(),
                ),
              ],
            ),

            const SizedBox(height: 20),

            Expanded(
              child: ListView.builder(
                itemCount: _absences.length,
                itemBuilder: (context, i) {
                  final a = _absences[i];
                  final isAbsent = a['statut'] == 'absent';

                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(12),

                      title: Text(
                        a['matiere'],
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),

                      subtitle: Text(
                        "${a['date_seance']} • ${a['heure_debut']} - ${a['heure_fin']}",
                      ),

                      trailing: Text(
                        isAbsent ? "Absent" : "Présent",
                        style: TextStyle(
                          color: isAbsent ? Theme.of(context).colorScheme.error : Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _summaryBox(String title, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 5),
            Text(title, style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6))),
          ],
        ),
      ),
    );
  }

  Future<void> exportPDF() async {
    final pdf = pw.Document();

    int totalAbsences = _absences.where((a) => a['statut'] == 'absent').length;

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                "Rapport des absences",
                style: pw.TextStyle(
                  fontSize: 22,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),

              pw.SizedBox(height: 10),

              pw.Text("Total: ${_absences.length}"),
              pw.Text("Absents: $totalAbsences"),
              pw.Text("Présents: ${_absences.length - totalAbsences}"),

              pw.SizedBox(height: 20),

              pw.TableHelper.fromTextArray(
                headers: ["Matière", "Date", "Heure", "Statut"],
                data: _absences.map((a) {
                  return [
                    a['matiere'],
                    a['date_seance'],
                    "${a['heure_debut']} - ${a['heure_fin']}",
                    a['statut'],
                  ];
                }).toList(),
              ),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(onLayout: (format) async => pdf.save());
  }
}
