# DOO CX Flutter SDK - Complete Integration Guide

## Token Architecture & Consistency

The DOO CX platform uses a clear token system to avoid confusion:

### Token Types

1. **SDK Token** (`sdkToken`) - **RECOMMENDED for Flutter apps**
   - Used for native Flutter SDK integration
   - Provides direct API access and enhanced features
   - Generated in DOO Admin → Inboxes → Flutter SDK Channel

2. **Website Token** (`websiteToken`) - **For web widgets only**
   - Used for web chat widgets and webview integration
   - Generated in DOO Admin → Inboxes → Website Channel
   - Should NOT be used for native Flutter apps

3. **Inbox Identifier** (`inboxIdentifier`) - **For direct inbox access**
   - Direct connection to a specific inbox
   - Alternative to SDK token for simple integrations

## Flutter SDK Configuration

### Basic Setup

```dart
import 'package:doo_cx_flutter_sdk_plus/doo_cx_flutter_sdk_plus.dart';

// Recommended: Use Flutter SDK token
final params = DOOParameters.forFlutterSDK(
  baseUrl: 'https://your-doocx-domain.com',
  sdkToken: 'your-flutter-sdk-token', // Get this from Flutter SDK Channel
  clientInstanceKey: 'your-unique-client-key',
);

await DOOClient.create(params);
```

### Comprehensive Customization

```dart
final params = DOOParameters.forFlutterSDK(
  // Required parameters
  baseUrl: 'https://your-doocx-domain.com',
  sdkToken: 'your-flutter-sdk-token',
  clientInstanceKey: 'unique-client-identifier',
  
  // User identification
  userIdentifier: 'user123',
  
  // Localization
  locale: 'en', // or 'fr', 'es', 'de', etc.
  
  // Data persistence
  isPersistenceEnabled: true,
  
  // UI Customization
  themeColor: Colors.purple,
  
  // Feature toggles
  enablePushNotifications: true,
  enableFileAttachments: true,
  enableEmojiPicker: true,
  enableTypingIndicators: true,
  enableReadReceipts: true,
  messagingWindowEnabled: true,
  
  // Auto-resolve settings
  autoResolveInactiveConversations: Duration(days: 7),
  
  // Custom messages
  welcomeMessage: 'Welcome! How can we help you today?',
  offlineMessage: 'We\'re currently offline. Leave us a message!',
  agentAwayMessage: 'Our agents are away. We\'ll get back to you soon.',
  
  // Custom attributes for conversation context
  customAttributes: {
    'source': 'mobile_app',
    'version': '1.0.0',
    'platform': 'flutter',
    'user_type': 'premium',
  },
  
  // Contact-specific attributes
  contactCustomAttributes: {
    'subscription': 'premium',
    'signup_date': '2024-01-15',
    'preferred_language': 'en',
  },
);
```

## Platform Configuration

### Creating Flutter SDK Channel

1. **Admin Panel Setup**:
   ```
   DOO Admin → Inboxes → Add Inbox → Flutter SDK
   ```

2. **Channel Configuration**:
   ```json
   {
     "features": {
       "file_attachments": true,
       "emoji_picker": true,
       "push_notifications": true,
       "typing_indicators": true,
       "read_receipts": true
     },
     "appearance": {
       "theme_color": "#1f93ff"
     },
     "behavior": {
       "messaging_window_enabled": true,
       "auto_resolve_duration": 0
     },
     "messages": {
       "welcome_message": "Welcome! How can we help?",
       "offline_message": "We're offline. Leave a message!",
       "agent_away_message": "Agents are away. We'll respond soon."
     }
   }
   ```

3. **Generated SDK Token**:
   - Copy the SDK token from the channel settings
   - Use this token in your Flutter app configuration
   - Keep it secure and don't expose it in client-side code

## API Integration

### Public API Endpoints

The platform provides public API endpoints for Flutter SDK integration:

```bash
# Get channel configuration
GET /public/api/v1/flutter_sdk/inboxes/:token

# Create contact and conversation
POST /public/api/v1/flutter_sdk/inboxes/:token/contacts
```

### Response Format

```json
{
  "id": 123,
  "name": "Mobile Support",
  "description": "Flutter SDK Channel",
  "app_identifier": "mobile-app-xyz",
  "configuration": {
    "features": {
      "file_attachments": true,
      "emoji_picker": true,
      "push_notifications": true,
      "typing_indicators": true,
      "read_receipts": true
    },
    "appearance": {
      "theme_color": "#1f93ff"
    },
    "behavior": {
      "messaging_window_enabled": true,
      "auto_resolve_duration": 0
    },
    "messages": {
      "welcome_message": "Welcome! How can we help?",
      "offline_message": "We're offline. Leave a message!",
      "agent_away_message": "Agents are away. We'll respond soon."
    }
  }
}
```

## Advanced Usage Examples

### Environment-Specific Configuration

```dart
class DOOEnvironmentConfig {
  static DOOParameters forEnvironment(String env, String sdkToken) {
    switch (env) {
      case 'development':
        return DOOParameters.forFlutterSDK(
          baseUrl: 'https://dev.doocx-domain.com',
          sdkToken: sdkToken,
          clientInstanceKey: 'dev-flutter-client',
          themeColor: Colors.orange,
          customAttributes: {'environment': 'development'},
        );
      
      case 'staging':
        return DOOParameters.forFlutterSDK(
          baseUrl: 'https://staging.doocx-domain.com',
          sdkToken: sdkToken,
          clientInstanceKey: 'staging-flutter-client',
          themeColor: Colors.amber,
          customAttributes: {'environment': 'staging'},
        );
      
      case 'production':
        return DOOParameters.forFlutterSDK(
          baseUrl: 'https://doocx-domain.com',
          sdkToken: sdkToken,
          clientInstanceKey: 'prod-flutter-client',
          themeColor: Color(0xFF1f93ff),
          customAttributes: {'environment': 'production'},
        );
      
      default:
        throw ArgumentError('Unknown environment: $env');
    }
  }
}
```

### User Context Integration

```dart
class DOOUserIntegration {
  static DOOParameters withUserContext({
    required String baseUrl,
    required String sdkToken,
    required User user,
  }) {
    return DOOParameters.forFlutterSDK(
      baseUrl: baseUrl,
      sdkToken: sdkToken,
      clientInstanceKey: 'user-${user.id}',
      userIdentifier: user.id,
      customAttributes: {
        'user_name': user.name,
        'user_email': user.email,
        'user_tier': user.subscriptionTier,
        'signup_date': user.signupDate.toIso8601String(),
      },
      contactCustomAttributes: {
        'name': user.name,
        'email': user.email,
        'subscription': user.subscriptionTier,
        'last_login': user.lastLogin.toIso8601String(),
      },
    );
  }
}
```

## Migration Guide

### From Website Token to SDK Token

If you're currently using `websiteToken`, migrate to `sdkToken`:

**Old (deprecated):**
```dart
DOOParameters.forWebView(
  baseUrl: 'https://your-domain.com',
  websiteToken: 'website-token-123', // ❌ Deprecated
  clientInstanceKey: 'client-key',
);
```

**New (recommended):**
```dart
DOOParameters.forFlutterSDK(
  baseUrl: 'https://your-domain.com',
  sdkToken: 'flutter-sdk-token-456', // ✅ Recommended
  clientInstanceKey: 'client-key',
);
```

### Benefits of SDK Token

1. **Enhanced Security**: Direct API access without widget dependencies
2. **Better Performance**: Native integration without webview overhead
3. **More Features**: Access to push notifications, file attachments, etc.
4. **Consistent Experience**: Same token used across platform and Flutter SDK
5. **Future-Proof**: All new features will be SDK-token exclusive

## Troubleshooting

### Common Issues

1. **Token Confusion**:
   - ❌ Don't mix website tokens with Flutter SDK
   - ✅ Use SDK tokens for native Flutter apps

2. **Configuration Mismatch**:
   - Ensure platform configuration matches Flutter SDK settings
   - Use the public API to fetch current configuration

3. **Authentication Errors**:
   - Verify SDK token is valid and active
   - Check that the token belongs to a Flutter SDK channel

### Debug Configuration

```dart
final params = DOOParameters.forFlutterSDK(
  baseUrl: 'https://your-domain.com',
  sdkToken: 'your-sdk-token',
  clientInstanceKey: 'debug-client',
  customAttributes: {
    'debug': 'true',
    'version': '1.0.0',
    'build': 'debug',
  },
);

// Enable debug logging
await DOOClient.create(params);
```

## Security Best Practices

1. **Token Management**:
   - Store SDK tokens securely
   - Don't hardcode tokens in source code
   - Use environment variables or secure storage

2. **User Privacy**:
   - Only collect necessary user attributes
   - Comply with privacy regulations (GDPR, CCPA)
   - Allow users to opt-out of data collection

3. **Data Validation**:
   - Validate all custom attributes
   - Sanitize user inputs
   - Use type-safe parameters

## Support

For additional help:
- Check the example app in `/example`
- Review the API documentation
- Test with different token types to understand the differences
- Use the debug mode for troubleshooting

Remember: **Always use SDK tokens for Flutter apps** - this ensures consistency between your platform configuration and Flutter SDK behavior.