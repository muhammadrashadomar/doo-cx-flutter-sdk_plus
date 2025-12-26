import 'package:doo_cx_flutter_sdk_plus/doo_cx_flutter_sdk.dart';
import 'package:flutter/material.dart';

/// Example showing comprehensive Flutter SDK configuration
/// with all available customization options
class DOOFlutterSDKExample extends StatelessWidget {
  const DOOFlutterSDKExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('DOO Flutter SDK Demo'),
        backgroundColor: const Color(0xFF1f93ff),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'DOO Flutter SDK Integration',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _initializeBasicSDK(context),
              child: const Text('Initialize Basic SDK'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => _initializeCustomizedSDK(context),
              child: const Text('Initialize Customized SDK'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => _initializeEnterpriseSDK(context),
              child: const Text('Initialize Enterprise SDK'),
            ),
          ],
        ),
      ),
    );
  }

  /// Basic SDK initialization with minimal configuration
  void _initializeBasicSDK(BuildContext context) async {
    try {
      // Create DOO client with basic configuration
      final client = await DOOClient.create(
        baseUrl: 'https://your-doocx-domain.com',
        inboxIdentifier: 'your-inbox-identifier',
        enablePersistence: true,
      );

      // Client created successfully
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Basic SDK initialized successfully!')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to initialize SDK: $e')),
        );
      }
    }
  }

  /// Customized SDK initialization with branding and features
  void _initializeCustomizedSDK(BuildContext context) async {
    try {
      // Create DOO client with user context
      final user = DOOUser(
        identifier: 'user123',
        name: 'John Doe',
        email: 'john@example.com',
        customAttributes: const {
          'subscription': 'premium',
          'signup_date': '2024-01-15',
        },
      );

      final client = await DOOClient.create(
        baseUrl: 'https://your-doocx-domain.com',
        inboxIdentifier: 'your-inbox-identifier',
        user: user,
        enablePersistence: true,
        locale: 'en',
      );

      // Client created successfully
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Customized SDK initialized successfully!')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to initialize customized SDK: $e')),
        );
      }
    }
  }

  /// Enterprise SDK initialization with advanced features
  void _initializeEnterpriseSDK(BuildContext context) async {
    try {
      // Create DOO client with enterprise user context
      final enterpriseUser = DOOUser(
        identifier: 'enterprise-user-456',
        name: 'Enterprise User',
        email: 'enterprise@company.com',
        customAttributes: const {
          'subscription': 'enterprise',
          'company': 'Enterprise Corp',
          'contract_tier': 'platinum',
          'support_priority': 'high',
          'account_manager': 'john.doe@company.com',
        },
      );

      final client = await DOOClient.create(
        baseUrl: 'https://enterprise.doocx-domain.com',
        inboxIdentifier: 'your-enterprise-inbox-identifier',
        user: enterpriseUser,
        enablePersistence: true,
        locale: 'en',
      );

      // Client created successfully
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Enterprise SDK initialized successfully!')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to initialize enterprise SDK: $e')),
        );
      }
    }
  }
}

/// Alternative initialization methods for different use cases
class DOOAdvancedExamples {
  /// Initialize for different environments
  static Future<DOOClient> createForEnvironment({
    required String environment,
    required String inboxIdentifier,
    String? userIdentifier,
  }) async {
    final baseConfig = {
      'development': {
        'baseUrl': 'https://dev.doocx-domain.com',
      },
      'staging': {
        'baseUrl': 'https://staging.doocx-domain.com',
      },
      'production': {
        'baseUrl': 'https://doocx-domain.com',
      },
    };

    final config = baseConfig[environment]!;

    return await DOOClient.create(
      baseUrl: config['baseUrl'] as String,
      inboxIdentifier: inboxIdentifier,
      enablePersistence: true,
      locale: 'en',
    );
  }

  /// Initialize with user context
  static Future<DOOClient> createWithUserContext({
    required String baseUrl,
    required String inboxIdentifier,
    required String userId,
    required String userName,
    required String userEmail,
    String? userAvatarUrl,
    Map<String, dynamic>? additionalAttributes,
  }) async {
    final user = DOOUser(
      identifier: userId,
      name: userName,
      email: userEmail,
      avatarUrl: userAvatarUrl,
      customAttributes: {
        'initialization_time': DateTime.now().toIso8601String(),
        ...?additionalAttributes,
      },
    );

    return await DOOClient.create(
      baseUrl: baseUrl,
      inboxIdentifier: inboxIdentifier,
      user: user,
      enablePersistence: true,
    );
  }

  /// Initialize with minimal configuration for quick setup
  static Future<DOOClient> createMinimal({
    required String baseUrl,
    required String inboxIdentifier,
  }) async {
    return await DOOClient.create(
      baseUrl: baseUrl,
      inboxIdentifier: inboxIdentifier,
      enablePersistence: true,
    );
  }
}
