abstract class Workspace {
  Future<String> ensureTempDir();
  Future<String> uniqueOutputPath(String requestedPath);
  Future<void> cleanupTemp();
}
