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
  Map<String, dynamic>? profil;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    fetchProfil();
  }

  Future<void> fetchProfil() async {
    try {
      final url = Uri.parse(
      // "${ApiConfig.baseUrl}/etudiant/profil.php?id=${widget.etudiantId}",
      "${ApiConfig.baseUrl}/etudiant/profil.php?id=1",
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        setState(() {
          profil = data["data"];
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

    if (profil == null) {
      return const Center(child: Text("Erreur de chargement"));
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircleAvatar(
            radius: 80,
            child: Icon(Icons.person, size: 80),
          ),
          const SizedBox(height: 20),

          Text("Nom: ${profil!['nom']}"),
          Text("Prénom: ${profil!['prenom']}"),
          Text("Email: ${profil!['email']}"),
          Text("Classe: ${profil!['classe']}"),
          Text("Niveau: ${profil!['niveau']}"),

          const SizedBox(height: 20),

          Text(
            "ID Étudiant: ${widget.etudiantId}",
            style: const TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}