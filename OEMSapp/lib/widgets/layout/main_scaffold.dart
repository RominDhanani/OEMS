import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';


class MainScaffold extends StatefulWidget {
  final StatefulNavigationShell navigationShell;

  const MainScaffold({
    super.key,
    required this.navigationShell,
  });

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  // Track navigation history to support logical back-button behavior
  final List<int> _history = [];

  void _goBranch(int index) {
    if (index != widget.navigationShell.currentIndex) {
      // Record the current index before moving to the new one
      _history.add(widget.navigationShell.currentIndex);
      HapticFeedback.selectionClick();
    }
    
    widget.navigationShell.goBranch(
      index,
      initialLocation: index == widget.navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return PopScope(
      canPop: _history.isEmpty && widget.navigationShell.currentIndex == 0,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;

        if (_history.isNotEmpty) {
          // Navigate to the previous tab in history
          final prevIndex = _history.removeLast();
          widget.navigationShell.goBranch(prevIndex);
          setState(() {});
        } else if (widget.navigationShell.currentIndex != 0) {
          // If history is empty but we aren't on the Home tab, go to Home
          widget.navigationShell.goBranch(0);
          setState(() {});
        }
      },
      child: Scaffold(
        extendBody: false,
        body: widget.navigationShell,
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            border: Border(top: BorderSide(color: theme.dividerColor.withOpacity(0.05))),
          ),
          child: NavigationBar(
            selectedIndex: widget.navigationShell.currentIndex,
            onDestinationSelected: _goBranch,
            labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
            height: 72,
            destinations: [
              _buildNavDestination(Icons.dashboard_outlined, Icons.dashboard, "Home"),
              _buildNavDestination(Icons.receipt_long_outlined, Icons.receipt_long, "Expenses"),
              _buildNavDestination(Icons.assessment_outlined, Icons.assessment, "Reports"),
              _buildNavDestination(Icons.person_outline, Icons.person, "Profile"),
            ],
          ),
        ),
      ),
    );
  }

  NavigationDestination _buildNavDestination(IconData icon, IconData selectedIcon, String label) {
    return NavigationDestination(
      icon: Icon(icon, size: 24),
      selectedIcon: Icon(selectedIcon, size: 24),
      label: label,
      tooltip: label,
    );
  }
}

