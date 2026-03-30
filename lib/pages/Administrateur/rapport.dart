import 'package:flutter/material.dart';
import 'package:marcelgestion/services/api_service.dart';
import 'package:marcelgestion/services/api_service.dart';

class RapportPage extends StatefulWidget {
  const RapportPage({super.key});

  @override
  State<RapportPage> createState() => _RapportPageState();
}

class _RapportPageState extends State<RapportPage>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
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
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeInOut),
      ),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: const Interval(0.3, 1.0, curve: Curves.easeOutCubic),
          ),
        );

    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final responses = await Future.wait([
        ApiService.getProduits(),
        ApiService.getVentes(),
      ]);

      setState(() {
        _produits = List<Map<String, dynamic>>.from(
          responses[0]['produits'] ?? [],
        );
        _ventes = List<Map<String, dynamic>>.from(responses[1]['ventes'] ?? []);
        _isLoading = false;
      });

      _calculateBenefices();
      _animationController.forward();
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _calculateBenefices() {
    _beneficesParProduit.clear();
    _beneficeTotal = 0;
    _totalVentes = _ventes.length;
    _meilleurProduit = null;

    for (var produit in _produits) {
      double prixUnitaire = _parseDouble(produit['prix_unitaire']);
      int quantiteVendue = 0;
      double totalVentes = 0;
      double coutTotal = 0;

      // Calculer les statistiques pour ce produit
      for (var vente in _ventes) {
        if (vente['produit_id'] == produit['id']) {
          quantiteVendue += (vente['quantite'] as int? ?? 0);
          totalVentes += _parseDouble(vente['total']);
        }
      }

      coutTotal = prixUnitaire * quantiteVendue;
      double benefice = totalVentes - coutTotal;

      if (quantiteVendue > 0) {
        _beneficesParProduit.add({
          'nom': produit['nom'] ?? 'Produit sans nom',
          'prix_unitaire': prixUnitaire,
          'quantite_vendue': quantiteVendue,
          'total_ventes': totalVentes,
          'cout_total': coutTotal,
          'benefice': benefice,
          'marge': prixUnitaire > 0 ? (benefice / totalVentes) * 100 : 0,
        });

        _beneficeTotal += benefice;

        // Mettre à jour le meilleur produit
        if (_meilleurProduit == null ||
            benefice > (_meilleurProduit?['benefice'] ?? 0)) {
          _meilleurProduit = {'nom': produit['nom'], 'benefice': benefice};
        }
      }
    }

    _beneficeMoyen = _totalVentes > 0 ? _beneficeTotal / _totalVentes : 0;
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
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF3B82F6),
              const Color(0xFF1D4ED8),
              const Color(0xFF1E40AF),
            ],
            stops: const [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildModernAppBar(),
              const SizedBox(height: 20),
              Expanded(
                child: _isLoading
                    ? _buildLoadingState()
                    : FadeTransition(
                        opacity: _fadeAnimation,
                        child: SlideTransition(
                          position: _slideAnimation,
                          child: Column(
                            children: [
                              _buildFiltersSection(),
                              const SizedBox(height: 20),
                              // Contenu des bénéfices
                              Expanded(
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.95),
                                    borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(30),
                                      topRight: Radius.circular(30),
                                    ),
                                  ),
                                  child: SingleChildScrollView(
                                    child: Padding(
                                      padding: const EdgeInsets.all(16),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          _buildSectionTitle(
                                            'Vue d\'ensemble des Bénéfices',
                                          ),
                                          const SizedBox(height: 16),
                                          _buildBeneficeCards(),
                                          const SizedBox(height: 24),
                                          _buildSectionTitle(
                                            'Détail des Bénéfices par Produit',
                                          ),
                                          const SizedBox(height: 12),
                                          _buildBeneficesTable(),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModernAppBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.3),
                  ),
                ),
                child: const Icon(
                  Icons.trending_up,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Rapport des Bénéfices',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Analyse des performances de vente',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.8),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: _loadData,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.3),
                    ),
                  ),
                  child: const Icon(
                    Icons.refresh,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 1500),
            tween: Tween<double>(begin: 0.0, end: 1.0),
            builder: (context, animation, child) {
              return Transform.scale(
                scale: animation,
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFF3B82F6),
                        const Color(0xFF1D4ED8),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: const Icon(
                    Icons.analytics,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 20),
          const Text(
            'Chargement des données...',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFiltersSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF3B82F6).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.filter_list,
                  color: Color(0xFF3B82F6),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Filtres',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1F2937),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: DropdownButtonFormField<String>(
                    value: _periodeSelectionnee,
                    decoration: InputDecoration(
                      labelText: 'Période',
                      labelStyle: TextStyle(color: Colors.grey.shade600),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    icon: const Icon(
                      Icons.calendar_today,
                      color: Color(0xFF3B82F6),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'jour',
                        child: Text("Aujourd'hui"),
                      ),
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
              ),
              const SizedBox(width: 16),
              ElevatedButton(
                onPressed: _loadData,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3B82F6),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.search, size: 18),
                    SizedBox(width: 8),
                    Text(
                      'Appliquer',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      decoration: BoxDecoration(
        border: Border(
          left: BorderSide(color: const Color(0xFF3B82F6), width: 4),
        ),
      ),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Color(0xFF1F2937),
          letterSpacing: -0.5,
        ),
      ),
    );
  }

  Widget _buildBeneficeCards() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      childAspectRatio: 1.5,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      children: [
        _buildAnimatedBeneficeCard(
          'Bénéfice Total',
          '${_beneficeTotal.toStringAsFixed(0)} FCFA',
          Icons.trending_up,
          [const Color(0xFF3B82F6), const Color(0xFF1D4ED8)],
          'success',
        ),
        _buildAnimatedBeneficeCard(
          'Total Ventes',
          '$_totalVentes',
          Icons.shopping_cart,
          [const Color(0xFF10B981), const Color(0xFF059669)],
          'info',
        ),
        _buildAnimatedBeneficeCard(
          'Bénéfice Moyen',
          '${_beneficeMoyen.toStringAsFixed(0)} FCFA',
          Icons.calculate,
          [const Color(0xFF1E40AF), const Color(0xFF3B82F6)],
          'primary',
        ),
        _buildAnimatedBeneficeCard(
          'Meilleur Produit',
          _meilleurProduit?['nom'] ?? 'N/A',
          Icons.star,
          [const Color(0xFFF59E0B), const Color(0xFFD97706)],
          'warning',
          subtitle:
              '${(_meilleurProduit?['benefice'] ?? 0).toStringAsFixed(0)} FCFA',
        ),
      ],
    );
  }

  Widget _buildAnimatedBeneficeCard(
    String title,
    String value,
    IconData icon,
    List<Color> gradientColors,
    String type, {
    String? subtitle,
  }) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 800),
      tween: Tween<double>(begin: 0.0, end: 1.0),
      builder: (context, animation, child) {
        return Transform.scale(
          scale: animation,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: gradientColors,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: gradientColors.first.withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(icon, color: Colors.white, size: 18),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(
                          _getTrendIcon(type),
                          color: Colors.white,
                          size: 14,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    value,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    title,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.8),
                        fontSize: 10,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  IconData _getTrendIcon(String type) {
    switch (type) {
      case 'success':
        return Icons.trending_up;
      case 'info':
        return Icons.info;
      case 'primary':
        return Icons.show_chart;
      case 'warning':
        return Icons.warning;
      default:
        return Icons.trending_flat;
    }
  }

  Widget _buildBeneficesTable() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          // En-tête moderne du tableau
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [const Color(0xFF3B82F6), const Color(0xFF1D4ED8)],
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 1,
                  child: Text(
                    'N°',
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Text(
                    'Produit',
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'Prix U.',
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'Total V.',
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'Coût T.',
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'Bénéfice',
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Text(
                    'Marge',
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Données du tableau avec design amélioré
          if (_beneficesParProduit.isEmpty)
            Container(
              padding: const EdgeInsets.all(40),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.bar_chart,
                          size: 48,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Aucune donnée trouvée',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Essayez de modifier les filtres ou la période',
                          style: TextStyle(
                            color: Colors.grey.shade500,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )
          else
            ...List.generate(
              _beneficesParProduit.length,
              (index) => _buildModernBeneficeTableRow(
                index + 1,
                _beneficesParProduit[index],
                index.isEven,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildModernBeneficeTableRow(
    int rank,
    Map<String, dynamic> produit,
    bool isEven,
  ) {
    double benefice = produit['benefice'];
    double marge = produit['marge'];
    Color beneficeColor = benefice > 0 ? Colors.green : Colors.red;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isEven ? Colors.grey.shade50 : Colors.white,
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade200, width: 0.5),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: const Color(0xFF3B82F6).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                '$rank',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF3B82F6),
                  fontSize: 11,
                ),
              ),
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            flex: 3,
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.blue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Icon(Icons.inventory, color: Colors.blue, size: 12),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    produit['nom'],
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              '${produit['prix_unitaire'].toStringAsFixed(0)} FCFA',
              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 11),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              '${produit['total_ventes'].toStringAsFixed(0)} FCFA',
              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 11),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              '${produit['cout_total'].toStringAsFixed(0)} FCFA',
              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 11),
            ),
          ),
          Expanded(
            flex: 2,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
              decoration: BoxDecoration(
                color: beneficeColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: beneficeColor.withValues(alpha: 0.3)),
              ),
              child: Text(
                '${benefice.toStringAsFixed(0)} FCFA',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: beneficeColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 10,
                ),
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(1),
                  decoration: BoxDecoration(
                    color: _getMargeColor(marge).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(3),
                  ),
                  child: Icon(
                    _getMargeIcon(marge),
                    color: _getMargeColor(marge),
                    size: 8,
                  ),
                ),
                const SizedBox(width: 1),
                Flexible(
                  child: Text(
                    '${marge.toStringAsFixed(1)}%',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 9,
                      color: _getMargeColor(marge),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getMargeColor(double marge) {
    if (marge >= 20) return Colors.green;
    if (marge >= 10) return Colors.orange;
    return Colors.red;
  }

  IconData _getMargeIcon(double marge) {
    if (marge >= 20) return Icons.trending_up;
    if (marge >= 10) return Icons.trending_flat;
    return Icons.trending_down;
  }
}
