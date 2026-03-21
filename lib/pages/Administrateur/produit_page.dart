import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class ProduitPage extends StatefulWidget {
  const ProduitPage({super.key});

  @override
  State<ProduitPage> createState() => _ProduitPageState();
}

class _ProduitPageState extends State<ProduitPage>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  List<Map<String, dynamic>> _produitsVendus = [];
  List<Map<String, dynamic>> _produitsFiltres = [];
  bool _isLoading = true;
  double _totalVentes = 0;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOut));

    _fadeController.forward();
    _slideController.forward();

    _loadProduitsVendus();
  }

  Future<void> _loadProduitsVendus() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await ApiService.getVentes();

      if (response['success'] == true && response['ventes'] != null) {
        List<Map<String, dynamic>> allVentes = List<Map<String, dynamic>>.from(
          response['ventes'],
        );

        // Transformer les ventes en liste de produits vendus avec informations client
        List<Map<String, dynamic>> produitsVendus = [];

        for (var vente in allVentes) {
          if (vente['vente_details'] != null) {
            for (var detail in vente['vente_details']) {
              if (detail['produit_unite'] != null &&
                  detail['produit_unite']['produit'] != null) {
                var produit = detail['produit_unite']['produit'];
                var venteInfo = {
                  'id': produit['id'],
                  'nom': produit['nom'],
                  'categorie': produit['categorie'],
                  'marque': produit['marque'],
                  'modele': produit['modele'],
                  'prix_vente': detail['prix_unitaire'],
                  'prix_achat': produit['prix_achat'],
                  'numero_serie': detail['produit_unite']['numero_serie'],
                  'date_vente': vente['date_vente'],
                  'reference': vente['reference'],
                  'client_nom':
                      vente['nom_client']?.toString().isNotEmpty == true
                      ? vente['nom_client'].toString()
                      : vente['client']?['nom']?.toString() ?? 'Client inconnu',
                  'client_id': vente['client_id'],
                  'vente_id': vente['id'],
                  'detail_id': detail['id'],
                  'created_at': vente['created_at'],
                };
                produitsVendus.add(venteInfo);
              }
            }
          }
        }

        _produitsVendus = produitsVendus;
        _produitsFiltres = produitsVendus;
        _calculateStats();
      } else {
        print(
          'Erreur: ${response['message'] ?? 'Erreur lors du chargement des produits vendus'}',
        );
      }
    } catch (e) {
      print('Erreur de réseau: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _calculateStats() {
    _totalVentes = 0;

    for (var produitVendu in _produitsVendus) {
      final prixVente = produitVendu['prix_vente'];
      double prixVenteDouble = 0;

      if (prixVente is num) {
        prixVenteDouble = prixVente.toDouble();
      } else if (prixVente is String) {
        prixVenteDouble = double.tryParse(prixVente) ?? 0;
      }

      _totalVentes += prixVenteDouble;
    }
  }

  void _filterSearch(String query) {
    setState(() {
      if (query.isEmpty) {
        _produitsFiltres = _produitsVendus;
      } else {
        final lowerQuery = query.toLowerCase();
        _produitsFiltres = _produitsVendus.where((v) {
          final nom = v['nom']?.toString().toLowerCase() ?? '';
          final id = v['id']?.toString().toLowerCase() ?? '';
          final marque = v['marque']?['nom']?.toString().toLowerCase() ?? '';
          final clientNom = v['client_nom']?.toString().toLowerCase() ?? '';
          final reference = v['reference']?.toString().toLowerCase() ?? '';

          return nom.contains(lowerQuery) ||
              id.contains(lowerQuery) ||
              marque.contains(lowerQuery) ||
              clientNom.contains(lowerQuery) ||
              reference.contains(lowerQuery);
        }).toList();
      }
    });
  }

  double _calculateTotalForProduct(Map<String, dynamic> produit) {
    final prixVente = produit['prix_vente'];
    double prixVenteDouble = 0;

    if (prixVente is num) {
      prixVenteDouble = prixVente.toDouble();
    } else if (prixVente is String) {
      prixVenteDouble = double.tryParse(prixVente) ?? 0;
    }

    return prixVenteDouble;
  }

  String _formatDate(dynamic createdAt) {
    if (createdAt == null) return 'N/A';

    try {
      final dateStr = createdAt.toString();
      final parts = dateStr.split(' ')[0].split('-'); // Format YYYY-MM-DD

      if (parts.length == 3) {
        return '${parts[2]}/${parts[1]}/${parts[0]}'; // DD/MM/YYYY
      }
    } catch (e) {
      // En cas d'erreur, essayer avec un autre format
      try {
        final date = DateTime.parse(createdAt.toString());
        return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
      } catch (e) {
        return createdAt.toString();
      }
    }

    return createdAt.toString();
  }

  String _getSoldCount(dynamic produitUnites) {
    if (produitUnites == null ||
        produitUnites is! List ||
        produitUnites.isEmpty) {
      return '0';
    }

    try {
      final soldCount = produitUnites
          .where((unite) => unite['statut'] == 'vendu')
          .length;
      return soldCount.toString();
    } catch (e) {
      return '0';
    }
  }

  String _getFirstSoldSerialNumber(dynamic produitUnites) {
    if (produitUnites == null ||
        produitUnites is! List ||
        produitUnites.isEmpty) {
      return 'N/A';
    }

    try {
      final firstSoldUnit = produitUnites.firstWhere(
        (unite) => unite['statut'] == 'vendu',
        orElse: () => null,
      );
      return firstSoldUnit?['numero_serie']?.toString() ?? 'N/A';
    } catch (e) {
      return 'N/A';
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text(
          'Produits Vendus',
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
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: () => _showSearchDialog(),
          ),
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadProduitsVendus,
          ),
        ],
      ),
      body: Column(
        children: [
          // Section statistiques avec animation
          FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF3B82F6), Color(0xFF1E40AF)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.withOpacity(0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildAnimatedStatCard(
                          'Produits Vendus',
                          _produitsVendus.length.toString(),
                          Icons.sell_outlined,
                          Colors.blue,
                        ),
                        _buildAnimatedStatCard(
                          'Total Ventes',
                          '${_totalVentes.toStringAsFixed(0)} \$',
                          Icons.monetization_on,
                          Colors.green,
                        ),
                        // _buildAnimatedStatCard(
                        //   'Unités Vendues',
                        //   _produitsVendus.fold<int>(0, (sum, product) {
                        //     final vendusCount =
                        //         (product['produit_unites'] as List?)
                        //             ?.where(
                        //               (unite) => unite['statut'] == 'vendu',
                        //             )
                        //             .length ??
                        //         0;
                        //     return sum + vendusCount;
                        //   }).toString(),
                        //   Icons.inventory_2_outlined,
                        //   Colors.orange,
                        // ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Liste des produits vendus
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                await Future.delayed(const Duration(seconds: 1));
                _loadProduitsVendus();
              },
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF3B82F6),
                      ),
                    )
                  : _produitsFiltres.isEmpty
                  ? const Center(child: Text("Aucun produit vendu trouvé"))
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: _produitsFiltres.length,
                      itemBuilder: (context, index) {
                        final produitItem = _produitsFiltres[index];
                        return AnimatedContainer(
                          duration: Duration(milliseconds: 300 + (index * 100)),
                          curve: Curves.easeOut,
                          margin: const EdgeInsets.only(bottom: 6),
                          transform: Matrix4.translationValues(0, 0, 0),
                          child: Card(
                            elevation: 8,
                            shadowColor: Colors.black.withOpacity(0.1),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                gradient: LinearGradient(
                                  colors: [Colors.white, Colors.grey.shade50],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                              ),
                              child: ListTile(
                                contentPadding: const EdgeInsets.all(8),
                                leading: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.blue.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(
                                    Icons.sell_outlined,
                                    color: Colors.blue,
                                    size: 18,
                                  ),
                                ),
                                title: Text(
                                  produitItem['nom'] ?? 'Nom non disponible',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    color: Color(0xFF2C3E50),
                                  ),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 2),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.person,
                                          size: 14,
                                          color: Colors.grey[600],
                                        ),
                                        const SizedBox(width: 2),
                                        Expanded(
                                          child: Text(
                                            "Client: ${produitItem['client_nom'] ?? 'Client inconnu'}",
                                            style: TextStyle(
                                              color: Colors.grey[600],
                                              fontSize: 12,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 2),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.inventory_2,
                                          size: 14,
                                          color: Colors.grey[600],
                                        ),
                                        const SizedBox(width: 2),
                                        Expanded(
                                          child: Text(
                                            "N° Série: ${produitItem['numero_serie'] ?? 'N/A'}",
                                            style: TextStyle(
                                              color: Colors.grey[600],
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 2),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.receipt,
                                          size: 14,
                                          color: Colors.grey[600],
                                        ),
                                        const SizedBox(width: 2),
                                        Expanded(
                                          child: Text(
                                            "Ref: ${produitItem['reference'] ?? 'N/A'}",
                                            style: TextStyle(
                                              color: Colors.grey[600],
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 2),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.sell,
                                          size: 14,
                                          color: Colors.grey[600],
                                        ),
                                        const SizedBox(width: 2),
                                        Text(
                                          "${produitItem['prix_vente'] ?? 0} FC",
                                          style: TextStyle(
                                            color: Colors.grey[600],
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 2),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.calendar_today,
                                          size: 14,
                                          color: Colors.grey[600],
                                        ),
                                        const SizedBox(width: 2),
                                        Text(
                                          "Vente: ${_formatDate(produitItem['date_vente'])}",
                                          style: TextStyle(
                                            color: Colors.grey[600],
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                trailing: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.red,
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        'Vendu',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                onTap: () => _showProduitDetails(produitItem),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 800),
      builder: (context, animationValue, child) {
        return Transform.scale(
          scale: animationValue,
          child: Opacity(
            opacity: animationValue,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.white.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(icon, color: Colors.white, size: 20),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withOpacity(0.9),
                      fontWeight: FontWeight.w500,
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

  void _showSearchDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rechercher un produit vendu'),
        content: TextField(
          onChanged: (val) {
            _filterSearch(val);
          },
          decoration: const InputDecoration(
            hintText: 'Entrez le nom du produit, la marque...',
            prefixIcon: Icon(Icons.search),
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF3B82F6),
              foregroundColor: Colors.white,
              minimumSize: const Size(100, 40),
              textStyle: const TextStyle(fontSize: 16),
            ),
            child: const Text('Rechercher'),
          ),
        ],
      ),
    );
  }

  void _showProduitDetails(Map<String, dynamic> produit) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              colors: [Colors.white, Colors.grey.shade50],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header avec statut
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF3B82F6), Color(0xFF1E40AF)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.sell_outlined,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Détails du produit vendu',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            '#${produit['id']} - ${_formatDate(produit['created_at'])}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white.withOpacity(0.9),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'Vendu',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Informations détaillées
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
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
                    _buildDetailRow(
                      'Nom du produit',
                      produit['nom'] ?? 'N/A',
                      Icons.inventory,
                    ),
                    _buildDetailRow(
                      'Marque',
                      produit['marque']?['nom'] ?? 'N/A',
                      Icons.branding_watermark,
                    ),
                    _buildDetailRow(
                      'Modèle',
                      produit['modele'] ?? 'N/A',
                      Icons.category,
                    ),
                    _buildDetailRow(
                      'Client',
                      produit['client_nom'] ?? 'Client inconnu',
                      Icons.person,
                    ),
                    _buildDetailRow(
                      'N° Série',
                      produit['numero_serie'] ?? 'N/A',
                      Icons.tag,
                    ),
                    _buildDetailRow(
                      'Référence vente',
                      produit['reference'] ?? 'N/A',
                      Icons.receipt,
                    ),
                    _buildDetailRow(
                      'Date de vente',
                      _formatDate(produit['date_vente']),
                      Icons.calendar_today,
                    ),
                    _buildDetailRow(
                      'Prix unitaire',
                      '${produit['prix_vente'] ?? 0} FC',
                      Icons.attach_money,
                    ),
                    const SizedBox(height: 8),
                    const Divider(color: Color(0xFF3B82F6)),
                    const SizedBox(height: 8),
                    _buildDetailRow(
                      'Total',
                      '${_calculateTotalForProduct(produit)} FC',
                      Icons.monetization_on,
                      isTotal: true,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Bouton fermer
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: const BorderSide(color: Color(0xFF3B82F6)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Fermer',
                    style: TextStyle(
                      color: Color(0xFF3B82F6),
                      fontWeight: FontWeight.bold,
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

  Widget _buildDetailRow(
    String label,
    String value,
    IconData icon, {
    bool isTotal = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isTotal
                  ? const Color(0xFF3B82F6).withOpacity(0.1)
                  : Colors.grey.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: isTotal ? const Color(0xFF3B82F6) : Colors.grey[600],
              size: 16,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            label,
            style: TextStyle(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
              color: isTotal ? const Color(0xFF3B82F6) : Colors.grey[700],
              fontSize: isTotal ? 16 : 14,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.w600,
              color: isTotal ? const Color(0xFF3B82F6) : Colors.black87,
              fontSize: isTotal ? 16 : 14,
            ),
          ),
        ],
      ),
    );
  }
}
