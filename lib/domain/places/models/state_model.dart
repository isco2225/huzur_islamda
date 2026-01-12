class StateModel {
  const StateModel({required this.id, required this.name});
  final String id;
  final String name;

  factory StateModel.fromJson(Map<String, Object?> json) {
    return StateModel(id: json['_id'] as String, name: json['name'] as String);
  }
}
