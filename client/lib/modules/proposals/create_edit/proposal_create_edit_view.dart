import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/utils/constants.dart';
import 'proposal_create_edit_controller.dart';

class ProposalCreateEditView extends GetView<ProposalCreateEditController> {
  const ProposalCreateEditView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundSecondary,
      appBar: AppBar(
        title: Obx(() => Text(controller.isEditMode.value
            ? 'Edit Proposal'
            : 'New Proposal')),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: controller.formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _sectionTitle('Basic Information'),
              const SizedBox(height: 12),
              AppTextField(
                label: 'Proposal Title *',
                hint: 'e.g. Annual Tech Symposium 2025',
                controller: controller.titleCtrl,
                prefixIcon: Icons.title_rounded,
                validator: (v) {
                  if (v == null || v.trim().length < 5) {
                    return 'Title must be at least 5 characters';
                  }
                  if (v.trim().length > 120) return 'Title too long (max 120)';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              AppTextField(
                label: 'Event Name *',
                hint: 'Name of the event or activity',
                controller: controller.eventNameCtrl,
                prefixIcon: Icons.event_outlined,
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Event name required' : null,
              ),
              const SizedBox(height: 16),
              AppTextField(
                label: 'Purpose *',
                hint: 'Brief purpose of this proposal',
                controller: controller.purposeCtrl,
                prefixIcon: Icons.lightbulb_outline_rounded,
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Purpose required' : null,
              ),
              const SizedBox(height: 16),
              AppTextField(
                label: 'Description *',
                hint: 'Detailed description (min 20 characters)',
                controller: controller.descriptionCtrl,
                maxLines: 4,
                maxLength: 1000,
                validator: (v) {
                  if (v == null || v.trim().length < 20) {
                    return 'Description must be at least 20 characters';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 24),
              _sectionTitle('Budget & Timeline'),
              const SizedBox(height: 12),

              AppTextField(
                label: 'Requested Budget (RM) *',
                hint: 'e.g. 5000.00',
                controller: controller.budgetCtrl,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                prefixIcon: Icons.payments_outlined,
                validator: (v) {
                  final val = double.tryParse(v ?? '');
                  if (val == null || val <= 0) {
                    return 'Enter a valid budget amount';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Priority dropdown
              Obx(() => DropdownButtonFormField<String>(
                    initialValue: controller.selectedPriority.value,
                    hint: const Text('Select Priority'),
                    items: AppConstants.priorities
                        .map((p) =>
                            DropdownMenuItem(value: p, child: Text(p)))
                        .toList(),
                    onChanged: (v) => controller.selectedPriority.value = v,
                    validator: (v) =>
                        v == null ? 'Priority is required' : null,
                    decoration: const InputDecoration(
                      labelText: 'Priority *',
                      prefixIcon:
                          Icon(Icons.flag_outlined, size: 20),
                    ),
                  )),
              const SizedBox(height: 16),

              // Date picker
              Obx(() => AppTextField(
                    label: 'Required Date *',
                    hint: 'Tap to select date',
                    controller: TextEditingController(
                      text: controller.selectedDate.value != null
                          ? DateFormat('d MMMM yyyy')
                              .format(controller.selectedDate.value!)
                          : '',
                    ),
                    prefixIcon: Icons.calendar_today_outlined,
                    readOnly: true,
                    onTap: () => controller.pickDate(context),
                    validator: (_) => controller.selectedDate.value == null
                        ? 'Required date is needed'
                        : null,
                  )),

              const SizedBox(height: 24),
              _sectionTitle('Additional Information'),
              const SizedBox(height: 12),

              AppTextField(
                label: 'Notes (Optional)',
                hint: 'Any additional notes or remarks',
                controller: controller.notesCtrl,
                maxLines: 3,
              ),
              const SizedBox(height: 16),

              // Quotation upload
              Obx(() => GestureDetector(
                    onTap: controller.pickQuotation,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.backgroundSecondary,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: AppColors.border,
                          style: BorderStyle.solid,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: AppColors.primaryLight,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.attach_file_rounded,
                                color: AppColors.primary),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Quotation / Attachment',
                                    style: AppTextStyles.labelLarge),
                                Text(
                                  controller.quotationFile.value?.name ??
                                      'PDF, JPG or PNG (optional)',
                                  style: AppTextStyles.bodySmall,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          if (controller.quotationFile.value != null)
                            const Icon(Icons.check_circle_rounded,
                                color: AppColors.success)
                          else
                            const Icon(Icons.arrow_forward_ios_rounded,
                                size: 16, color: AppColors.textTertiary),
                        ],
                      ),
                    ),
                  )),

              const SizedBox(height: 32),

              // Action buttons
              Obx(() => Column(
                    children: [
                      AppButton(
                        label: 'Save as Draft',
                        variant: AppButtonVariant.ghost,
                        isLoading: controller.isLoading.value,
                        onPressed: () => controller.save(submitAfter: false),
                        icon: Icons.save_outlined,
                      ),
                      const SizedBox(height: 12),
                      AppButton(
                        label: 'Save & Submit for Review',
                        isLoading: controller.isLoading.value,
                        onPressed: () => controller.save(submitAfter: true),
                        icon: Icons.send_rounded,
                      ),
                    ],
                  )),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(title, style: AppTextStyles.headlineSmall);
  }
}
