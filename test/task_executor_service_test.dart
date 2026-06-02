import 'package:flutter_test/flutter_test.dart';
import 'package:offline_pdf_tool/src/domain/models/job_models.dart';
import 'package:offline_pdf_tool/src/domain/services/converter.dart';
import 'package:offline_pdf_tool/src/domain/services/pdf_tool_service.dart';
import 'package:offline_pdf_tool/src/infrastructure/jobs/task_executor_service.dart';

class _FakePdfToolService implements PdfToolService {
  int mergeCalls = 0;

  @override
  Future<void> compressPdf({required String inputPath, required String outputPath, required String preset}) async {}

  @override
  Future<void> deletePages({required String inputPath, required String outputPath, required List<int> pagesToDelete}) async {}

  @override
  Future<void> mergePdf({required List<String> inputPaths, required String outputPath}) async {
    mergeCalls++;
  }

  @override
  Future<void> reorderPages({required String inputPath, required String outputPath, required List<int> newOrder}) async {}

  @override
  Future<void> rotatePages({required String inputPath, required String outputPath, required List<int> pages, required int angle}) async {}

  @override
  Future<void> splitPdf({required String inputPath, required String outputDirectory, required List<int> pageRanges}) async {}
}

class _FakeConverter implements Converter {
  _FakeConverter(this._type);
  final JobType _type;
  int runCalls = 0;

  @override
  JobType get type => _type;

  @override
  Future<void> run(JobRequest request) async {
    runCalls++;
  }
}

class _FakeRegistry implements ConverterRegistry {
  _FakeRegistry(this.converter);
  final Converter converter;

  @override
  Converter? getConverter(JobType type) => type == converter.type ? converter : null;
}

void main() {
  test('executor runs merge jobs', () async {
    final pdf = _FakePdfToolService();
    final executor = TaskExecutorService(
      pdfToolService: pdf,
      converterRegistry: _FakeRegistry(_FakeConverter(JobType.htmlToPdf)),
    );

    await executor.run(
      JobRequest(type: JobType.mergePdf, inputPaths: ['a.pdf', 'b.pdf'], outputPath: 'c.pdf'),
    );

    expect(pdf.mergeCalls, 1);
  });

  test('executor runs converter jobs', () async {
    final pdf = _FakePdfToolService();
    final converter = _FakeConverter(JobType.markdownToPdf);
    final executor = TaskExecutorService(
      pdfToolService: pdf,
      converterRegistry: _FakeRegistry(converter),
    );

    await executor.run(
      JobRequest(type: JobType.markdownToPdf, inputPaths: ['a.md'], outputPath: 'a.pdf'),
    );

    expect(converter.runCalls, 1);
  });
}
