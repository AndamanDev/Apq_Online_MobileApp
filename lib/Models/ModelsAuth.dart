class Modelsauth {
  final String domain;
  final String username;
  final dynamic data;
  final String node;

  Modelsauth({
    required this.domain,
    required this.username,
    required this.data,
    required this.node,
  });

  Map<String, dynamic> toMap() {
    return {
      'domain': domain,
      'username': username,
      'data': data,
      'node': node,
    };
  }

  Modelsauth copyWith({
    String? domain,
    String? username,
    dynamic data,
    String? node,
  }) {
    return Modelsauth(
      domain: domain ?? this.domain,
      username: username ?? this.username,
      data: data ?? this.data,
      node: node ?? this.node,
    );
  }

}
