import 'package:flutter/material.dart';

import '../../infrastructure/jobs/task_executor_service.dart';
import '../convert/convert_page.dart';
import '../pdf_tools/pdf_tools_page.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key, required this.taskExecutor});

  final TaskExecutorService taskExecutor;

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int index = 0;
  final ValueNotifier<bool> isBusy = ValueNotifier<bool>(false);

  @override
  void dispose() {
    isBusy.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      PdfToolsPage(taskExecutor: widget.taskExecutor, isBusy: isBusy),
      ConvertPage(taskExecutor: widget.taskExecutor, isBusy: isBusy),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Offline PDF Tool'),
        actions: [
          ValueListenableBuilder<bool>(
            valueListenable: isBusy,
            builder: (context, busy, _) {
              if (!busy) return const SizedBox.shrink();
              return const Padding(
                padding: EdgeInsets.only(right: 16),
                child: Center(
                  child: SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: pages[index],
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (value) => setState(() => index = value),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.picture_as_pdf), label: 'PDF Tools'),
          NavigationDestination(icon: Icon(Icons.transform), label: 'Convert'),
        ],
      ),
    );
  }
}
