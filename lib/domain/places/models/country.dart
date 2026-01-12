class Country {
  const Country({required this.id, required this.name});
  final String id;
  final String name;

  factory Country.fromJson(Map<String, Object?> json) {
    return Country(id: json['_id'] as String, name: json['name'] as String);
  }
}
