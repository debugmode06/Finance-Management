import 'package:dio/dio.dart' as dio;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/providers/proposal_provider.dart';
import '../../../data/models/proposal_model.dart';

class ProposalCreateEditController extends GetxController {
  final ProposalProvider _provider = ProposalProvider();

  final isLoading = false.obs;
  final isEditMode = false.obs;
  String? editingId;
  ProposalModel? editingProposal;

  final formKey = GlobalKey<FormState>();
  final titleCtrl = TextEditingController();
  final eventNameCtrl = TextEditingController();
  final purposeCtrl = TextEditingController();
  final descriptionCtrl = TextEditingController();
  final budgetCtrl = TextEditingController();
  final notesCtrl = TextEditingController();
  final selectedPriority = RxnString();
  final selectedDate = Rxn<DateTime>();
  final quotationFile = Rxn<PlatformFile>();

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as Map<String, dynamic>?;
    if (args != null && args['proposal'] != null) {
      isEditMode.value = true;
      editingProposal = args['proposal'] as ProposalModel;
      _prefill(editingProposal!);
    } else if (args != null && args['id'] != null) {
      // Edit mode from route — load proposal
      editingId = args['id'] as String;
      isEditMode.value = true;
    }
  }

  void _prefill(ProposalModel p) {
    titleCtrl.text = p.title;
    eventNameCtrl.text = p.eventName;
    purposeCtrl.text = p.purpose;
    descriptionCtrl.text = p.description;
    budgetCtrl.text = p.requestedBudget.toStringAsFixed(2);
    notesCtrl.text = p.notes ?? '';
    selectedPriority.value = p.priority;
    selectedDate.value = p.requiredDate;
    editingId = p.id;
  }

  Future<void> pickQuotation() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
    );
    if (result != null && result.files.isNotEmpty) {
      quotationFile.value = result.files.first;
    }
  }

  Future<void> pickDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate.value ?? DateTime.now().add(const Duration(days: 7)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
      builder: (ctx, child) => Theme(
        data: ThemeData.light().copyWith(
          colorScheme: const ColorScheme.light(
            primary: Color(0xFF0A5FFF),
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) selectedDate.value = picked;
  }

  Future<void> save({bool submitAfter = false}) async {
    if (!formKey.currentState!.validate()) return;
    if (selectedPriority.value == null) {
      Get.snackbar('Error', 'Please select a priority');
      return;
    }
    if (selectedDate.value == null) {
      Get.snackbar('Error', 'Please select a required date');
      return;
    }

    isLoading.value = true;
    try {
      final fields = {
        'title': titleCtrl.text.trim(),
        'eventName': eventNameCtrl.text.trim(),
        'purpose': purposeCtrl.text.trim(),
        'description': descriptionCtrl.text.trim(),
        'requestedBudget': budgetCtrl.text.trim(),
        'priority': selectedPriority.value!,
        'requiredDate': selectedDate.value!.toIso8601String(),
        'notes': notesCtrl.text.trim(),
      };

      final Map<String, dynamic> formFields = {
        ...fields,
      };

      dio.MultipartFile? quotation;
      if (quotationFile.value != null) {
        quotation = await dio.MultipartFile.fromFile(
          quotationFile.value!.path!,
          filename: quotationFile.value!.name,
        );
        formFields['quotation'] = quotation;
      }

      final fd = dio.FormData.fromMap(formFields);

      dio.Response response;
      if (isEditMode.value && editingId != null) {
        response = await _provider.updateProposal(editingId!, fd);
      } else {
        response = await _provider.createProposal(fd);
      }

      if ((response.statusCode == 200 || response.statusCode == 201) &&
          response.data['success'] == true) {
        final proposalData =
            response.data['data'] as Map<String, dynamic>;
        final proposal = ProposalModel.fromJson(proposalData);

        if (submitAfter) {
          await _provider.submitProposal(proposal.id);
          Get.snackbar('Submitted!', 'Proposal submitted for review');
        } else {
          Get.snackbar(
              isEditMode.value ? 'Updated' : 'Saved', 'Draft saved successfully');
        }

        Get.back(result: true);
      } else {
        Get.snackbar('Error', response.data['message'] ?? 'Save failed');
      }
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    titleCtrl.dispose();
    eventNameCtrl.dispose();
    purposeCtrl.dispose();
    descriptionCtrl.dispose();
    budgetCtrl.dispose();
    notesCtrl.dispose();
    super.onClose();
  }
}
