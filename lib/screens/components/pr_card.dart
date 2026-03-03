import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/pull_request.dart';
import '../../providers/github_provider.dart';
import '../pr_detail_screen.dart';

class PullRequestCard extends StatelessWidget {
  final PullRequest pr;
  final GitHubProvider provider;

  const PullRequestCard({
    Key? key,
    required this.pr,
    required this.provider,
  }) : super(key: key);

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'open':
        return Colors.green;
      case 'closed':
        return Colors.red;
      case 'merged':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: InkWell(
        onTap: () async {
          final navigator = Navigator.of(context);
          await provider.selectPullRequest(pr);
          if (context.mounted) {
            navigator.push(
              MaterialPageRoute(
                builder: (context) => const PRDetailScreen(),
              ),
            );
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    backgroundImage: NetworkImage(pr.authorAvatarUrl),
                    radius: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '#${pr.number} - ${pr.title}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'by ${pr.author}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        Text(
                          'on ${DateFormat('MMM dd, yyyy').format(pr.createdAt)}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor(pr.status),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      pr.status.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.comment, size: 16, color: Colors.grey.shade600),
                  const SizedBox(width: 4),
                  Text(
                    '${pr.commentsCount}',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                  const SizedBox(width: 16),
                  Icon(Icons.edit, size: 16, color: Colors.grey.shade600),
                  const SizedBox(width: 4),
                  Text(
                    '${pr.changesCount} changes',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                ],
              ),
              if (pr.labels.isNotEmpty) ...[
                const SizedBox(height: 8),
                Wrap(
                  spacing: 4,
                  children: pr.labels
                      .map((label) => Chip(
                            label: Text(label),
                            labelStyle: const TextStyle(fontSize: 10),
                            padding: EdgeInsets.zero,
                          ))
                      .toList(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
