import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:inventory_flutter/models/product.dart';

class InventoryProvider extends ChangeNotifier {
  late Dio _dio;
  bool _isLoading = false;

  // Change the type to List<Product> to store Firestore data
  List<Product> _inventory = [];

  List<Product> get inventory => _inventory;
  bool get isLoading => _isLoading;

  // Initialize Dio instance
  InventoryProvider() {
    _dio = Dio();
  }

  // Fetch inventory data from Firestore
  Future<void> getInventoryData() async {
    _isLoading = true;
    final String projectId = dotenv.env['FIREBASE_PROJECT_ID']!;
    final String collectionName = 'Inventory';

    try {
      final response = await _dio.get(
        'https://firestore.googleapis.com/v1/projects/$projectId/databases/(default)/documents/$collectionName',
      );

      if (response.statusCode == 200) {
        // Convert the Firestore response to a list of Product objects
        _inventory = (response.data['documents'] as List)
            .map((doc) => Product.fromJson(doc))
            .toList();

        _isLoading = false;
        notifyListeners();
      } else {
        _isLoading = false;
        throw Exception('Failed to load inventory data');
      }
    } catch (e) {
      _isLoading = false;
      throw Exception('Error fetching inventory data: $e');
    }
  }

  // Function to add a new inventory item
  Future<void> addInventoryData({
    required String name,
    required int quantity,
    required String brand,
    required String description,
  }) async {
    final String projectId = dotenv.env['FIREBASE_PROJECT_ID']!;
    final String collectionName = 'Inventory';

    try {
      // Prepare the data for the new document
      final Map<String, dynamic> newItem = {
        'name': {'stringValue': name},
        'quantity': {'integerValue': quantity},
        'brand': {'stringValue': brand},
        'description': {'stringValue': description},
      };

      // Send the POST request to Firestore to create a new document
      final response = await _dio.post(
        'https://firestore.googleapis.com/v1/projects/$projectId/databases/(default)/documents/$collectionName',
        data: {
          'fields': newItem,
        },
      );

      if (response.statusCode == 200) {
        // If the item is added successfully, create a Product and add it to the local list
        final newProduct = Product(
          id: response.data['name'].split('/').last, // Extract document ID
          name: name,
          quantity: quantity,
          brand: brand,
          description: description,
        );

        _inventory.add(newProduct);
        notifyListeners();
      } else {
        throw Exception('Failed to add inventory data');
      }
    } catch (e) {
      throw Exception('Error adding inventory data: $e');
    }
  }

  // Function to delete an inventory item
  Future<void> deleteInventoryData(String documentId) async {
    final String projectId = dotenv.env['FIREBASE_PROJECT_ID']!;
    final String collectionName = 'Inventory';

    try {
      // Send the DELETE request to Firestore to remove the document
      final response = await _dio.delete(
        'https://firestore.googleapis.com/v1/projects/$projectId/databases/(default)/documents/$collectionName/$documentId',
      );

      if (response.statusCode == 200) {
        // If deletion is successful, remove the item from the local inventory list
        _inventory.removeWhere((product) => product.id == documentId);
        notifyListeners();
      } else {
        throw Exception('Failed to delete inventory data');
      }
    } catch (e) {
      throw Exception('Error deleting inventory data: $e');
    }
  }

  // Function to update an inventory item
  Future<void> updateInventoryData({
    required String id,
    required String name,
    required int quantity,
    required String brand,
    required String description,
  }) async {
    final String projectId = dotenv.env['FIREBASE_PROJECT_ID']!;
    final String collectionName = 'Inventory';

    try {
      // Prepare the data to update
      final Map<String, dynamic> updatedItem = {
        'name': {'stringValue': name},
        'quantity': {'integerValue': quantity},
        'brand': {'stringValue': brand},
        'description': {'stringValue': description},
      };

      // Send the PATCH request to Firestore to update the document
      final response = await _dio.patch(
        'https://firestore.googleapis.com/v1/projects/$projectId/databases/(default)/documents/$collectionName/$id',
        data: {
          'fields': updatedItem,
        },
      );

      if (response.statusCode == 200) {
        // Find the product in the local list and update it
        final index = _inventory.indexWhere((product) => product.id == id);
        if (index != -1) {
          _inventory[index] = Product(
            id: id,
            name: name,
            quantity: quantity,
            brand: brand,
            description: description,
          );
          notifyListeners();
        }
      } else {
        throw Exception('Failed to update inventory data');
      }
    } catch (e) {
      throw Exception('Error updating inventory data: $e');
    }
  }
}
