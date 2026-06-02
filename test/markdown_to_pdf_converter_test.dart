import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:offline_pdf_tool/src/domain/models/job_models.dart';
import 'package:offline_pdf_tool/src/domain/services/workspace.dart';
import 'package:offline_pdf_tool/src/infrastructure/convert/markdown_to_pdf_converter.dart';

class _FakeWorkspace implements Workspace {
  @override
  Future<void> cleanupTemp() async {}

  @override
  Future<String> ensureTempDir() async => Directory.systemTemp.path;

  @override
  Future<String> uniqueOutputPath(String requestedPath) async => requestedPath;
}

void main() {
  test('markdown converter creates a PDF file', () async {
    final tempDir = await Directory.systemTemp.createTemp('markdown_to_pdf_test_');
    final markdownFile = File('${tempDir.path}/input.md');
    final outputFile = File('${tempDir.path}/output.pdf');

    await markdownFile.writeAsString('# Title\n\n- one\n- two\n\n`code`');

    final converter = MarkdownToPdfConverter(workspace: _FakeWorkspace());
    await converter.run(
      JobRequest(
        type: JobType.markdownToPdf,
        inputPaths: [markdownFile.path],
        outputPath: outputFile.path,
      ),
    );

    final bytes = await outputFile.readAsBytes();
    expect(outputFile.existsSync(), isTrue);
    expect(bytes.take(4).toList(), equals(const [37, 80, 68, 70]));

    await tempDir.delete(recursive: true);
  });
}
