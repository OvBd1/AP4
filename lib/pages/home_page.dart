import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _isLoading = true;
  int _totalProducts = 0;
  int _lowStockAlerts = 0;
  int _pendingOrders = 0;
  int _expiringProducts = 0;
  List<Map<String, dynamic>> _lowStockItems = [];
  Map<String, double> _stockByCategory = {};

  // API base URL
  final String apiBaseUrl = "http://localhost:3000";

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  // API call helper method
  Future<dynamic> _fetchFromApi(String endpoint) async {
    try {
      final response = await http.get(
        Uri.parse('$apiBaseUrl$endpoint'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to load data: ${response.statusCode}');
      }
    } catch (e) {
      print('API Error: $e');
      throw e;
    }
  }

  Future<void> _loadDashboardData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Fetch dashboard summary data
      final summaryData = await _fetchFromApi('/api/dashboard/summary');
      
      // Fetch low stock items
      final lowStockData = await _fetchFromApi('/api/products/low-stock');
      
      // Fetch stock by category for the pie chart
      final categoryData = await _fetchFromApi(/*Categorie route dans l'api*/"");
      
      setState(() {
        _totalProducts = summaryData['totalProducts'] ?? 0;
        _lowStockAlerts = summaryData['lowStockAlerts'] ?? 0;
        _pendingOrders = summaryData['pendingOrders'] ?? 0;
        _expiringProducts = summaryData['expiringProducts'] ?? 0;
        
        _lowStockItems = List<Map<String, dynamic>>.from(lowStockData ?? []);
        
        _stockByCategory = Map<String, double>.from(categoryData ?? {});
        
        _isLoading = false;
      });
    } catch (e) {
      // For demo purposes, set some sample data if API fails
      setState(() {
        _totalProducts = 1205;
        _lowStockAlerts = 8;
        _pendingOrders = 12;
        _expiringProducts = 15;
        
        _lowStockItems = [
          {'name': 'Doliprane 1000mg', 'quantity': 5, 'threshold': 20},
          {'name': 'Amoxicilline 500mg', 'quantity': 8, 'threshold': 25},
          {'name': 'Ventoline 100μg', 'quantity': 3, 'threshold': 15},
        ];
        
        _stockByCategory = {
          'Analgésiques': 35.0,
          'Antibiotiques': 25.0,
          'Anti-inflammatoires': 15.0,
          'Antihistaminiques': 10.0,
          'Autres': 15.0,
        };
        
        _isLoading = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erreur lors du chargement des données')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('GSB Stock', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF4F4CD2),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadDashboardData,
          ),
          IconButton(
            icon: const Icon(Icons.notifications, color: Colors.white),
            onPressed: () {
              // Navigate to notifications
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Tableau de bord',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF4F4CD2),
                      ),
                    ),
                    const SizedBox(height: 20),
                    
                    // Summary cards
                    GridView.count(
                      crossAxisCount: 2,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        _buildSummaryCard(
                          'Stock',
                          _totalProducts.toString(),
                          'produits',
                          Icons.inventory,
                          Colors.blue,
                        ),
                        _buildSummaryCard(
                          'Alertes',
                          _lowStockAlerts.toString(),
                          'produits',
                          Icons.warning,
                          Colors.orange,
                        ),
                        _buildSummaryCard(
                          'Commandes',
                          _pendingOrders.toString(),
                          'en cours',
                          Icons.shopping_cart,
                          Colors.green,
                        ),
                        _buildSummaryCard(
                          'Péremption',
                          _expiringProducts.toString(),
                          'produits',
                          Icons.event_busy,
                          Colors.red,
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Stock distribution chart
                    if (_stockByCategory.isNotEmpty) ...[
                      const Text(
                        'Répartition des stocks',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF4F4CD2),
                        ),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        height: 200,
                        child: PieChart(
                          PieChartData(
                            sections: _buildPieChartSections(),
                            centerSpaceRadius: 40,
                            sectionsSpace: 2,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8.0,
                        runSpacing: 8.0,
                        children: _buildLegendItems(),
                      ),
                    ],
                    
                    const SizedBox(height: 20),
                    
                    // Quick action buttons
                    const Text(
                      'Actions rapides',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF4F4CD2),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildActionButton(
                          Icons.qr_code_scanner,
                          'Scanner',
                          () {
                            // Scanner action
                          },
                        ),
                        _buildActionButton(
                          Icons.check_circle,
                          'Valider',
                          () {
                            // Validate action
                          },
                        ),
                        _buildActionButton(
                          Icons.add_circle,
                          'Ajouter',
                          () {
                            // Add product action
                          },
                        ),
                        _buildActionButton(
                          Icons.bar_chart,
                          'Rapport',
                          () {
                            // Generate report action
                          },
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Low stock alerts
                    const Text(
                      'Stocks critiques',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF4F4CD2),
                      ),
                    ),
                    const SizedBox(height: 10),
                    ..._lowStockItems.map((item) => _buildLowStockItem(item)),
                  ],
                ),
              ),
            ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: 0,
        selectedItemColor: const Color(0xFF4F4CD2),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Accueil',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.inventory),
            label: 'Produits',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment),
            label: 'Commandes',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
        onTap: (index) {
          // Handle navigation
        },
      ),
    );
  }

  Widget _buildSummaryCard(
    String title,
    String value,
    String subtitle,
    IconData icon,
    Color color,
  ) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              '$title\n$subtitle',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<PieChartSectionData> _buildPieChartSections() {
    final List<Color> colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.red,
      Colors.teal,
      Colors.amber,
    ];
    
    int i = 0;
    return _stockByCategory.entries.map((entry) {
      final color = colors[i % colors.length];
      i++;
      return PieChartSectionData(
        color: color,
        value: entry.value,
        title: '',
        radius: 50,
        titleStyle: const TextStyle(
          fontSize: 0,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();
  }

  List<Widget> _buildLegendItems() {
    final List<Color> colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.red,
      Colors.teal,
      Colors.amber,
    ];
    
    int i = 0;
    return _stockByCategory.entries.map((entry) {
      final color = colors[i % colors.length];
      i++;
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 16,
              height: 16,
              color: color,
            ),
            const SizedBox(width: 4),
            Text(
              '${entry.key} (${entry.value.toInt()}%)',
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
      );
    }).toList();
  }

  Widget _buildActionButton(IconData icon, String label, VoidCallback onPressed) {
    return InkWell(
      onTap: onPressed,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF4F4CD2).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: const Color(0xFF4F4CD2), size: 28),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[800],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLowStockItem(Map<String, dynamic> item) {
    final double percentage = (item['quantity'] / item['threshold']) * 100;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            Icon(
              Icons.warning,
              color: percentage < 20 ? Colors.red : Colors.orange,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item['name'],
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  LinearProgressIndicator(
                    value: percentage / 100,
                    backgroundColor: Colors.grey[200],
                    valueColor: AlwaysStoppedAnimation<Color>(
                      percentage < 20 ? Colors.red : Colors.orange,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${item['quantity']} unités restantes (seuil: ${item['threshold']})',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.shopping_cart, color: Color(0xFF4F4CD2)),
              onPressed: () {
                // Commander ce produit
              },
            ),
          ],
        ),
      ),
    );
  }
}