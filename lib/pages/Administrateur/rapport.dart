import 'package:flutter/material.dart';
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
  bool _isLoading = true;

  // Statistiques calculées
  double _beneficeTotal = 0;
  int _totalVentes = 0;
  double _beneficeMoyen = 0;
  final List<Map<String, dynamic>> _beneficesParProduit = [];
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
      final rapportResponse = await ApiService.getRapportVentes();

      if (rapportResponse['success'] == true) {
        setState(() {
          _produits = List<Map<String, dynamic>>.from(
            rapportResponse['produitRapports'] ?? [],
          );
          _beneficeTotal = _parseDouble(rapportResponse['beneficeTotal']);
          _totalVentes = _parseInt(rapportResponse['totalVentes']);
          _beneficeMoyen = _parseDouble(rapportResponse['beneficeMoyen']);
          _meilleurProduit = rapportResponse['meilleurProduit'];
          _isLoading = false;
        });

        // Préparer les données pour le tableau
        _prepareBeneficesData();
      } else {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(rapportResponse['message'] ?? 'Erreur de chargement'),
            backgroundColor: Colors.red,
          ),
        );
      }

      _animationController.forward();
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _prepareBeneficesData() {
    _beneficesParProduit.clear();

    // Les données viennent déjà préparées de l'API
    for (var produit in _produits) {
      _beneficesParProduit.add({
        'nom': produit['nom'] ?? 'Produit sans nom',
        'prix_unitaire': _parseDouble(produit['prix_unitaire']),
        'quantite_vendue': _parseInt(produit['quantite_vendue']),
        'total_ventes': _parseDouble(produit['total_ventes']),
        // 'cout_total': _parseDouble(produit['cout_total']),
        'benefice': _parseDouble(produit['benefice']),
        'marge': _parseDouble(produit['marge']),
        'categorie': produit['categorie'] ?? 'N/A',
        'date_vente': produit['date_vente'] ?? 'N/A',
        // 'numero_serie': produit['numero_serie'] ?? 'N/A',
      });
    }
  }

  double _parseDouble(dynamic value) {
    if (value == null) return 0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0;
    return 0;
  }

  int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
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
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text(
          'Rapport des Bénéfices',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        backgroundColor: const Color(0xFF3B82F6),
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF3B82F6), Color(0xFF1E40AF)],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xFF3B82F6).withValues(alpha: 0.05),
              const Color(0xFF1E40AF).withValues(alpha: 0.02),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: _isLoading
            ? _buildLoadingState()
            : FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Column(
                    children: [
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
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildSectionTitle(
                                    'Vue d\'ensemble des Bénéfices',
                                  ),
                                  const SizedBox(height: 16),
                                  _buildBeneficeCards(),
                                  const SizedBox(height: 24),
                                  if (_meilleurProduit != null) ...[
                                    _buildMeilleurProduitCard(),
                                    const SizedBox(height: 24),
                                  ],
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
          const SizedBox(height: 24),
          TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 800),
            tween: Tween<double>(begin: 0.0, end: 1.0),
            builder: (context, animation, child) {
              return Opacity(
                opacity: animation,
                child: const Text(
                  'Chargement des données...',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF6B7280),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 24,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [const Color(0xFF3B82F6), const Color(0xFF1E40AF)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1F2937),
              letterSpacing: -0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBeneficeCards() {
    return Column(
      children: [
        _buildAnimatedBeneficeCard(
          'Bénéfice Total',
          '${_beneficeTotal.toStringAsFixed(0)} \$',
          Icons.trending_up,
          [const Color(0xFF10B981), const Color(0xFF059669)],
          'success',
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildAnimatedBeneficeCard(
                'Total Ventes',
                '$_totalVentes',
                Icons.shopping_cart,
                [const Color(0xFF3B82F6), const Color(0xFF1E40AF)],
                'primary',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildAnimatedBeneficeCard(
                'Bénéfice Moyen',
                '${_beneficeMoyen.toStringAsFixed(0)} \$',
                Icons.calculate,
                [const Color(0xFF8B5CF6), const Color(0xFF7C3AED)],
                'primary',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAnimatedBeneficeCard(
    String title,
    String value,
    IconData icon,
    List<Color> gradientColors,
    String type,
  ) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 600),
      tween: Tween<double>(begin: 0.0, end: 1.0),
      builder: (context, animation, child) {
        return Transform.translate(
          offset: Offset(0, (1 - animation) * 20),
          child: Opacity(
            opacity: animation,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: gradientColors,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: gradientColors.first.withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(icon, color: Colors.white, size: 20),
                      ),
                      const Spacer(),
                      _getTrendIcon(type),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    title,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      value,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _getTrendIcon(String type) {
    switch (type) {
      case 'success':
        return const Icon(Icons.arrow_upward, color: Colors.white, size: 16);
      case 'warning':
        return const Icon(Icons.trending_flat, color: Colors.white, size: 16);
      default:
        return const Icon(Icons.arrow_downward, color: Colors.white, size: 16);
    }
  }

  Widget _buildBeneficesTable() {
    if (_beneficesParProduit.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(40),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(50),
              ),
              child: Icon(
                Icons.bar_chart,
                size: 48,
                color: Colors.grey.shade400,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Aucune donnée disponible',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Les statistiques des bénéfices apparaîtront ici une fois les ventes enregistrées.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
            ),
          ],
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // En-tête du tableau
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF3B82F6), Color(0xFF1E40AF)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
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
                      fontSize: 10,
                      color: Colors.white,
                      letterSpacing: 0.4,
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'Produit',
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 10,
                      color: Colors.white,
                      letterSpacing: 0.4,
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Text(
                    'Prix U.',
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 10,
                      color: Colors.white,
                      letterSpacing: 0.4,
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Text(
                    'Total V.',
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 10,
                      color: Colors.white,
                      letterSpacing: 0.4,
                    ),
                  ),
                ),
                // Expanded(
                //   flex: 1,
                //   child: Text(
                //     'Coût T.',
                //     style: const TextStyle(
                //       fontWeight: FontWeight.w700,
                //       fontSize: 10,
                //       color: Colors.white,
                //       letterSpacing: 0.4,
                //     ),
                //   ),
                // ),
                // Expanded(
                //   flex: 1,
                //   child: Text(
                //     'Date',
                //     style: const TextStyle(
                //       fontWeight: FontWeight.w700,
                //       fontSize: 10,
                //       color: Colors.white,
                //       letterSpacing: 0.4,
                //     ),
                //   ),
                // ),
                // Expanded(
                //   flex: 1,
                //   child: Text(
                //     'N° Série',
                //     style: const TextStyle(
                //       fontWeight: FontWeight.w700,
                //       fontSize: 10,
                //       color: Colors.white,
                //       letterSpacing: 0.4,
                //     ),
                //   ),
                // ),
                Expanded(
                  flex: 1,
                  child: Text(
                    'Bénéfice',
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 10,
                      color: Colors.white,
                      letterSpacing: 0.4,
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Text(
                    'Marge',
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 10,
                      color: Colors.white,
                      letterSpacing: 0.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Corps du tableau
          ..._beneficesParProduit.asMap().entries.map((entry) {
            final index = entry.key;
            final benefice = entry.value;
            return _buildModernBeneficeTableRow(index + 1, benefice);
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildModernBeneficeTableRow(
    int index,
    Map<String, dynamic> benefice,
  ) {
    final marge = benefice['marge'] as double;
    final margeColor = _getMargeColor(marge);
    final margeIcon = _getMargeIcon(marge);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 1),
      decoration: BoxDecoration(
        color: index % 2 == 0 ? Colors.grey.shade50 : Colors.white,
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade100, width: 1),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Expanded(
              flex: 1,
              child: Text(
                '$index',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                  color: Colors.grey.shade700,
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                benefice['nom'] ?? 'N/A',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                  color: Color(0xFF1F2937),
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Expanded(
              flex: 1,
              child: Text(
                '${benefice['prix_unitaire']?.toStringAsFixed(0) ?? '0'}',
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 11,
                  color: Color(0xFF6B7280),
                ),
                textAlign: TextAlign.center,
              ),
            ),
            Expanded(
              flex: 1,
              child: Text(
                '${benefice['total_ventes']?.toStringAsFixed(0) ?? '0'}',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 11,
                  color: Color(0xFF3B82F6),
                ),
                textAlign: TextAlign.center,
              ),
            ),
            // Expanded(
            //   flex: 1,
            //   child: Text(
            //     '${benefice['cout_total']?.toStringAsFixed(0) ?? '0'}',
            //     style: const TextStyle(
            //       fontWeight: FontWeight.w500,
            //       fontSize: 11,
            //       color: Color(0xFF6B7280),
            //     ),
            //     textAlign: TextAlign.center,
            //   ),
            // ),
            // Expanded(
            //   flex: 1,
            //   child: Text(
            //     benefice['date_vente'] ?? 'N/A',
            //     style: const TextStyle(
            //       fontWeight: FontWeight.w500,
            //       fontSize: 10,
            //       color: Color(0xFF6B7280),
            //     ),
            //     textAlign: TextAlign.center,
            //   ),
            // ),
            // Expanded(
            //   flex: 1,
            //   child: Text(
            //     benefice['numero_serie'] ?? 'N/A',
            //     style: const TextStyle(
            //       fontWeight: FontWeight.w500,
            //       fontSize: 10,
            //       color: Color(0xFF6B7280),
            //     ),
            //     overflow: TextOverflow.ellipsis,
            //   ),
            // ),
            Expanded(
              flex: 1,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: _getBeneficeColor(
                    benefice['benefice'],
                  ).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${benefice['benefice']?.toStringAsFixed(0) ?? '0'}',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 11,
                    color: _getBeneficeColor(benefice['benefice']),
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(margeIcon, size: 14, color: margeColor),
                  const SizedBox(width: 4),
                  Text(
                    '${marge.toStringAsFixed(1)}%',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 11,
                      color: margeColor,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMeilleurProduitCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [const Color(0xFFEC7023), const Color(0xFFEC7023)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFEC7023).withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.emoji_events,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const Spacer(),
              const Icon(Icons.star, color: Colors.white, size: 16),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Meilleur Produit',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.9),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _meilleurProduit?['nom'] ?? 'N/A',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          Text(
            'Bénéfice: ${_parseDouble(_meilleurProduit?['benefice']).toStringAsFixed(0)} \$',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.8),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Color _getMargeColor(double marge) {
    if (marge >= 20) return const Color(0xFF10B981);
    if (marge >= 10) return const Color(0xFF3B82F6);
    if (marge >= 0) return const Color(0xFFF59E0B);
    return const Color(0xFFEF4444);
  }

  IconData _getMargeIcon(double marge) {
    if (marge >= 20) return Icons.trending_up;
    if (marge >= 10) return Icons.trending_flat;
    if (marge >= 0) return Icons.trending_down;
    return Icons.arrow_downward;
  }

  Color _getBeneficeColor(dynamic benefice) {
    final value = _parseDouble(benefice);
    if (value > 0) return const Color(0xFF10B981);
    if (value == 0) return const Color(0xFF6B7280);
    return const Color(0xFFEF4444);
  }
}
