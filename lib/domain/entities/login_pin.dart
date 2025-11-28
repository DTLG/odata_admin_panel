import 'package:latlong2/latlong.dart' as latlng;

class LoginPin {
  final latlng.LatLng point;
  final String agentGuid;
  final String deviceUuid;
  final DateTime createdAt;

  LoginPin({
    required this.point,
    required this.agentGuid,
    required this.deviceUuid,
    required this.createdAt,
  });

  factory LoginPin.fromJson(Map<String, dynamic> json) {
    return LoginPin(
      point: latlng.LatLng(json['lat'] as double, json['lng'] as double),
      agentGuid: json['agent_guid'] as String,
      deviceUuid: json['device_uuid'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}
