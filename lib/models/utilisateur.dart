class Utilisateur {
  final int id;
  final String nom;
  final String prenom;
  final String email;
  final String role;
 
  Utilisateur({
    required this.id,
    required this.nom,
    required this.prenom,
    required this.email,
    required this.role,
  });
 
  factory Utilisateur.fromJson(Map<String, dynamic> json) => Utilisateur(
        id: json['id'],
        nom: json['nom'],
        prenom: json['prenom'],
        email: json['email'],
        role: json['role'],
      );
}