class PostModel {
  String description;
  DateTime dateDebut;
  DateTime dateFin;
  String uidUser;
  String postPic;
  String createdAt;
  String uid;

  PostModel({
    required this.description,
    required this.dateDebut,
    required this.dateFin,
    required this.postPic,
    required this.createdAt,
    required this.uidUser,
    required this.uid,
  });

  // from map
  factory PostModel.fromMap(Map<String, dynamic> map) {
    return PostModel(
      dateDebut: map['dateDebut'] ?? '',
      dateFin: map['dateFin'] ?? '',
      description: map['description'] ?? '',
      uid: map['uid'] ?? '',
      uidUser: map['uidUser'] ?? '',
      createdAt: map['createdAt'] ?? '',
      postPic: map['postPic'] ?? '',
    );
  }

  // to map
  Map<String, dynamic> toMap() {
    return {
      "dateDebut": dateDebut,
      "dateFin": dateFin,
      "uid": uid,
      "description": description,
      "uidUser": uidUser,
      "postPic": postPic,
      "createdAt": createdAt,
    };
  }
}