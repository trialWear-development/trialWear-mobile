class Patient {
  final String id;
  final String name;
  final String dateOfBirth;
  final String trialId;
  final String status;

  const Patient({
    required this.id,
    required this.name,
    required this.dateOfBirth,
    required this.trialId,
    required this.status,
  });

  factory Patient.fromJson(Map<String, dynamic> json) {
    return Patient(
      id: (json['id'] ?? json['patientId'] ?? '').toString(),
      name: (json['name'] ?? json['patientName'] ?? 'Unknown Patient')
          .toString(),
      dateOfBirth: (json['dateOfBirth'] ?? json['dob'] ?? '').toString(),
      trialId: (json['trialId'] ?? '').toString(),
      status: (json['status'] ?? 'Active').toString(),
    );
  }

  factory Patient.mock(String deviceId) {
    return Patient(
      id: deviceId,
      name: 'Demo Patient',
      dateOfBirth: '2012-06-15',
      trialId: 'TRIAL-001',
      status: 'Active',
    );
  }
}
