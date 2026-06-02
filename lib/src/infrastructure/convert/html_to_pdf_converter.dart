import 'dart:io';

import '../../domain/models/job_models.dart';
import '../../domain/services/converter.dart';
import '../../domain/services/workspace.dart';

class HtmlToPdfConverter implements Converter {
  HtmlToPdfConverter({required this.workspace});

  final Workspace workspace;

  @override
  JobType get type => JobType.htmlToPdf;

  @override
  Future<void> run(JobRequest request) async {
    final htmlPath = request.inputPaths.first;
    final html = await File(htmlPath).readAsString();
    final out = File(request.outputPath);
    await out.writeAsString('PDF_PLACEHOLDER\n$html');
  }
}
