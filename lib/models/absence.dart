class Absence {
  final int id;
  final String matiere;
  final String dateSeance;
  final String heureDebut;
  final String heureFin;
  final String statut; // 'present' ou 'absent'
 
  Absence({
    required this.id,
    required this.matiere,
    required this.dateSeance,
    required this.heureDebut,
    required this.heureFin,
    required this.statut,
  });
 
  factory Absence.fromJson(Map<String, dynamic> json) => Absence(
        id: json['id'],
        matiere: json['matiere'],
        dateSeance: json['date_seance'],
        heureDebut: json['heure_debut'],
        heureFin: json['heure_fin'],
        statut: json['statut'],
      );
}