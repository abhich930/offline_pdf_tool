import 'dart:io';
import 'dart:ui';

import 'package:syncfusion_flutter_pdf/pdf.dart';

import '../../domain/services/pdf_tool_service.dart';
import '../../domain/services/workspace.dart';

class DefaultPdfToolService implements PdfToolService {
  DefaultPdfToolService({required this.workspace});

  final Workspace workspace;

  @override
  Future<void> compressPdf({
    required String inputPath,
    required String outputPath,
    required String preset,
  }) async {
    final inputFile = File(inputPath);
    if (!await inputFile.exists()) throw ArgumentError('Missing input file: $inputPath');
    final bytes = await inputFile.readAsBytes();
    final document = PdfDocument(inputBytes: bytes);
    document.compressionLevel = _compressionFromPreset(preset);
    final outBytes = await document.save();
    document.dispose();
    await File(outputPath).writeAsBytes(outBytes, flush: true);
  }

  @override
  Future<void> deletePages({
    required String inputPath,
    required String outputPath,
    required List<int> pagesToDelete,
  }) async {
    final inputFile = File(inputPath);
    if (!await inputFile.exists()) throw ArgumentError('Missing input file: $inputPath');
    final bytes = await inputFile.readAsBytes();
    final document = PdfDocument(inputBytes: bytes);
    final indices = pagesToDelete
        .map((p) => p - 1)
        .where((i) => i >= 0 && i < document.pages.count)
        .toList()
      ..sort((a, b) => b.compareTo(a));

    for (final index in indices) {
      document.pages.removeAt(index);
    }

    final outBytes = await document.save();
    document.dispose();
    await File(outputPath).writeAsBytes(outBytes, flush: true);
  }

  @override
  Future<void> mergePdf({
    required List<String> inputPaths,
    required String outputPath,
  }) async {
    if (inputPaths.isEmpty) throw ArgumentError('No input PDFs provided.');

    final merged = PdfDocument();
    for (final path in inputPaths) {
      final file = File(path);
      if (!await file.exists()) continue;
      final bytes = await file.readAsBytes();
      final source = PdfDocument(inputBytes: bytes);
      for (var i = 0; i < source.pages.count; i++) {
        _appendPageAsTemplate(merged, source.pages[i]);
      }
      source.dispose();
    }

    final outBytes = await merged.save();
    merged.dispose();
    await File(outputPath).writeAsBytes(outBytes, flush: true);
  }

  @override
  Future<void> reorderPages({
    required String inputPath,
    required String outputPath,
    required List<int> newOrder,
  }) async {
    final inputFile = File(inputPath);
    if (!await inputFile.exists()) throw ArgumentError('Missing input file: $inputPath');
    final bytes = await inputFile.readAsBytes();
    final source = PdfDocument(inputBytes: bytes);
    final reordered = PdfDocument();

    for (final page in newOrder) {
      final index = page - 1;
      if (index >= 0 && index < source.pages.count) {
        _appendPageAsTemplate(reordered, source.pages[index]);
      }
    }

    if (reordered.pages.count == 0) {
      source.dispose();
      reordered.dispose();
      throw ArgumentError('New page order does not include any valid pages.');
    }

    final outBytes = await reordered.save();
    source.dispose();
    reordered.dispose();
    await File(outputPath).writeAsBytes(outBytes, flush: true);
  }

  @override
  Future<void> rotatePages({
    required String inputPath,
    required String outputPath,
    required List<int> pages,
    required int angle,
  }) async {
    final inputFile = File(inputPath);
    if (!await inputFile.exists()) throw ArgumentError('Missing input file: $inputPath');
    final bytes = await inputFile.readAsBytes();
    final document = PdfDocument(inputBytes: bytes);
    final rotation = _rotationForAngle(angle);

    for (final page in pages) {
      final index = page - 1;
      if (index >= 0 && index < document.pages.count) {
        document.pages[index].rotation = rotation;
      }
    }

    final outBytes = await document.save();
    document.dispose();
    await File(outputPath).writeAsBytes(outBytes, flush: true);
  }

  @override
  Future<void> splitPdf({
    required String inputPath,
    required String outputDirectory,
    required List<int> pageRanges,
  }) async {
    final source = File(inputPath);
    if (!await source.exists()) {
      throw ArgumentError('Input PDF does not exist.');
    }
    final outDir = Directory(outputDirectory);
    if (!await outDir.exists()) {
      await outDir.create(recursive: true);
    }

    final bytes = await source.readAsBytes();
    final input = PdfDocument(inputBytes: bytes);
    for (var i = 0; i < pageRanges.length; i++) {
      final page = pageRanges[i];
      final pageIndex = page - 1;
      if (pageIndex < 0 || pageIndex >= input.pages.count) continue;

      final split = PdfDocument();
      _appendPageAsTemplate(split, input.pages[pageIndex]);
      final outBytes = await split.save();
      split.dispose();

      final out = File('$outputDirectory/split_${i + 1}.pdf');
      await out.writeAsBytes(outBytes, flush: true);
    }
    input.dispose();
  }

  PdfPageRotateAngle _rotationForAngle(int angle) {
    switch (angle % 360) {
      case 90:
      case -270:
        return PdfPageRotateAngle.rotateAngle90;
      case 180:
      case -180:
        return PdfPageRotateAngle.rotateAngle180;
      case 270:
      case -90:
        return PdfPageRotateAngle.rotateAngle270;
      default:
        return PdfPageRotateAngle.rotateAngle0;
    }
  }

  PdfCompressionLevel _compressionFromPreset(String preset) {
    switch (preset.toLowerCase()) {
      case 'low':
        return PdfCompressionLevel.belowNormal;
      case 'high':
        return PdfCompressionLevel.best;
      case 'balanced':
      default:
        return PdfCompressionLevel.normal;
    }
  }

  void _appendPageAsTemplate(PdfDocument target, PdfPage sourcePage) {
    final orientation = sourcePage.size.width > sourcePage.size.height
        ? PdfPageOrientation.landscape
        : PdfPageOrientation.portrait;
    target.pageSettings.orientation = orientation;
    target.pageSettings.size = sourcePage.size;
    target.pageSettings.rotate = sourcePage.rotation;
    target.pageSettings.margins.all = 0;
    final newPage = target.pages.add();
    newPage.graphics.drawPdfTemplate(
      sourcePage.createTemplate(),
      Offset.zero,
      sourcePage.size,
    );
  }
}
