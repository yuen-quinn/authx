# authx

A simple and flexible authentication library for Dart applications supporting multiple OAuth providers with type-safe provider management.

## Features

- 🔐 OAuth 2.0 authentication
- 🌐 Multiple provider support (GitHub, Google, and more)
- 📦 Easy integration with singleton pattern
- 🎯 Type-safe API with ProviderId enum
- 🔄 State management with configurable expiration
- 🛡️ Built-in error handling and validation

## Supported Providers

- **GitHub** - Complete OAuth flow with user profile and email
- **Google** - OpenID Connect with profile information

## Installation

Add this to your `pubspec.yaml`:

```yaml
dependencies:
  authx: ^1.0.0
```

Then run:

```bash
dart pub get
```

## Quick Start

```dart
import 'package:authx/authx.dart';

void main() async {
  // 1. Configure AuthX singleton with providers (call once)
  AuthX.configure(
    expiration: Duration(minutes: 30),
    providers: {
      'github': GitHubProvider(
        clientId: 'your_github_client_id',
        clientSecret: 'your_github_client_secret',
        redirectUri: 'http://localhost:8080/api/v1/auth/github/callback',
      ),
      'google': GoogleProvider(
        clientId: 'your_google_client_id',
        clientSecret: 'your_google_client_secret',
        redirectUri: 'http://localhost:8080/api/v1/auth/google/callback',
      ),
    },
  );

  // 2. Get the singleton instance
  final authX = AuthX.instance;

  // 3. Get authorization URL (redirect user to this URL)
  final authUrl = authX.getAuthorizationUrl(ProviderId.github);
  print('Redirect user to: $authUrl');

  // 4. Handle callback and get user profile
  try {
    final profile = await authX.handleCallback(
      providerId: ProviderId.github,
      query: {
        'code': 'authorization_code_from_callback',
        'state': 'state_from_auth_url',
      },
    );

    print('✓ Authentication successful!');
    print('User email: ${profile.email}');
    print('User name: ${profile.name}');
    print('Avatar: ${profile.avatar}');
    print('Provider: ${profile.provider}');
  } on DartAuthException catch (e) {
    print('✗ Authentication failed: ${e.message}');
    print('Error code: ${e.code}');
  }
}
```

## API Reference

### ProviderId Enum

Type-safe provider identification:

```dart
enum ProviderId {
  github,
  google;
  
  String get value; // Returns string representation
  static ProviderId fromString(String value); // Convert string to enum
}
```

### AuthX Class

Main authentication manager with singleton pattern.

#### Configuration

```dart
AuthX.configure({
  Duration? expiration, // State expiration time (default: 5 minutes)
  Map<String, OAuthProvider>? providers, // Provider configuration
});
```

#### Methods

- `AuthX.instance` - Get singleton instance
- `getAuthorizationUrl(ProviderId providerId)` - Generate auth URL with state
- `handleCallback({ProviderId providerId, Map<String, String> query})` - Process callback
- `registerProvider(ProviderId id, OAuthProvider provider)` - Register additional provider
- `isStateValid(String state)` - Validate state without consuming it
- `cleanStates()` - Remove expired states

### OAuthProfile

User profile returned after successful authentication:

```dart
class OAuthProfile {
  final ProviderId providerId;     // Enum-based provider identification
  final String email;             // User email (always present)
  final String? name;             // User display name
  final String? avatar;           // Profile avatar URL
  final String? provider;         // Provider name as string
  final Map<String, dynamic> raw; // Raw provider response
}
```

### Error Handling

Built-in exception types for comprehensive error handling:

```dart
try {
  final profile = await authX.handleCallback(...);
} on DartAuthException catch (e) {
  print('Error: ${e.message}');
  print('Code: ${e.code}');
  
  // Common error codes:
  // - NOT_CONFIGURED: AuthX not configured
  // - ALREADY_CONFIGURED: AuthX already configured
  // - INVALID_CALLBACK_PARAMS: Missing code or state
  // - INVALID_OR_EXPIRED_STATE: State invalid or expired
  // - PROVIDER_NOT_FOUND: Provider not registered
  // - TOKEN_EXCHANGE_FAILED: OAuth token exchange failed
  // - PROFILE_FETCH_FAILED: Failed to fetch user profile
  // - MISSING_EMAIL: Email not available in profile
}
```

## Provider Configuration

### GitHub Provider

```dart
GitHubProvider(
  clientId: 'your_client_id',
  clientSecret: 'your_client_secret',
  redirectUri: 'http://localhost:8080/api/v1/auth/github/callback',
)
```

**Required OAuth App Settings:**
- Authorization callback URL: `http://localhost:8080/api/v1/auth/github/callback`
- Scopes requested: `user:email`

### Google Provider

```dart
GoogleProvider(
  clientId: 'your_client_id',
  clientSecret: 'your_client_secret',
  redirectUri: 'http://localhost:8080/api/v1/auth/google/callback',
)
```

**Required OAuth App Settings:**
- Authorized redirect URI: `http://localhost:8080/api/v1/auth/google/callback`
- Scopes requested: `openid email profile`

## Advanced Usage

### Custom State Management

```dart
// Configure custom expiration
AuthX.configure(
  expiration: Duration(hours: 1), // Longer state validity
  providers: providers,
);

// Validate state without consuming
if (authX.isStateValid(state)) {
  // State is valid
}

// Clean up expired states
authX.cleanStates();
```

### Multiple Provider Registration

```dart
final authX = AuthX.instance;

// Register additional providers after configuration
authX.registerProvider(
  ProviderId.github,
  GitHubProvider(/* config */),
);

authX.registerProvider(
  ProviderId.google,
  GoogleProvider(/* config */),
);
```

### Testing

For testing purposes, you can reset the AuthX configuration:

```dart
// Reset singleton (for testing only)
AuthX.reset();
```

## Examples

See the [example](example/) directory for complete working examples:

- [Basic OAuth Flow](example/authx_example.dart) - Complete authentication example
- [Error Handling](example/error_handling_example.dart) - Comprehensive error scenarios
- [Multi-Provider Setup](example/multi_provider_example.dart) - Multiple provider configuration

## Security Considerations

- **State Management**: States automatically expire to prevent replay attacks
- **Secret Management**: Never commit client secrets to version control
- **Redirect URIs**: Ensure redirect URIs match your OAuth app configuration
- **HTTPS**: Always use HTTPS in production environments
- **State Validation**: Always validate the state parameter in callbacks

## Contributing

1. Fork the repository
2. Create a feature branch
3. Add tests for new functionality
4. Ensure all tests pass
5. Submit a pull request

## License

MIT License - see the [LICENSE](LICENSE) file for details.

## Changelog

### v1.0.0
- Initial release with GitHub and Google OAuth providers
- Type-safe ProviderId enum
- Singleton pattern with state management
- Comprehensive error handling
- Complete documentation and examples