import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/governance_provider.dart';
import '../models/proposal.dart';

class GovernanceScreen extends StatefulWidget {
  const GovernanceScreen({super.key});

  @override
  State<GovernanceScreen> createState() => _GovernanceScreenState();
}

class _GovernanceScreenState extends State<GovernanceScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<GovernanceProvider>().loadProposals();
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Governance'),
      ),
      body: Consumer<GovernanceProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
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
                      children: [
                        Icon(
                          Icons.how_to_vote,
                          size: 48,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Democratic Governance',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Active members vote on platform decisions. Your voice matters in shaping our community.',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Active Proposals',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${provider.activeProposals.length} active',
                      style: TextStyle(
                        color: Theme.of(context).textTheme.bodySmall?.color,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (provider.proposals.isEmpty)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        children: [
                          Icon(
                            Icons.ballot_outlined,
                            size: 60,
                            color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
                          ),
                          const SizedBox(height: 16),
                          const Text('No proposals at the moment'),
                        ],
                      ),
                    ),
                  )
                else
                  ...provider.proposals.map((proposal) => _ProposalCard(
                        proposal: proposal,
                        onTap: () => context.push('/governance/vote/${proposal.id}'),
                      )),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _ProposalCard extends StatelessWidget {
  final Proposal proposal;
  final VoidCallback onTap;
  
  const _ProposalCard({
    required this.proposal,
    required this.onTap,
  });
  
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      proposal.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  _StatusBadge(status: proposal.status),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                proposal.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Theme.of(context).textTheme.bodySmall?.color,
                ),
              ),
              const SizedBox(height: 12),
              if (proposal.totalVotes > 0) ...[
                _VoteProgressBar(proposal: proposal),
                const SizedBox(height: 8),
              ],
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${proposal.totalVotes} votes',
                    style: const TextStyle(fontSize: 12),
                  ),
                  Text(
                    'Ends ${_formatDate(proposal.votingEndsAt)}',
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = date.difference(now);
    
    if (difference.isNegative) {
      return 'ended';
    } else if (difference.inDays > 0) {
      return 'in ${difference.inDays}d';
    } else if (difference.inHours > 0) {
      return 'in ${difference.inHours}h';
    } else {
      return 'soon';
    }
  }
}

class _StatusBadge extends StatelessWidget {
  final ProposalStatus status;
  
  const _StatusBadge({required this.status});
  
  @override
  Widget build(BuildContext context) {
    Color color;
    String text;
    
    switch (status) {
      case ProposalStatus.active:
        color = Colors.blue;
        text = 'Active';
        break;
      case ProposalStatus.passed:
        color = Colors.green;
        text = 'Passed';
        break;
      case ProposalStatus.rejected:
        color = Colors.red;
        text = 'Rejected';
        break;
      case ProposalStatus.expired:
        color = Colors.grey;
        text = 'Expired';
        break;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _VoteProgressBar extends StatelessWidget {
  final Proposal proposal;
  
  const _VoteProgressBar({required this.proposal});
  
  @override
  Widget build(BuildContext context) {
    final total = proposal.totalVotes;
    if (total == 0) return const SizedBox.shrink();
    
    final forPercent = proposal.votesFor / total;
    final againstPercent = proposal.votesAgainst / total;
    
    return Row(
      children: [
        Expanded(
          flex: (forPercent * 100).round(),
          child: Container(
            height: 8,
            decoration: BoxDecoration(
              color: Colors.green,
              borderRadius: const BorderRadius.horizontal(left: Radius.circular(4)),
            ),
          ),
        ),
        Expanded(
          flex: (againstPercent * 100).round(),
          child: Container(
            height: 8,
            color: Colors.red,
          ),
        ),
        Expanded(
          flex: ((1 - forPercent - againstPercent) * 100).round(),
          child: Container(
            height: 8,
            decoration: BoxDecoration(
              color: Colors.grey,
              borderRadius: const BorderRadius.horizontal(right: Radius.circular(4)),
            ),
          ),
        ),
      ],
    );
  }
}
