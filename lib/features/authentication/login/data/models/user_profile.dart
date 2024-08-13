class UserProfile {
  final int id;
  final String firstName;
  final String lastName;
  final String email;
  final String phoneNumber;
  final String birthDate;
  final String userImage;
  final int gender;
  final String? password;
  final String gouvernate;
  final String state;
  final int points;
  final DateTime createdDate;

  UserProfile({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phoneNumber,
    required this.birthDate,
    required this.userImage,
    required this.gender,
    this.password,
    required this.gouvernate,
    required this.state,
    required this.points,
    required this.createdDate,
  });

  // Factory method to create a User instance from JSON
  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'],
      firstName: json['firstName'] ?? "",
      lastName: json['lastName']?? "",
      email: json['email'],
      phoneNumber: json['phoneNumber'],
      birthDate: json['birthDate'] ?? "",
      userImage: json['userImage'] ?? "",
      gender: json['gender'] ?? "",
      password: json['password'],
      gouvernate: json['gouvernate'] ?? "",
      state: json['state'] ?? "",
      points: json['points'],
      createdDate: DateTime.parse(json['createdDate']),
    );
  }

  // Method to convert a User instance to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'phoneNumber': phoneNumber,
      'birthDate': birthDate,
      'userImage': userImage,
      'gender': gender,
      'password': password,
      'gouvernate': gouvernate,
      'state': state,
      'points': points,
      'createdDate': createdDate.toIso8601String(),
    };
  }
}
