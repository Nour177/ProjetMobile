import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../config/api_config.dart';
import 'appel_screen.dart';

class MesSeancesScreen extends StatefulWidget {
  final int enseignantId;

  const MesSeancesScreen({super.key, required this.enseignantId});

  @override
  State<MesSeancesScreen> createState() => _MesSeancesScreenState();
}

class _MesSeancesScreenState extends State<MesSeancesScreen> {
  List<dynamic> _seances = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchSeances();
  }

  Future<void> _fetchSeances() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final uri = Uri.parse(
        "${ApiConfig.baseUrl}/enseignant/seances.php?id=${widget.enseignantId}",
      );

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);

        if (body['success'] == 1) {
          setState(() {
            _seances = body['data'];
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

  void _navigateToAppel(Map<String, dynamic> seance) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AppelScreen(seance: seance)),
    );
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
                Icon(Icons.error_outline, size: 50, color: Theme.of(context).colorScheme.error),
                const SizedBox(height: 10),
                Text(_error!),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: _fetchSeances,
                  child: const Text("Réessayer"),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (_seances.isEmpty) {
      return Scaffold(
        body: Center(
          child: Text(
            "Aucune séance assignée",
            style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6)),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        leading: const Icon(Icons.schedule),
        title: const Text("Mes Séances"),
      ),

      body: RefreshIndicator(
        onRefresh: _fetchSeances,
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: _seances.length,
          itemBuilder: (context, i) {
            final s = _seances[i];
            return _SeanceCard(
              seance: s,
              onFaireAppel: () => _navigateToAppel(s),
            );
          },
        ),
      ),
    );
  }
}

class _SeanceCard extends StatelessWidget {
  final Map<String, dynamic> seance;
  final VoidCallback onFaireAppel;

  const _SeanceCard({required this.seance, required this.onFaireAppel});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              seance['matiere'] ?? '—',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),

            const SizedBox(height: 4),

            Text(
              "Classe: ${seance['classe'] ?? '—'}",
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6)),
            ),

            const SizedBox(height: 10),

            Row(
              children: [
                Icon(Icons.calendar_today, size: 14, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6)),
                const SizedBox(width: 5),
                Text(seance['date_seance'] ?? ''),

                const SizedBox(width: 15),

                Icon(Icons.access_time, size: 14, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6)),
                const SizedBox(width: 5),
                Text(
                  "${seance['heure_debut'] ?? ''} - ${seance['heure_fin'] ?? ''}",
                ),
              ],
            ),

            const SizedBox(height: 12),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onFaireAppel,
                child: const Text("Faire l'appel"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
