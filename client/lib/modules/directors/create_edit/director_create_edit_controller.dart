import 'package:csea_finance/data/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart' as dio;
import '../../../data/models/user_model.dart';

class DirectorCreateEditController extends GetxController {
  final UserProvider _userProvider = UserProvider();

  final isLoading = false.obs;
  final isEditMode = false.obs;
  String? editingId;

  final nameCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();
  final selectedDepartment = RxnString();

  final formKey = GlobalKey<FormState>();

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as Map<String, dynamic>?;
    if (args != null && args.containsKey('user')) {
      isEditMode.value = true;
      final user = args['user'] as UserModel;
      editingId = user.id;
      nameCtrl.text = user.name;
      emailCtrl.text = user.email;
      phoneCtrl.text = user.phone ?? '';
      selectedDepartment.value = user.department;
    }
  }

  Future<void> save() async {
    if (!formKey.currentState!.validate()) return;
    if (selectedDepartment.value == null) {
      Get.snackbar('Error', 'Please select a department');
      return;
    }

    isLoading.value = true;
    try {
      if (isEditMode.value && editingId != null) {
        final fd = dio.FormData.fromMap({
          'name': nameCtrl.text.trim(),
          'phone': phoneCtrl.text.trim(),
          'department': selectedDepartment.value,
        });
        final response = await _userProvider.updateUser(editingId!, fd);
        if (response.statusCode == 200) {
          Get.back(result: true);
          Get.snackbar('Success', 'Director updated');
        } else {
          Get.snackbar('Error', response.data['message'] ?? 'Update failed');
        }
      } else {
        final response = await _userProvider.createUser({
          'name': nameCtrl.text.trim(),
          'email': emailCtrl.text.trim(),
          'phone': phoneCtrl.text.trim(),
          'department': selectedDepartment.value,
          'password': passwordCtrl.text,
        });
        if (response.statusCode == 201) {
          Get.back(result: true);
          Get.snackbar('Success', 'Director created');
        } else {
          Get.snackbar('Error', response.data['message'] ?? 'Creation failed');
        }
      }
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    nameCtrl.dispose();
    emailCtrl.dispose();
    phoneCtrl.dispose();
    passwordCtrl.dispose();
    super.onClose();
  }
}
