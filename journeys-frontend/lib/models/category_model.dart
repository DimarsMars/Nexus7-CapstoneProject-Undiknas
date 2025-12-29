class CategoryModel {
  final int id;
  final String name;
  final String imageBase64;

  CategoryModel({
    required this.id,
    required this.name,
    required this.imageBase64,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['category_id'],
      name: json['name'],
      imageBase64: json['image'],
    );
  }
}
