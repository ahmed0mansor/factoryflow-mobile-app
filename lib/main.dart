import 'package:flutter/material.dart';

void main() {
  runApp(const FactoryFlowApp());
}

class FactoryFlowApp extends StatelessWidget {
  const FactoryFlowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'FactoryFlow Mobile',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFF00695C),
        scaffoldBackgroundColor: const Color(0xFFF4F7F6),
      ),
      home: const FactoryHome(),
    );
  }
}

class FactoryHome extends StatefulWidget {
  const FactoryHome({super.key});

  @override
  State<FactoryHome> createState() => _FactoryHomeState();
}

class _FactoryHomeState extends State<FactoryHome> {
  int _pageIndex = 0;

  final List<InventoryItem> _items = [
    InventoryItem(name: 'Cotton Rolls', category: 'Raw Materials', stock: 48, minimumStock: 20, unit: 'roll'),
    InventoryItem(name: 'Packing Boxes', category: 'Packaging', stock: 12, minimumStock: 30, unit: 'box'),
    InventoryItem(name: 'Blue T-Shirts', category: 'Finished Goods', stock: 86, minimumStock: 25, unit: 'pcs'),
    InventoryItem(name: 'Button Sets', category: 'Accessories', stock: 7, minimumStock: 15, unit: 'pack'),
  ];

  final List<Employee> _employees = [
    Employee(name: 'Ahmed Ali', role: 'Inventory Officer', present: true),
    Employee(name: 'Sara Mohammed', role: 'HR Assistant', present: true),
    Employee(name: 'Khaled Hassan', role: 'Accountant', present: false),
    Employee(name: 'Mona Saleh', role: 'Operations', present: true),
  ];

  final List<StockMovement> _movements = [
    StockMovement(item: 'Blue T-Shirts', type: 'Stock In', quantity: 40, note: 'New production batch'),
    StockMovement(item: 'Packing Boxes', type: 'Stock Out', quantity: 18, note: 'Used for delivery'),
  ];

  @override
  Widget build(BuildContext context) {
    final pages = [
      _DashboardPage(items: _items, employees: _employees, movements: _movements),
      _InventoryPage(items: _items, onUpdate: () => setState(() {})),
      _AttendancePage(employees: _employees, onUpdate: () => setState(() {})),
      _MovementsPage(items: _items, movements: _movements, onAdd: _addMovement),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('FactoryFlow Mobile'),
        actions: [
          IconButton(
            tooltip: 'About',
            onPressed: () => showAboutDialog(
              context: context,
              applicationName: 'FactoryFlow Mobile',
              applicationVersion: '1.0.0',
              applicationLegalese: 'Portfolio demo for small factory operations.',
            ),
            icon: const Icon(Icons.info_outline),
          ),
        ],
      ),
      body: pages[_pageIndex],
      floatingActionButton: _pageIndex == 1
          ? FloatingActionButton.extended(
              onPressed: _showAddItemSheet,
              icon: const Icon(Icons.add),
              label: const Text('Item'),
            )
          : null,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _pageIndex,
        onDestinationSelected: (index) => setState(() => _pageIndex = index),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.dashboard_outlined), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.inventory_2_outlined), label: 'Inventory'),
          NavigationDestination(icon: Icon(Icons.badge_outlined), label: 'Staff'),
          NavigationDestination(icon: Icon(Icons.swap_vert_circle_outlined), label: 'Logs'),
        ],
      ),
    );
  }

  void _addMovement(StockMovement movement) {
    setState(() => _movements.insert(0, movement));
  }

  void _showAddItemSheet() {
    final name = TextEditingController();
    final category = TextEditingController(text: 'General');
    final stock = TextEditingController(text: '10');
    final minimum = TextEditingController(text: '5');
    final unit = TextEditingController(text: 'pcs');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          left: 18,
          right: 18,
          top: 18,
          bottom: MediaQuery.of(context).viewInsets.bottom + 18,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Add inventory item', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
            const SizedBox(height: 12),
            TextField(controller: name, decoration: const InputDecoration(labelText: 'Item name')),
            TextField(controller: category, decoration: const InputDecoration(labelText: 'Category')),
            TextField(controller: stock, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Current stock')),
            TextField(controller: minimum, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Minimum stock')),
            TextField(controller: unit, decoration: const InputDecoration(labelText: 'Unit')),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () {
                  final parsedStock = int.tryParse(stock.text.trim());
                  final parsedMinimum = int.tryParse(minimum.text.trim());
                  if (name.text.trim().isEmpty || parsedStock == null || parsedMinimum == null) return;
                  setState(() {
                    _items.insert(
                      0,
                      InventoryItem(
                        name: name.text.trim(),
                        category: category.text.trim(),
                        stock: parsedStock,
                        minimumStock: parsedMinimum,
                        unit: unit.text.trim().isEmpty ? 'pcs' : unit.text.trim(),
                      ),
                    );
                  });
                  Navigator.pop(context);
                },
                child: const Text('Save item'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class InventoryItem {
  InventoryItem({required this.name, required this.category, required this.stock, required this.minimumStock, required this.unit});

  final String name;
  final String category;
  int stock;
  final int minimumStock;
  final String unit;

  bool get isLow => stock <= minimumStock;
}

class Employee {
  Employee({required this.name, required this.role, required this.present});

  final String name;
  final String role;
  bool present;
}

class StockMovement {
  StockMovement({required this.item, required this.type, required this.quantity, required this.note}) : createdAt = DateTime.now();

  final String item;
  final String type;
  final int quantity;
  final String note;
  final DateTime createdAt;

  String get timeLabel {
    final hour = createdAt.hour.toString().padLeft(2, '0');
    final minute = createdAt.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}

class _DashboardPage extends StatelessWidget {
  const _DashboardPage({required this.items, required this.employees, required this.movements});

  final List<InventoryItem> items;
  final List<Employee> employees;
  final List<StockMovement> movements;

  @override
  Widget build(BuildContext context) {
    final lowStock = items.where((item) => item.isLow).length;
    final presentStaff = employees.where((employee) => employee.present).length;

    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: const Color(0xFF004D40),
            borderRadius: BorderRadius.circular(26),
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.factory_outlined, color: Colors.white, size: 38),
              SizedBox(height: 14),
              Text('Small Factory Operations', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900)),
              SizedBox(height: 8),
              Text('Track inventory, staff attendance, and daily stock movements from a mobile dashboard.', style: TextStyle(color: Colors.white70, height: 1.5)),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: _StatCard(title: 'Items', value: '${items.length}', icon: Icons.inventory_2_outlined)),
            const SizedBox(width: 12),
            Expanded(child: _StatCard(title: 'Low stock', value: '$lowStock', icon: Icons.warning_amber_outlined)),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _StatCard(title: 'Present', value: '$presentStaff/${employees.length}', icon: Icons.people_outline)),
            const SizedBox(width: 12),
            Expanded(child: _StatCard(title: 'Logs', value: '${movements.length}', icon: Icons.receipt_long_outlined)),
          ],
        ),
        const SizedBox(height: 18),
        const Text('Critical stock alerts', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
        const SizedBox(height: 8),
        ...items.where((item) => item.isLow).map((item) => _InventoryTile(item: item)),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.title, required this.value, required this.icon});

  final String title;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 14),
            Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
            Text(title, style: const TextStyle(color: Colors.black54)),
          ],
        ),
      ),
    );
  }
}

class _InventoryPage extends StatelessWidget {
  const _InventoryPage({required this.items, required this.onUpdate});

  final List<InventoryItem> items;
  final VoidCallback onUpdate;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        const Text('Inventory', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
        const SizedBox(height: 12),
        ...items.map((item) => _InventoryTile(item: item, onUpdate: onUpdate)),
      ],
    );
  }
}

class _InventoryTile extends StatelessWidget {
  const _InventoryTile({required this.item, this.onUpdate});

  final InventoryItem item;
  final VoidCallback? onUpdate;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: item.isLow ? const Color(0xFFFFEBEE) : const Color(0xFFE8F5E9),
              child: Icon(item.isLow ? Icons.priority_high : Icons.check, color: item.isLow ? Colors.red : Colors.green),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.name, style: const TextStyle(fontWeight: FontWeight.w900)),
                  Text('${item.category} • minimum ${item.minimumStock} ${item.unit}', style: const TextStyle(color: Colors.black54)),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('${item.stock}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
                Text(item.unit),
              ],
            ),
            if (onUpdate != null) ...[
              const SizedBox(width: 8),
              IconButton(
                onPressed: () {
                  item.stock += 1;
                  onUpdate!();
                },
                icon: const Icon(Icons.add_circle_outline),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _AttendancePage extends StatelessWidget {
  const _AttendancePage({required this.employees, required this.onUpdate});

  final List<Employee> employees;
  final VoidCallback onUpdate;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        const Text('Staff Attendance', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
        const SizedBox(height: 12),
        ...employees.map(
          (employee) => Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: SwitchListTile(
              value: employee.present,
              onChanged: (value) {
                employee.present = value;
                onUpdate();
              },
              title: Text(employee.name, style: const TextStyle(fontWeight: FontWeight.w800)),
              subtitle: Text(employee.role),
              secondary: CircleAvatar(
                child: Text(employee.name.substring(0, 1)),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _MovementsPage extends StatefulWidget {
  const _MovementsPage({required this.items, required this.movements, required this.onAdd});

  final List<InventoryItem> items;
  final List<StockMovement> movements;
  final ValueChanged<StockMovement> onAdd;

  @override
  State<_MovementsPage> createState() => _MovementsPageState();
}

class _MovementsPageState extends State<_MovementsPage> {
  String? _selectedItem;
  String _selectedType = 'Stock In';
  final _quantityController = TextEditingController(text: '5');
  final _noteController = TextEditingController(text: 'Manual entry from mobile app');

  @override
  void dispose() {
    _quantityController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _selectedItem ??= widget.items.isNotEmpty ? widget.items.first.name : null;

    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        const Text('Stock Movements', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                DropdownButtonFormField<String>(
                  value: _selectedItem,
                  items: widget.items.map((item) => DropdownMenuItem(value: item.name, child: Text(item.name))).toList(),
                  onChanged: (value) => setState(() => _selectedItem = value),
                  decoration: const InputDecoration(labelText: 'Item'),
                ),
                const SizedBox(height: 12),
                SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(value: 'Stock In', label: Text('Stock In')),
                    ButtonSegment(value: 'Stock Out', label: Text('Stock Out')),
                  ],
                  selected: {_selectedType},
                  onSelectionChanged: (values) => setState(() => _selectedType = values.first),
                ),
                const SizedBox(height: 12),
                TextField(controller: _quantityController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Quantity')),
                TextField(controller: _noteController, decoration: const InputDecoration(labelText: 'Note')),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: _saveMovement,
                    icon: const Icon(Icons.save_outlined),
                    label: const Text('Save movement'),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        ...widget.movements.map((movement) => Card(
              margin: const EdgeInsets.only(bottom: 10),
              child: ListTile(
                leading: Icon(movement.type == 'Stock In' ? Icons.call_received : Icons.call_made),
                title: Text('${movement.type}: ${movement.item}', style: const TextStyle(fontWeight: FontWeight.w800)),
                subtitle: Text('${movement.quantity} units • ${movement.note}'),
                trailing: Text(movement.timeLabel),
              ),
            )),
      ],
    );
  }

  void _saveMovement() {
    final quantity = int.tryParse(_quantityController.text.trim());
    if (_selectedItem == null || quantity == null) return;

    final target = widget.items.firstWhere((item) => item.name == _selectedItem);
    if (_selectedType == 'Stock In') {
      target.stock += quantity;
    } else {
      target.stock = (target.stock - quantity).clamp(0, 999999).toInt();
    }

    widget.onAdd(StockMovement(item: _selectedItem!, type: _selectedType, quantity: quantity, note: _noteController.text.trim()));
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Movement saved')));
  }
}
