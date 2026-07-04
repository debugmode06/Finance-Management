import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/utils/constants.dart';
import 'director_create_edit_controller.dart';

class DirectorCreateEditView extends GetView<DirectorCreateEditController> {
  const DirectorCreateEditView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundSecondary,
      appBar: AppBar(
        title: Obx(() => Text(
            controller.isEditMode.value ? 'Edit Director' : 'Add Director')),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: controller.formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppTextField(
                label: 'Full Name',
                hint: 'Enter full name',
                controller: controller.nameCtrl,
                prefixIcon: Icons.person_outline_rounded,
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Name is required' : null,
              ),
              const SizedBox(height: 16),
              Obx(() => controller.isEditMode.value
                  ? const SizedBox.shrink()
                  : AppTextField(
                      label: 'Email',
                      hint: 'Enter email address',
                      controller: controller.emailCtrl,
                      keyboardType: TextInputType.emailAddress,
                      prefixIcon: Icons.mail_outline_rounded,
                      textCapitalization: TextCapitalization.none,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return 'Email is required';
                        }
                        if (!GetUtils.isEmail(v)) return 'Invalid email';
                        return null;
                      },
                    )),
              Obx(() => controller.isEditMode.value
                  ? const SizedBox.shrink()
                  : const SizedBox(height: 16)),
              AppTextField(
                label: 'Phone (Optional)',
                hint: 'e.g. +60123456789',
                controller: controller.phoneCtrl,
                keyboardType: TextInputType.phone,
                prefixIcon: Icons.phone_outlined,
              ),
              const SizedBox(height: 16),
              Obx(() => DropdownButtonFormField<String>(
                    initialValue: controller.selectedDepartment.value,
                    hint: const Text('Select Department'),
                    items: AppConstants.departments
                        .map((d) =>
                            DropdownMenuItem(value: d, child: Text(d)))
                        .toList(),
                    onChanged: (v) => controller.selectedDepartment.value = v,
                    validator: (v) =>
                        v == null ? 'Department is required' : null,
                    decoration: const InputDecoration(
                      labelText: 'Department',
                      prefixIcon:
                          Icon(Icons.business_outlined, size: 20),
                    ),
                  )),
              const SizedBox(height: 16),
              Obx(() => controller.isEditMode.value
                  ? const SizedBox.shrink()
                  : AppTextField(
                      label: 'Password',
                      hint: 'Min. 8 characters',
                      controller: controller.passwordCtrl,
                      obscureText: true,
                      prefixIcon: Icons.lock_outline_rounded,
                      validator: (v) {
                        if (v == null || v.length < 8) {
                          return 'Password must be at least 8 characters';
                        }
                        return null;
                      },
                    )),
              const SizedBox(height: 32),
              Obx(() => AppButton(
                    label: controller.isEditMode.value
                        ? 'Save Changes'
                        : 'Create Director',
                    isLoading: controller.isLoading.value,
                    onPressed: controller.save,
                  )),
            ],
          ),
        ),
      ),
    );
  }
}
