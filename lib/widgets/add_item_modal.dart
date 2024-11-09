import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:inventory_flutter/models/product.dart';
import 'package:provider/provider.dart';
import 'package:inventory_flutter/provider/inventory_provider.dart';

class AddItemModal extends StatefulWidget {
  final bool isEditMode; // Flag to check if we are editing or adding
  final Product? existingItem; // Item data (used for editing)

  const AddItemModal({
    Key? key,
    this.isEditMode = false, // Default is Add mode
    this.existingItem,
  }) : super(key: key);

  @override
  _AddItemModalState createState() => _AddItemModalState();
}

class _AddItemModalState extends State<AddItemModal> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _brandController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    // If we are in edit mode, prepopulate the fields with the existing item data
    if (widget.isEditMode && widget.existingItem != null) {
      _nameController.text = widget.existingItem!.name;
      _brandController.text = widget.existingItem!.brand;
      _quantityController.text = widget.existingItem!.quantity.toString();
      _descriptionController.text = widget.existingItem!.description;
    }
  }

  // Function to handle form submission
  Future<void> _submitForm() async {
    if (_formKey.currentState?.validate() ?? false) {
      final name = _nameController.text;
      final brand = _brandController.text;
      final quantity = int.tryParse(_quantityController.text) ?? 0;
      final description = _descriptionController.text;

      try {
        if (widget.isEditMode) {
          // If editing, call the updateInventoryData method
          await context.read<InventoryProvider>().updateInventoryData(
                id: widget.existingItem!.id,
                name: name,
                brand: brand,
                quantity: quantity,
                description: description,
              );
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Inventory item updated successfully!'),
          ));
        } else {
          // If adding, call the addInventoryData method
          await context.read<InventoryProvider>().addInventoryData(
                name: name,
                brand: brand,
                quantity: quantity,
                description: description,
              );
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Inventory item added successfully!'),
          ));
        }

        Navigator.of(context).pop(); // Close the modal after success
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
              'Failed to ${widget.isEditMode ? 'update' : 'add'} inventory item: $e'),
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      title: Text(
        widget.isEditMode ? 'Edit Item' : 'Add New Item',
        style: theme.textTheme.bodyMedium,
      ),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Item Name
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                  labelText: 'Item Name',
                  labelStyle: theme.textTheme.labelSmall),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter item name';
                }
                return null;
              },
            ),
            // Item Brand
            TextFormField(
              controller: _brandController,
              decoration: InputDecoration(
                  labelText: 'Brand', labelStyle: theme.textTheme.labelSmall),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter brand';
                }
                return null;
              },
            ),
            // Item Quantity
            TextFormField(
              controller: _quantityController,
              decoration: InputDecoration(
                  labelText: 'Quantity',
                  labelStyle: theme.textTheme.labelSmall),
              keyboardType: TextInputType.number,
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.digitsOnly
              ],
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter quantity';
                }
                if (int.tryParse(value) == null) {
                  return 'Quantity must be a number';
                }
                return null;
              },
            ),
            // Item Description
            TextFormField(
              controller: _descriptionController,
              decoration: InputDecoration(
                  labelText: 'Description',
                  labelStyle: theme.textTheme.labelSmall),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter description';
                }
                return null;
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(), // Close modal
          child: Text('Cancel', style: theme.textTheme.bodyMedium),
        ),
        ElevatedButton(
          onPressed: _submitForm,
          child: Text(widget.isEditMode ? 'Update Item' : 'Add Item',
              style: theme.textTheme.bodyMedium),
        ),
      ],
    );
  }
}
