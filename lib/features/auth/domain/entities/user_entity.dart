class UserEntity {
  final int id;
  final String username;
  final String email;
  final String firstName;
  final String lastName;
  final String image;
  final String gender;
  final String accessToken;
  final String refreshToken;

  const UserEntity({
    required this.id,
    required this.username,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.image,
    required this.gender,
    required this.accessToken,
    required this.refreshToken,
  });
}