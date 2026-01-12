class District {
  const District({required this.id, required this.name});
  final String id;
  final String name;

  factory District.fromJson(Map<String, Object?> json) {
    return District(id: json['_id'] as String, name: json['name'] as String);
  }
}
