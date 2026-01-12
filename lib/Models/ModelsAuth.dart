class Modelsauth {
  final String domain;
  final String username;
  final dynamic data;

  Modelsauth({
    required this.domain,
    required this.username,
    required this.data,
  });

  Map<String, dynamic> toMap() {
    return {
      'domain': domain,
      'username': username,
      'data': data,
    };
  }
}
