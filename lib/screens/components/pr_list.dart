import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/github_provider.dart';
import '../../providers/theme_provider.dart';
import 'pr_card.dart';

class PullRequestList extends StatelessWidget {
  final String selectedState;
  final VoidCallback onOpenSelected;
  final VoidCallback onClosedSelected;
  final VoidCallback onAllSelected;
  final VoidCallback onLogout;
  final VoidCallback onRetry;
  final GitHubProvider provider;

  const PullRequestList({
    Key? key,
    required this.selectedState,
    required this.onOpenSelected,
    required this.onClosedSelected,
    required this.onAllSelected,
    required this.onLogout,
    required this.onRetry,
    required this.provider,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          // use surface color so it adapts to light/dark themes
          color: Theme.of(context).colorScheme.surface,
          child: Row(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      FilterChip(
                        label: const Text('Open'),
                        selected: selectedState == 'open',
                        onSelected: (_) => onOpenSelected(),
                      ),
                      const SizedBox(width: 8),
                      FilterChip(
                        label: const Text('Closed'),
                        selected: selectedState == 'closed',
                        onSelected: (_) => onClosedSelected(),
                      ),
                      const SizedBox(width: 8),
                      FilterChip(
                        label: const Text('All'),
                        selected: selectedState == 'all',
                        onSelected: (_) => onAllSelected(),
                      ),
                    ],
                  ),
                ),
              ),
              IconButton(
                icon: Icon(
                  context.watch<ThemeProvider>().isDarkMode
                      ? Icons.light_mode
                      : Icons.dark_mode,
                ),
                onPressed: () {
                  context.read<ThemeProvider>().toggleTheme();
                },
                tooltip: 'Toggle theme',
              ),
              IconButton(
                icon: const Icon(Icons.logout),
                onPressed: onLogout,
                tooltip: 'Logout',
              ),
            ],
          ),
        ),
        Expanded(
  child: RefreshIndicator(
        onRefresh: () async {
          await provider.fetchPullRequests(state: selectedState);
        },
        child: provider.isLoading
            ? const Center(child: CircularProgressIndicator())
            : provider.error != null && provider.error!.isNotEmpty
              ? ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: [
                    const SizedBox(height: 150),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 64,
                          color: Theme.of(context).colorScheme.error,
                        ),
                        const SizedBox(height: 16),
                        Padding(
                          padding:
                              const EdgeInsets.symmetric(horizontal: 24),
                          child: Text(
                            provider.error!,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              color: Theme.of(context).colorScheme.error,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: onRetry,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Retry'),
                        ),
                      ],
                    ),
                  ],
                )
              : provider.pullRequests.isEmpty
                  ? ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: [
                        const SizedBox(height: 200),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.inbox_rounded,
                              size: 64,
                              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.38),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No pull requests found',
                              style: TextStyle(
                                fontSize: 16,
                                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                              ),
                            ),
                          ],
                        ),
                      ],
                    )
                  : ListView.builder(
                      physics:
                          const AlwaysScrollableScrollPhysics(),
                      itemCount: provider.pullRequests.length,
                      itemBuilder: (context, index) {
                        final pr = provider.pullRequests[index];
                        return PullRequestCard(
                          pr: pr,
                          provider: provider,
                        );
                      },
                    ),
        ),
      ),
    ],
    );
  }
}
