import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import '../../data/providers/notification_provider.dart';
import '../../core/utils/constants.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_text_styles.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_card.dart';

class ReportsController extends GetxController {
  final ReportProvider _provider = ReportProvider();

  final isExporting = false.obs;
  final selectedFormat = 'xlsx'.obs;
  final selectedPeriod = RxnString();
  final selectedDepartment = RxnString();
  final selectedStatus = RxnString();

  final periods = ['all', 'this_week', 'this_month', 'this_quarter', 'this_year'];
  final formats = ['xlsx', 'pdf'];

  Future<void> exportReport() async {
    isExporting.value = true;
    try {
      final res = await _provider.exportReport(
        format: selectedFormat.value,
        period: selectedPeriod.value,
        department: selectedDepartment.value,
        status: selectedStatus.value,
      );

      if (res.statusCode == 200) {
        final dir = await getTemporaryDirectory();
        final ext = selectedFormat.value;
        final file = File(
            '${dir.path}/csea_report_${DateTime.now().millisecondsSinceEpoch}.$ext');
        await file.writeAsBytes(res.data as List<int>);
        await OpenFilex.open(file.path);
        Get.snackbar('Downloaded', 'Report saved and opened');
      } else {
        Get.snackbar('Error', 'Report generation failed');
      }
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isExporting.value = false;
    }
  }
}


class ReportsView extends GetView<ReportsController> {
  const ReportsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundSecondary,
      appBar: AppBar(title: const Text('Export Reports')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppCard(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Report Configuration',
                      style: AppTextStyles.headlineSmall),
                  const SizedBox(height: 16),

                  const Text('Format', style: AppTextStyles.labelMedium),
                  const SizedBox(height: 8),
                  Obx(() => Row(
                        children: controller.formats.map((f) {
                          final selected = controller.selectedFormat.value == f;
                          return Padding(
                            padding: const EdgeInsets.only(right: 12),
                            child: GestureDetector(
                              onTap: () =>
                                  controller.selectedFormat.value = f,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 10),
                                decoration: BoxDecoration(
                                  color: selected
                                      ? AppColors.primary
                                      : AppColors.backgroundSecondary,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                      color: selected
                                          ? AppColors.primary
                                          : AppColors.border),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      f == 'xlsx'
                                          ? Icons.table_chart_outlined
                                          : Icons.picture_as_pdf_outlined,
                                      color: selected
                                          ? Colors.white
                                          : AppColors.textSecondary,
                                      size: 18,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(f.toUpperCase(),
                                        style: AppTextStyles.labelLarge
                                            .copyWith(
                                                color: selected
                                                    ? Colors.white
                                                    : AppColors.textPrimary)),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      )),

                  const SizedBox(height: 20),
                  const Text('Period', style: AppTextStyles.labelMedium),
                  const SizedBox(height: 8),
                  Obx(() => Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          null,
                          ...controller.periods,
                        ]
                            .map((p) => FilterChip(
                                  label: Text(_periodLabel(p)),
                                  selected:
                                      controller.selectedPeriod.value == p,
                                  onSelected: (_) =>
                                      controller.selectedPeriod.value = p,
                                  selectedColor: AppColors.primaryLight,
                                  checkmarkColor: AppColors.primary,
                                ))
                            .toList(),
                      )),

                  const SizedBox(height: 20),
                  const Text('Department', style: AppTextStyles.labelMedium),
                  const SizedBox(height: 8),
                  Obx(() => DropdownButtonFormField<String>(
                        initialValue: controller.selectedDepartment.value,
                        hint: const Text('All Departments'),
                        items: [
                          const DropdownMenuItem(
                              value: null, child: Text('All Departments')),
                          ...AppConstants.departments.map((d) =>
                              DropdownMenuItem(value: d, child: Text(d))),
                        ],
                        onChanged: (v) =>
                            controller.selectedDepartment.value = v,
                        decoration: const InputDecoration(
                          labelText: 'Department',
                          prefixIcon: Icon(Icons.business_outlined, size: 20),
                        ),
                      )),

                  const SizedBox(height: 20),
                  const Text('Status', style: AppTextStyles.labelMedium),
                  const SizedBox(height: 8),
                  Obx(() => DropdownButtonFormField<String>(
                        initialValue: controller.selectedStatus.value,
                        hint: const Text('All Statuses'),
                        items: [
                          const DropdownMenuItem(
                              value: null, child: Text('All Statuses')),
                          ...AppConstants.proposalStatuses.map((s) =>
                              DropdownMenuItem(value: s, child: Text(s))),
                        ],
                        onChanged: (v) => controller.selectedStatus.value = v,
                        decoration: const InputDecoration(
                          labelText: 'Status',
                          prefixIcon:
                              Icon(Icons.filter_list_rounded, size: 20),
                        ),
                      )),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Obx(() => AppButton(
                  label: 'Generate & Download Report',
                  icon: Icons.download_rounded,
                  isLoading: controller.isExporting.value,
                  onPressed: controller.exportReport,
                )),
            const SizedBox(height: 16),
            AppCard(
              padding: const EdgeInsets.all(16),
              color: AppColors.infoLight,
              child: Row(
                children: [
                  const Icon(Icons.info_outline_rounded,
                      color: AppColors.info, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Reports include all proposal details, budget summaries, and expense tracking. Files are downloaded to your device.',
                      style: AppTextStyles.bodySmall
                          .copyWith(color: AppColors.info),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _periodLabel(String? period) {
    switch (period) {
      case null:
        return 'All Time';
      case 'this_week':
        return 'This Week';
      case 'this_month':
        return 'This Month';
      case 'this_quarter':
        return 'This Quarter';
      case 'this_year':
        return 'This Year';
      default:
        return period;
    }
  }
}
