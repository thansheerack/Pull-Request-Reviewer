import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/pull_request.dart';
import '../services/github_service.dart';

class GitHubProvider extends ChangeNotifier {
  final GitHubService _service = GitHubService();
  late SharedPreferences _prefs;
  
  List<PullRequest> _pullRequests = [];
  PullRequest? _selectedPR;
  List<Review> _reviews = [];
  
  bool _isLoading = false;
  String? _error;
  String? _token;
  String? _owner;
  String? _repo;
  bool _isInitialized = false;
  
  // Getters
  List<PullRequest> get pullRequests => _pullRequests;
  PullRequest? get selectedPR => _selectedPR;
  List<Review> get reviews => _reviews;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _token != null && _owner != null && _repo != null;
  String? get token => _token;
  bool get isInitialized => _isInitialized;

  Future<void> initializePreferences() async {
    if (_isInitialized) return;
    _prefs = await SharedPreferences.getInstance();
    
    // Load saved credentials
    final savedToken = _prefs.getString('github_token');
    final savedOwner = _prefs.getString('github_owner');
    final savedRepo = _prefs.getString('github_repo');
    
    if (savedToken != null && savedOwner != null && savedRepo != null) {
      _token = savedToken;
      _owner = savedOwner;
      _repo = savedRepo;
      _service.setCredentials(_token!, _owner!, _repo!);
    }
    
    _isInitialized = true;
    notifyListeners();
  }

// authenticate with GitHub using a personal access token
  Future<void> authenticate(String token, String owner, String repo) async {
    try {
      _token = token;
      _owner = owner;
      _repo = repo;
      _service.setCredentials(token, owner, repo);
      
      // Save credentials to preferences
      await _prefs.setString('github_token', token);
      await _prefs.setString('github_owner', owner);
      await _prefs.setString('github_repo', repo);
      
      _error = null;
      notifyListeners();
      
      // Fetch PRs after authentication
      await fetchPullRequests();
    } catch (e) {
      _error = 'Authentication failed: $e';
      notifyListeners();
      rethrow;
    }
  }

// authenticate to access public repositories without a token
  Future<void> authenticatePublic(String owner, String repo) async {
    try {
      // Use dummy token 'abc123' for display purposes only
      _token = 'abc123';
      _owner = owner;
      _repo = repo;
      _service.setCredentials('abc123', owner, repo);
      
      // Save credentials to preferences
      await _prefs.setString('github_token', _token!);
      await _prefs.setString('github_owner', owner);
      await _prefs.setString('github_repo', repo);
      
      _error = null;
      notifyListeners();
      
      // Fetch PRs after authentication
      await fetchPullRequests();
    } catch (e) {
      _error = 'Public repo access failed: $e';
      notifyListeners();
      rethrow;
    }
  }

// fetch pull requests from GitHub based on the selected state (open, closed, all)
  Future<void> fetchPullRequests({String state = 'open'}) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      
      _pullRequests = await _service.fetchPullRequests(state: state);
      _isLoading = false;
      _error = null;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

// select a pull request and fetch its reviews
  Future<void> selectPullRequest(PullRequest pr) async {
    try {
      _selectedPR = pr;
      _isLoading = true;
      notifyListeners();
      
      // Fetch reviews for the selected PR
      _reviews = await _service.fetchReviews(pr.number);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> approveReview(String comment) async {
    if (_selectedPR == null) return;
    
    try {
      _isLoading = true;
      notifyListeners();
      
      await _service.createReview(
        prNumber: _selectedPR!.number,
        comment: comment,
        event: 'APPROVE',
      );
      
      // Refresh reviews
      await selectPullRequest(_selectedPR!);
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> requestChanges(String comment) async {
    if (_selectedPR == null) return;
    
    try {
      _isLoading = true;
      notifyListeners();
      
      await _service.createReview(
        prNumber: _selectedPR!.number,
        comment: comment,
        event: 'REQUEST_CHANGES',
      );
      
      // Refresh reviews
      await selectPullRequest(_selectedPR!);
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> addComment(String comment) async {
    if (_selectedPR == null) return;
    
    try {
      _isLoading = true;
      notifyListeners();
      
      await _service.createReview(
        prNumber: _selectedPR!.number,
        comment: comment,
        event: 'COMMENT',
      );
      
      // Refresh reviews
      await selectPullRequest(_selectedPR!);
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> mergePR() async {
    if (_selectedPR == null) return;
    
    try {
      _isLoading = true;
      notifyListeners();
      
      await _service.mergePullRequest(_selectedPR!.number);
      
      _error = 'PR merged successfully!';
      _isLoading = false;
      notifyListeners();
      
      // Refresh the PR list
      await fetchPullRequests();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  Future<void> logout() async {
    _token = null;
    _owner = null;
    _repo = null;
    _pullRequests = [];
    _selectedPR = null;
    _reviews = [];
    _error = null;
    
    // Clear saved credentials
    await _prefs.remove('github_token');
    await _prefs.remove('github_owner');
    await _prefs.remove('github_repo');
    
    notifyListeners();
  }
}
