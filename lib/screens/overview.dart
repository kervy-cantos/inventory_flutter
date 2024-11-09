import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:inventory_flutter/models/product.dart';
import 'package:inventory_flutter/provider/inventory_provider.dart';
import 'package:inventory_flutter/utils/helpers.dart';
import 'package:inventory_flutter/widgets/add_item_modal.dart';
import 'package:inventory_flutter/widgets/drawer.dart';
import 'package:provider/provider.dart';

class Overview extends StatefulWidget {
  const Overview({super.key});

  @override
  OverviewState createState() => OverviewState();
}

class OverviewState extends State<Overview> {
  bool _isLoading = true;
  bool isHovered = false;
  List<Product> _inventoryData = [];
  List<Product> _filteredInventoryData = [];
  TextEditingController _searchController = TextEditingController();
  Map<String, bool> _sortDirection = {
    'brand': true,
    'name': true,
    'quantity': true,
    'description': true,
  };

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isLoading) {
      _fetchInventoryData();
    }
  }

  Future<void> _fetchInventoryData() async {
    try {
      // Call getInventoryData to trigger data fetch and update the provider's state
      await context.read<InventoryProvider>().getInventoryData();

      // After the data is fetched and state is updated, retrieve the updated inventory list
      setState(() {
        // Get the updated inventory list from the provider
        _inventoryData = context.read<InventoryProvider>().inventory;
        _filteredInventoryData = _inventoryData;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print('Error fetching inventory data: $e');
    }
  }

  void _filterInventory(String query) {
    final filteredData = _inventoryData.where((item) {
      final name = item.name.toLowerCase();
      final brand = item.brand.toLowerCase();
      final searchQuery = query.toLowerCase();
      return name.contains(searchQuery) || brand.contains(searchQuery);
    }).toList();

    setState(() {
      _filteredInventoryData = filteredData;
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final theme = Theme.of(context);
    InventoryProvider inventoryProvider =
        Provider.of<InventoryProvider>(context);

    bool isLoading = inventoryProvider.isLoading;

    if (user == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.go('/');
      });
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.primaryColorLight,
        title: Row(
          children: [
            Text('Welcome, ${user?.email}'),
            const Spacer(),
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () async {
                bool? shouldLogout = await showLogoutDialog(context);
                if (shouldLogout ?? false) {
                  await FirebaseAuth.instance.signOut();
                  context.go('/');
                }
              },
            ),
          ],
        ),
      ),
      drawer: const CustomDrawer(),
      body: Center(
        child: isLoading
            ? const CircularProgressIndicator()
            : Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 1000,
                    child: _buildInventoryTable(),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildInventoryTable() {
    final theme = Theme.of(context);

    return Column(
      children: [
        // Row for the Search bar and Add Item button (Outside the table)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            children: [
              SizedBox(
                width: 200,
                child: TextField(
                  controller: _searchController,
                  onChanged: _filterInventory,
                  decoration: InputDecoration(
                    labelText: 'Search Inventory',
                    labelStyle: theme.textTheme.bodyMedium,
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(16), // Rounded corners
                    ),
                  ),
                ),
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: () {
                  showDialog(
                      context: context, builder: (context) => AddItemModal());
                },
                child: Text('Add Item'),
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16), // Rounded corners
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Check if filtered data is available
        _filteredInventoryData.isEmpty
            ? const Center(child: Text('No inventory data available.'))
            : ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: SizedBox(
                  width: 1000,
                  height: 600,
                  child: Theme(
                    data: ThemeData(textTheme: TextTheme()),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: Consumer<InventoryProvider>(
                        builder: (context, inventoryProvider, child) {
                          return PaginatedDataTable(
                            arrowHeadColor: Colors.black,
                            headingRowColor:
                                MaterialStateProperty.all(theme.primaryColor),
                            rowsPerPage: _rowsPerPage,
                            availableRowsPerPage: const [5, 10, 20],
                            onRowsPerPageChanged: (rowCount) {
                              setState(() {
                                if (rowCount != null) {
                                  _rowsPerPage = rowCount;
                                }
                              });
                            },
                            columns: [
                              DataColumn(
                                label: Text(
                                  'Brand',
                                  style: theme.textTheme.headlineSmall,
                                ),
                                onSort: (columnIndex, _) {
                                  _sortData('brand');
                                },
                              ),
                              DataColumn(
                                label: Text(
                                  'Name',
                                  style: theme.textTheme.headlineSmall,
                                ),
                                onSort: (columnIndex, _) {
                                  _sortData('name');
                                },
                              ),
                              DataColumn(
                                label: Text(
                                  'Quantity',
                                  style: theme.textTheme.headlineSmall,
                                ),
                                onSort: (columnIndex, _) {
                                  _sortData('quantity');
                                },
                              ),
                              DataColumn(
                                label: Text(
                                  'Description',
                                  style: theme.textTheme.headlineSmall,
                                ),
                                onSort: (columnIndex, _) {
                                  _sortData('description');
                                },
                              ),
                              DataColumn(
                                label: Text(
                                  'Actions',
                                  style: theme.textTheme.headlineSmall,
                                ),
                              ),
                            ],
                            source: InventoryDataSource(
                                _filteredInventoryData, context),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
      ],
    );
  }

  int _rowsPerPage = 10;

  void _sortData(String columnName) {
    setState(() {
      _sortDirection[columnName] = !_sortDirection[columnName]!;

      if (columnName == 'brand') {
        _filteredInventoryData.sort((a, b) => _sortDirection[columnName]!
            ? a.brand.compareTo(b.brand)
            : b.brand.compareTo(a.brand));
      } else if (columnName == 'name') {
        _filteredInventoryData.sort((a, b) => _sortDirection[columnName]!
            ? a.name.compareTo(b.name)
            : b.name.compareTo(a.name));
      } else if (columnName == 'quantity') {
        _filteredInventoryData.sort((a, b) => _sortDirection[columnName]!
            ? a.quantity.compareTo(b.quantity)
            : b.quantity.compareTo(a.quantity));
      } else if (columnName == 'description') {
        _filteredInventoryData.sort((a, b) => _sortDirection[columnName]!
            ? a.description.compareTo(b.description)
            : b.description.compareTo(a.description));
      }
    });
  }
}

class InventoryDataSource extends DataTableSource {
  final List<Product> _inventoryData;
  final BuildContext context;

  InventoryDataSource(this._inventoryData, this.context);

  @override
  DataRow getRow(int index) {
    final item = _inventoryData[index];

    String brand = item.brand;
    String name = item.name;
    String quantity = item.quantity.toString();
    String description = item.description;
    String id = item.id;

    // Alternating row colors (light gray and white)
    bool isEvenRow = index % 2 == 0;

    return DataRow(
      color: MaterialStateProperty.all(
          isEvenRow ? Colors.grey.shade100 : Colors.white),
      cells: [
        DataCell(Text(
          brand,
          style: Theme.of(context).textTheme.bodyMedium,
        )),
        DataCell(Text(name, style: Theme.of(context).textTheme.bodyMedium)),
        DataCell(Text(quantity, style: Theme.of(context).textTheme.bodyMedium)),
        DataCell(
            Text(description, style: Theme.of(context).textTheme.bodyMedium)),
        DataCell(
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.blue),
                onPressed: () {
                  showDialog(
                      context: context,
                      builder: (context) => AddItemModal(
                            existingItem: item,
                            isEditMode: true,
                          ));
                },
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () async {
                  await context
                      .read<InventoryProvider>()
                      .deleteInventoryData(id);
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text('Inventory item deleted successfully!'),
                  ));
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  int get rowCount => _inventoryData.length;

  @override
  bool get hasMoreRows => false;

  @override
  int get selectedRowCount => 0;

  @override
  bool get isRowCountApproximate => false;
}
