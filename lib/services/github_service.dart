import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import '../models/pull_request.dart';

class GitHubService {
  static const String _baseUrl = 'https://api.github.com';
  late String _token = '';
  late String _owner = '';
  late String _repo = '';

  void setCredentials(String token, String owner, String repo) {
    _token = token;
    _owner = owner;
    _repo = repo;
  }

  Map<String, String> get _headers {
    final headers = {
      'Accept': 'application/vnd.github.v3+json',
      'Content-Type': 'application/json',
    };
    // Only add Authorization header if token is not empty and not the dummy token
    if (_token.isNotEmpty && _token != 'abc123') {
      headers['Authorization'] = 'Bearer $_token';
    }
    return headers;
  }

  Future<List<PullRequest>> fetchPullRequests({
    String state = 'open',
    int perPage = 30,
    int page = 1,
  }) async {
    try {
      final url = Uri.parse(
        '$_baseUrl/repos/$_owner/$_repo/pulls'
        '?state=$state&per_page=$perPage&page=$page&sort=updated&direction=desc',
      );

      final response = await http.get(url, headers: _headers).timeout(
        const Duration(seconds: 10),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data
            .map((json) => PullRequest.fromJson(json as Map<String, dynamic>))
            .toList();
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized - Invalid token');
      } else if (response.statusCode == 403) {
        throw Exception('Rate limit exceeded - Please try again later');
      } else if (response.statusCode == 404) {
        throw Exception('Repository not found');
      } else {
        throw Exception('Failed to fetch PRs: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<PullRequest> fetchPullRequestDetail(String prNumber) async {
    try {
      final url = Uri.parse(
        '$_baseUrl/repos/$_owner/$_repo/pulls/$prNumber',
      );

      final response = await http.get(url, headers: _headers).timeout(
        const Duration(seconds: 10),
      );

      if (response.statusCode == 200) {
        return PullRequest.fromJson(jsonDecode(response.body));
      } else if (response.statusCode == 403) {
        throw Exception('Rate limit exceeded - Please try again later');
      } else if (response.statusCode == 404) {
        throw Exception('Pull request not found');
      } else {
        throw Exception('Failed to fetch PR detail: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Review>> fetchReviews(String prNumber) async {
    try {
      final url = Uri.parse(
        '$_baseUrl/repos/$_owner/$_repo/pulls/$prNumber/reviews',
      );

      final response = await http.get(url, headers: _headers).timeout(
        const Duration(seconds: 10),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data
            .map((json) => Review.fromJson(json as Map<String, dynamic>))
            .toList();
      } else if (response.statusCode == 403) {
        print('Rate limit exceeded while fetching reviews');
        return [];
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }

  Future<String> createReview({
    required String prNumber,
    required String comment,
    required String event, // APPROVE, REQUEST_CHANGES, COMMENT
  }) async {
    try {
      final url = Uri.parse(
        '$_baseUrl/repos/$_owner/$_repo/pulls/$prNumber/reviews',
      );

      final body = {
        'body': comment,
        'event': event,
      };

      final response = await http.post(
        url,
        headers: _headers,
        body: jsonEncode(body),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return data['id']?.toString() ?? '';
      } else if (response.statusCode == 403) {
        throw Exception('Rate limit exceeded - Please try again later');
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized - Invalid token');
      } else {
        throw Exception('Failed to create review: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> mergePullRequest(String prNumber) async {
    try {
      final url = Uri.parse(
        '$_baseUrl/repos/$_owner/$_repo/pulls/$prNumber/merge',
      );

      final response = await http.put(
        url,
        headers: _headers,
        body: jsonEncode({'merge_method': 'squash'}),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return;
      } else if (response.statusCode == 403) {
        throw Exception('Rate limit exceeded or insufficient permissions - Please try again later');
      } else if (response.statusCode == 404) {
        throw Exception('Pull request not found');
      } else if (response.statusCode == 409) {
        throw Exception('PR cannot be merged (may have conflicts or is already merged)');
      } else {
        throw Exception('Failed to merge PR: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }
}
