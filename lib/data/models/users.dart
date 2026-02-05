class Users {
  final String id;
  final String name;
  final String email;
  final String password;       
  final String passwordRepeat;  
  final String role;
  final String profilePictureUrl;
  final String phoneNumber;

  Users({
    required this.id,
    required this.name,
    required this.email,
    required this.password,
    required this.passwordRepeat,
    required this.role,
    required this.profilePictureUrl,
    required this.phoneNumber,
  });

  factory Users.fromJson(Map<String, dynamic> json) {
    return Users(
      id: json['id'],
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      password: '',      
      passwordRepeat: '',  
      role: json['role'] ?? '',
      profilePictureUrl: json['profile_picture_url'] ?? '',
      phoneNumber: json['phone_number'] ?? '',
    );
  }

  Map<String, dynamic> toJson({
    bool includePassword = false,
  }) {
    final data = <String, dynamic>{
      'id':id,
      'name': name,
      'email': email,
      'phone_number': phoneNumber,
      'profile_picture_url': profilePictureUrl,
      'role': role,
    };

    if (includePassword) {
      data['password'] = password;
      data['password_repeat'] = passwordRepeat;
    }

    return data;
  }
}
