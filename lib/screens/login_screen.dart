import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:projet_mobile/config/api_config.dart';
import 'package:projet_mobile/screens/admin/admin_home.dart';
import 'package:http/http.dart' as http;
import 'package:projet_mobile/screens/etudiant/etudiant_home.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool isPasswordVisible = false;

  void login() async {
  var url = Uri.parse("${ApiConfig.baseUrl}/auth/login.php");

  try {
    var response = await http.post(url, body: {
      "email": emailController.text,
      "password": passwordController.text,
    });
    print(response.body);
    var data = jsonDecode(response.body);

    if (data["success"] == 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Connexion réussie - ${data["role"]}")),
      );
      switch (data["role"]) {
        case "admin":Navigator.push(context,MaterialPageRoute(builder: (context) => AdminHome()),);
        case "etudiant":Navigator.push(context,MaterialPageRoute(builder: (context) => EtudiantHome()),);
        // case "enseignant":Navigator.push(context,MaterialPageRoute(builder: (context) => EnseignantH()),);
      }}
     else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(data["message"] ?? "Erreur login")),
      );
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Erreur serveur")),
    );
  }
}

    // var data = jsonDecode(response.body);
    // if (emailController.text == "nour" &&
    //     passwordController.text == "nour") {
    //       ScaffoldMessenger.of(context,).showSnackBar(const SnackBar(content: Text("Connexion reussie")));
    //   Navigator.push(context,MaterialPageRoute(builder:(context) => AdminHome(),));
      
    // } else {
    //   ScaffoldMessenger.of(context,).showSnackBar(const SnackBar(content: Text("Invalid credentials")));
    // }
  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(centerTitle: true, title: Text("Login")),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: "Email institutionnel",
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: passwordController,
                obscureText: !isPasswordVisible,
                decoration: InputDecoration(
                  labelText: "Password",
                  suffixIcon: IconButton(
                    icon: Icon(
                      isPasswordVisible
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        isPasswordVisible = !isPasswordVisible;
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 20),
              FilledButton(onPressed: login, child: const Text("Login")),
            ],
          ),
        ),
      ),
    );
  }
}
