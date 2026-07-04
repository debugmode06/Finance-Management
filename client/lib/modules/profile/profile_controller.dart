import 'package:dio/dio.dart' as dio;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../data/providers/user_provider.dart';
import '../../data/providers/auth_provider.dart';
import '../../data/models/user_model.dart';
import '../../core/storage/secure_storage_service.dart';
import '../../app/routes/app_routes.dart';

class ProfileController extends GetxController {
  final UserProvider _userProvider = UserProvider();
  final AuthProvider _authProvider = AuthProvider();

  final isLoading = true.obs;
  final isSaving = false.obs;
  final user = Rxn<UserModel>();

  final nameCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();

  final currentPassCtrl = TextEditingController();
  final newPassCtrl = TextEditingController();
  final confirmPassCtrl = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    loadProfile();
  }

  Future<void> loadProfile() async {
    isLoading.value = true;
    try {
      final res = await _userProvider.getMyProfile();
      if (res.statusCode == 200 && res.data['success'] == true) {
        user.value =
            UserModel.fromJson(res.data['data'] as Map<String, dynamic>);
        nameCtrl.text = user.value!.name;
        phoneCtrl.text = user.value!.phone ?? '';
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateProfile() async {
    isSaving.value = true;
    try {
      final fd = dio.FormData.fromMap({
        'name': nameCtrl.text.trim(),
        'phone': phoneCtrl.text.trim(),
      });
      final res = await _userProvider.updateMyProfile(fd);
      if (res.statusCode == 200) {
        Get.snackbar('Updated', 'Profile updated successfully');
        await loadProfile();
      } else {
        Get.snackbar('Error', res.data['message'] ?? 'Update failed');
      }
    } finally {
      isSaving.value = false;
    }
  }

  Future<void> changePassword() async {
    if (newPassCtrl.text != confirmPassCtrl.text) {
      Get.snackbar('Error', 'New passwords do not match');
      return;
    }
    if (newPassCtrl.text.length < 8) {
      Get.snackbar('Error', 'Password must be at least 8 characters');
      return;
    }
    isSaving.value = true;
    try {
      final res = await _authProvider.changePassword(
        currentPassword: currentPassCtrl.text,
        newPassword: newPassCtrl.text,
        confirmPassword: confirmPassCtrl.text,
      );
      if (res.statusCode == 200) {
        currentPassCtrl.clear();
        newPassCtrl.clear();
        confirmPassCtrl.clear();
        Get.snackbar('Success', 'Password changed successfully');
      } else {
        Get.snackbar('Error', res.data['message'] ?? 'Change failed');
      }
    } finally {
      isSaving.value = false;
    }
  }

  Future<void> pickAndUploadAvatar() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (image == null) return;

    isSaving.value = true;
    try {
      final fd = dio.FormData.fromMap({
        'profileImage': await dio.MultipartFile.fromFile(image.path,
            filename: image.name),
      });
      final res = await _userProvider.updateMyProfile(fd);
      if (res.statusCode == 200) {
        Get.snackbar('Updated', 'Profile photo updated');
        await loadProfile();
      }
    } finally {
      isSaving.value = false;
    }
  }

  Future<void> logout() async {
    try {
      await _authProvider.logout();
    } catch (_) {}
    await SecureStorageService.deleteAll();
    Get.offAllNamed(AppRoutes.login);
  }

  @override
  void onClose() {
    nameCtrl.dispose();
    phoneCtrl.dispose();
    currentPassCtrl.dispose();
    newPassCtrl.dispose();
    confirmPassCtrl.dispose();
    super.onClose();
  }
}
