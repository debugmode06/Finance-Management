import 'package:get/get.dart';
import '../../../data/providers/user_provider.dart';
import '../../../data/models/user_model.dart';

class DirectorsListController extends GetxController {
  final UserProvider _userProvider = UserProvider();

  final isLoading = true.obs;
  final errorMessage = RxnString();
  final directors = <UserModel>[].obs;
  final searchQuery = ''.obs;
  final selectedDepartment = RxnString();
  final selectedActive = RxnString();
  int _page = 1;
  final hasMore = true.obs;

  @override
  void onInit() {
    super.onInit();
    fetchDirectors();
    debounce(searchQuery, (_) => refresh(), time: const Duration(milliseconds: 400));
  }

  Future<void> fetchDirectors({bool reset = false}) async {
    if (reset) {
      _page = 1;
      directors.clear();
      hasMore.value = true;
    }
    if (!hasMore.value) return;

    if (_page == 1) isLoading.value = true;
    errorMessage.value = null;
    try {
      final response = await _userProvider.getUsers(
        search: searchQuery.value.isEmpty ? null : searchQuery.value,
        department: selectedDepartment.value,
        isActive: selectedActive.value,
        page: _page,
        limit: 20,
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final data = response.data['data'] as List<dynamic>;
        final fetched = data
            .map((u) => UserModel.fromJson(u as Map<String, dynamic>))
            .toList();

        directors.addAll(fetched);
        _page++;

        final meta = response.data['meta'];
        if (meta != null && directors.length >= (meta['total'] ?? 0)) {
          hasMore.value = false;
        }
      }
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void refresh() => fetchDirectors(reset: true);

  Future<void> activate(UserModel user) async {
    try {
      await _userProvider.activateUser(user.id);
      Get.snackbar('Success', '${user.name} activated');
      refresh();
    } catch (e) {
      Get.snackbar('Error', e.toString());
    }
  }

  Future<void> deactivate(UserModel user) async {
    try {
      await _userProvider.deactivateUser(user.id);
      Get.snackbar('Success', '${user.name} deactivated');
      refresh();
    } catch (e) {
      Get.snackbar('Error', e.toString());
    }
  }

  Future<void> delete(UserModel user) async {
    try {
      await _userProvider.deleteUser(user.id);
      Get.snackbar('Deleted', '${user.name} removed');
      refresh();
    } catch (e) {
      Get.snackbar('Error', e.toString());
    }
  }
}
