import '../../domain/models/job_models.dart';
import '../../domain/services/converter.dart';
import '../../domain/services/pdf_tool_service.dart';

class TaskExecutorService {
  TaskExecutorService({
    required this.pdfToolService,
    required this.converterRegistry,
  });

  final PdfToolService pdfToolService;
  final ConverterRegistry converterRegistry;

  Future<void> run(JobRequest req) async {
    switch (req.type) {
      case JobType.mergePdf:
        await pdfToolService.mergePdf(inputPaths: req.inputPaths, outputPath: req.outputPath);
      case JobType.splitPdf:
        await pdfToolService.splitPdf(
          inputPath: req.inputPaths.first,
          outputDirectory: req.outputPath,
          pageRanges: (req.options['ranges'] as List<int>? ?? [1]),
        );
      case JobType.rotatePages:
        await pdfToolService.rotatePages(
          inputPath: req.inputPaths.first,
          outputPath: req.outputPath,
          pages: (req.options['pages'] as List<int>? ?? [1]),
          angle: (req.options['angle'] as int? ?? 90),
        );
      case JobType.reorderPages:
        await pdfToolService.reorderPages(
          inputPath: req.inputPaths.first,
          outputPath: req.outputPath,
          newOrder: (req.options['order'] as List<int>? ?? [1]),
        );
      case JobType.deletePages:
        await pdfToolService.deletePages(
          inputPath: req.inputPaths.first,
          outputPath: req.outputPath,
          pagesToDelete: (req.options['pages'] as List<int>? ?? [1]),
        );
      case JobType.compressPdf:
        await pdfToolService.compressPdf(
          inputPath: req.inputPaths.first,
          outputPath: req.outputPath,
          preset: (req.options['preset'] as String? ?? 'balanced'),
        );
      case JobType.htmlToPdf:
      case JobType.markdownToPdf:
      case JobType.jsonToPdf:
      case JobType.imagesToPdf:
      case JobType.pdfToImages:
        final converter = converterRegistry.getConverter(req.type);
        if (converter == null) {
          throw UnsupportedError('No converter registered for ${req.type.name}');
        }
        await converter.run(req);
    }
  }
}
