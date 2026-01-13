class Group {
  final String id;
  final String name;
  final List<String> members;

  Group({required this.id, required this.name, required this.members});

  Map<String, dynamic> toMap() {
    return {'name': name, 'members': members};
  }
}
