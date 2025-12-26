import 'package:doo_cx_flutter_sdk_plus/data/local/dao/doo_contact_dao.dart';
import 'package:doo_cx_flutter_sdk_plus/data/local/dao/doo_conversation_dao.dart';
import 'package:doo_cx_flutter_sdk_plus/data/local/dao/doo_messages_dao.dart';
import 'package:doo_cx_flutter_sdk_plus/data/local/dao/doo_user_dao.dart';
import 'package:doo_cx_flutter_sdk_plus/data/local/entity/doo_conversation.dart';
import 'package:doo_cx_flutter_sdk_plus/data/remote/responses/doo_event.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'entity/doo_contact.dart';
import 'entity/doo_message.dart';
import 'entity/doo_user.dart';

const DOO_CONTACT_HIVE_TYPE_ID = 50;
const DOO_CONVERSATION_HIVE_TYPE_ID = 51;
const DOO_MESSAGE_HIVE_TYPE_ID = 52;
const DOO_USER_HIVE_TYPE_ID = 53;
const DOO_EVENT_USER_HIVE_TYPE_ID = 54;

class LocalStorage {
  DOOUserDao userDao;
  DOOConversationDao conversationDao;
  DOOContactDao contactDao;
  DOOMessagesDao messagesDao;

  LocalStorage({
    required this.userDao,
    required this.conversationDao,
    required this.contactDao,
    required this.messagesDao,
  });

  static Future<void> openDB({void Function()? onInitializeHive}) async {
    if (onInitializeHive == null) {
      await Hive.initFlutter();
      if (!Hive.isAdapterRegistered(DOO_CONTACT_HIVE_TYPE_ID)) {
        Hive..registerAdapter(DOOContactAdapter());
      }
      if (!Hive.isAdapterRegistered(DOO_CONVERSATION_HIVE_TYPE_ID)) {
        Hive..registerAdapter(DOOConversationAdapter());
      }
      if (!Hive.isAdapterRegistered(DOO_MESSAGE_HIVE_TYPE_ID)) {
        Hive..registerAdapter(DOOMessageAdapter());
      }
      if (!Hive.isAdapterRegistered(DOO_EVENT_USER_HIVE_TYPE_ID)) {
        Hive..registerAdapter(DOOEventMessageUserAdapter());
      }
      if (!Hive.isAdapterRegistered(DOO_USER_HIVE_TYPE_ID)) {
        Hive..registerAdapter(DOOUserAdapter());
      }
    } else {
      onInitializeHive();
    }

    await PersistedDOOContactDao.openDB();
    await PersistedDOOConversationDao.openDB();
    await PersistedDOOMessagesDao.openDB();
    await PersistedDOOUserDao.openDB();
  }

  Future<void> clear({bool clearDOOUserStorage = true}) async {
    await conversationDao.deleteConversation();
    await messagesDao.clear();
    if (clearDOOUserStorage) {
      await userDao.deleteUser();
      await contactDao.deleteContact();
    }
  }

  Future<void> clearAll() async {
    await conversationDao.clearAll();
    await contactDao.clearAll();
    await messagesDao.clearAll();
    await userDao.clearAll();
  }

  dispose() {
    userDao.onDispose();
    conversationDao.onDispose();
    contactDao.onDispose();
    messagesDao.onDispose();
  }
}
