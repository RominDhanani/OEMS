import 'package:flutter/material.dart';

class NavItem {
  final String id;
  final String label;
  final IconData icon;
  final String? route;
  final List<NavItem>? subItems;

  const NavItem({
    required this.id,
    required this.label,
    required this.icon,
    this.route,
    this.subItems,
  });
}

class NavigationUtils {
  static List<NavItem> getMenuItems(String role) {
    switch (role) {

      case 'MANAGER':
        return [
          const NavItem(id: 'dashboard', label: 'Dashboard', icon: Icons.dashboard_outlined, route: '/manager_dashboard'),
          const NavItem(
            id: 'expenses_root', 
            label: 'Expenses', 
            icon: Icons.receipt_long_outlined,
            subItems: [
              NavItem(id: 'add_expense', label: 'Add Expense', icon: Icons.add_circle_outline, route: '/create_expense'),
              NavItem(id: 'my_expenses', label: 'My Expenses', icon: Icons.list_alt, route: '/expenses'),
              NavItem(id: 'pending_team', label: 'Pending Approval', icon: Icons.check_circle_outline, route: '/expenses?scope=team&filter=pending'),
              NavItem(id: 'all_team', label: 'All Team Expenses', icon: Icons.groups_outlined, route: '/expenses?scope=team'),
            ],
          ),
          const NavItem(id: 'reports', label: 'Reports', icon: Icons.assessment_outlined, route: '/reports'),
          const NavItem(id: 'profile', label: 'Settings', icon: Icons.settings_outlined, route: '/profile'),
        ];
      case 'USER':
        return [
          const NavItem(id: 'dashboard', label: 'Dashboard', icon: Icons.dashboard_outlined, route: '/user_dashboard'),
          const NavItem(
            id: 'expenses_root', 
            label: 'Expenses', 
            icon: Icons.receipt_long_outlined,
            subItems: [
              NavItem(id: 'add_expense', label: 'Add Expense', icon: Icons.add_circle_outline, route: '/create_expense'),
              NavItem(id: 'my_expenses', label: 'My Expenses', icon: Icons.list_alt, route: '/expenses'),
            ],
          ),
          const NavItem(id: 'reports', label: 'Reports', icon: Icons.assessment_outlined, route: '/reports'),
          const NavItem(id: 'profile', label: 'Settings', icon: Icons.settings_outlined, route: '/profile'),
        ];
      default:
        return [];
    }
  }

  static List<String> getBreadcrumbs(String role, String currentPath) {
    final items = getMenuItems(role);
    for (final item in items) {
      if (item.route == currentPath) {
        return [item.label];
      }
      if (item.subItems != null) {
        for (final sub in item.subItems!) {
          if (sub.route == currentPath) {
            return [item.label, sub.label];
          }
        }
      }
    }
    return [currentPath.split('/').last.replaceAll('_', ' ').split(' ').map((e) => e.isNotEmpty ? e[0].toUpperCase() + e.substring(1) : '').join(' ')];
  }
}
