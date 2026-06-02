import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../domain/services/workspace.dart';

class LocalFileWorkspace implements Workspace {
  @override
  Future<String> ensureTempDir() async {
    final base = await getTemporaryDirectory();
    final dir = Directory(p.join(base.path, 'offline_pdf_tool'));
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir.path;
  }

  @override
  Future<String> uniqueOutputPath(String requestedPath) async {
    final original = File(requestedPath);
    if (!await original.exists()) return requestedPath;

    final dir = p.dirname(requestedPath);
    final ext = p.extension(requestedPath);
    final name = p.basenameWithoutExtension(requestedPath);

    for (var i = 1; i <= 9999; i++) {
      final candidate = p.join(dir, '${name}_$i$ext');
      if (!await File(candidate).exists()) return candidate;
    }

    throw StateError('Could not generate unique output path.');
  }

  @override
  Future<void> cleanupTemp() async {
    final dirPath = await ensureTempDir();
    final dir = Directory(dirPath);
    if (await dir.exists()) {
      await dir.delete(recursive: true);
    }
  }
}
