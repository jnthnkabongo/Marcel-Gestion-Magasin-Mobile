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

  // Variables pour les données réelles
  List<Map<String, dynamic>> _produits = [];
  List<Map<String, dynamic>> _ventes = [];
  bool _isLoading = true;

  // Statistiques calculées
  double _beneficeTotal = 0;
  int _totalVentes = 0;
  double _beneficeMoyen = 0;
  List<Map<String, dynamic>> _beneficesParProduit = [];
  Map<String, dynamic>? _meilleurProduit;

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
        ApiService.getVentes(),
        ApiService.getProduits(),
      ]);

      // Ventes
      if (results[0]['success'] == true) {
        _ventes = List<Map<String, dynamic>>.from(results[0]['ventes'] ?? []);
      }

      // Produits
      if (results[1]['success'] == true) {
        _produits = List<Map<String, dynamic>>.from(
          results[1]['produits'] ?? [],
        );
      }

      // Calculer les statistiques
      _calculateBenefices();
    } catch (e) {
      print('Erreur lors du chargement des données: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _calculateBenefices() {
    _beneficesParProduit = [];
    _beneficeTotal = 0;
    _totalVentes = 0;

    // Créer une map pour regrouper les bénéfices par produit
    Map<String, Map<String, dynamic>> produitsMap = {};

    for (var vente in _ventes) {
      if (vente['vente_details'] != null) {
        for (var detail in vente['vente_details']) {
          String produitNom = 'Produit inconnu';
          double prixVente = 0;
          double prixAchat = 0;

          // Récupérer les informations du produit
          if (detail['produit_unite'] != null &&
              detail['produit_unite']['produit'] != null) {
            var produit = detail['produit_unite']['produit'];
            produitNom = produit['nom'] ?? 'Produit inconnu';
            prixAchat = _parseDouble(produit['prix_achat']);
          }

          prixVente = _parseDouble(detail['prix_unitaire']);
          double beneficeUnitaire = prixVente - prixAchat;
          double totalVente = _parseDouble(detail['total']);

          // Ajouter à la map du produit
          if (!produitsMap.containsKey(produitNom)) {
            produitsMap[produitNom] = {
              'nom': produitNom,
              'quantite_vendue': 0,
              'prix_unitaire': prixVente,
              'total_ventes': 0,
              'cout_total': 0,
              'benefice': 0,
              'marge': 0,
            };
          }

          var produitData = produitsMap[produitNom]!;
          produitData['quantite_vendue']++;
          produitData['total_ventes'] += totalVente;
          produitData['cout_total'] += prixAchat;
          produitData['benefice'] += beneficeUnitaire;
          produitData['marge'] = produitData['total_ventes'] > 0
              ? (produitData['benefice'] / produitData['total_ventes']) * 100
              : 0;
        }
      }
    }

    // Convertir en liste et calculer les totaux
    _beneficesParProduit = produitsMap.values.toList();
    _totalVentes = _ventes.length;

    for (var produit in _beneficesParProduit) {
      _beneficeTotal += produit['benefice'];
    }

    _beneficeMoyen = _totalVentes > 0 ? _beneficeTotal / _totalVentes : 0;

    // Trouver le meilleur produit
    if (_beneficesParProduit.isNotEmpty) {
      _meilleurProduit = _beneficesParProduit.reduce(
        (a, b) => a['benefice'] > b['benefice'] ? a : b,
      );
    }

    // Trier par bénéfice décroissant
    _beneficesParProduit.sort((a, b) => b['benefice'].compareTo(a['benefice']));
  }

  double _parseDouble(dynamic value) {
    if (value == null) return 0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0;
    return 0;
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
        title: const Text('Rapport de Ventes'),
        backgroundColor: const Color(0xFF7C3AED),
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'Bénéfices', icon: Icon(Icons.trending_up)),
            Tab(text: 'Produits', icon: Icon(Icons.inventory)),
            Tab(text: 'Ventes', icon: Icon(Icons.shopping_cart)),
            Tab(text: 'Analyse', icon: Icon(Icons.analytics)),
          ],
        ),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadData),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF7C3AED)),
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
                      _buildBeneficesTab(),
                      _buildProduitsTab(),
                      _buildVentesTab(),
                      _buildAnalyseTab(),
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
                  value: _periodeSelectionnee,
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
              Expanded(
                child: ElevatedButton(
                  onPressed: _loadData,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF7C3AED),
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Appliquer'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBeneficesTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cartes de bénéfices généraux
          _buildBeneficeCards(),

          const SizedBox(height: 24),

          // Tableau des bénéfices par produit
          _buildSectionTitle('Détail des Bénéfices par Produit'),
          const SizedBox(height: 16),
          _buildBeneficesTable(),
        ],
      ),
    );
  }

  Widget _buildBeneficeCards() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      childAspectRatio: 1.5,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      children: [
        // Bénéfice total
        _buildBeneficeCard(
          'Bénéfice Total',
          '${_beneficeTotal.toStringAsFixed(0)} FCFA',
          Icons.trending_up,
          Colors.green,
        ),
        // Total ventes
        _buildBeneficeCard(
          'Total Ventes',
          '$_totalVentes',
          Icons.shopping_cart,
          Colors.blue,
        ),
        // Bénéfice moyen
        _buildBeneficeCard(
          'Bénéfice Moyen',
          '${_beneficeMoyen.toStringAsFixed(0)} FCFA',
          Icons.calculate,
          Colors.purple,
        ),
        // Meilleur produit
        _buildBeneficeCard(
          'Meilleur Produit',
          _meilleurProduit?['nom'] ?? 'N/A',
          Icons.star,
          Colors.orange,
          subtitle:
              '${(_meilleurProduit?['benefice'] ?? 0).toStringAsFixed(0)} FCFA',
        ),
      ],
    );
  }

  Widget _buildBeneficeCard(
    String title,
    String value,
    IconData icon,
    Color color, {
    String? subtitle,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [color.withOpacity(0.8), color],
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Icon(icon, color: Colors.white.withOpacity(0.8), size: 24),
              ],
            ),
            const Spacer(),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 12,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildBeneficesTable() {
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
      child: Column(
        children: [
          // En-tête du tableau
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Expanded(flex: 1, child: _buildTableHeader('N°')),
                Expanded(flex: 3, child: _buildTableHeader('Produit')),
                Expanded(flex: 2, child: _buildTableHeader('Prix Unitaire')),
                Expanded(flex: 2, child: _buildTableHeader('Total Ventes')),
                Expanded(flex: 2, child: _buildTableHeader('Coût Total')),
                Expanded(flex: 2, child: _buildTableHeader('Bénéfice')),
                Expanded(flex: 1, child: _buildTableHeader('Marge')),
              ],
            ),
          ),
          // Données du tableau
          if (_beneficesParProduit.isEmpty)
            Container(
              padding: const EdgeInsets.all(32),
              child: Column(
                children: [
                  Icon(Icons.bar_chart, size: 48, color: Colors.grey.shade300),
                  const SizedBox(height: 16),
                  Text(
                    'Aucune donnée trouvée pour cette période',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Essayez de modifier les filtres ou la période',
                    style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                  ),
                ],
              ),
            )
          else
            ...List.generate(
              _beneficesParProduit.length,
              (index) => _buildBeneficeTableRow(
                index + 1,
                _beneficesParProduit[index],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTableHeader(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 12,
        color: Color(0xFF6B7280),
      ),
    );
  }

  Widget _buildBeneficeTableRow(int rank, Map<String, dynamic> produit) {
    double benefice = produit['benefice'];
    double marge = produit['marge'];
    Color beneficeColor = benefice > 0 ? Colors.green : Colors.red;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        children: [
          Expanded(flex: 1, child: Text('$rank')),
          Expanded(
            flex: 3,
            child: Row(
              children: [
                Icon(Icons.inventory, color: Colors.blue, size: 16),
                const SizedBox(width: 8),
                Expanded(child: Text(produit['nom'])),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Text('${produit['prix_unitaire'].toStringAsFixed(0)} FCFA'),
          ),
          Expanded(
            flex: 2,
            child: Text('${produit['total_ventes'].toStringAsFixed(0)} FCFA'),
          ),
          Expanded(
            flex: 2,
            child: Text('${produit['cout_total'].toStringAsFixed(0)} FCFA'),
          ),
          Expanded(
            flex: 2,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: beneficeColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${benefice.toStringAsFixed(0)} FCFA',
                style: TextStyle(
                  color: beneficeColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Row(
              children: [
                Icon(
                  marge > 50
                      ? Icons.arrow_upward
                      : marge > 20
                      ? Icons.arrow_forward
                      : Icons.arrow_downward,
                  color: marge > 50
                      ? Colors.green
                      : marge > 20
                      ? Colors.yellow
                      : Colors.red,
                  size: 16,
                ),
                const SizedBox(width: 4),
                Text('${marge.toStringAsFixed(1)}%'),
              ],
            ),
          ),
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
          _buildSectionTitle('Statistiques des Produits'),
          const SizedBox(height: 16),
          _buildProduitsStats(),
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
          _buildSectionTitle('Historique des Ventes'),
          const SizedBox(height: 16),
          _buildVentesList(),
        ],
      ),
    );
  }

  Widget _buildAnalyseTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Analyse Graphique'),
          const SizedBox(height: 16),
          _buildCharts(),
        ],
      ),
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

  Widget _buildProduitsStats() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      childAspectRatio: 1.5,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      children: [
        _buildStatCard(
          'Total Produits',
          '${_produits.length}',
          Icons.inventory,
          Colors.blue,
        ),
        _buildStatCard(
          'Stock Disponible',
          '${_getStockDisponible()}',
          Icons.warehouse,
          Colors.green,
        ),
        _buildStatCard(
          'Ruptures',
          '${_getRuptures()}',
          Icons.warning,
          Colors.red,
        ),
        _buildStatCard(
          'Valeur Stock',
          '${_getValeurStock().toStringAsFixed(0)} FCFA',
          Icons.attach_money,
          Colors.orange,
        ),
      ],
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
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
                Icon(icon, color: color, size: 24),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    value,
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVentesList() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: _ventes.length,
        itemBuilder: (context, index) {
          final vente = _ventes[index];
          return ListTile(
            leading: Icon(Icons.receipt, color: Colors.blue),
            title: Text('Vente #${vente['id'] ?? index + 1}'),
            subtitle: Text('Client: ${vente['nom_client'] ?? 'N/A'}'),
            trailing: Text('${vente['total'] ?? 0} FCFA'),
          );
        },
      ),
    );
  }

  Widget _buildCharts() {
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
              'Répartition des Bénéfices',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF7C3AED),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(child: _buildSimpleBarChart()),
          ],
        ),
      ),
    );
  }

  Widget _buildSimpleBarChart() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: _beneficesParProduit.take(6).map((produit) {
        double height = produit['benefice'] > 0
            ? (produit['benefice'] / _beneficeTotal).clamp(0.0, 1.0)
            : 0.0;
        return Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Container(
              width: 30,
              height: 200 * height,
              decoration: BoxDecoration(
                color: produit['benefice'] > 0 ? Colors.green : Colors.red,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(4),
                ),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: 40,
              child: Text(
                produit['nom'].length > 8
                    ? '${produit['nom'].substring(0, 8)}...'
                    : produit['nom'],
                style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        );
      }).toList(),
    );
  }

  int _getStockDisponible() {
    int stock = 0;
    for (var produit in _produits) {
      if (produit['produit_unites'] != null) {
        stock += (produit['produit_unites'] as List)
            .where((unite) => unite['statut'] == 'en_stock')
            .length;
      }
    }
    return stock;
  }

  int _getRuptures() {
    int ruptures = 0;
    for (var produit in _produits) {
      if (produit['produit_unites'] != null) {
        var unites = produit['produit_unites'] as List;
        if (unites.every((unite) => unite['statut'] == 'vendu')) {
          ruptures++;
        }
      }
    }
    return ruptures;
  }

  double _getValeurStock() {
    double valeur = 0;
    for (var produit in _produits) {
      if (produit['produit_unites'] != null) {
        double prix = _parseDouble(produit['prix_vente']);
        int stock = (produit['produit_unites'] as List)
            .where((unite) => unite['statut'] == 'en_stock')
            .length;
        valeur += prix * stock;
      }
    }
    return valeur;
  }
}
