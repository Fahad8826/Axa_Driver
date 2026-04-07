// ── Driver (nested in login response) ────────────────────────────────────────
class DriverModel {
  final int id;
  final int driverId;
  final String name;
  final String phoneNumber;

  DriverModel({
    required this.id,
    required this.driverId,
    required this.name,
    required this.phoneNumber,
  });

  factory DriverModel.fromJson(Map<String, dynamic> json) {
    return DriverModel(
      id: json['id'],
      driverId: json['driver_id'],
      name: json['name'] ?? '',
      phoneNumber: json['phone_number'] ?? '',
    );
  }
}

// ── Login response ────────────────────────────────────────────────────────────
class LoginResponse {
  final String message;
  final String accessToken;
  final String refreshToken;
 
  LoginResponse({
    required this.message,
    required this.accessToken,
    required this.refreshToken,
  });
 
  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      message:      json['message']  as String? ?? '',
      accessToken:  json['access']   as String? ?? '',
      refreshToken: json['refresh']  as String? ?? '',
    );
  }
}