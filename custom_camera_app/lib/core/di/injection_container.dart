import 'package:get_it/get_it.dart';

/// Global service locator instance
final getIt = GetIt.instance;

/// Initialize all dependencies
/// Call this once at app startup (main.dart)
Future<void> initializeDependencies() async {
  // Core services
  // TODO: Register logging, config, etc.

  // Infrastructure
  // TODO: Register SDK adapters, network clients, storage

  // Data sources
  // TODO: Register remote/local data sources

  // Repositories
  // TODO: Register repository implementations

  // Use cases
  // TODO: Register use cases

  // Blocs/Cubits
  // TODO: Register factories for blocs
}

/// Clean up all dependencies (for testing)
Future<void> resetDependencies() async {
  await getIt.reset();
}
