enum JobType {
  mergePdf,
  splitPdf,
  rotatePages,
  reorderPages,
  deletePages,
  compressPdf,
  htmlToPdf,
  markdownToPdf,
  jsonToPdf,
  imagesToPdf,
  pdfToImages,
}

class JobRequest {
  JobRequest({
    required this.type,
    required this.inputPaths,
    required this.outputPath,
    this.options = const {},
  });

  final JobType type;
  final List<String> inputPaths;
  final String outputPath;
  final Map<String, Object?> options;
}
