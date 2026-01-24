import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/governance_provider.dart';
import '../models/proposal.dart';

class VotingScreen extends StatefulWidget {
  final String proposalId;

  const VotingScreen({
    super.key,
    required this.proposalId,
  });

  @override
  State<VotingScreen> createState() => _VotingScreenState();
}

class _VotingScreenState extends State<VotingScreen> {
  VoteChoice? _selectedChoice;
  bool _isSubmitting = false;

  Future<void> _submitVote() async {
    if (_selectedChoice == null) return;

    setState(() {
      _isSubmitting = true;
    });

    final provider = context.read<GovernanceProvider>();
    final success =
        await provider.submitVote(widget.proposalId, _selectedChoice!);

    if (mounted) {
      setState(() {
        _isSubmitting = false;
      });

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Vote submitted successfully')),
        );
        context.pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to submit vote')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vote on Proposal'),
      ),
      body: Consumer<GovernanceProvider>(
        builder: (context, provider, child) {
          final proposal = provider.proposals
              .where((p) => p.id == widget.proposalId)
              .firstOrNull;

          if (proposal == null) {
            return const Center(
              child: Text('Proposal not found'),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          proposal.title,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          proposal.description,
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 16),
                        const Divider(),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Total Votes: ${proposal.totalVotes}',
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              'Ends: ${proposal.votingEndsAt.toLocal().toString().split('.').first}',
                              style: const TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Cast Your Vote',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                _VoteOption(
                  choice: VoteChoice.forProposal,
                  label: 'Vote For',
                  icon: Icons.thumb_up,
                  color: Colors.green,
                  isSelected: _selectedChoice == VoteChoice.forProposal,
                  onTap: () {
                    setState(() {
                      _selectedChoice = VoteChoice.forProposal;
                    });
                  },
                ),
                const SizedBox(height: 12),
                _VoteOption(
                  choice: VoteChoice.against,
                  label: 'Vote Against',
                  icon: Icons.thumb_down,
                  color: Colors.red,
                  isSelected: _selectedChoice == VoteChoice.against,
                  onTap: () {
                    setState(() {
                      _selectedChoice = VoteChoice.against;
                    });
                  },
                ),
                const SizedBox(height: 12),
                _VoteOption(
                  choice: VoteChoice.abstain,
                  label: 'Abstain',
                  icon: Icons.remove_circle_outline,
                  color: Colors.grey,
                  isSelected: _selectedChoice == VoteChoice.abstain,
                  onTap: () {
                    setState(() {
                      _selectedChoice = VoteChoice.abstain;
                    });
                  },
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _selectedChoice == null || _isSubmitting
                      ? null
                      : _submitVote,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Submit Vote'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _VoteOption extends StatelessWidget {
  final VoteChoice choice;
  final String label;
  final IconData icon;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const _VoteOption({
    required this.choice,
    required this.label,
    required this.icon,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: isSelected ? 4 : 1,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: isSelected ? Border.all(color: color, width: 2) : null,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(icon, color: color, size: 32),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
              if (isSelected)
                Icon(
                  Icons.check_circle,
                  color: color,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
