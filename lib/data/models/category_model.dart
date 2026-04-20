class CategoryModel {
  final String id;
  final String name;
  final String iconName;
  final String color;

  const CategoryModel({
    required this.id,
    required this.name,
    required this.iconName,
    required this.color,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      iconName: json['iconName'] as String? ?? 'place',
      color: json['color'] as String? ?? 'grey',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'iconName': iconName,
      'color': color,
    };
  }

  Map<String, dynamic> toMap() => toJson();

  factory CategoryModel.fromMap(Map<String, dynamic> map) =>
      CategoryModel.fromJson(map);

  CategoryModel copyWith({
    String? id,
    String? name,
    String? iconName,
    String? color,
  }) {
    return CategoryModel(
      id: id ?? this.id,
      name: name ?? this.name,
      iconName: iconName ?? this.iconName,
      color: color ?? this.color,
    );
  }
}
