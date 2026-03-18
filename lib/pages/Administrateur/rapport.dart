import 'package:flutter/material.dart';

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

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
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
      body: Column(
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
              'value': '2,543,200 FCFA',
              'icon': Icons.shopping_cart,
              'color': Colors.green,
            },
            {
              'label': 'Nombre Ventes',
              'value': '156',
              'icon': Icons.receipt,
              'color': Colors.blue,
            },
            {
              'label': 'Panier Moyen',
              'value': '16,300 FCFA',
              'icon': Icons.calculate,
              'color': Colors.orange,
            },
            {
              'label': 'Croissance',
              'value': '+12.5%',
              'icon': Icons.trending_up,
              'color': Colors.purple,
            },
          ]),

          const SizedBox(height: 24),

          // Graphique d'évolution
          _buildSectionTitle('Évolution des ventes'),
          const SizedBox(height: 16),
          Container(
            height: 300,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: const Center(
              child: Text('Graphique d\'évolution des ventes'),
            ),
          ),

          const SizedBox(height: 24),

          // Top produits vendus
          _buildSectionTitle('Top 10 produits vendus'),
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
              'value': '245',
              'icon': Icons.inventory,
              'color': Colors.blue,
            },
            {
              'label': 'Stock Total',
              'value': '1,234',
              'icon': Icons.warehouse,
              'color': Colors.green,
            },
            {
              'label': 'Ruptures',
              'value': '12',
              'icon': Icons.warning,
              'color': Colors.red,
            },
            {
              'label': 'Valeur Stock',
              'value': '8,450,000 FCFA',
              'icon': Icons.attach_money,
              'color': Colors.orange,
            },
          ]),

          const SizedBox(height: 24),

          // Categories les plus vendues
          _buildSectionTitle('Catégories les plus vendues'),
          const SizedBox(height: 16),
          Container(
            height: 250,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: const Center(
              child: Text('Graphique camembert des catégories'),
            ),
          ),
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
              'value': '89',
              'icon': Icons.people,
              'color': Colors.blue,
            },
            {
              'label': 'Nouveaux',
              'value': '15',
              'icon': Icons.person_add,
              'color': Colors.green,
            },
            {
              'label': 'Clients Actifs',
              'value': '67',
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
              'value': '2,543,200 FCFA',
              'icon': Icons.trending_up,
              'color': Colors.green,
            },
            {
              'label': 'Bénéfice Net',
              'value': '845,600 FCFA',
              'icon': Icons.account_balance,
              'color': Colors.blue,
            },
            {
              'label': 'Dépenses',
              'value': '1,697,600 FCFA',
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
          Container(
            height: 300,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: const Center(child: Text('Graphique financier')),
          ),
        ],
      ),
    );
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
          ...List.generate(5, (index) => _buildProductTableRow(index + 1)),
        ],
      ),
    );
  }

  Widget _buildProductTableRow(int rank) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        children: [
          Expanded(flex: 1, child: Text('#$rank')),
          Expanded(flex: 3, child: Text('Produit $rank')),
          Expanded(flex: 2, child: Text('${(rank * 23)}')),
          Expanded(flex: 2, child: Text('${(rank * 15000)} FCFA')),
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
          ...List.generate(5, (index) => _buildClientTableRow(index + 1)),
        ],
      ),
    );
  }

  Widget _buildClientTableRow(int rank) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        children: [
          Expanded(flex: 3, child: Text('Client $rank')),
          Expanded(flex: 2, child: Text('${(rank * 5)}')),
          Expanded(flex: 2, child: Text('${(rank * 85000)} FCFA')),
        ],
      ),
    );
  }
}
