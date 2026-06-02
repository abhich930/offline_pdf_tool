import 'dart:io';
import 'dart:ui';

import 'package:markdown/markdown.dart' as md;
import 'package:syncfusion_flutter_pdf/pdf.dart';

import '../../domain/models/job_models.dart';
import '../../domain/services/converter.dart';
import '../../domain/services/workspace.dart';

class MarkdownToPdfConverter implements Converter {
  MarkdownToPdfConverter({required this.workspace});

  final Workspace workspace;

  @override
  JobType get type => JobType.markdownToPdf;

  @override
  Future<void> run(JobRequest request) async {
    final markdownPath = request.inputPaths.first;
    final markdownSource = await File(markdownPath).readAsString();

    final document = PdfDocument();
    final renderer = _MarkdownPdfRenderer(document);
    renderer.render(markdownSource);

    final bytes = await document.save();
    document.dispose();
    await File(request.outputPath).writeAsBytes(bytes, flush: true);
  }
}

class _MarkdownPdfRenderer {
  _MarkdownPdfRenderer(this.document) {
    _currentPage = document.pages.add();
  }

  static const double _pageMargin = 40;
  static const double _sectionGap = 10;
  static const double _listIndent = 20;

  final PdfDocument document;
  final PdfBrush _textBrush = PdfSolidBrush(PdfColor(34, 34, 34));
  final PdfBrush _mutedBrush = PdfSolidBrush(PdfColor(92, 92, 92));
  final PdfBrush _codeBrush = PdfSolidBrush(PdfColor(48, 48, 48));
  final PdfBrush _codeFillBrush = PdfSolidBrush(PdfColor(245, 245, 245));
  final PdfPen _dividerPen = PdfPen(PdfColor(210, 210, 210), width: 1);
  late PdfPage _currentPage;
  double _cursorY = _pageMargin;

  double get _usableWidth => _currentPage.size.width - (_pageMargin * 2);
  double get _bottomLimit => _currentPage.size.height - _pageMargin;

  void render(String markdownSource) {
    final nodes = md.Document().parse(markdownSource);
    for (final node in nodes) {
      _renderNode(node, indentLevel: 0);
    }
  }

  void _renderNode(md.Node node, {required int indentLevel}) {
    if (node is md.Text) {
      final text = node.text.trim();
      if (text.isNotEmpty) {
        _drawTextBlock(text, font: _bodyFont(), indentLevel: indentLevel);
      }
      return;
    }

    if (node is! md.Element) return;

    switch (node.tag) {
      case 'h1':
        _drawTextBlock(node.textContent.trim(),
            font: _headingFont(24), indentLevel: indentLevel);
      case 'h2':
        _drawTextBlock(node.textContent.trim(),
            font: _headingFont(20), indentLevel: indentLevel);
      case 'h3':
        _drawTextBlock(node.textContent.trim(),
            font: _headingFont(17), indentLevel: indentLevel);
      case 'h4':
      case 'h5':
      case 'h6':
        _drawTextBlock(node.textContent.trim(),
            font: _headingFont(14), indentLevel: indentLevel);
      case 'p':
        _drawTextBlock(_inlineText(node).trim(),
            font: _bodyFont(), indentLevel: indentLevel);
      case 'blockquote':
        _drawTextBlock(
          _inlineText(node).trim(),
          font: _italicFont(),
          brush: _mutedBrush,
          indentLevel: indentLevel + 1,
        );
      case 'pre':
        _drawCodeBlock(node.textContent);
      case 'ul':
        _renderList(node, ordered: false, indentLevel: indentLevel);
      case 'ol':
        _renderList(node, ordered: true, indentLevel: indentLevel);
      case 'hr':
        _drawDivider();
      default:
        final children = node.children;
        if (children == null || children.isEmpty) {
          final text = node.textContent.trim();
          if (text.isNotEmpty) {
            _drawTextBlock(text, font: _bodyFont(), indentLevel: indentLevel);
          }
        } else {
          for (final child in children) {
            _renderNode(child, indentLevel: indentLevel);
          }
        }
    }
  }

  void _renderList(md.Element list,
      {required bool ordered, required int indentLevel}) {
    final items = list.children
            ?.whereType<md.Element>()
            .where((child) => child.tag == 'li')
            .toList() ??
        const [];
    for (var i = 0; i < items.length; i++) {
      final prefix = ordered ? '${i + 1}. ' : '• ';
      final inlineParts = <String>[];
      final nestedLists = <md.Element>[];

      for (final child in items[i].children ?? const <md.Node>[]) {
        if (child is md.Element && (child.tag == 'ul' || child.tag == 'ol')) {
          nestedLists.add(child);
        } else {
          final text = _nodeText(child).trim();
          if (text.isNotEmpty) {
            inlineParts.add(text);
          }
        }
      }

      final itemText =
          inlineParts.join(' ').replaceAll(RegExp(r'\s+'), ' ').trim();
      if (itemText.isNotEmpty) {
        _drawTextBlock(
          '$prefix$itemText',
          font: _bodyFont(),
          indentLevel: indentLevel + 1,
        );
      }

      for (final nested in nestedLists) {
        _renderList(nested,
            ordered: nested.tag == 'ol', indentLevel: indentLevel + 1);
      }
    }
  }

  void _drawCodeBlock(String text) {
    final lines = text.replaceAll('\t', '  ').split('\n');
    final font = PdfStandardFont(PdfFontFamily.courier, 10);
    const indent = _pageMargin;
    final blockWidth = _usableWidth;
    const innerPadding = 10.0;

    for (final rawLine in lines) {
      final wrappedLines = _wrapText(
        rawLine.isEmpty ? ' ' : rawLine,
        font: font,
        maxWidth: blockWidth - (innerPadding * 2),
      );

      for (final line in wrappedLines) {
        final lineHeight = font.measureString(line).height + 4;
        _ensurePageCapacity(lineHeight + (innerPadding * 2));
        _currentPage.graphics.drawRectangle(
          brush: _codeFillBrush,
          pen: PdfPen(PdfColor(232, 232, 232)),
          bounds: Rect.fromLTWH(
            indent,
            _cursorY,
            blockWidth,
            lineHeight + (innerPadding * 2),
          ),
        );
        _currentPage.graphics.drawString(
          line,
          font,
          brush: _codeBrush,
          bounds: Rect.fromLTWH(
            indent + innerPadding,
            _cursorY + innerPadding,
            blockWidth - (innerPadding * 2),
            lineHeight,
          ),
        );
        _cursorY += lineHeight + (innerPadding * 2) + 3;
      }
    }

    _cursorY += _sectionGap;
  }

  void _drawDivider() {
    _ensurePageCapacity(_sectionGap + 4);
    final y = _cursorY + 2;
    _currentPage.graphics.drawLine(
      _dividerPen,
      Offset(_pageMargin, y),
      Offset(_pageMargin + _usableWidth, y),
    );
    _cursorY += _sectionGap + 4;
  }

  void _drawTextBlock(
    String text, {
    required PdfFont font,
    PdfBrush? brush,
    required int indentLevel,
  }) {
    if (text.trim().isEmpty) {
      _cursorY += 6;
      return;
    }

    final effectiveBrush = brush ?? _textBrush;
    final indent = indentLevel * _listIndent;
    final maxWidth = _usableWidth - indent;
    final lines = text
        .split('\n')
        .expand((line) => _wrapText(line.trim().isEmpty ? ' ' : line.trim(),
            font: font, maxWidth: maxWidth))
        .toList();

    for (final line in lines) {
      final lineHeight = font.measureString(line).height + 4;
      _ensurePageCapacity(lineHeight);
      _currentPage.graphics.drawString(
        line,
        font,
        brush: effectiveBrush,
        bounds:
            Rect.fromLTWH(_pageMargin + indent, _cursorY, maxWidth, lineHeight),
      );
      _cursorY += lineHeight;
    }

    _cursorY += _sectionGap;
  }

  List<String> _wrapText(String text,
      {required PdfFont font, required double maxWidth}) {
    final normalized = text.replaceAll(RegExp(r'\s+'), ' ').trimRight();
    if (normalized.isEmpty) return const [''];

    final words = normalized.split(' ');
    final lines = <String>[];
    var currentLine = '';

    for (final word in words) {
      final candidate = currentLine.isEmpty ? word : '$currentLine $word';
      final width = font.measureString(candidate).width;
      if (width <= maxWidth || currentLine.isEmpty) {
        currentLine = candidate;
      } else {
        lines.add(currentLine);
        currentLine = word;
      }
    }

    if (currentLine.isNotEmpty) {
      lines.add(currentLine);
    }

    return lines;
  }

  String _inlineText(md.Element element) {
    final children = element.children;
    if (children == null || children.isEmpty) {
      return element.textContent;
    }
    return children.map(_nodeText).join();
  }

  String _nodeText(md.Node node) {
    if (node is md.Text) return node.text;
    if (node is! md.Element) return node.textContent;

    switch (node.tag) {
      case 'br':
        return '\n';
      case 'a':
        final label = node.children?.map(_nodeText).join() ?? node.textContent;
        final href = node.attributes['href'];
        if (href == null || href.isEmpty || href == label) {
          return label;
        }
        return '$label ($href)';
      case 'code':
        return node.textContent;
      default:
        return node.children?.map(_nodeText).join() ?? node.textContent;
    }
  }

  void _ensurePageCapacity(double nextBlockHeight) {
    if (_cursorY + nextBlockHeight <= _bottomLimit) return;
    _currentPage = document.pages.add();
    _cursorY = _pageMargin;
  }

  PdfFont _bodyFont() => PdfStandardFont(PdfFontFamily.helvetica, 11);

  PdfFont _headingFont(double size) => PdfStandardFont(
        PdfFontFamily.helvetica,
        size,
        style: PdfFontStyle.bold,
      );

  PdfFont _italicFont() => PdfStandardFont(
        PdfFontFamily.helvetica,
        11,
        style: PdfFontStyle.italic,
      );
}
