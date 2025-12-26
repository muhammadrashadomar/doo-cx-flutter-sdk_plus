import 'package:doo_cx_flutter_sdk_plus/data/local/entity/doo_user.dart';
import 'package:hive_flutter/hive_flutter.dart';

abstract class DOOUserDao {
  Future<void> saveUser(DOOUser user);
  DOOUser? getUser();
  Future<void> deleteUser();
  Future<void> onDispose();
  Future<void> clearAll();
}

//Only used when persistence is enabled
enum DOOUserBoxNames { USERS, CLIENT_INSTANCE_TO_USER }

class PersistedDOOUserDao extends DOOUserDao {
  //box containing chat users
  Box<DOOUser> _box;
  //box with one to one relation between generated client instance id and user identifier
  final Box<String> _clientInstanceIdToUserIdentifierBox;

  final String _clientInstanceKey;

  PersistedDOOUserDao(this._box, this._clientInstanceIdToUserIdentifierBox,
      this._clientInstanceKey);

  @override
  Future<void> deleteUser() async {
    final userIdentifier =
        _clientInstanceIdToUserIdentifierBox.get(_clientInstanceKey);
    await _clientInstanceIdToUserIdentifierBox.delete(_clientInstanceKey);
    await _box.delete(userIdentifier);
  }

  @override
  Future<void> saveUser(DOOUser user) async {
    await _clientInstanceIdToUserIdentifierBox.put(
        _clientInstanceKey, user.identifier.toString());
    await _box.put(user.identifier, user);
  }

  @override
  DOOUser? getUser() {
    if (_box.values.length == 0) {
      return null;
    }
    final userIdentifier =
        _clientInstanceIdToUserIdentifierBox.get(_clientInstanceKey);

    return _box.get(userIdentifier);
  }

  @override
  Future<void> onDispose() async {}

  @override
  Future<void> clearAll() async {
    await _box.clear();
    await _clientInstanceIdToUserIdentifierBox.clear();
  }

  static Future<void> openDB() async {
    await Hive.openBox<DOOUser>(DOOUserBoxNames.USERS.toString());
    await Hive.openBox<String>(
        DOOUserBoxNames.CLIENT_INSTANCE_TO_USER.toString());
  }
}

class NonPersistedDOOUserDao extends DOOUserDao {
  DOOUser? _user;

  @override
  Future<void> deleteUser() async {
    _user = null;
  }

  @override
  DOOUser? getUser() {
    return _user;
  }

  @override
  Future<void> onDispose() async {
    _user = null;
  }

  @override
  Future<void> saveUser(DOOUser user) async {
    _user = user;
  }

  @override
  Future<void> clearAll() async {
    _user = null;
  }
}
