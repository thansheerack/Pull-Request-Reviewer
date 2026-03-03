import 'package:flutter/material.dart';

class LoginForm extends StatelessWidget {
  final TextEditingController tokenController;
  final TextEditingController ownerController;
  final TextEditingController repoController;
  final VoidCallback onLoginPressed;
  final VoidCallback onPublicRepoPressed;

  const LoginForm({
    Key? key,
    required this.tokenController,
    required this.ownerController,
    required this.repoController,
    required this.onLoginPressed,
    required this.onPublicRepoPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 40),
          Icon(
            Icons.code_rounded,
            size: 80,
            color: Colors.blue.shade700,
          ),
          const SizedBox(height: 32),
          const Text(
            'GitHub PR Reviewer',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Review and manage pull requests easily',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 48),
          
          
          TextField(
            controller: ownerController,
            decoration: InputDecoration(
              labelText: 'Repository Owner',
              hintText: 'e.g., google',
              prefixIcon: const Icon(Icons.person),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: repoController,
            decoration: InputDecoration(
              labelText: 'Repository Name',
              hintText: 'e.g., flutter',
              prefixIcon: const Icon(Icons.folder),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: tokenController,
            obscureText: true,
            decoration: InputDecoration(
              labelText: 'GitHub Token',
              hintText: 'gh_xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx',
              prefixIcon: const Icon(Icons.key),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: onLoginPressed,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Login with GitHub Token'),
          ),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: onPublicRepoPressed,
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Access Public Repository (No Token)'),
          ),
          const SizedBox(height: 16),
          Text(
            'Tip: To access public repositories, use the "Access Public Repository" button.\n'
            'For private repos or authenticated access, use a GitHub Personal Access Token.\n'
            'Token must have "repo" and "read:user" scopes.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }
}
