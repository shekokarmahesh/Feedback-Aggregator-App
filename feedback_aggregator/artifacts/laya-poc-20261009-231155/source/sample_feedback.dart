/// Fixed synthetic benchmark. Expected labels stay out of Laya requests.
class SampleFeedback {
  final String id;
  final String source;
  final String reporterId;
  final String title;
  final String text;
  final int hoursAgo;
  final String? expectedIssue;

  const SampleFeedback(
    this.id,
    this.source,
    this.reporterId,
    this.title,
    this.text,
    this.hoursAgo,
    this.expectedIssue,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'source': source,
    'reporterId': reporterId,
    'title': title,
    'text': text,
    'hoursAgo': hoursAgo,
  };
}

const pocSources = ['Discord', 'Slack', 'Email', 'Forms', 'Support'];

List<SampleFeedback> generateSampleFeedback() {
  const scenarios = [
    (
      'google-login',
      'Google sign-in loops back to login',
      [
        'Google sign in succeeds then sends me right back to the login screen. Cannot reach my dashboard.',
        'Stuck in a loop after Google OAuth. Approve account, land on sign-in again. Email login works.',
        'After selecting my Google account I never get into the app. It just opens login again.',
        'Using Continue with Google returns to sign in repeatedly instead of the workspace.',
        'Google authentication redirects back to login every time. My team cannot enter using Google.',
      ],
    ),
    (
      'reset-email',
      'Password-reset email never arrives',
      [
        'Forgot password says code sent but no reset email arrives, even in spam. I use email/password.',
        'Password recovery emails are missing. Tried resending the reset code three times.',
        'I forgot my email account password. The reset message never reaches my inbox.',
        'Reset password cannot be completed because the email with the code is never delivered.',
        'Support case: email-password recovery code not received. Google sign-in is fine.',
      ],
    ),
    (
      'csv-timeout',
      'Large CSV exports time out',
      [
        'Exporting 10,000 feedback rows as CSV times out after 60 seconds. Small exports work.',
        'Large feedback CSV download fails with a timeout. Need the full dataset for our review.',
        'Cannot export a big workspace: CSV request ends in 504. A hundred rows downloads normally.',
        'Please fix timeout on CSV export with thousands of rows; we cannot send weekly reports.',
        'CSV export for a large date range fails after a minute. There is no file to download.',
      ],
    ),
    (
      'csv-empty',
      'Filtered CSV downloads contain no rows',
      [
        'CSV export downloads immediately but has only headers after filtering by Slack. There are 20 rows on screen.',
        'Filtered feedback export is an empty CSV, just column names. Unfiltered download is okay.',
        'Export with the Open status filter returns zero rows although the table shows matching feedback.',
        'Downloaded CSV contains headers only when a source filter is active. No timeout, just missing data.',
        'A filtered CSV downloads successfully but the actual feedback rows are absent.',
      ],
    ),
    (
      'slow-dashboard',
      'Workspace dashboard loads slowly',
      [
        'Opening the dashboard takes 25 seconds in a workspace with lots of tickets. Then it works.',
        'Our large workspace overview is painfully slow to load. Waiting on initial feedback table.',
        'First dashboard load takes around half a minute with 8,000 tickets; exports are fine.',
        'Please speed up the initial workspace dashboard. It eventually loads but delays every meeting.',
        'The feedback list takes 20 to 30 seconds to appear for our biggest workspace.',
      ],
    ),
    (
      'dark-mode',
      'Add a dark theme',
      [
        'Could you add a dark mode? Reviewing feedback late at night hurts my eyes.',
        'Feature request: dark theme for the feedback dashboard and ticket details.',
        'Would love a night theme across the application, especially during evening support shifts.',
        'Please offer a dark appearance option for the dashboard.',
        'Can the team ship dark mode? The white background is too bright at night.',
      ],
    ),
  ];
  final reports = <SampleFeedback>[];
  // Interleave topics: clustering must handle paraphrases and near-miss issues.
  for (var channel = 0; channel < pocSources.length; channel++) {
    for (var topic = 0; topic < scenarios.length; topic++) {
      final scenario = scenarios[topic];
      reports.add(
        SampleFeedback(
          'SAMPLE-${reports.length + 1}',
          pocSources[channel],
          'sample-person-${topic * 4 + (channel == 4 ? 0 : channel)}',
          channel == 0 ? scenario.$2 : scenario.$3[channel].split('.').first,
          scenario.$3[channel],
          [2, 6, 18, 36, 90][channel],
          scenario.$1,
        ),
      );
    }
  }
  reports.addAll(const [
    SampleFeedback(
      'SAMPLE-31',
      'Discord',
      'sample-person-25',
      'Thanks team!',
      'Thanks for the great demo today. Looking forward to the next update!',
      3,
      'noise-31',
    ),
    SampleFeedback(
      'SAMPLE-32',
      'Slack',
      'sample-person-26',
      'Meeting reminder',
      'Reminder: our internal planning meeting starts at 3 pm.',
      4,
      'noise-32',
    ),
    SampleFeedback(
      'SAMPLE-33',
      'Email',
      'sample-person-27',
      'Login problem',
      'Login is broken for me. Can someone help?',
      1,
      null,
    ),
    SampleFeedback(
      'SAMPLE-34',
      'Forms',
      'sample-person-28',
      'Export is broken',
      'My export is not working. Not sure what happened.',
      7,
      null,
    ),
  ]);
  return reports;
}
