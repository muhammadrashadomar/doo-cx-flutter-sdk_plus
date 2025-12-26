import 'package:doo_cx_flutter_sdk_plus/data/local/entity/doo_conversation.dart';
import 'package:hive_flutter/hive_flutter.dart';

abstract class DOOConversationDao {
  Future<void> saveConversation(DOOConversation conversation);
  DOOConversation? getConversation();
  Future<void> deleteConversation();
  Future<void> onDispose();
  Future<void> clearAll();
}

//Only used when persistence is enabled
enum DOOConversationBoxNames { CONVERSATIONS, CLIENT_INSTANCE_TO_CONVERSATIONS }

class PersistedDOOConversationDao extends DOOConversationDao {
  //box containing all persisted conversations
  Box<DOOConversation> _box;

  //box with one to one relation between generated client instance id and conversation id
  final Box<String> _clientInstanceIdToConversationIdentifierBox;

  final String _clientInstanceKey;

  PersistedDOOConversationDao(
      this._box,
      this._clientInstanceIdToConversationIdentifierBox,
      this._clientInstanceKey);

  @override
  Future<void> deleteConversation() async {
    final conversationIdentifier =
        _clientInstanceIdToConversationIdentifierBox.get(_clientInstanceKey);
    await _clientInstanceIdToConversationIdentifierBox
        .delete(_clientInstanceKey);
    await _box.delete(conversationIdentifier);
  }

  @override
  Future<void> saveConversation(DOOConversation conversation) async {
    await _clientInstanceIdToConversationIdentifierBox.put(
        _clientInstanceKey, conversation.id.toString());
    await _box.put(conversation.id, conversation);
  }

  @override
  DOOConversation? getConversation() {
    if (_box.values.length == 0) {
      return null;
    }

    final conversationidentifierString =
        _clientInstanceIdToConversationIdentifierBox.get(_clientInstanceKey);
    final conversationIdentifier =
        int.tryParse(conversationidentifierString ?? "");

    if (conversationIdentifier == null) {
      return null;
    }

    return _box.get(conversationIdentifier);
  }

  @override
  Future<void> onDispose() async {}

  static Future<void> openDB() async {
    await Hive.openBox<DOOConversation>(
        DOOConversationBoxNames.CONVERSATIONS.toString());
    await Hive.openBox<String>(
        DOOConversationBoxNames.CLIENT_INSTANCE_TO_CONVERSATIONS.toString());
  }

  @override
  Future<void> clearAll() async {
    await _box.clear();
    await _clientInstanceIdToConversationIdentifierBox.clear();
  }
}

class NonPersistedDOOConversationDao extends DOOConversationDao {
  DOOConversation? _conversation;

  @override
  Future<void> deleteConversation() async {
    _conversation = null;
  }

  @override
  DOOConversation? getConversation() {
    return _conversation;
  }

  @override
  Future<void> onDispose() async {
    _conversation = null;
  }

  @override
  Future<void> saveConversation(DOOConversation conversation) async {
    _conversation = conversation;
  }

  @override
  Future<void> clearAll() async {
    _conversation = null;
  }
}
