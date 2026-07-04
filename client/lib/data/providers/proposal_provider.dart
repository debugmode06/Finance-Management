import 'package:dio/dio.dart';
import '../../core/network/api_client.dart';
import '../../core/network/endpoints.dart';

class ProposalProvider {
  final Dio _dio = ApiClient.instance;

  Future<Response> getProposals({
    String? status,
    String? department,
    String? priority,
    String? search,
    String sortBy = 'createdAt',
    String order = 'desc',
    int page = 1,
    int limit = 20,
  }) async {
    return _dio.get(AppEndpoints.proposals, queryParameters: {
      if (status != null) 'status': status,
      if (department != null) 'department': department,
      if (priority != null) 'priority': priority,
      if (search != null) 'search': search,
      'sortBy': sortBy,
      'order': order,
      'page': page,
      'limit': limit,
    });
  }

  Future<Response> getProposalById(String id) async {
    return _dio.get(AppEndpoints.proposalById(id));
  }

  Future<Response> createProposal(FormData formData) async {
    return _dio.post(AppEndpoints.proposals, data: formData);
  }

  Future<Response> updateProposal(String id, FormData formData) async {
    return _dio.put(AppEndpoints.proposalById(id), data: formData);
  }

  Future<Response> deleteProposal(String id) async {
    return _dio.delete(AppEndpoints.proposalById(id));
  }

  Future<Response> submitProposal(String id) async {
    return _dio.post(AppEndpoints.submitProposal(id));
  }

  Future<Response> approveProposal(String id, double approvedBudget) async {
    return _dio.patch(AppEndpoints.approveProposal(id),
        data: {'approvedBudget': approvedBudget});
  }

  Future<Response> rejectProposal(String id, String reason) async {
    return _dio.patch(AppEndpoints.rejectProposal(id),
        data: {'reason': reason});
  }

  Future<Response> resubmitProposal(String id) async {
    return _dio.post(AppEndpoints.resubmitProposal(id));
  }

  Future<Response> uploadBills(String id, FormData formData) async {
    return _dio.post(AppEndpoints.uploadBills(id), data: formData);
  }

  Future<Response> verifyBill(String proposalId,
      {required String billId,
      required String verificationStatus,
      String? verificationNote}) async {
    return _dio.patch(AppEndpoints.verifyBills(proposalId), data: {
      'billId': billId,
      'verificationStatus': verificationStatus,
      if (verificationNote != null) 'verificationNote': verificationNote,
    });
  }

  Future<Response> completeProposal(String id) async {
    return _dio.patch(AppEndpoints.completeProposal(id));
  }

  Future<Response> getProposalHistory(String id) async {
    return _dio.get(AppEndpoints.proposalHistory(id));
  }

  Future<Response> getProposalActivity(String id) async {
    return _dio.get(AppEndpoints.proposalActivity(id));
  }

  Future<Response> getDashboardStats() async {
    return _dio.get(AppEndpoints.dashboardStats);
  }

  Future<Response> getDirectorStats() async {
    return _dio.get(AppEndpoints.directorStats);
  }

  Future<Response> getComments(String proposalId) async {
    return _dio.get(AppEndpoints.comments(proposalId));
  }

  Future<Response> addComment(String proposalId, String message) async {
    return _dio.post(AppEndpoints.comments(proposalId),
        data: {'message': message});
  }
}
