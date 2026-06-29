import 'package:hive_ce/hive.dart';
import 'package:recipeapp/features/auth/data/models/user_hive_model.dart';

class UserLocalStorage {
  static const _boxName = 'user_box';
  static const _userKey = 'current_user';

  static Future<void> init() async {
    await Hive.openBox<UserHiveModel>(_boxName);
  }

  static Future<void> saveUser(UserHiveModel user) async {
    final box = Hive.box<UserHiveModel>(_boxName);
    await box.put(_userKey, user);
  }

  static UserHiveModel? getUser() {
    final box = Hive.box<UserHiveModel>(_boxName);
    return box.get(_userKey);
  }

  static Future<void> clearUser() async {
    final box = Hive.box<UserHiveModel>(_boxName);
    await box.delete(_userKey);
  }

  static bool hasUser() {
    final box = Hive.box<UserHiveModel>(_boxName);
    return box.containsKey(_userKey);
  }
}