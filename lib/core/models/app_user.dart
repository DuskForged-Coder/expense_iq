class AppUser {
  const AppUser({
    required this.id,
    required this.email,
    required this.name,
    this.photoUrl,
  });

  final String id;
  final String email;
  final String name;
  final String? photoUrl;

  Map<String, Object?> toJson() => <String, Object?>{
        'id': id,
        'email': email,
        'name': name,
        'photoUrl': photoUrl,
      };

  factory AppUser.fromJson(Map<String, Object?> json) => AppUser(
        id: json['id'] as String,
        email: json['email'] as String,
        name: json['name'] as String,
        photoUrl: json['photoUrl'] as String?,
      );
}
