import 'package:flutter/material.dart';

import '../../core/utils/task_value_parsers.dart';
import '../../domain/models/job_models.dart';
import '../../infrastructure/jobs/task_executor_service.dart';
import '../shared/file_flow_support.dart';

class PdfToolsPage extends StatelessWidget {
  const PdfToolsPage({super.key, required this.taskExecutor, required this.isBusy});

  final TaskExecutorService taskExecutor;
  final ValueNotifier<bool> isBusy;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _ActionTile(
          title: 'Merge PDFs',
          subtitle: 'Combine multiple PDF files into one.',
          onTap: () => _runMerge(context),
        ),
        _ActionTile(
          title: 'Split PDF',
          subtitle: 'Extract selected pages into separate PDFs.',
          onTap: () => _runSplit(context),
        ),
        _ActionTile(
          title: 'Rotate Pages',
          subtitle: 'Rotate selected pages by angle.',
          onTap: () => _runRotate(context),
        ),
        _ActionTile(
          title: 'Reorder/Delete Pages',
          subtitle: 'Rearrange pages or remove selected pages.',
          onTap: () => _runReorderOrDelete(context),
        ),
        _ActionTile(
          title: 'Compress PDF',
          subtitle: 'Apply basic export compression presets.',
          onTap: () => _runCompress(context),
        ),
      ],
    );
  }

  Future<void> _runMerge(BuildContext context) async {
    try {
      final inputPaths = await FileFlowSupport.pickInputPaths(JobType.mergePdf);
      if (inputPaths == null || inputPaths.isEmpty || !context.mounted) return;

      final outputPath = await FileFlowSupport.pickOutputPath(
        type: JobType.mergePdf,
        inputPaths: inputPaths,
      );
      if (outputPath == null || !context.mounted) return;

      await _execute(
        context,
        label: 'Merge PDFs',
        request: JobRequest(
          type: JobType.mergePdf,
          inputPaths: inputPaths,
          outputPath: outputPath,
        ),
      );
    } catch (e) {
      _showFailure(context, e);
    }
  }

  Future<void> _runSplit(BuildContext context) async {
    try {
      final inputPaths = await FileFlowSupport.pickInputPaths(JobType.splitPdf);
      if (inputPaths == null || inputPaths.isEmpty || !context.mounted) return;

      final pages = await _showPageListDialog(
        context,
        title: 'Split PDF',
        hint: 'Pages to extract, e.g. 1,3,5',
        initialValue: '1',
      );
      if (pages == null || !context.mounted) return;

      final outputPath = await FileFlowSupport.pickOutputPath(
        type: JobType.splitPdf,
        inputPaths: inputPaths,
      );
      if (outputPath == null || !context.mounted) return;

      await _execute(
        context,
        label: 'Split PDF',
        request: JobRequest(
          type: JobType.splitPdf,
          inputPaths: inputPaths,
          outputPath: outputPath,
          options: {'ranges': pages},
        ),
      );
    } catch (e) {
      _showFailure(context, e);
    }
  }

  Future<void> _runRotate(BuildContext context) async {
    try {
      final inputPaths = await FileFlowSupport.pickInputPaths(JobType.rotatePages);
      if (inputPaths == null || inputPaths.isEmpty || !context.mounted) return;

      final config = await _showRotateDialog(context);
      if (config == null || !context.mounted) return;

      final outputPath = await FileFlowSupport.pickOutputPath(
        type: JobType.rotatePages,
        inputPaths: inputPaths,
      );
      if (outputPath == null || !context.mounted) return;

      await _execute(
        context,
        label: 'Rotate Pages',
        request: JobRequest(
          type: JobType.rotatePages,
          inputPaths: inputPaths,
          outputPath: outputPath,
          options: {
            'pages': config.pages,
            'angle': config.angle,
          },
        ),
      );
    } catch (e) {
      _showFailure(context, e);
    }
  }

  Future<void> _runReorderOrDelete(BuildContext context) async {
    try {
      final inputPaths = await FileFlowSupport.pickInputPaths(JobType.reorderPages);
      if (inputPaths == null || inputPaths.isEmpty || !context.mounted) return;

      final config = await _showReorderDeleteDialog(context);
      if (config == null || !context.mounted) return;

      final outputPath = await FileFlowSupport.pickOutputPath(
        type: config.type,
        inputPaths: inputPaths,
      );
      if (outputPath == null || !context.mounted) return;

      await _execute(
        context,
        label: config.type == JobType.deletePages ? 'Delete Pages' : 'Reorder Pages',
        request: JobRequest(
          type: config.type,
          inputPaths: inputPaths,
          outputPath: outputPath,
          options: config.type == JobType.deletePages
              ? {'pages': config.values}
              : {'order': config.values},
        ),
      );
    } catch (e) {
      _showFailure(context, e);
    }
  }

  Future<void> _runCompress(BuildContext context) async {
    try {
      final inputPaths = await FileFlowSupport.pickInputPaths(JobType.compressPdf);
      if (inputPaths == null || inputPaths.isEmpty || !context.mounted) return;

      final preset = await _showPresetDialog(context);
      if (preset == null || !context.mounted) return;

      final outputPath = await FileFlowSupport.pickOutputPath(
        type: JobType.compressPdf,
        inputPaths: inputPaths,
      );
      if (outputPath == null || !context.mounted) return;

      await _execute(
        context,
        label: 'Compress PDF',
        request: JobRequest(
          type: JobType.compressPdf,
          inputPaths: inputPaths,
          outputPath: outputPath,
          options: {'preset': preset},
        ),
      );
    } catch (e) {
      _showFailure(context, e);
    }
  }

  Future<void> _execute(
    BuildContext context, {
    required String label,
    required JobRequest request,
  }) async {
    if (isBusy.value) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please wait for the current task to finish.')),
      );
      return;
    }

    isBusy.value = true;
    try {
      await taskExecutor.run(request);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$label completed')),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Task failed: $e')),
      );
    } finally {
      isBusy.value = false;
    }
  }

  Future<List<int>?> _showPageListDialog(
    BuildContext context, {
    required String title,
    required String hint,
    required String initialValue,
  }) async {
    final controller = TextEditingController(text: initialValue);

    final result = await showDialog<List<int>>(
      context: context,
      builder: (dialogContext) {
        String? errorText;

        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(title),
              content: TextField(
                controller: controller,
                decoration: InputDecoration(
                  labelText: hint,
                  errorText: errorText,
                ),
                autofocus: true,
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () {
                    try {
                      final values = parsePositiveIntList(controller.text);
                      Navigator.of(dialogContext).pop(values);
                    } on FormatException catch (error) {
                      setState(() => errorText = error.message);
                    }
                  },
                  child: const Text('Continue'),
                ),
              ],
            );
          },
        );
      },
    );

    controller.dispose();
    return result;
  }

  Future<_RotateDialogResult?> _showRotateDialog(BuildContext context) async {
    final controller = TextEditingController(text: '1');

    final result = await showDialog<_RotateDialogResult>(
      context: context,
      builder: (dialogContext) {
        String? errorText;
        int angle = 90;

        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Rotate Pages'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: controller,
                    decoration: InputDecoration(
                      labelText: 'Pages, e.g. 1,2,3',
                      errorText: errorText,
                    ),
                    autofocus: true,
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<int>(
                    value: angle,
                    decoration: const InputDecoration(labelText: 'Angle'),
                    items: const [
                      DropdownMenuItem(value: 90, child: Text('90°')),
                      DropdownMenuItem(value: 180, child: Text('180°')),
                      DropdownMenuItem(value: 270, child: Text('270°')),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => angle = value);
                      }
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () {
                    try {
                      final pages = parsePositiveIntList(controller.text);
                      Navigator.of(dialogContext).pop(_RotateDialogResult(pages, angle));
                    } on FormatException catch (error) {
                      setState(() => errorText = error.message);
                    }
                  },
                  child: const Text('Continue'),
                ),
              ],
            );
          },
        );
      },
    );

    controller.dispose();
    return result;
  }

  Future<_ReorderDeleteDialogResult?> _showReorderDeleteDialog(BuildContext context) async {
    final controller = TextEditingController(text: '1');

    final result = await showDialog<_ReorderDeleteDialogResult>(
      context: context,
      builder: (dialogContext) {
        String? errorText;
        JobType mode = JobType.reorderPages;

        return StatefulBuilder(
          builder: (context, setState) {
            final label = mode == JobType.deletePages
                ? 'Pages to delete, e.g. 2,4'
                : 'New page order, e.g. 3,1,2';

            return AlertDialog(
              title: const Text('Reorder or Delete Pages'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<JobType>(
                    value: mode,
                    decoration: const InputDecoration(labelText: 'Action'),
                    items: const [
                      DropdownMenuItem(
                        value: JobType.reorderPages,
                        child: Text('Reorder pages'),
                      ),
                      DropdownMenuItem(
                        value: JobType.deletePages,
                        child: Text('Delete pages'),
                      ),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => mode = value);
                      }
                    },
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: controller,
                    decoration: InputDecoration(
                      labelText: label,
                      errorText: errorText,
                    ),
                    autofocus: true,
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () {
                    try {
                      final values = parsePositiveIntList(controller.text);
                      Navigator.of(dialogContext).pop(_ReorderDeleteDialogResult(mode, values));
                    } on FormatException catch (error) {
                      setState(() => errorText = error.message);
                    }
                  },
                  child: const Text('Continue'),
                ),
              ],
            );
          },
        );
      },
    );

    controller.dispose();
    return result;
  }

  Future<String?> _showPresetDialog(BuildContext context) async {
    return showDialog<String>(
      context: context,
      builder: (dialogContext) {
        String preset = 'balanced';

        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Compression Preset'),
              content: DropdownButtonFormField<String>(
                value: preset,
                decoration: const InputDecoration(labelText: 'Preset'),
                items: const [
                  DropdownMenuItem(value: 'low', child: Text('Low compression')),
                  DropdownMenuItem(value: 'balanced', child: Text('Balanced')),
                  DropdownMenuItem(value: 'high', child: Text('High compression')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() => preset = value);
                  }
                },
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () => Navigator.of(dialogContext).pop(preset),
                  child: const Text('Continue'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showFailure(BuildContext context, Object error) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Task failed: $error')),
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}

class _RotateDialogResult {
  const _RotateDialogResult(this.pages, this.angle);

  final List<int> pages;
  final int angle;
}

class _ReorderDeleteDialogResult {
  const _ReorderDeleteDialogResult(this.type, this.values);

  final JobType type;
  final List<int> values;
}
