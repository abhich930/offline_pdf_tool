import '../../domain/models/job_models.dart';
import '../../domain/services/converter.dart';
import '../../domain/services/workspace.dart';
import 'html_to_pdf_converter.dart';
import 'images_pdf_converters.dart';
import 'json_to_pdf_converter.dart';
import 'markdown_to_pdf_converter.dart';

class DefaultConverterRegistry implements ConverterRegistry {
  DefaultConverterRegistry({required Workspace workspace})
      : _converters = {
          JobType.htmlToPdf: HtmlToPdfConverter(workspace: workspace),
          JobType.markdownToPdf: MarkdownToPdfConverter(workspace: workspace),
          JobType.jsonToPdf: JsonToPdfConverter(workspace: workspace),
          JobType.imagesToPdf: ImagesToPdfConverter(workspace: workspace),
          JobType.pdfToImages: PdfToImagesConverter(workspace: workspace),
        };

  final Map<JobType, Converter> _converters;

  @override
  Converter? getConverter(JobType type) => _converters[type];
}
