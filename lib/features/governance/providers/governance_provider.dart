import 'package:flutter/material.dart';
import '../../../core/services/pocketbase_service.dart';
import '../models/proposal.dart';

class GovernanceProvider extends ChangeNotifier {
  final PocketBaseService _pb;
  List<Proposal> _proposals = [];
  bool _isLoading = false;
  String? _errorMessage;

  GovernanceProvider({PocketBaseService? pocketBaseService})
      : _pb = pocketBaseService ?? PocketBaseService();

  List<Proposal> get proposals => _proposals;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  List<Proposal> get activeProposals =>
      _proposals.where((p) => p.status == ProposalStatus.active).toList();

  Future<void> loadProposals() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _pb.getProposals();
      _proposals = result.items
          .map((record) => Proposal.fromPocketBase(record))
          .toList();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> submitVote(String proposalId, VoteChoice choice) async {
    try {
      await _pb.submitVote(
        proposalId: proposalId,
        choice: choice.value,
      );

      // Reload proposals to get updated vote counts
      await loadProposals();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    }
  }

  Future<bool> createProposal(String title, String description) async {
    try {
      final votingEndsAt = DateTime.now().add(const Duration(days: 7));
      final record = await _pb.createProposal(
        title: title,
        description: description,
        votingEndsAt: votingEndsAt,
      );
      final newProposal = Proposal.fromPocketBase(record);
      _proposals.insert(0, newProposal);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    }
  }
}
