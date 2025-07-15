/// Central location for network API constants and endpoints.
///
/// Note: On Android emulator, use '10.0.2.2' to access host machine.
///       On physical device, update [apiBaseUrl] to point to host's LAN IP.
///       For cloud/remote preview, use the backend preview URL accessible from your device/web:
///         e.g. https://vscode-internal-4816-beta.beta01.cloud.kavia.ai:3001
///
/// Update the value below as follows:
///   - Android Emulator:        'http://10.0.2.2:3001'
///   - iOS Simulator:           'http://localhost:3001' (if backend runs on your Mac)
///   - Real device (LAN):       'http://your-host-LAN-IP:3001'
///   - Remote/Cloud backend:    'https://vscode-internal-4816-beta.beta01.cloud.kavia.ai:3001'
///
/// For CI/CD or deployment, set the API_BASE_URL env using --dart-define or .env:
///   flutter run --dart-define=API_BASE_URL=https://your-backend/api
class ApiConstants {
  // PUBLIC_INTERFACE
  /// Base URL for backend API.
  /// Default points to the remote preview deployment for 'finance_tracker_backend'.
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    // Change this default to your current backend endpoint for best results:
    // E.g. for cloud preview:
    defaultValue: 'https://vscode-internal-4816-beta.beta01.cloud.kavia.ai:3001',
  );
}
