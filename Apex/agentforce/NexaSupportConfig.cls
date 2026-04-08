public with sharing class NexaSupportConfig {
   // Case statuses
    public static final String CASE_STATUS_NEW = 'New';
    public static final String CASE_STATUS_CLOSED = 'Closed';

    // Priorities
    public static final String PRIORITY_HIGH = 'High';
    public static final String PRIORITY_MEDIUM = 'Medium';

    // Categories
    public static final String CATEGORY_TECHNICAL = 'Technical';

    // Issue Nature
    public static final String ISSUE_NATURE_PHYSICAL = 'Physical';
    public static final String ISSUE_NATURE_REMOTE = 'Remote';
    public static final String ISSUE_NATURE_UNKNOWN = 'Unknown';

    // Interaction Log
    public static final String FOLLOW_UP_STATUS_PENDING = 'Pending';
    public static final String FOLLOW_UP_STATUS_COMPLETED = 'Completed';
    public static final String FOLLOW_UP_TYPE_CLARIFICATION = 'Clarification';
    public static final String SOURCE_CHANNEL_AGENTFORCE = 'Agentforce';
    //queue Id
    public static final Id HUMAN_SUPPORT_QUEUE_ID='00GgL00000CQjiX';
    public static final String HUMAN_SUPPORT_QUEUE_DEV_NAME='Human_support_Queue';

    // Generic messages
    public static final String MSG_UNSUPPORTED_REQUEST =
    'I can assist only with NexaAssist support requests such as login issues, billing concerns, technical problems, subscription issues, or service-related requests. Please describe your support issue.';
    public static final String MSG_PROVIDE_EMAIL =
        'To continue, please provide the email address associated with your account.';

    public static final String MSG_CONTACT_NOT_FOUND =
        'We could not find an account associated with that email address. Please provide the email address registered with NexaAssist support.';

    public static final String MSG_ALREADY_ESCALATED =
        'Your issue has already been escalated to our human support team and they are actively working on it. We will contact you soon.';
}