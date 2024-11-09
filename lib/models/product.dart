class Product {
  final String id;
  final String name;
  final String brand;
  final int quantity;
  final String description;

  Product({
    required this.id,
    required this.name,
    required this.brand,
    required this.quantity,
    required this.description,
  });

  // From Firestore JSON format to Product object
  static Product fromJson(dynamic data) {
    final jsonData = data as Map<String, dynamic>;
    var fields = jsonData['fields'];
    String name = fields['name']?['stringValue'] ?? 'Unknown';
    int quantity =
        int.tryParse(fields['quantity']?['integerValue'].toString() ?? '0') ??
            0;
    String brand = fields['brand']?['stringValue'] ?? 'Unknown';
    String description =
        fields['description']?['stringValue'] ?? 'No description';
    String id =
        jsonData['name'].split('/').last; // Extract document ID from the path

    return Product(
      id: id,
      name: name,
      brand: brand,
      quantity: quantity,
      description: description,
    );
  }

  // Convert Product object to Map (for Firestore data sending)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'brand': brand,
      'quantity': quantity,
      'description': description,
    };
  }
}
