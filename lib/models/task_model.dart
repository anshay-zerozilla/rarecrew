class Task {
  final String id;
  final String title;
  final String description;
  final String ownerId;
  final List<String> sharedWith;

  Task({
    required this.id,
    required this.title,
    required this.description,
    required this.ownerId,
    List<String>? sharedWith,
  }) : sharedWith = sharedWith ?? [];

  factory Task.fromMap(String id, Map<String, dynamic> map) {
    return Task(
      id: id,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      ownerId: map['ownerId'] ?? '',
      sharedWith: List<String>.from(map['sharedWith'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'ownerId': ownerId,
      'sharedWith': sharedWith,
    };
  }

  bool isSharedWithCurrentUser(String currentUserId) {
    return sharedWith.contains(currentUserId);
  }
}
