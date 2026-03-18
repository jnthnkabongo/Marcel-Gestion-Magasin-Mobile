import 'package:flutter/material.dart';
import 'package:marcelgestion/pages/Administrateur/dashboard.dart';
import 'package:marcelgestion/pages/Administrateur/parametres.dart';
import 'package:marcelgestion/pages/Administrateur/produit.dart';
import 'package:marcelgestion/pages/Administrateur/rapport.dart';
import 'package:marcelgestion/pages/Administrateur/vente_marcel.dart';

class MainPageAdmin extends StatefulWidget {
  const MainPageAdmin({super.key});

  @override
  State<MainPageAdmin> createState() => _MainPageAdminState();
}

class _MainPageAdminState extends State<MainPageAdmin> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const AdminDashboard(),
    const RapportPage(),
    const ProduitPage(),
    const VentePage(),
    const ParametresPage(),
  ];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          // borderRadius: const BorderRadius.only(
          //   topLeft: Radius.circular(20),
          //   topRight: Radius.circular(20),
          // ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(
                  icon: Icons.home_outlined,
                  selectedIcon: Icons.home,
                  label: 'Home',
                  index: 0,
                ),
                _buildNavItem(
                  icon: Icons.bar_chart_outlined,
                  selectedIcon: Icons.bar_chart,
                  label: 'Rapport',
                  index: 1,
                ),
                _buildNavItem(
                  icon: Icons.inventory_outlined,
                  selectedIcon: Icons.inventory,
                  label: 'Produits',
                  index: 2,
                ),
                _buildNavItem(
                  icon: Icons.payment_outlined,
                  selectedIcon: Icons.payment,
                  label: 'Ventes',
                  index: 3,
                ),
                _buildNavItem(
                  icon: Icons.settings_outlined,
                  selectedIcon: Icons.settings,
                  label: 'Paramètres',
                  index: 4,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required IconData selectedIcon,
    required String label,
    required int index,
  }) {
    final isSelected = _selectedIndex == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedIndex = index;
        });
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isSelected ? selectedIcon : icon,
            color: isSelected ? Color(0xFF7C3AED) : Colors.grey,
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? Color(0xFF7C3AED) : Colors.grey,
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
          if (isSelected)
            Container(
              margin: const EdgeInsets.only(top: 4),
              height: 2,
              width: 20,
              decoration: BoxDecoration(
                color: const Color(0xFF7C3AED),
                // borderRadius: BorderRadius.circular(1),
              ),
            ),
        ],
      ),
    );
  }
}
