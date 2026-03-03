import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/github_provider.dart';

class PRDetailScreen extends StatefulWidget {
  const PRDetailScreen({Key? key}) : super(key: key);

  @override
  State<PRDetailScreen> createState() => _PRDetailScreenState();
}

class _PRDetailScreenState extends State<PRDetailScreen> {
  late TextEditingController _commentController;
  String _reviewAction = 'COMMENT';

  @override
  void initState() {
    super.initState();
    _commentController = TextEditingController();
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  void _submitReview(BuildContext context, GitHubProvider provider) async {
    if (_commentController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a comment')),
      );
      return;
    }

    try {
      switch (_reviewAction) {
        case 'APPROVE':
          await provider.approveReview(_commentController.text);
          break;
        case 'REQUEST_CHANGES':
          await provider.requestChanges(_commentController.text);
          break;
        case 'COMMENT':
          await provider.addComment(_commentController.text);
          break;
      }

      if (mounted) {
        _commentController.clear();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Review submitted successfully!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pull Request Details'),
        elevation: 0,
      ),
      body: Consumer<GitHubProvider>(
        builder: (context, provider, _) {
          final pr = provider.selectedPR;
          if (pr == null) {
            return const Center(child: Text('No PR selected'));
          }

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // PR Header
                Container(
                  padding: const EdgeInsets.all(16),
                  color: Colors.grey.shade50,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CircleAvatar(
                            backgroundImage: NetworkImage(pr.authorAvatarUrl),
                            radius: 24,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '#${pr.number} - ${pr.title}',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                  const SizedBox(height: 4),
                                Text(
                                  'on ${DateFormat('MMM dd, yyyy').format(pr.createdAt)}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'by ${pr.author}',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey.shade700,
                                  ),
                                ),
                              
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _buildInfoChip(
                            Icons.history,
                            '${pr.changesCount} changes',
                          ),
                          _buildInfoChip(
                            Icons.comment_outlined,
                            '${pr.commentsCount} comments',
                          ),
                          if (pr.branchName != null)
                            _buildInfoChip(Icons.merge_type, pr.branchName!),
                        ],
                      ),
                    ],
                  ),
                ),

                // Status
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: _getStatusColor(pr.status),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          pr.status.toUpperCase(),
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const Spacer(),
                      ElevatedButton.icon(
                        onPressed: () => _showMergeDialog(context, provider),
                        icon: const Icon(Icons.merge_type),
                        label: const Text('Merge'),
                      ),
                    ],
                  ),
                ),

                // Token Information
                if (provider.token != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        border: Border.all(color: Colors.blue.shade200),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Authentication Token',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue.shade700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            provider.token!,
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.blue.shade600,
                              fontFamily: 'Courier',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                // Description
                if (pr.description.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Description',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            pr.description,
                            style: TextStyle(color: Colors.grey.shade700),
                          ),
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: 24),

                // Reviews Section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'Reviews (${provider.reviews.length})',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                const SizedBox(height: 12),

                if (provider.isLoading)
                  const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (provider.reviews.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      'No reviews yet',
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  )
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: provider.reviews.length,
                    itemBuilder: (context, index) {
                      final review = provider.reviews[index];
                      return _buildReviewCard(review);
                    },
                  ),

                const SizedBox(height: 24),

                // Review Form
                Container(
                  padding: const EdgeInsets.all(16),
                  color: Colors.grey.shade50,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Add Your Review',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: SegmentedButton<String>(
                              segments: const [
                                ButtonSegment(
                                  value: 'COMMENT',
                                  label: Text('Comment'),
                                ),
                                ButtonSegment(
                                  value: 'APPROVE',
                                  label: Text('Approve'),
                                ),
                                ButtonSegment(
                                  value: 'REQUEST_CHANGES',
                                  label: Text('Changes'),
                                ),
                              ],
                              selected: {_reviewAction},
                              onSelectionChanged: (newSelection) {
                                setState(() {
                                  _reviewAction = newSelection.first;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _commentController,
                        maxLines: 4,
                        decoration: InputDecoration(
                          hintText: 'Enter your review...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: provider.isLoading
                              ? null
                              : () => _submitReview(context, provider),
                          child: provider.isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text('Submit Review'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildReviewCard(dynamic review) {
    final statusColor = _getReviewStatusColor(review.status);
    final statusText = review.status.replaceAll('_', ' ');

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundImage: NetworkImage(review.avatarUrl),
                  radius: 16,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        review.reviewer,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        DateFormat('MMM dd, yyyy').format(review.createdAt),
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
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    statusText,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: statusColor,
                    ),
                  ),
                ),
              ],
            ),
            if (review.comment != null && review.comment!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(review.comment!),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label) {
    return Chip(
      avatar: Icon(icon, size: 18),
      label: Text(label),
      backgroundColor: Colors.white,
      side: BorderSide(color: Colors.grey.shade300),
    );
  }

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

  Color _getReviewStatusColor(String status) {
    switch (status) {
      case 'APPROVED':
        return Colors.green;
      case 'CHANGES_REQUESTED':
        return Colors.red;
      case 'COMMENTED':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  void _showMergeDialog(BuildContext context, GitHubProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Merge Pull Request'),
        content: const Text(
          'Are you sure you want to merge this pull request? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              provider.mergePR();
            },
            child: const Text('Merge'),
          ),
        ],
      ),
    );
  }
}
