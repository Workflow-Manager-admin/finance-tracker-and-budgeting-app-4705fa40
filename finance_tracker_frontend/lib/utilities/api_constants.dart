/// Central location for network API constants and endpoints.
///
/// Note: On Android emulator, use '10.0.2.2' to access host machine.
///       On physical device, update [apiBaseUrl] to point to host's LAN IP.
///       Backend is assumed to be running on port 3001.
class ApiConstants {
  // PUBLIC_INTERFACE
  /// Base URL for backend API. Do NOT use 'localhost' directly in mobile apps.
  /// By default, uses Android emulator address for host machine.
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:3001',
  );
}
