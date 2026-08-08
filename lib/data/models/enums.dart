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
  residentialAddress('Residential Address Verification'),
  businessAddress('Business Address Verification'),
  identityVerification('Identity Verification'),
  propertyVerification('Property Verification');

  const VerificationType(this.label);
  final String label;
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
}
