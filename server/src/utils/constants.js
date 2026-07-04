// ─── Roles ────────────────────────────────────────────────────────────────────
const ROLES = {
  FINANCE_DIRECTOR: 'finance_director',
  DIRECTOR: 'director',
};

// ─── Departments ──────────────────────────────────────────────────────────────
const DEPARTMENTS = {
  TECHNICAL_ACTIVITIES: 'Technical Activities',
  MEDIA_COMMUNICATION: 'Media & Communication',
  EVENTS_OUTREACH: 'Events & Outreach',
  PROFESSIONAL_DEVELOPMENT: 'Professional Development',
  ENTREPRENEURSHIP: 'Entrepreneurship',
  CLUB: 'Club',
};

// ─── Proposal Statuses ────────────────────────────────────────────────────────
const PROPOSAL_STATUSES = {
  DRAFT: 'Draft',
  SUBMITTED: 'Submitted',
  UNDER_REVIEW: 'Under Review',
  APPROVED: 'Approved',
  REJECTED: 'Rejected',
  RESUBMITTED: 'Resubmitted',
  WAITING_FOR_BILLS: 'Waiting for Bills',
  COMPLETED: 'Completed',
};

// ─── Proposal Priorities ──────────────────────────────────────────────────────
const PROPOSAL_PRIORITIES = {
  LOW: 'Low',
  MEDIUM: 'Medium',
  HIGH: 'High',
  URGENT: 'Urgent',
};

// ─── Bill Verification Statuses ───────────────────────────────────────────────
const BILL_VERIFICATION_STATUSES = {
  PENDING: 'Pending',
  VERIFIED: 'Verified',
  NEED_CORRECTION: 'Need Correction',
  COMPLETED: 'Completed',
};

// ─── Notification Types ───────────────────────────────────────────────────────
const NOTIFICATION_TYPES = {
  PROPOSAL_SUBMITTED: 'proposal_submitted',
  PROPOSAL_APPROVED: 'proposal_approved',
  PROPOSAL_REJECTED: 'proposal_rejected',
  PROPOSAL_RESUBMITTED: 'proposal_resubmitted',
  PROPOSAL_COMPLETED: 'proposal_completed',
  NEW_COMMENT: 'new_comment',
  BILLS_UPLOADED: 'bills_uploaded',
  BILLS_REQUESTED: 'bills_requested',
  BILLS_VERIFIED: 'bills_verified',
  REMINDER_BILLS_PENDING: 'reminder_bills_pending',
  REMINDER_NO_ACTION: 'reminder_no_action',
  REMINDER_RESUBMISSION: 'reminder_resubmission',
  REMINDER_VERIFICATION: 'reminder_verification',
};

// ─── Activity Actions ─────────────────────────────────────────────────────────
const ACTIVITY_ACTIONS = {
  CREATED: 'Created',
  SUBMITTED: 'Submitted',
  VIEWED: 'Viewed',
  EDITED: 'Edited',
  APPROVED: 'Approved',
  REJECTED: 'Rejected',
  RESUBMITTED: 'Resubmitted',
  BILLS_UPLOADED: 'Bills Uploaded',
  BILLS_VERIFIED: 'Bills Verified',
  COMPLETED: 'Completed',
  COMMENT_ADDED: 'Comment Added',
  ATTACHMENT_UPLOADED: 'Attachment Uploaded',
  PASSWORD_CHANGED: 'Password Changed',
  PROFILE_UPDATED: 'Profile Updated',
  DIRECTOR_CREATED: 'Director Created',
  DIRECTOR_UPDATED: 'Director Updated',
  DIRECTOR_DEACTIVATED: 'Director Deactivated',
  DIRECTOR_ACTIVATED: 'Director Activated',
  DIRECTOR_DELETED: 'Director Deleted',
  PASSWORD_RESET: 'Password Reset',
  LOGGED_IN: 'Logged In',
  LOGGED_OUT: 'Logged Out',
};

// ─── Report Periods ───────────────────────────────────────────────────────────
const REPORT_PERIODS = {
  MONTHLY: 'monthly',
  SEMESTER: 'semester',
  ACADEMIC_YEAR: 'academic_year',
  ALL: 'all',
};

module.exports = {
  ROLES,
  DEPARTMENTS,
  PROPOSAL_STATUSES,
  PROPOSAL_PRIORITIES,
  BILL_VERIFICATION_STATUSES,
  NOTIFICATION_TYPES,
  ACTIVITY_ACTIONS,
  REPORT_PERIODS,
};
