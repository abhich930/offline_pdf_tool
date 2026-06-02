abstract class PdfToolService {
  Future<void> mergePdf({
    required List<String> inputPaths,
    required String outputPath,
  });

  Future<void> splitPdf({
    required String inputPath,
    required String outputDirectory,
    required List<int> pageRanges,
  });

  Future<void> rotatePages({
    required String inputPath,
    required String outputPath,
    required List<int> pages,
    required int angle,
  });

  Future<void> reorderPages({
    required String inputPath,
    required String outputPath,
    required List<int> newOrder,
  });

  Future<void> deletePages({
    required String inputPath,
    required String outputPath,
    required List<int> pagesToDelete,
  });

  Future<void> compressPdf({
    required String inputPath,
    required String outputPath,
    required String preset,
  });
}
