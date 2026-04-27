
class UserModel {
  String uid;
  String name;
  String email;
  List<String> skills;
  List<Map<String, String>> experience;
  List<Map<String, String>> education;
  List<String> interests;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.skills,
    required this.experience,
    required this.education,
    required this.interests,
  });

  Map<String, dynamic> toJson() => {
    "uid": uid,
    "name": name,
    "email": email,
    "skills": skills,
    "experience": experience,
    "education": education,
    "interests": interests,
  };

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      uid: json['uid'],
      name: json['name'],
      email: json['email'],
      skills: List<String>.from(json['skills'] ?? []),
      experience: List<Map<String, String>>.from(json['experience'] ?? []),
      education: List<Map<String, String>>.from(json['education'] ?? []),
      interests: List<String>.from(json['interests'] ?? []),
    );
  }
}
