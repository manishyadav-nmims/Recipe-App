// features/auth/data/models/user_hive_model.dart
import 'package:hive_ce/hive.dart';

class UserHiveModel {
  final int id;
  final String username;
  final String email;
  final String firstName;
  final String lastName;
  final String image;
  final String gender;
  final String accessToken;
  final String refreshToken;

  UserHiveModel({
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

class UserHiveModelAdapter extends TypeAdapter<UserHiveModel> {
  @override
  final int typeId = 0;

  @override
  UserHiveModel read(BinaryReader reader) {
    return UserHiveModel(
      id: reader.readInt(),
      username: reader.readString(),
      email: reader.readString(),
      firstName: reader.readString(),
      lastName: reader.readString(),
      image: reader.readString(),
      gender: reader.readString(),
      accessToken: reader.readString(),
      refreshToken: reader.readString(),
    );
  }

  @override
  void write(BinaryWriter writer, UserHiveModel obj) {
    writer.writeInt(obj.id);
    writer.writeString(obj.username);
    writer.writeString(obj.email);
    writer.writeString(obj.firstName);
    writer.writeString(obj.lastName);
    writer.writeString(obj.image);
    writer.writeString(obj.gender);
    writer.writeString(obj.accessToken);
    writer.writeString(obj.refreshToken);
  }
}