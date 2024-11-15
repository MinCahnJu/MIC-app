import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class User {
  final String userId;
  final String userPw;
  final String name;
  final String phone;
  final String authority;

  User(
      {required this.userId,
      required this.userPw,
      required this.name,
      required this.phone,
      required this.authority});
}

class UserProvider with ChangeNotifier {
  User? _user;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  User? get user => _user;

  void setUser(User user) {
    _user = user;
    _saveUserToStorage(user);
    notifyListeners();
  }

  void clearUser() {
    _user = null;
    _storage.deleteAll();
    notifyListeners();
  }

  Future<void> loadUserFromStorage() async {
    final userId = await _storage.read(key: 'user_id');
    final userPw = await _storage.read(key: 'user_pw');
    final name = await _storage.read(key: 'name');
    final phone = await _storage.read(key: 'phone');
    final authority = await _storage.read(key: 'authority');
    if (userId != null &&
        userPw != null &&
        name != null &&
        phone != null &&
        authority != null) {
      _user = User(
        userId: userId,
        userPw: userPw,
        name: name,
        phone: phone,
        authority: authority,
      );
      notifyListeners();
    }
  }

  Future<void> _saveUserToStorage(User user) async {
    await _storage.write(key: 'user_id', value: user.userId);
    await _storage.write(key: 'user_pw', value: user.userPw);
    await _storage.write(key: 'name', value: user.name);
    await _storage.write(key: 'phone', value: user.phone);
    await _storage.write(key: 'authority', value: user.authority);
  }
}
