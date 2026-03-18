import 'package:flutter/material.dart';
import 'package:marcelgestion/services/api_service.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  Map<String, dynamic>? _userData;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future _loadUserData() async {
    final userData = await ApiService.getUserData();
    setState(() {
      _userData = userData;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Dashboard")),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFF5F5F5), Color(0xFFE8EAF6), Color(0xFFE8EAF6)],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildWelcomeSection(),
              const SizedBox(height: 24),
              //_buildMainStats(),
              const SizedBox(height: 24),
              _buildAdminActions(context),
              const SizedBox(height: 24),
              _buildDetailedStats(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeSection() {
    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF7C3AED), Color(0xFF764BA2)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF7C3AED).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.admin_panel_settings,
                  color: Colors.white,
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Bienvenu(e) ${_userData!['name'] ?? ''}',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Gérez l\'ensemble du système',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withOpacity(0.3)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildQuickStat(
                  'Accesoires',
                  '12',
                  Icons.headphones,
                  Colors.white,
                ),
                _buildQuickStat(
                  'Téléphone',
                  '45',
                  Icons.phone_android,
                  Colors.white,
                ),
                _buildQuickStat(
                  'Ordinateurs',
                  '128',
                  Icons.desktop_mac,
                  Colors.white,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStat(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: color.withOpacity(0.8)),
        ),
      ],
    );
  }

  // Widget _buildMainStats() {
  //   return Column(
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     children: [
  //       const Text(
  //         'Aperçu rapide',
  //         style: TextStyle(
  //           fontSize: 20,
  //           fontWeight: FontWeight.bold,
  //           color: Color(0xFF1F2937),
  //         ),
  //       ),
  //       const SizedBox(height: 16),
  //       GridView.count(
  //         shrinkWrap: true,
  //         physics: const NeverScrollableScrollPhysics(),
  //         crossAxisCount: 2,
  //         mainAxisSpacing: 16,
  //         crossAxisSpacing: 16,
  //         childAspectRatio: 1.4,
  //         children: [
  //           _buildStatCard(
  //             'Utilisateurs',
  //             '45',
  //             '12 cette semaine',
  //             const Color(0xFFDC2626),
  //             Icons.people,
  //             Icons.trending_up,
  //             '+15%',
  //           ),
  //           _buildStatCard(
  //             'Produits',
  //             '128',
  //             '8 nouveaux',
  //             const Color(0xFF059669),
  //             Icons.inventory,
  //             Icons.trending_up,
  //             '+6.7%',
  //           ),
  //           _buildStatCard(
  //             'Ventes',
  //             '1,247',
  //             '234 aujourd\'hui',
  //             const Color(0xFF7C3AED),
  //             Icons.shopping_cart,
  //             Icons.trending_up,
  //             '+12%',
  //           ),
  //           _buildStatCard(
  //             'Revenus',
  //             '2.5M FCFA',
  //             '125K aujourd\'hui',
  //             const Color(0xFF6B7280),
  //             Icons.attach_money,
  //             Icons.trending_up,
  //             '+8%',
  //           ),
  //         ],
  //       ),
  //     ],
  //   );
  // }

  Widget _buildStatCard(
    String title,
    String value,
    String subtitle,
    Color color,
    IconData mainIcon,
    IconData trendIcon,
    String percentage,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(mainIcon, color: color, size: 20),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(trendIcon, color: Colors.green, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        percentage,
                        style: const TextStyle(
                          color: Colors.green,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdminActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Actions administratives',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1F2937),
          ),
        ),
        const SizedBox(height: 16),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 1.1,
          children: [
            _buildActionCard(
              context,
              Icons.people,
              'Gestion utilisateurs',
              const Color(0xFFDC2626),
              'Gérer les comptes',
              () {
                // TODO: Naviguer vers la gestion des utilisateurs
              },
            ),
            _buildActionCard(
              context,
              Icons.inventory,
              'Gestion produits',
              const Color(0xFF059669),
              'Catalogue produits',
              () {
                // TODO: Naviguer vers la gestion des produits
              },
            ),
            _buildActionCard(
              context,
              Icons.category,
              'Gestion catégories',
              const Color(0xFF7C3AED),
              'Organiser les catégories',
              () {
                // TODO: Naviguer vers la gestion des catégories
              },
            ),
            _buildActionCard(
              context,
              Icons.settings,
              'Paramètres',
              const Color(0xFF6B7280),
              'Configuration',
              () {
                // TODO: Naviguer vers les paramètres
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionCard(
    BuildContext context,
    IconData icon,
    String title,
    Color color,
    String description,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [color, color.withOpacity(0.8)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: color.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(icon, color: Colors.white, size: 32),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailedStats() {
    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Statistiques détaillées',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 20),
          Container(
            height: 200,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomLeft,
                end: Alignment.topRight,
                colors: [
                  const Color(0xFF7C3AED).withOpacity(0.1),
                  const Color(0xFF764BA2).withOpacity(0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.insert_chart, size: 48, color: Color(0xFF7C3AED)),
                  SizedBox(height: 8),
                  Text(
                    'Graphique des ventes',
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(0xFF7C3AED),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    'Visualisation des données',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Activités récentes',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 12),
          _buildActivityItem(
            'Nouvel utilisateur inscrit',
            'Il y a 5 minutes',
            Icons.person_add,
            Colors.green,
          ),
          _buildActivityItem(
            'Produit mis à jour',
            'Il y a 1 heure',
            Icons.inventory,
            Colors.blue,
          ),
          _buildActivityItem(
            'Vente enregistrée',
            'Il y a 2 heures',
            Icons.shopping_cart,
            Colors.purple,
          ),
          _buildActivityItem(
            'Système mis à jour',
            'Il y a 3 heures',
            Icons.system_update,
            Colors.orange,
          ),
        ],
      ),
    );
  }

  Widget _buildActivityItem(
    String title,
    String time,
    IconData icon,
    Color color,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF1F2937),
                  ),
                ),
                Text(
                  time,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
