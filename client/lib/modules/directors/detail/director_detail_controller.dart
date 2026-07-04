import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/providers/user_provider.dart';
import '../../../data/models/user_model.dart';

class DirectorDetailController extends GetxController {
  final UserProvider _userProvider = UserProvider();

  final isLoading = true.obs;
  final user = Rxn<UserModel>();
  final isActioning = false.obs;
  String get directorId => (Get.arguments as Map)['id'] as String;

  @override
  void onInit() {
    super.onInit();
    loadDirector();
  }

  Future<void> loadDirector() async {
    isLoading.value = true;
    try {
      final response = await _userProvider.getUserById(directorId);
      if (response.statusCode == 200) {
        user.value = UserModel.fromJson(
            response.data['data'] as Map<String, dynamic>);
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> toggleActive() async {
    if (user.value == null) return;
    isActioning.value = true;
    try {
      if (user.value!.isActive) {
        await _userProvider.deactivateUser(user.value!.id);
        Get.snackbar('Deactivated', '${user.value!.name} deactivated');
      } else {
        await _userProvider.activateUser(user.value!.id);
        Get.snackbar('Activated', '${user.value!.name} activated');
      }
      await loadDirector();
    } finally {
      isActioning.value = false;
    }
  }

  Future<void> resetPasswordDialog(BuildContext context) async {
    final ctrl = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reset Password'),
        content: TextField(
          controller: ctrl,
          obscureText: true,
          decoration: const InputDecoration(
            labelText: 'New Password',
            hintText: 'Min. 8 characters',
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel')),
          TextButton(
              onPressed: () => Navigator.pop(ctx, ctrl.text),
              child: const Text('Reset')),
        ],
      ),
    );
    if (result != null && result.length >= 8) {
      isActioning.value = true;
      try {
        await _userProvider.resetPassword(user.value!.id, result);
        Get.snackbar('Success', 'Password reset successfully');
      } finally {
        isActioning.value = false;
      }
    }
  }

  Future<void> delete() async {
    isActioning.value = true;
    try {
      await _userProvider.deleteUser(user.value!.id);
      Get.back(result: true);
      Get.snackbar('Deleted', 'Director removed');
    } finally {
      isActioning.value = false;
    }
  }
}
