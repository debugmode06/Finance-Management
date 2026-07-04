import 'package:get/get.dart';
import '../../../data/providers/proposal_provider.dart';
import '../../../data/models/proposal_model.dart';

class ProposalsListController extends GetxController {
  final ProposalProvider _provider = ProposalProvider();

  final isLoading = true.obs;
  final errorMessage = RxnString();
  final proposals = <ProposalModel>[].obs;
  final searchQuery = ''.obs;
  final selectedStatus = RxnString();
  final selectedDepartment = RxnString();
  int _page = 1;
  final hasMore = true.obs;
  final totalCount = 0.obs;

  @override
  void onInit() {
    super.onInit();
    // Handle deep-link arguments
    final args = Get.arguments as Map<String, dynamic>?;
    if (args != null && args['status'] != null) {
      selectedStatus.value = args['status'] as String;
    }
    fetchProposals();
    debounce(searchQuery, (_) => refresh(),
        time: const Duration(milliseconds: 400));
  }

  Future<void> fetchProposals({bool reset = false}) async {
    if (reset) {
      _page = 1;
      proposals.clear();
      hasMore.value = true;
    }
    if (!hasMore.value && !reset) return;

    if (_page == 1) isLoading.value = true;
    errorMessage.value = null;
    try {
      final response = await _provider.getProposals(
        status: selectedStatus.value,
        department: selectedDepartment.value,
        search: searchQuery.value.isEmpty ? null : searchQuery.value,
        page: _page,
        limit: 20,
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final data = response.data['data'] as List<dynamic>;
        final fetched = data
            .map((p) => ProposalModel.fromJson(p as Map<String, dynamic>))
            .toList();

        proposals.addAll(fetched);
        _page++;

        final meta = response.data['meta'];
        if (meta != null) {
          totalCount.value = meta['total'] ?? 0;
          if (proposals.length >= (meta['total'] ?? 0)) {
            hasMore.value = false;
          }
        }
      }
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void refresh() => fetchProposals(reset: true);

  void setStatus(String? status) {
    selectedStatus.value = status;
    refresh();
  }

  void setDepartment(String? dept) {
    selectedDepartment.value = dept;
    refresh();
  }
}
