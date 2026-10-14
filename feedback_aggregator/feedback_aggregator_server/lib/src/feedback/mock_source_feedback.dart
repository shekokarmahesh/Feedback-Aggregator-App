/// A bounded synthetic inbox. Stable IDs make repeat deliveries idempotent.
/// Replacing a provider later does not require changing workspace ticket UI.
class MockSourceFeedback {
  final String externalId;
  final String title;
  final String description;
  final String requester;
  final String priority;

  const MockSourceFeedback(
    this.externalId,
    this.title,
    this.description,
    this.requester,
    this.priority,
  );
}

const mockSourceFeedback = <String, List<MockSourceFeedback>>{
  'Email': [
    MockSourceFeedback(
      'email-demo-v1-01',
      'CSV export downloads an empty file',
      'From: Maya Chen <maya.chen@example.com>\nSubject: Empty CSV export\n\nOur filtered inbox has 86 tickets, but the exported CSV contains only headers. Can you investigate?',
      'Maya Chen · maya.chen@example.com',
      'High',
    ),
    MockSourceFeedback(
      'email-demo-v1-02',
      'Workspace invitations never arrive',
      'From: Daniel Ortiz <daniel.ortiz@example.com>\nSubject: Team invitation missing\n\nI invited two teammates this morning. Neither received the invitation, including in spam.',
      'Daniel Ortiz · daniel.ortiz@example.com',
      'High',
    ),
    MockSourceFeedback(
      'email-demo-v1-03',
      'Please add a dark theme',
      'From: Priya Shah <priya.shah@example.com>\nSubject: Dark mode request\n\nWe use the dashboard late at night. A dark theme would make longer support triage sessions more comfortable.',
      'Priya Shah · priya.shah@example.com',
      'Low',
    ),
    MockSourceFeedback(
      'email-demo-v1-04',
      'Google sign-in returns me to the login page',
      'From: Alex Morgan <alex.morgan@example.com>\nSubject: Cannot enter my workspace\n\nAfter choosing my Google account, I land back on the login screen. Password login works.',
      'Alex Morgan · alex.morgan@example.com',
      'High',
    ),
    MockSourceFeedback(
      'email-demo-v1-05',
      'Remember the last selected workspace',
      'From: Lina Park <lina.park@example.com>\nSubject: Workspace preference\n\nEvery refresh switches me to the first workspace. Please remember which team I was working with.',
      'Lina Park · lina.park@example.com',
      'Medium',
    ),
    MockSourceFeedback(
      'email-demo-v1-06',
      'Exported CSV is missing filtered feedback',
      'From: Noah Reed <noah.reed@example.com>\nSubject: Export loses our tickets\n\nSelecting Slack as the source and exporting produces a file with no rows even though the table has feedback.',
      'Noah Reed · noah.reed@example.com',
      'High',
    ),
    MockSourceFeedback(
      'email-demo-v1-07',
      'Dashboard loads slowly for larger teams',
      'From: Sara Ali <sara.ali@example.com>\nSubject: Slow team dashboard\n\nOur organization has several thousand tickets. The first dashboard load takes around thirty seconds.',
      'Sara Ali · sara.ali@example.com',
      'Medium',
    ),
    MockSourceFeedback(
      'email-demo-v1-08',
      'Notify requesters when a ticket is resolved',
      'From: Oliver Jones <oliver.jones@example.com>\nSubject: Resolution notifications\n\nPlease send an update to the people who reported an issue when the team marks it resolved.',
      'Oliver Jones · oliver.jones@example.com',
      'Medium',
    ),
    MockSourceFeedback(
      'email-demo-v1-09',
      'Invitation emails are still missing',
      'From: Emma Wilson <emma.wilson@example.com>\nSubject: Invite delivery\n\nMy new teammate cannot find the workspace invitation. A copied invitation link works immediately.',
      'Emma Wilson · emma.wilson@example.com',
      'High',
    ),
    MockSourceFeedback(
      'email-demo-v1-10',
      'Assign a feedback owner',
      'From: Amir Khan <amir.khan@example.com>\nSubject: Ticket ownership\n\nCould we assign grouped feedback to a developer so that follow-up responsibility is clear?',
      'Amir Khan · amir.khan@example.com',
      'Medium',
    ),
    MockSourceFeedback(
      'email-demo-v1-11',
      'Google OAuth loops after choosing an account',
      'From: Zoe Taylor <zoe.taylor@example.com>\nSubject: Login loop\n\nI pick my Google account, consent, and end up at login again. It happens on a fresh browser too.',
      'Zoe Taylor · zoe.taylor@example.com',
      'High',
    ),
    MockSourceFeedback(
      'email-demo-v1-12',
      'Search should include feedback descriptions',
      'From: Ben Carter <ben.carter@example.com>\nSubject: Search improvement\n\nThe keywords our support team remembers are usually in the message body. Please include descriptions in search.',
      'Ben Carter · ben.carter@example.com',
      'Low',
    ),
  ],
  'Slack': [
    MockSourceFeedback(
      'slack-demo-v1-01',
      'CSV export has headers but no ticket rows',
      '#customer-feedback · @maya\nWe can see feedback in the filtered inbox, but downloading CSV gives only the header row. Anyone else seeing this?',
      'Maya · #customer-feedback',
      'High',
    ),
    MockSourceFeedback(
      'slack-demo-v1-02',
      'Invite emails do not reach new teammates',
      '#support-triage · @daniel\nTwo teammates are waiting for workspace invitations. We resent them, checked spam, and still nothing arrived.',
      'Daniel · #support-triage',
      'High',
    ),
    MockSourceFeedback(
      'slack-demo-v1-03',
      'A dark theme would help support shifts',
      '#product-ideas · @priya\nFeature request: dark mode for the feedback dashboard. We often handle support after sunset.',
      'Priya · #product-ideas',
      'Low',
    ),
    MockSourceFeedback(
      'slack-demo-v1-04',
      'Google login gets stuck in a loop',
      '#customer-feedback · @alex\nChoosing my Google account takes me straight back to login instead of the team inbox.',
      'Alex · #customer-feedback',
      'High',
    ),
    MockSourceFeedback(
      'slack-demo-v1-05',
      'Show who is responsible for each issue',
      '#product-ideas · @amir\nCan we assign an owner to a feedback ticket? Two engineers picked up the same customer issue today.',
      'Amir · #product-ideas',
      'Medium',
    ),
    MockSourceFeedback(
      'slack-demo-v1-06',
      'Filtered exports are empty again',
      '#support-triage · @noah\nExporting tickets for a particular source produces an empty CSV. Removing the filter seems to work.',
      'Noah · #support-triage',
      'High',
    ),
    MockSourceFeedback(
      'slack-demo-v1-07',
      'Loading a large workspace takes thirty seconds',
      '#customer-feedback · @sara\nThe dashboard is really slow for our large workspace. It takes about half a minute before any rows appear.',
      'Sara · #customer-feedback',
      'Medium',
    ),
    MockSourceFeedback(
      'slack-demo-v1-08',
      'Let customers know when we fix their issue',
      '#product-ideas · @oliver\nAfter resolving feedback, can we automatically notify everyone who reported it? We currently send individual replies.',
      'Oliver · #product-ideas',
      'Medium',
    ),
    MockSourceFeedback(
      'slack-demo-v1-09',
      'Remember the inbox filters',
      '#support-triage · @lina\nSwitching tabs clears my source and status filters. I would love to return to exactly the same triage view.',
      'Lina · #support-triage',
      'Low',
    ),
    MockSourceFeedback(
      'slack-demo-v1-10',
      'Allow bulk status changes',
      '#product-ideas · @emma\nWe have a release that fixes several requests. Selecting multiple tickets and resolving them together would save time.',
      'Emma · #product-ideas',
      'Medium',
    ),
    MockSourceFeedback(
      'slack-demo-v1-11',
      'Team invitation email still does not arrive',
      '#customer-feedback · @zoe\nThe workspace invite never reaches my inbox, but I could join with the shared link from our Admin.',
      'Zoe · #customer-feedback',
      'High',
    ),
    MockSourceFeedback(
      'slack-demo-v1-12',
      'Add keyboard shortcuts for triage',
      '#product-ideas · @ben\nA shortcut for searching and moving between feedback items would make daily triage quicker.',
      'Ben · #product-ideas',
      'Low',
    ),
  ],
};
