import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import '../../config/api_config.dart';

class ProfilScreen extends StatefulWidget {
  final int etudiantId;

  const ProfilScreen({super.key, required this.etudiantId});

  @override
  State<ProfilScreen> createState() => _ProfilScreenState();
}

class _ProfilScreenState extends State<ProfilScreen> {
  Map<String, dynamic>? _profil;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchProfil();
  }

  Future<void> _fetchProfil() async {
    try {
      final url = Uri.parse(
        "${ApiConfig.baseUrl}/etudiant/profil.php?id=${widget.etudiantId}",
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);

        if (body['success'] == 1) {
          setState(() {
            _profil = body['data'];
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
                  onPressed: _fetchProfil,
                  child: const Text("Réessayer"),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        leading: const Icon(Icons.person),
        title: const Text("Profil"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 20),

            CircleAvatar(
              radius: 50,
              backgroundColor: Theme.of(
                context,
              ).colorScheme.surfaceContainerLowest,
              child: const Icon(Icons.person, size: 50),
            ),

            const SizedBox(height: 15),

            Text(
              "${_profil!['prenom']} ${_profil!['nom']}",
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),

            const SizedBox(height: 30),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerLow,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  _item("Email", _profil!['email']),
                  _divider(),
                  _item("Classe", _profil!['classe']),
                  _divider(),
                  _item("Niveau", _profil!['niveau']),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _item(String title, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
      ],
    );
  }

  Widget _divider() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 10),
      child: Divider(height: 1),
    );
  }
}
