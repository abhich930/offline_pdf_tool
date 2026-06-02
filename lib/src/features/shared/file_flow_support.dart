import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as p;

import '../../domain/models/job_models.dart';

class FileFlowSupport {
  static Future<List<String>?> pickInputPaths(JobType type) async {
    switch (type) {
      case JobType.mergePdf:
        return _pickFiles(
          allowMultiple: true,
          dialogTitle: 'Choose PDF files to merge',
          extensions: const ['pdf'],
        );
      case JobType.imagesToPdf:
        return _pickFiles(
          allowMultiple: true,
          dialogTitle: 'Choose image files',
          extensions: const ['png', 'jpg', 'jpeg', 'webp'],
        );
      case JobType.splitPdf:
      case JobType.rotatePages:
      case JobType.reorderPages:
      case JobType.deletePages:
      case JobType.compressPdf:
      case JobType.pdfToImages:
        return _pickFiles(
          dialogTitle: 'Choose a PDF file',
          extensions: const ['pdf'],
        );
      case JobType.htmlToPdf:
        return _pickFiles(
          dialogTitle: 'Choose an HTML file',
          extensions: const ['html', 'htm'],
        );
      case JobType.markdownToPdf:
        return _pickFiles(
          dialogTitle: 'Choose a Markdown file',
          extensions: const ['md', 'markdown'],
        );
      case JobType.jsonToPdf:
        return _pickFiles(
          dialogTitle: 'Choose a JSON file',
          extensions: const ['json'],
        );
    }
  }

  static Future<String?> pickOutputPath({
    required JobType type,
    required List<String> inputPaths,
  }) async {
    switch (type) {
      case JobType.splitPdf:
      case JobType.pdfToImages:
        return FilePicker.platform.getDirectoryPath(
          dialogTitle: type == JobType.splitPdf
              ? 'Choose output folder for split PDFs'
              : 'Choose output folder for images',
        );
      default:
        return FilePicker.platform.saveFile(
          dialogTitle: 'Save output file',
          fileName: suggestedOutputName(type, inputPaths),
          type: FileType.custom,
          allowedExtensions: _outputExtensions(type),
        );
    }
  }

  static String suggestedOutputName(JobType type, List<String> inputPaths) {
    final firstInput = inputPaths.isEmpty
        ? 'output'
        : p.basenameWithoutExtension(inputPaths.first);
    final safeFirstInput = _safeStem(firstInput);

    switch (type) {
      case JobType.mergePdf:
        return 'merged_$safeFirstInput.pdf';
      case JobType.splitPdf:
        return 'split_$safeFirstInput';
      case JobType.rotatePages:
        return '${safeFirstInput}_rotated.pdf';
      case JobType.reorderPages:
        return '${safeFirstInput}_reordered.pdf';
      case JobType.deletePages:
        return '${safeFirstInput}_trimmed.pdf';
      case JobType.compressPdf:
        return '${safeFirstInput}_compressed.pdf';
      case JobType.htmlToPdf:
      case JobType.markdownToPdf:
      case JobType.jsonToPdf:
      case JobType.imagesToPdf:
        return '$safeFirstInput.pdf';
      case JobType.pdfToImages:
        return '${safeFirstInput}_images';
    }
  }

  static List<String> _outputExtensions(JobType type) {
    switch (type) {
      case JobType.pdfToImages:
      case JobType.splitPdf:
        return const [];
      default:
        return const ['pdf'];
    }
  }

  static Future<List<String>?> _pickFiles({
    required List<String> extensions,
    required String dialogTitle,
    bool allowMultiple = false,
  }) async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: allowMultiple,
      type: FileType.custom,
      allowedExtensions: extensions,
      dialogTitle: dialogTitle,
    );

    final paths =
        result?.files.map((file) => file.path).whereType<String>().toList();
    if (paths == null || paths.isEmpty) return null;
    return paths;
  }

  static String _safeStem(String value) {
    return value.replaceAll(RegExp(r'[^A-Za-z0-9._-]+'), '_');
  }
}
