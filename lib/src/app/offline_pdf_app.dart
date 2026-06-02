import 'package:flutter/material.dart';

import '../features/dashboard/dashboard_page.dart';
import '../infrastructure/convert/default_converter_registry.dart';
import '../infrastructure/jobs/task_executor_service.dart';
import '../infrastructure/pdf/default_pdf_tool_service.dart';
import '../infrastructure/storage/local_file_workspace.dart';

class OfflinePdfApp extends StatefulWidget {
  const OfflinePdfApp({super.key});

  @override
  State<OfflinePdfApp> createState() => _OfflinePdfAppState();
}

class _OfflinePdfAppState extends State<OfflinePdfApp> {
  late final TaskExecutorService taskExecutor;

  @override
  void initState() {
    super.initState();
    final workspace = LocalFileWorkspace();
    final pdfToolService = DefaultPdfToolService(workspace: workspace);
    final converterRegistry = DefaultConverterRegistry(workspace: workspace);
    taskExecutor = TaskExecutorService(
      pdfToolService: pdfToolService,
      converterRegistry: converterRegistry,
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Offline PDF Tool',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: DashboardPage(taskExecutor: taskExecutor),
    );
  }
}
