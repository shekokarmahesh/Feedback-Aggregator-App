import 'package:flutter/material.dart';

/// Public entry point. The preview uses the same sample feedback as the inbox.
class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  static const _ink = Color(0xFF0F172A);
  static const _muted = Color(0xFF64748B);
  static const _accent = Color(0xFF4F46E5);

  void _open(BuildContext context, String route) =>
      Navigator.of(context).pushNamed(route);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 900;
        return SingleChildScrollView(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1280),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: wide ? 48 : 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      child: Row(
                        children: [
                          const Icon(Icons.forum_rounded, color: _accent),
                          const SizedBox(width: 8),
                          const Expanded(
                            child: Text(
                              'Feedback',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                color: _ink,
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: () => _open(context, '/login'),
                            child: const Text('Log in'),
                          ),
                          const SizedBox(width: 8),
                          FilledButton(
                            style: FilledButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 16,
                              ),
                            ),
                            onPressed: () => _open(context, '/signup'),
                            child: const Text('Sign up'),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: wide ? 72 : 36, bottom: 64),
                      child: wide
                          ? Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Expanded(child: _hero(context, wide)),
                                const SizedBox(width: 52),
                                Expanded(child: _preview()),
                              ],
                            )
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _hero(context, wide),
                                const SizedBox(height: 40),
                                _preview(),
                              ],
                            ),
                    ),
                    const Divider(color: Color(0xFFE2E8F0)),
                    const SizedBox(height: 52),
                    const Text(
                      'Less noise. Clearer priorities.',
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w800,
                        color: _ink,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'A shared view of what your users need, built for developers and product teams.',
                      style: TextStyle(
                        fontSize: 16,
                        color: _muted,
                        height: 1.6,
                      ),
                    ),
                    const SizedBox(height: 28),
                    LayoutBuilder(
                      builder: (context, box) {
                        final width = wide
                            ? (box.maxWidth - 32) / 3
                            : box.maxWidth;
                        return Wrap(
                          spacing: 16,
                          runSpacing: 16,
                          children: [
                            _feature(
                              width,
                              Icons.inbox_outlined,
                              'One place for feedback',
                              'Explore a unified inbox with clear sources, statuses, and ticket details.',
                            ),
                            _feature(
                              width,
                              Icons.people_outline,
                              'See the strongest signals',
                              'Sort feedback by request count to see which ideas matter to more users.',
                            ),
                            _feature(
                              width,
                              Icons.filter_alt_outlined,
                              'Find your next focus',
                              'Search and filter by source, priority, and status without losing the bigger picture.',
                            ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 48),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEEF2FF),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        children: [
                          const Text(
                            'Turn feedback into your next step.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w800,
                              color: _ink,
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Create an account and explore the sample workspace.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: _muted, height: 1.5),
                          ),
                          const SizedBox(height: 24),
                          FilledButton(
                            onPressed: () => _open(context, '/signup'),
                            child: const Text('Get started'),
                          ),
                        ],
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 28),
                      child: Text(
                        'Feedback Aggregator · Built for better product decisions',
                        style: TextStyle(color: _muted, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _hero(BuildContext context, bool wide) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFFEEF2FF),
          borderRadius: BorderRadius.circular(24),
        ),
        child: const Text(
          'FROM FEEDBACK TO FOCUS',
          style: TextStyle(
            color: _accent,
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.1,
          ),
        ),
      ),
      const SizedBox(height: 24),
      Text(
        'Every voice.\nOne clear picture.',
        style: TextStyle(
          fontSize: wide ? 56 : 42,
          height: 1.08,
          letterSpacing: -1.8,
          fontWeight: FontWeight.w800,
          color: _ink,
        ),
      ),
      const SizedBox(height: 24),
      const Text(
        'Bring user feedback into focus. Discover common requests, understand what matters, and give your team a clearer path forward.',
        style: TextStyle(fontSize: 18, height: 1.65, color: _muted),
      ),
      const SizedBox(height: 28),
      Wrap(
        spacing: 12,
        runSpacing: 12,
        children: [
          FilledButton.icon(
            onPressed: () => _open(context, '/signup'),
            icon: const Icon(Icons.arrow_forward, size: 18),
            label: const Text('Get started'),
          ),
          OutlinedButton(
            onPressed: () => _open(context, '/login'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
            ),
            child: const Text('Log in to your workspace'),
          ),
        ],
      ),
      const SizedBox(height: 16),
      const Text(
        'Email or Google sign-in. Start with a sample inbox.',
        style: TextStyle(fontSize: 12, color: _muted),
      ),
    ],
  );

  Widget _preview() => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: const Color(0xFFE2E8F0)),
      boxShadow: const [
        BoxShadow(
          color: Color(0x124F46E5),
          blurRadius: 48,
          offset: Offset(0, 20),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.inbox_outlined, size: 18, color: _accent),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'Feedback inbox',
                style: TextStyle(fontWeight: FontWeight.w700, color: _ink),
              ),
            ),
            Text('PREVIEW', style: TextStyle(fontSize: 10, color: _muted)),
          ],
        ),
        const SizedBox(height: 24),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFEEF2FF),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '121 user requests',
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.w800,
                  color: _accent,
                ),
              ),
              SizedBox(height: 4),
              Text(
                '8 feedback groups · 5 sources',
                style: TextStyle(color: _muted, fontSize: 12),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _previewTicket('Add dark mode to the dashboard', 'Slack · Planned', 28),
        _previewTicket('Export feedback as CSV', 'Email · In progress', 24),
        _previewTicket('Group duplicate feedback', 'Forms · Open', 19),
        const SizedBox(height: 12),
        const Text(
          'Sample data. Live integrations are coming next.',
          style: TextStyle(fontSize: 11, color: _muted),
        ),
      ],
    ),
  );

  Widget _previewTicket(String title, String subtitle, int count) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 12),
    child: Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: _ink,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                subtitle,
                style: const TextStyle(fontSize: 11, color: _muted),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            '↑ $count',
            style: const TextStyle(fontWeight: FontWeight.w700, color: _accent),
          ),
        ),
      ],
    ),
  );

  Widget _feature(
    double width,
    IconData icon,
    String title,
    String description,
  ) => SizedBox(
    width: width,
    child: Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE2E8F0)),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: _accent, size: 28),
          const SizedBox(height: 20),
          Text(
            title,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: _ink,
            ),
          ),
          const SizedBox(height: 12),
          Text(description, style: const TextStyle(color: _muted, height: 1.6)),
        ],
      ),
    ),
  );
}
