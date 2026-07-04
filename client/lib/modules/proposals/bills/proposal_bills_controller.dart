import 'package:dio/dio.dart' as dio;
import 'package:file_picker/file_picker.dart';
import 'package:get/get.dart';
import '../../../data/providers/proposal_provider.dart';
import '../../../data/models/proposal_model.dart';

class ProposalBillsController extends GetxController {
  final ProposalProvider _provider = ProposalProvider();

  final isLoading = true.obs;
  final isUploading = false.obs;
  final proposal = Rxn<ProposalModel>();
  final pickedFiles = <PlatformFile>[].obs;
  final amounts = <String>[].obs;
  String get proposalId => (Get.arguments as Map)['id'] as String;

  @override
  void onInit() {
    super.onInit();
    loadProposal();
  }

  Future<void> loadProposal() async {
    isLoading.value = true;
    try {
      final res = await _provider.getProposalById(proposalId);
      if (res.statusCode == 200) {
        proposal.value =
            ProposalModel.fromJson(res.data['data'] as Map<String, dynamic>);
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
      allowMultiple: true,
    );
    if (result != null && result.files.isNotEmpty) {
      pickedFiles.addAll(result.files);
      amounts.addAll(List.filled(result.files.length, ''));
    }
  }

  void removeFile(int index) {
    pickedFiles.removeAt(index);
    amounts.removeAt(index);
  }

  void setAmount(int index, String value) {
    final newAmounts = List<String>.from(amounts);
    newAmounts[index] = value;
    amounts.value = newAmounts;
  }

  Future<void> uploadBills() async {
    if (pickedFiles.isEmpty) {
      Get.snackbar('Error', 'Please select at least one file');
      return;
    }

    for (int i = 0; i < amounts.length; i++) {
      final amt = double.tryParse(amounts[i]);
      if (amt == null || amt <= 0) {
        Get.snackbar('Error', 'Enter a valid amount for file ${i + 1}');
        return;
      }
    }

    isUploading.value = true;
    try {
      final Map<String, dynamic> data = {};
      final files = <MapEntry<String, dio.MultipartFile>>[];

      for (int i = 0; i < pickedFiles.length; i++) {
        files.add(MapEntry(
          'bills',
          await dio.MultipartFile.fromFile(
            pickedFiles[i].path!,
            filename: pickedFiles[i].name,
          ),
        ));
        data['amounts[$i]'] = amounts[i];
      }

      final fd = dio.FormData.fromMap({...data});
      for (final f in files) {
        fd.files.add(f);
      }

      final response = await _provider.uploadBills(proposalId, fd);
      if (response.statusCode == 200) {
        pickedFiles.clear();
        amounts.clear();
        Get.snackbar('Uploaded!', 'Bills uploaded successfully');
        await loadProposal();
      } else {
        Get.snackbar('Error', response.data['message'] ?? 'Upload failed');
      }
    } finally {
      isUploading.value = false;
    }
  }

  Future<void> verifyBill(String billId, String status, String? note) async {
    try {
      await _provider.verifyBill(proposalId,
          billId: billId, verificationStatus: status, verificationNote: note);
      Get.snackbar('Updated', 'Bill status updated');
      await loadProposal();
    } catch (e) {
      Get.snackbar('Error', e.toString());
    }
  }
}
