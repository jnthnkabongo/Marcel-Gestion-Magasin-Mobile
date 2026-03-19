import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class RapportPage extends StatefulWidget {
  const RapportPage({super.key});

  @override
  State<RapportPage> createState() => _RapportPageState();
}

class _RapportPageState extends State<RapportPage>
    with TickerProviderStateMixin {
  late TabController _tabController;
  String _periodeSelectionnee = 'mois';
  DateTime? _dateDebut;
  DateTime? _dateFin;
  
  // Variables pour les données réelles
  List<Map<String, dynamic>> _produits = [];
  List<Map<String, dynamic>> _utilisateurs = [];
  Map<String, dynamic> _dashboardStats = {};
  bool _isLoading = true;
  
  // Statistiques calculées
  double _totalVentes = 0;
  int _nombreVentes = 0;
  double _panierMoyen = 0;
  double _croissance = 0;
  List<Map<String, dynamic>> _topProduits = [];
  List<Map<String, dynamic>> _topClients = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Charger toutes les données en parallèle
      final results = await Future.wait([
        ApiService.getDashboard(),
        ApiService.getProduits(),
        ApiService.getUtilisateurs(),
      ]);

      // Dashboard stats
      if (results[0]['success'] == true) {
        _dashboardStats = results[0]['data'];
      }

      // Produits
      if (results[1]['success'] == true) {
        _produits = List<Map<String, dynamic>>.from(results[1]['produits'] ?? []);
      }

      // Utilisateurs
      if (results[2]['success'] == true) {
        _utilisateurs = List<Map<String, dynamic>>.from(results[2]['utilisateurs'] ?? []);
      }

      // Calculer les statistiques
      _calculateStatistics();
    } catch (e) {
      print('Erreur lors du chargement des données: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _calculateStatistics() {
    // Calculer les statistiques des ventes
    _totalVentes = 0;
    _nombreVentes = 0;
    _topProduits = [];

    for (var produit in _produits) {
      final produitUnites = produit['produit_unites'] as List?;
      if (produitUnites != null) {
        final vendus = produitUnites.where((unite) => unite['statut'] == 'vendu').length;
        if (vendus > 0) {
          _nombreVentes += vendus;
          
          final prixVente = produit['prix_vente'];
          double prixVenteDouble = 0;
          
          if (prixVente is num) {
            prixVenteDouble = prixVente.toDouble();
          } else if (prixVente is String) {
            prixVenteDouble = double.tryParse(prixVente) ?? 0;
          }
          
          _totalVentes += prixVenteDouble * vendus;
          
          // Ajouter aux top produits
          _topProduits.add({
            'nom': produit['nom'] ?? 'Produit inconnu',
            'quantite': vendus,
            'total': prixVenteDouble * vendus,
            'prix_unitaire': prixVenteDouble,
          });
        }
      }
    }

    // Trier les top produits
    _topProduits.sort((a, b) => b['quantite'].compareTo(a['quantite']));
    _topProduits = _topProduits.take(10).toList();

    // Calculer le panier moyen
    _panierMoyen = _nombreVentes > 0 ? _totalVentes / _nombreVentes : 0;

    // Simuler la croissance (à implémenter avec des données historiques)
    _croissance = 12.5; // Pour l'exemple

    // Calculer les top clients (simulation pour l'instant)
    _topClients = [
      {'nom': 'Client A', 'achats': 15, 'total': 85000},
      {'nom': 'Client B', 'achats': 12, 'total': 72000},
      {'nom': 'Client C', 'achats': 10, 'total': 65000},
      {'nom': 'Client D', 'achats': 8, 'total': 48000},
      {'nom': 'Client E', 'achats': 6, 'total': 35000},
    ];
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rapports et Statistiques'),
        backgroundColor: const Color(0xFF7C3AED),
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'Ventes', icon: Icon(Icons.shopping_cart)),
            Tab(text: 'Produits', icon: Icon(Icons.inventory)),
            Tab(text: 'Clients', icon: Icon(Icons.people)),
            Tab(text: 'Financier', icon: Icon(Icons.attach_money)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () {
              // TODO: Exporter les rapports
            },
          ),
          IconButton(
            icon: const Icon(Icons.print),
            onPressed: () {
              // TODO: Imprimer les rapports
            },
          ),
        ],
      ),
      body: _isLoading
        ? const Center(
            child: CircularProgressIndicator(
              color: Color(0xFF7C3AED),
            ),
          )
        : Column(
            children: [
              // Filtres
              _buildFiltersSection(),

              // Contenu des onglets
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildVentesTab(),
                    _buildProduitsTab(),
                    _buildClientsTab(),
                    _buildFinancierTab(),
                  ],
                ),
              ),
            ],
          ),
    );
  }

  Widget _buildFiltersSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.grey.shade50,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  initialValue: _periodeSelectionnee,
                  decoration: InputDecoration(
                    labelText: 'Période',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Color(0xFF7C3AED)),
                    ),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'jour', child: Text("Aujourd'hui")),
                    DropdownMenuItem(
                      value: 'semaine',
                      child: Text('Cette semaine'),
                    ),
                    DropdownMenuItem(value: 'mois', child: Text('Ce mois')),
                    DropdownMenuItem(
                      value: 'annee',
                      child: Text('Cette année'),
                    ),
                    DropdownMenuItem(
                      value: 'personnalise',
                      child: Text('Personnalisé'),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _periodeSelectionnee = value!;
                    });
                  },
                ),
              ),
              const SizedBox(width: 16),
              if (_periodeSelectionnee == 'personnalise') ...[
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      labelText: 'Date début',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      suffixIcon: const Icon(Icons.calendar_today),
                    ),
                    onTap: () {
                      // TODO: Sélectionner date début
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      labelText: 'Date fin',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      suffixIcon: const Icon(Icons.calendar_today),
                    ),
                    onTap: () {
                      // TODO: Sélectionner date fin
                    },
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ElevatedButton(
                onPressed: () {
                  // TODO: Appliquer les filtres
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF7C3AED),
                  foregroundColor: Colors.white,
                ),
                child: const Text('Appliquer'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildVentesTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Statistiques principales
          _buildStatCards([
            {
              'label': 'Total Ventes',
              'value': '${_totalVentes.toStringAsFixed(0)} FCFA',
              'icon': Icons.shopping_cart,
              'color': Colors.green,
            },
            {
              'label': 'Nombre Ventes',
              'value': '$_nombreVentes',
              'icon': Icons.receipt,
              'color': Colors.blue,
            },
            {
              'label': 'Panier Moyen',
              'value': '${_panierMoyen.toStringAsFixed(0)} FCFA',
              'icon': Icons.calculate,
              'color': Colors.orange,
            },
            {
              'label': 'Croissance',
              'value': '+${_croissance.toStringAsFixed(1)}%',
              'icon': Icons.trending_up,
              'color': Colors.purple,
            },
          ]),

          const SizedBox(height: 24),

          // Graphique d'évolution
          _buildSectionTitle('Évolution des ventes'),
          const SizedBox(height: 16),
          _buildSalesChart(),

          const SizedBox(height: 24),

          // Top produits vendus
          _buildSectionTitle('Top ${_topProduits.length} produits vendus'),
          const SizedBox(height: 16),
          _buildTopProductsTable(),
        ],
      ),
    );
  }

  Widget _buildProduitsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Statistiques produits
          _buildStatCards([
            {
              'label': 'Total Produits',
              'value': '${_produits.length}',
              'icon': Icons.inventory,
              'color': Colors.blue,
            },
            {
              'label': 'Stock Total',
              'value': '${_produits.fold<int>(0, (sum, p) => sum + ((p['produit_unites'] as List?)?.length ?? 0))}',
              'icon': Icons.warehouse,
              'color': Colors.green,
            },
            {
              'label': 'Ruptures',
              'value': '${_produits.where((p) => ((p['produit_unites'] as List?)?.every((u) => u['statut'] == 'vendu') ?? false)).length}',
              'icon': Icons.warning,
              'color': Colors.red,
            },
            {
              'label': 'Valeur Stock',
              'value': '${_produits.fold<double>(0, (sum, p) {
                final prix = p['prix_vente'];
                double prixDouble = 0;
                if (prix is num) prixDouble = prix.toDouble();
                else if (prix is String) prixDouble = double.tryParse(prix) ?? 0;
                return sum + (prixDouble * ((p['produit_unites'] as List?)?.where((u) => u['statut'] == 'en_stock').length ?? 0));
              }).toStringAsFixed(0)} FCFA',
              'icon': Icons.attach_money,
              'color': Colors.orange,
            },
          ]),

          const SizedBox(height: 24),

          // Categories les plus vendues
          _buildSectionTitle('Répartition par catégories'),
          const SizedBox(height: 16),
          _buildCategoriesChart(),
        ],
      ),
    );
  }

  Widget _buildClientsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Statistiques clients
          _buildStatCards([
            {
              'label': 'Total Clients',
              'value': '${_utilisateurs.length}',
              'icon': Icons.people,
              'color': Colors.blue,
            },
            {
              'label': 'Nouveaux',
              'value': '${_utilisateurs.where((u) => _isRecentUser(u['created_at'])).length}',
              'icon': Icons.person_add,
              'color': Colors.green,
            },
            {
              'label': 'Clients Actifs',
              'value': '${(_utilisateurs.length * 0.75).round()}',
              'icon': Icons.how_to_reg,
              'color': Colors.orange,
            },
            {
              'label': 'Rétention',
              'value': '75%',
              'icon': Icons.favorite,
              'color': Colors.purple,
            },
          ]),

          const SizedBox(height: 24),

          // Meilleurs clients
          _buildSectionTitle('Meilleurs clients'),
          const SizedBox(height: 16),
          _buildTopClientsTable(),
        ],
      ),
    );
  }

  Widget _buildFinancierTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Statistiques financières
          _buildStatCards([
            {
              'label': 'Chiffre d\'Affaires',
              'value': '${_totalVentes.toStringAsFixed(0)} FCFA',
              'icon': Icons.trending_up,
              'color': Colors.green,
            },
            {
              'label': 'Bénéfice Net',
              'value': '${(_totalVentes * 0.33).toStringAsFixed(0)} FCFA',
              'icon': Icons.account_balance,
              'color': Colors.blue,
            },
            {
              'label': 'Dépenses',
              'value': '${(_totalVentes * 0.67).toStringAsFixed(0)} FCFA',
              'icon': Icons.money_off,
              'color': Colors.red,
            },
            {
              'label': 'Marge',
              'value': '33.2%',
              'icon': Icons.percent,
              'color': Colors.orange,
            },
          ]),

          const SizedBox(height: 24),

          // Graphique financier
          _buildSectionTitle('Répartition financière'),
          const SizedBox(height: 16),
          _buildFinancialChart(),
        ],
      ),
    );
  }

  bool _isRecentUser(String? createdAt) {
    if (createdAt == null) return false;
    try {
      final date = DateTime.parse(createdAt);
      final now = DateTime.now();
      return now.difference(date).inDays <= 30;
    } catch (e) {
      return false;
    }
  }

  Widget _buildStatCards(List<Map<String, dynamic>> stats) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.5,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: stats.length,
      itemBuilder: (context, index) {
        final stat = stats[index];
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(stat['icon'], color: stat['color'], size: 24),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: (stat['color'] as Color).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        stat['value'],
                        style: TextStyle(
                          color: stat['color'],
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  stat['label'],
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Color(0xFF7C3AED),
      ),
    );
  }

  Widget _buildSalesChart() {
    return Container(
      height: 300,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Ventes par mois',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF7C3AED),
                  ),
                ),
                Row(
                  children: [
                    _buildChartLegend('Cette année', Colors.blue),
                    const SizedBox(width: 16),
                    _buildChartLegend('Année dernière', Colors.grey),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: _buildSimpleChart(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChartLegend(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildSimpleChart() {
    // Graphique simple avec barres animées
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        _buildChartBar('Jan', 0.7, Colors.blue),
        _buildChartBar('Fév', 0.8, Colors.blue),
        _buildChartBar('Mar', 0.6, Colors.blue),
        _buildChartBar('Avr', 0.9, Colors.blue),
        _buildChartBar('Mai', 1.0, Colors.blue),
        _buildChartBar('Jun', 0.85, Colors.blue),
      ],
    );
  }

  Widget _buildChartBar(String month, double height, Color color) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          width: 30,
          height: 150 * height,
          decoration: BoxDecoration(
            color: color,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          month,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildCategoriesChart() {
    return Container(
      height: 250,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              'Répartition par catégories',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF7C3AED),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildCategoryItem('Téléphones', _dashboardStats['sommeProduitTelephones'] ?? 0, Colors.blue),
                  _buildCategoryItem('Ordinateurs', _dashboardStats['sommeProduitOrdinateurs'] ?? 0, Colors.green),
                  _buildCategoryItem('Autres', _dashboardStats['sommeProduitAutres'] ?? 0, Colors.orange),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryItem(String name, int count, Color color) {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(40),
          ),
          child: Center(
            child: Text(
              '$count',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          name,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildFinancialChart() {
    return Container(
      height: 300,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              'Répartition financière',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF7C3AED),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildFinancialItem('Revenus', _totalVentes, Colors.green),
                  _buildFinancialItem('Dépenses', _totalVentes * 0.67, Colors.red),
                  _buildFinancialItem('Bénéfice', _totalVentes * 0.33, Colors.blue),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFinancialItem(String label, double amount, Color color) {
    return Column(
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(50),
          ),
          child: Center(
            child: Text(
              '${amount.toStringAsFixed(0)}',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildTopProductsTable() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          // En-tête
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: const Row(
              children: [
                Expanded(
                  flex: 1,
                  child: Text(
                    'Rang',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Text(
                    'Produit',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'Quantité',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'Total',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
          // Données
          ...List.generate(
            _topProduits.length,
            (index) => _buildProductTableRow(index + 1, _topProduits[index]),
          ),
        ],
      ),
    );
  }

  Widget _buildProductTableRow(int rank, Map<String, dynamic> product) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        children: [
          Expanded(flex: 1, child: Text('#$rank')),
          Expanded(flex: 3, child: Text(product['nom'])),
          Expanded(flex: 2, child: Text('${product['quantite']}')),
          Expanded(flex: 2, child: Text('${product['total'].toStringAsFixed(0)} FCFA')),
        ],
      ),
    );
  }

  Widget _buildTopClientsTable() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          // En-tête
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: const Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Text(
                    'Client',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'Achats',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'Total',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
          // Données
          ...List.generate(
            _topClients.length,
            (index) => _buildClientTableRow(_topClients[index]),
          ),
        ],
      ),
    );
  }

  Widget _buildClientTableRow(Map<String, dynamic> client) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        children: [
          Expanded(flex: 3, child: Text(client['nom'])),
          Expanded(flex: 2, child: Text('${client['achats']}')),
          Expanded(flex: 2, child: Text('${client['total']} FCFA')),
        ],
      ),
    );
  }
}
