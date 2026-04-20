class Category {
  final String id;
  final String name;
  final String iconName;
  final String color;

  const Category({
    required this.id,
    required this.name,
    required this.iconName,
    required this.color,
  });

  Category copyWith({
    String? id,
    String? name,
    String? iconName,
    String? color,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      iconName: iconName ?? this.iconName,
      color: color ?? this.color,
    );
  }
}
