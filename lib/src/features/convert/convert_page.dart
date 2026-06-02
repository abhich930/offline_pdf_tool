import 'package:flutter/material.dart';

import '../../domain/models/job_models.dart';
import '../../infrastructure/jobs/task_executor_service.dart';
import '../shared/file_flow_support.dart';

class ConvertPage extends StatelessWidget {
  const ConvertPage({super.key, required this.taskExecutor, required this.isBusy});

  final TaskExecutorService taskExecutor;
  final ValueNotifier<bool> isBusy;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _ConvertTile(
          label: 'HTML to PDF',
          type: JobType.htmlToPdf,
          taskExecutor: taskExecutor,
          isBusy: isBusy,
        ),
        _ConvertTile(
          label: 'Markdown to PDF',
          type: JobType.markdownToPdf,
          taskExecutor: taskExecutor,
          isBusy: isBusy,
        ),
        _ConvertTile(
          label: 'JSON to PDF',
          type: JobType.jsonToPdf,
          taskExecutor: taskExecutor,
          isBusy: isBusy,
        ),
        _ConvertTile(
          label: 'Images to PDF',
          type: JobType.imagesToPdf,
          taskExecutor: taskExecutor,
          isBusy: isBusy,
        ),
        _ConvertTile(
          label: 'PDF to Images',
          type: JobType.pdfToImages,
          taskExecutor: taskExecutor,
          isBusy: isBusy,
        ),
      ],
    );
  }
}

class _ConvertTile extends StatelessWidget {
  const _ConvertTile({
    required this.label,
    required this.type,
    required this.taskExecutor,
    required this.isBusy,
  });

  final String label;
  final JobType type;
  final TaskExecutorService taskExecutor;
  final ValueNotifier<bool> isBusy;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(label),
        trailing: ElevatedButton(
          onPressed: () => _run(context),
          child: const Text('Run'),
        ),
      ),
    );
  }

  Future<void> _run(BuildContext context) async {
    try {
      if (isBusy.value) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please wait for the current task to finish.')),
        );
        return;
      }

      final inputPaths = await FileFlowSupport.pickInputPaths(type);
      if (inputPaths == null || inputPaths.isEmpty || !context.mounted) return;

      final outputPath = await FileFlowSupport.pickOutputPath(
        type: type,
        inputPaths: inputPaths,
      );
      if (outputPath == null || !context.mounted) return;

      isBusy.value = true;
      await taskExecutor.run(
        JobRequest(
          type: type,
          inputPaths: inputPaths,
          outputPath: outputPath,
        ),
      );
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
}
