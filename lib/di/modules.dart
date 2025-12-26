import 'package:doo_cx_flutter_sdk_plus/data/doo_repository.dart';
import 'package:doo_cx_flutter_sdk_plus/data/local/dao/doo_contact_dao.dart';
import 'package:doo_cx_flutter_sdk_plus/data/local/dao/doo_conversation_dao.dart';
import 'package:doo_cx_flutter_sdk_plus/data/local/dao/doo_messages_dao.dart';
import 'package:doo_cx_flutter_sdk_plus/data/local/dao/doo_user_dao.dart';
import 'package:doo_cx_flutter_sdk_plus/data/local/entity/doo_contact.dart';
import 'package:doo_cx_flutter_sdk_plus/data/local/entity/doo_conversation.dart';
import 'package:doo_cx_flutter_sdk_plus/data/local/entity/doo_message.dart';
import 'package:doo_cx_flutter_sdk_plus/data/local/entity/doo_user.dart';
import 'package:doo_cx_flutter_sdk_plus/data/local/local_storage.dart';
import 'package:doo_cx_flutter_sdk_plus/data/remote/service/doo_client_api_interceptor.dart';
import 'package:doo_cx_flutter_sdk_plus/data/remote/service/doo_client_auth_service.dart';
import 'package:doo_cx_flutter_sdk_plus/data/remote/service/doo_client_service.dart';
import 'package:doo_cx_flutter_sdk_plus/doo_parameters.dart';
import 'package:doo_cx_flutter_sdk_plus/repository_parameters.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

/// Provides an instance of [Dio] for unauthenticated requests
///
/// This provider creates a Dio instance without authentication interceptors
/// for initial API calls that don't require authentication
final unauthenticatedDioProvider =
    Provider.family<Dio, DOOParameters>((ref, params) {
  return Dio(BaseOptions(
    baseUrl: params.baseUrl,
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 30),
  ));
});

/// Provides an instance of [DOOClientApiInterceptor]
///
/// This interceptor handles authentication for API requests
final dooClientApiInterceptorProvider =
    Provider.family<DOOClientApiInterceptor, DOOParameters>((ref, params) {
  final localStorage = ref.watch(localStorageProvider(params));
  final authService = ref.watch(dooClientAuthServiceProvider(params));
  return DOOClientApiInterceptor(
      params.inboxIdentifier ?? '', localStorage, authService);
});

/// Provides an instance of Dio with authentication interceptors
///
/// This provider creates a Dio instance with the necessary interceptors
/// to authenticate all requests made with this instance
final authenticatedDioProvider =
    Provider.family<Dio, DOOParameters>((ref, params) {
  final authenticatedDio = Dio(BaseOptions(
    baseUrl: params.baseUrl,
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 30),
  ));
  final interceptor = ref.watch(dooClientApiInterceptorProvider(params));
  authenticatedDio.interceptors.add(interceptor);
  return authenticatedDio;
});

/// Provides instance of DOO client auth service [DOOClientAuthService]
///
/// This service handles authentication with the DOO API
final dooClientAuthServiceProvider =
    Provider.family<DOOClientAuthService, DOOParameters>((ref, params) {
  final unAuthenticatedDio = ref.watch(unauthenticatedDioProvider(params));
  return DOOClientAuthServiceImpl(dio: unAuthenticatedDio);
});

/// Provides instance of DOO client API service [DOOClientService]
///
/// This service handles all API communication with the DOO backend
final dooClientServiceProvider =
    Provider.family<DOOClientService, DOOParameters>((ref, params) {
  final authenticatedDio = ref.watch(authenticatedDioProvider(params));
  return DOOClientServiceImpl(params.baseUrl, dio: authenticatedDio);
});

/// Provides Hive box to store relations between DOO client instance and contact object
///
/// Client instances are distinguished using baseurl and inboxIdentifier
final clientInstanceToContactBoxProvider = Provider<Box<String>>((ref) {
  return Hive.box<String>(
      DOOContactBoxNames.CLIENT_INSTANCE_TO_CONTACTS.toString());
});

/// Provides Hive box to store relations between DOO client instance and conversation object
///
/// Client instances are distinguished using baseurl and inboxIdentifier
final clientInstanceToConversationBoxProvider = Provider<Box<String>>((ref) {
  return Hive.box<String>(
      DOOConversationBoxNames.CLIENT_INSTANCE_TO_CONVERSATIONS.toString());
});

/// Provides Hive box to store relations between DOO client instance and messages
///
/// Client instances are distinguished using baseurl and inboxIdentifier
final messageToClientInstanceBoxProvider = Provider<Box<String>>((ref) {
  return Hive.box<String>(
      DOOMessagesBoxNames.MESSAGES_TO_CLIENT_INSTANCE_KEY.toString());
});

/// Provides Hive box to store relations between DOO client instance and user object
///
/// Client instances are distinguished using baseurl and inboxIdentifier
final clientInstanceToUserBoxProvider = Provider<Box<String>>((ref) {
  return Hive.box<String>(DOOUserBoxNames.CLIENT_INSTANCE_TO_USER.toString());
});

/// Provides Hive box for [DOOContact] objects when persistence is enabled
final contactBoxProvider = Provider<Box<DOOContact>>((ref) {
  return Hive.box<DOOContact>(DOOContactBoxNames.CONTACTS.toString());
});

/// Provides Hive box for [DOOConversation] objects when persistence is enabled
final conversationBoxProvider = Provider<Box<DOOConversation>>((ref) {
  return Hive.box<DOOConversation>(
      DOOConversationBoxNames.CONVERSATIONS.toString());
});

/// Provides Hive box for [DOOMessage] objects when persistence is enabled
final messagesBoxProvider = Provider<Box<DOOMessage>>((ref) {
  return Hive.box<DOOMessage>(DOOMessagesBoxNames.MESSAGES.toString());
});

/// Provides Hive box for [DOOUser] objects when persistence is enabled
final userBoxProvider = Provider<Box<DOOUser>>((ref) {
  return Hive.box<DOOUser>(DOOUserBoxNames.USERS.toString());
});

/// Provides an instance of DOO contact dao
///
/// Creates an in-memory storage if persistence isn't enabled,
/// otherwise uses Hive boxes to store the DOO client's contact information
final dooContactDaoProvider =
    Provider.family<DOOContactDao, DOOParameters>((ref, params) {
  if (!params.isPersistenceEnabled) {
    return NonPersistedDOOContactDao();
  }

  final contactBox = ref.watch(contactBoxProvider);
  final clientInstanceToContactBox =
      ref.watch(clientInstanceToContactBoxProvider);
  return PersistedDOOContactDao(
      contactBox, clientInstanceToContactBox, params.clientInstanceKey);
});

/// Provides an instance of DOO conversation dao
///
/// Creates an in-memory storage if persistence isn't enabled,
/// otherwise uses Hive boxes to store the DOO client's conversation
final dooConversationDaoProvider =
    Provider.family<DOOConversationDao, DOOParameters>((ref, params) {
  if (!params.isPersistenceEnabled) {
    return NonPersistedDOOConversationDao();
  }
  final conversationBox = ref.watch(conversationBoxProvider);
  final clientInstanceToConversationBox =
      ref.watch(clientInstanceToConversationBoxProvider);
  return PersistedDOOConversationDao(conversationBox,
      clientInstanceToConversationBox, params.clientInstanceKey);
});

/// Provides an instance of DOO messages dao
///
/// Creates an in-memory storage if persistence isn't enabled,
/// otherwise uses Hive boxes to store the DOO client's messages
final dooMessagesDaoProvider =
    Provider.family<DOOMessagesDao, DOOParameters>((ref, params) {
  if (!params.isPersistenceEnabled) {
    return NonPersistedDOOMessagesDao();
  }
  final messagesBox = ref.watch(messagesBoxProvider);
  final messageToClientInstanceBox =
      ref.watch(messageToClientInstanceBoxProvider);
  return PersistedDOOMessagesDao(
      messagesBox, messageToClientInstanceBox, params.clientInstanceKey);
});

/// Provides an instance of DOO user dao
///
/// Creates an in-memory storage if persistence isn't enabled,
/// otherwise uses Hive boxes to store user information
final dooUserDaoProvider =
    Provider.family<DOOUserDao, DOOParameters>((ref, params) {
  if (!params.isPersistenceEnabled) {
    return NonPersistedDOOUserDao();
  }
  final userBox = ref.watch(userBoxProvider);
  final clientInstanceToUserBoxBox = ref.watch(clientInstanceToUserBoxProvider);
  return PersistedDOOUserDao(
      userBox, clientInstanceToUserBoxBox, params.clientInstanceKey);
});

/// Provides an instance of local storage
///
/// This combines all DAOs to provide a unified local storage interface
final localStorageProvider =
    Provider.family<LocalStorage, DOOParameters>((ref, params) {
  final contactDao = ref.watch(dooContactDaoProvider(params));
  final conversationDao = ref.watch(dooConversationDaoProvider(params));
  final userDao = ref.watch(dooUserDaoProvider(params));
  final messagesDao = ref.watch(dooMessagesDaoProvider(params));

  return LocalStorage(
      contactDao: contactDao,
      conversationDao: conversationDao,
      userDao: userDao,
      messagesDao: messagesDao);
});

/// Provides an instance of DOO repository
///
/// This is the main repository that handles all DOO SDK operations
final dooRepositoryProvider =
    Provider.family<DOORepository, RepositoryParameters>((ref, repoParams) {
  final localStorage = ref.watch(localStorageProvider(repoParams.params));
  final clientService = ref.watch(dooClientServiceProvider(repoParams.params));

  return DOORepositoryImpl(
      clientService: clientService,
      localStorage: localStorage,
      streamCallbacks: repoParams.callbacks);
});
