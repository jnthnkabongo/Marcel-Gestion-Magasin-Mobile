import 'package:flutter/material.dart';
import 'dart:convert';

import 'package:marcelgestion/services/api_service.dart';

class AuditPage extends StatefulWidget {
  const AuditPage({super.key});

  @override
  State<AuditPage> createState() => _AuditPageState();
}

class _AuditPageState extends State<AuditPage> with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;

  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _historique = [];
  bool _isLoading = true;

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

    _fadeController.forward();
    _slideController.forward();

    _loadHistorique();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadHistorique() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await ApiService.getHistoriques();

      if (response['success'] == true) {
        final historiquesData = response['historiques'] as List;
        setState(() {
          _historique = historiquesData.map((item) {
            // Convertir l'objet en Map<String, dynamic> et extraire les infos utilisateur
            final Map<String, dynamic> historiqueItem =
                Map<String, dynamic>.from(item);

            // Extraire les informations de l'utilisateur si disponible
            if (historiqueItem.containsKey('user') &&
                historiqueItem['user'] != null) {
              final user = Map<String, dynamic>.from(historiqueItem['user']);
              historiqueItem['user_name'] =
                  user['name'] ?? 'Utilisateur inconnu';
              historiqueItem['user_email'] = user['email'] ?? '';
            } else {
              historiqueItem['user_name'] = 'Utilisateur inconnu';
              historiqueItem['user_email'] = '';
            }

            return historiqueItem;
          }).toList();
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: ${response['message']}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur réseau: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text(
          'Historique',
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
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadHistorique,
          ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 10),

          // Liste de l'historique
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: Color(0xFF2E7D32)),
                  )
                : RefreshIndicator(
                    onRefresh: _loadHistorique,
                    child: _historique.isEmpty
                        ? _buildEmptyState()
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: _historique.length,
                            itemBuilder: (context, index) {
                              final item = _historique[index];
                              return AnimatedContainer(
                                duration: Duration(
                                  milliseconds: 300 + (index * 50),
                                ),
                                curve: Curves.easeOut,
                                margin: const EdgeInsets.only(bottom: 12),
                                child: Card(
                                  elevation: 4,
                                  shadowColor: Colors.black.withOpacity(0.1),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      gradient: LinearGradient(
                                        colors: [
                                          Colors.white,
                                          Colors.grey.shade50,
                                        ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                    ),
                                    child: ListTile(
                                      contentPadding: const EdgeInsets.all(16),
                                      leading: Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: _getActionColor(
                                            item['action'],
                                          ).withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                        ),
                                        child: Icon(
                                          _getActionIcon(item['action']),
                                          color: _getActionColor(
                                            item['action'],
                                          ),
                                          size: 20,
                                        ),
                                      ),
                                      title: Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              item['action'] ??
                                                  'Action inconnue',
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14,
                                                color: Color(0xFF2C3E50),
                                              ),
                                            ),
                                          ),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: _getActionColor(
                                                item['action'],
                                              ).withOpacity(0.1),
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                            ),
                                            child: Text(
                                              item['type'] ?? 'AUTRE',
                                              style: TextStyle(
                                                color: _getActionColor(
                                                  item['action'],
                                                ),
                                                fontSize: 10,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      subtitle: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const SizedBox(height: 4),
                                          Text(
                                            item['description'] ??
                                                'Aucune description',
                                            style: TextStyle(
                                              color: Colors.grey[600],
                                              fontSize: 12,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Row(
                                            children: [
                                              Icon(
                                                Icons.access_time,
                                                size: 12,
                                                color: Colors.grey[500],
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                item['formatted_date'] ??
                                                    _formatDate(
                                                      item['created_at'],
                                                    ),
                                                style: TextStyle(
                                                  color: Colors.grey[500],
                                                  fontSize: 11,
                                                ),
                                              ),
                                              const SizedBox(width: 12),
                                              Icon(
                                                Icons.person,
                                                size: 12,
                                                color: Colors.grey[500],
                                              ),
                                              const SizedBox(width: 4),
                                              Expanded(
                                                child: Text(
                                                  item['user_name'] ??
                                                      'Utilisateur inconnu',
                                                  style: TextStyle(
                                                    color: Colors.grey[500],
                                                    fontSize: 11,
                                                  ),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      trailing: PopupMenuButton<String>(
                                        icon: Icon(
                                          Icons.more_vert,
                                          size: 16,
                                          color: Colors.grey[600],
                                        ),
                                        onSelected: (value) {
                                          if (value == 'details') {
                                            _showAuditDetails(item);
                                          } else if (value == 'export') {
                                            _exportSingleItem(item);
                                          }
                                        },
                                        itemBuilder: (context) => [
                                          const PopupMenuItem(
                                            value: 'details',
                                            child: Row(
                                              children: [
                                                Icon(Icons.info, size: 16),
                                                SizedBox(width: 8),
                                                Text('Détails'),
                                              ],
                                            ),
                                          ),
                                          const PopupMenuItem(
                                            value: 'export',
                                            child: Row(
                                              children: [
                                                Icon(Icons.download, size: 16),
                                                SizedBox(width: 8),
                                                Text('Exporter'),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      onTap: () => _showAuditDetails(item),
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

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.1),
              borderRadius: BorderRadius.circular(50),
            ),
            child: Icon(Icons.history, size: 64, color: Colors.grey[400]),
          ),
          const SizedBox(height: 16),
          Text(
            'Aucune donnée d\'audit',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Commencez à utiliser l\'application pour voir l\'historique',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Color _getActionColor(String? action) {
    if (action == null) return Colors.grey;

    final actionLower = action.toLowerCase();
    if (actionLower.contains('connexion') || actionLower.contains('login')) {
      return Colors.green;
    } else if (actionLower.contains('déconnexion') ||
        actionLower.contains('logout')) {
      return Colors.red;
    } else if (actionLower.contains('création') ||
        actionLower.contains('ajout')) {
      return Colors.blue;
    } else if (actionLower.contains('modification') ||
        actionLower.contains('mise à jour')) {
      return Colors.orange;
    } else if (actionLower.contains('suppression') ||
        actionLower.contains('delete')) {
      return Colors.purple;
    } else if (actionLower.contains('accès') ||
        actionLower.contains('consultation')) {
      return Colors.teal;
    }

    return Colors.grey;
  }

  IconData _getActionIcon(String? action) {
    if (action == null) return Icons.info;

    final actionLower = action.toLowerCase();
    if (actionLower.contains('connexion') || actionLower.contains('login')) {
      return Icons.login;
    } else if (actionLower.contains('déconnexion') ||
        actionLower.contains('logout')) {
      return Icons.logout;
    } else if (actionLower.contains('création') ||
        actionLower.contains('ajout')) {
      return Icons.add_circle;
    } else if (actionLower.contains('modification') ||
        actionLower.contains('mise à jour')) {
      return Icons.edit;
    } else if (actionLower.contains('suppression') ||
        actionLower.contains('delete')) {
      return Icons.delete;
    } else if (actionLower.contains('accès') ||
        actionLower.contains('consultation')) {
      return Icons.visibility;
    }

    return Icons.info;
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return 'Date inconnue';

    try {
      final date = DateTime.parse(dateString);
      return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateString;
    }
  }

  void _showAuditDetails(Map<String, dynamic> item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _getActionColor(item['action']).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                _getActionIcon(item['action']),
                color: _getActionColor(item['action']),
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            const Text('Détails de l\'action'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailRow('Action:', item['action'] ?? 'Action inconnue'),
              _buildDetailRow(
                'Description:',
                item['description'] ?? 'Aucune description',
              ),
              _buildDetailRow(
                'Utilisateur:',
                item['user_name'] ?? 'Utilisateur inconnu',
              ),
              _buildDetailRow('Type:', item['type'] ?? 'AUTRE'),
              _buildDetailRow(
                'Date:',
                item['formatted_date'] ?? _formatDate(item['created_at']),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Fermer'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _exportSingleItem(item);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF3B82F6),
              foregroundColor: Colors.white,
            ),
            child: const Text('Exporter'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFF1F2937),
              ),
            ),
          ),
          Expanded(
            child: Text(value, style: TextStyle(color: Colors.grey[700])),
          ),
        ],
      ),
    );
  }

  void _showExportDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF3B82F6).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.download,
                color: Color(0xFF3B82F6),
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            const Text('Exporter le journal'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Choisissez le format d\'export:',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            _buildExportOption(
              'CSV',
              'Format Excel compatible',
              Icons.table_chart,
            ),
            const SizedBox(height: 8),
            _buildExportOption(
              'PDF',
              'Document imprimable',
              Icons.picture_as_pdf,
            ),
            const SizedBox(height: 8),
            _buildExportOption('JSON', 'Format de données brut', Icons.code),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _exportAllData();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF3B82F6),
              foregroundColor: Colors.white,
            ),
            child: const Text('Exporter'),
          ),
        ],
      ),
    );
  }

  Widget _buildExportOption(String format, String description, IconData icon) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF3B82F6)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  format,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF3B82F6),
                  ),
                ),
                Text(
                  description,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _exportAllData() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Exportation en cours...'),
        backgroundColor: Color(0xFF3B82F6),
      ),
    );

    // TODO: Implémenter l'exportation réelle
    Future.delayed(const Duration(seconds: 2), () {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Journal exporté avec succès!'),
          backgroundColor: Colors.blue,
        ),
      );
    });
  }

  void _exportSingleItem(Map<String, dynamic> item) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Exportation de: ${item['action']}'),
        backgroundColor: const Color(0xFF3B82F6),
      ),
    );

    // TODO: Implémenter l'exportation individuelle
  }
}
