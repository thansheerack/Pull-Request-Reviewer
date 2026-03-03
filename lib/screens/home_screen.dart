import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/github_provider.dart';
import 'components/login_form.dart';
import 'components/pr_list.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late TextEditingController _tokenController;
  late TextEditingController _ownerController;
  late TextEditingController _repoController;
  String _selectedState = 'open';

  @override
  void initState() {
    super.initState();
    _tokenController = TextEditingController();
    _ownerController = TextEditingController();
    _repoController = TextEditingController();
    
    // Initialize preferences on startup
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<GitHubProvider>().initializePreferences();
    });
  }

  @override
  void dispose() {
    _tokenController.dispose();
    _ownerController.dispose();
    _repoController.dispose();
    super.dispose();
  }

  void _authenticate(BuildContext context) async {
    final provider = context.read<GitHubProvider>();
    try {
      await provider.authenticate(
        _tokenController.text.trim(),
        _ownerController.text.trim(),
        _repoController.text.trim(),
      );
      _tokenController.clear();
      _ownerController.clear();
      _repoController.clear();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Authentication failed: $e')),
        );
      }
    }
  }

  void _authenticatePublic(BuildContext context) async {
    final provider = context.read<GitHubProvider>();
    try {
      await provider.authenticatePublic(
        _ownerController.text.trim(),
        _repoController.text.trim(),
      );
      _tokenController.clear();
      _ownerController.clear();
      _repoController.clear();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Public repo access failed: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('GitHub PR Reviewer'),
        elevation: 0,
      ),
      body: Consumer<GitHubProvider>(
        builder: (context, provider, _) {
          if (!provider.isAuthenticated) {
            return LoginForm(
              tokenController: _tokenController,
              ownerController: _ownerController,
              repoController: _repoController,
              onLoginPressed: () => _authenticate(context),
              onPublicRepoPressed: () => _authenticatePublic(context),
            );
          }
          return PullRequestList(
            selectedState: _selectedState,
            onOpenSelected: () {
              setState(() => _selectedState = 'open');
              provider.fetchPullRequests(state: 'open');
            },
            onClosedSelected: () {
              setState(() => _selectedState = 'closed');
              provider.fetchPullRequests(state: 'closed');
            },
            onAllSelected: () {
              setState(() => _selectedState = 'all');
              provider.fetchPullRequests(state: 'all');
            },
            onLogout: () => provider.logout(),
            onRetry: () {
              provider.clearError();
              provider.fetchPullRequests(state: _selectedState);
            },
            provider: provider,
          );
        },
      ),
    );
  }
}
