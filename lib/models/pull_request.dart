class PullRequest {
  final int id;
  final String number;
  final String title;
  final String description;
  final String status; // OPEN, CLOSED, MERGED
  final String author;
  final String authorAvatarUrl;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final int commentsCount;
  final int changesCount;
  final String? branchName;
  final String? targetBranch;
  final List<String> reviewers;
  final List<String> labels;
  final String htmlUrl;

  PullRequest({
    required this.id,
    required this.number,
    required this.title,
    required this.description,
    required this.status,
    required this.author,
    required this.authorAvatarUrl,
    required this.createdAt,
    this.updatedAt,
    required this.commentsCount,
    required this.changesCount,
    this.branchName,
    this.targetBranch,
    required this.reviewers,
    required this.labels,
    required this.htmlUrl,
  });

  factory PullRequest.fromJson(Map<String, dynamic> json) {
    return PullRequest(
      id: json['id'] as int? ?? 0,
      number: json['number']?.toString() ?? '',
      title: json['title'] as String? ?? '',
      description: json['body'] as String? ?? '',
      status: json['state'] as String? ?? 'OPEN',
      author: json['user']?['login'] as String? ?? 'Unknown',
      authorAvatarUrl: json['user']?['avatar_url'] as String? ?? '',
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at'] as String? ?? ''),
      commentsCount: json['comments'] as int? ?? 0,
      changesCount: (json['changed_files'] as int? ?? 0) + (json['additions'] as int? ?? 0),
      branchName: json['head']?['ref'] as String?,
      targetBranch: json['base']?['ref'] as String?,
      reviewers: _parseReviewers(json['requested_reviewers']),
      labels: _parseLabels(json['labels']),
      htmlUrl: json['html_url'] as String? ?? '',
    );
  }

  static List<String> _parseReviewers(dynamic reviewers) {
    if (reviewers == null) return [];
    if (reviewers is List) {
      return reviewers.map((r) => r['login'] as String? ?? '').toList();
    }
    return [];
  }

  static List<String> _parseLabels(dynamic labels) {
    if (labels == null) return [];
    if (labels is List) {
      return labels.map((l) => l['name'] as String? ?? '').toList();
    }
    return [];
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'number': number,
    'title': title,
    'body': description,
    'state': status,
    'user': {'login': author, 'avatar_url': authorAvatarUrl},
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt?.toIso8601String(),
    'comments': commentsCount,
    'changed_files': changesCount,
  };
}

class Review {
  final String id;
  final String reviewer;
  final String status; // APPROVED, CHANGES_REQUESTED, COMMENTED, PENDING
  final String? comment;
  final DateTime createdAt;
  final String avatarUrl;

  Review({
    required this.id,
    required this.reviewer,
    required this.status,
    this.comment,
    required this.createdAt,
    required this.avatarUrl,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id']?.toString() ?? '',
      reviewer: json['user']?['login'] as String? ?? 'Unknown',
      status: json['state'] as String? ?? 'PENDING',
      comment: json['body'] as String?,
      createdAt: DateTime.tryParse(json['submitted_at'] as String? ?? '') ?? DateTime.now(),
      avatarUrl: json['user']?['avatar_url'] as String? ?? '',
    );
  }
}
