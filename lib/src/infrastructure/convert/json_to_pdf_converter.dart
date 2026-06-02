import 'dart:convert';
import 'dart:io';

import '../../domain/models/job_models.dart';
import '../../domain/services/converter.dart';
import '../../domain/services/workspace.dart';

class JsonToPdfConverter implements Converter {
  JsonToPdfConverter({required this.workspace});

  final Workspace workspace;

  @override
  JobType get type => JobType.jsonToPdf;

  @override
  Future<void> run(JobRequest request) async {
    final jsonPath = request.inputPaths.first;
    final map = jsonDecode(await File(jsonPath).readAsString());
    final out = File(request.outputPath);
    await out.writeAsString('PDF_PLACEHOLDER\n${const JsonEncoder.withIndent('  ').convert(map)}');
  }
}
