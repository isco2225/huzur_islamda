class Country {
  const Country({required this.id, required this.name, required this.code});
  final String id;
  final String name;
  final String code;

  factory Country.fromJson(Map<String, Object?> json) {
    return Country(
      id: json['id'] as String,
      name: json['name'] as String,
      code: json['code'] as String,
    );
  }
}
