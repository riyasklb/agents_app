enum JobStatus {
  available,
  accepted,
  inProgress,
  submitted,
  completed,
  approved,
  rejected,
}

enum JobPriority {
  low,
  medium,
  high,
}

enum LoanType {
  homeLoan('Home Loan'),
  personalLoan('Personal Loan'),
  businessLoan('Business Loan'),
  residenceVerification('Residence Verification');

  const LoanType(this.label);
  final String label;
}

enum VerificationType {
  residentialAddress('Residential Address Verification', 'Address Verification'),
  businessAddress('Business Address Verification', 'Business Verification'),
  identityVerification('Identity Verification', 'Identity Verification'),
  propertyVerification('Property Verification', 'Property Verification');

  const VerificationType(this.label, this.shortLabel);
  final String label;
  final String shortLabel;
}

enum MediaType {
  photo,
  video,
  document,
}

enum NotificationType {
  newJob,
  verificationApproved,
  paymentAdded,
  general,
  caseRolledBack,
  deadlineExtended,
}

enum AllocationMode {
  pincode,
  distance,
}

enum PaymentStatus {
  none,
  pendingReview,
  pendingPayment,
  paid,
}

enum ExtensionReason {
  partUnavailable('Part / document unavailable'),
  applicantUnavailable('Applicant unavailable'),
  accessDenied('Could not access location'),
  weather('Weather / safety issue'),
  other('Other valid reason');

  const ExtensionReason(this.label);
  final String label;
}
