import 'dart:io';

import '../../domain/models/job_models.dart';
import '../../domain/services/converter.dart';
import '../../domain/services/workspace.dart';

class ImagesToPdfConverter implements Converter {
  ImagesToPdfConverter({required this.workspace});
  final Workspace workspace;

  @override
  JobType get type => JobType.imagesToPdf;

  @override
  Future<void> run(JobRequest request) async {
    final out = File(request.outputPath);
    final lines = request.inputPaths.join('\n');
    await out.writeAsString('PDF_FROM_IMAGES\n$lines');
  }
}

class PdfToImagesConverter implements Converter {
  PdfToImagesConverter({required this.workspace});
  final Workspace workspace;

  @override
  JobType get type => JobType.pdfToImages;

  @override
  Future<void> run(JobRequest request) async {
    final outputDir = Directory(request.outputPath);
    if (!await outputDir.exists()) {
      await outputDir.create(recursive: true);
    }
    await File('${outputDir.path}/page_1.png').writeAsBytes(const [0, 1, 2, 3]);
  }
}
