class Product {
  final String name;
  final String description;
  final String uid;
  Product({required this.name, required this.description, this.uid = ''});

  factory Product.fromRTDB(Map<String, dynamic> data) {
    return Product(
        name: data["name"] ?? 'null',
        description: data['description'] ?? 'null');
  }
}
