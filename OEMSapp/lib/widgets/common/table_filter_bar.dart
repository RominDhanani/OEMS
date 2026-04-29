import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class TableFilterBar extends StatelessWidget {
  final TextEditingController searchController;
  final String searchPlaceholder;
  final DateTimeRange? dateRange;
  final Function(DateTimeRange?) onDateRangeChanged;
  final Map<String, List<String>> dropdownFilters;
  final Map<String, String> selectedFilters;
  final Function(String, String) onFilterChanged;
  final VoidCallback onClearFilters;

  const TableFilterBar({
    super.key,
    required this.searchController,
    this.searchPlaceholder = "Search...",
    this.dateRange,
    required this.onDateRangeChanged,
    this.dropdownFilters = const {},
    required this.selectedFilters,
    required this.onFilterChanged,
    required this.onClearFilters,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(32), bottomRight: Radius.circular(32)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: theme.colorScheme.onSurface.withOpacity(0.05),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: searchController,
                    style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600),
                    decoration: InputDecoration(
                      hintText: searchPlaceholder,
                      hintStyle: GoogleFonts.inter(color: theme.colorScheme.onSurface.withOpacity(0.3)),
                      prefixIcon: Icon(Icons.search_rounded, size: 22, color: theme.primaryColor),
                      suffixIcon: searchController.text.isNotEmpty 
                        ? IconButton(
                            icon: const Icon(Icons.close_rounded, size: 18),
                            onPressed: () => searchController.clear(),
                          )
                        : null,
                      filled: true,
                      fillColor: Colors.transparent,
                      contentPadding: const EdgeInsets.symmetric(vertical: 18),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              _buildFilterActionButton(
                context, 
                Icons.tune_rounded, 
                () => _showAdvancedFilters(context),
                isActive: selectedFilters.values.any((v) => v != 'All') || dateRange != null,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterActionButton(BuildContext context, IconData icon, VoidCallback onTap, {bool isActive = false}) {
    final theme = Theme.of(context);
    return Material(
      color: isActive ? theme.primaryColor : theme.colorScheme.surface,
      borderRadius: BorderRadius.circular(18),
      elevation: isActive ? 4 : 0,
      shadowColor: theme.primaryColor.withOpacity(0.3),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: isActive ? null : Border.all(color: theme.colorScheme.onSurface.withOpacity(0.08)),
          ),
          child: Icon(icon, color: isActive ? Colors.white : theme.colorScheme.onSurface, size: 24),
        ),
      ),
    );
  }


  void _showAdvancedFilters(BuildContext context) {
    final theme = Theme.of(context);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          decoration: BoxDecoration(
            color: theme.scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          ),
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 40),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)))),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Advanced Filters", style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: -0.5)),
                    TextButton(
                      onPressed: () {
                        onClearFilters();
                        Navigator.pop(context);
                      },
                      child: Text("Reset All", style: GoogleFonts.outfit(color: Colors.red, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Text("DATE RANGE", style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.w900, color: Colors.grey, letterSpacing: 1.2)),
                const SizedBox(height: 12),
                InkWell(
                  onTap: () async {
                    final picked = await showDateRangePicker(
                      context: context,
                      firstDate: DateTime(2023),
                      lastDate: DateTime(2030),
                      initialDateRange: dateRange,
                    );
                    if (picked != null) {
                      onDateRangeChanged(picked);
                      setModalState(() {});
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: dateRange != null ? theme.primaryColor : theme.colorScheme.onSurface.withOpacity(0.08)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.calendar_today_rounded, size: 18, color: dateRange != null ? theme.primaryColor : Colors.grey),
                        const SizedBox(width: 12),
                        Text(
                          dateRange == null ? "Select Date Range" : "${DateFormat('dd-MM-yyyy').format(dateRange!.start)} - ${DateFormat('dd-MM-yyyy').format(dateRange!.end)}",
                          style: GoogleFonts.outfit(
                            fontWeight: FontWeight.bold,
                            color: dateRange != null ? theme.primaryColor : theme.colorScheme.onSurface.withOpacity(0.4),
                          ),
                        ),
                        const Spacer(),
                        if (dateRange != null) IconButton(icon: const Icon(Icons.close, size: 16), onPressed: () { onDateRangeChanged(null); setModalState(() {}); }),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                for (var entry in dropdownFilters.entries) ...[
                    Text(entry.key.toUpperCase(), style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.w900, color: Colors.grey, letterSpacing: 1.2)),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _buildAdvancedChip(context, "All", selectedFilters[entry.key] == 'All', () {
                          onFilterChanged(entry.key, "All");
                          setModalState(() {});
                        }),
                        for (var val in entry.value)
                          _buildAdvancedChip(context, val.replaceAll('_', ' '), selectedFilters[entry.key] == val, () {
                            onFilterChanged(entry.key, val);
                            setModalState(() {});
                          }),
                      ],
                    ),
                    const SizedBox(height: 24),
                  ],
                const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.primaryColor,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 60),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 8,
                      shadowColor: theme.primaryColor.withOpacity(0.4),
                    ),
                    child: Text("Apply Filters", style: GoogleFonts.outfit(fontWeight: FontWeight.w900, fontSize: 16)),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAdvancedChip(BuildContext context, String label, bool isSelected, VoidCallback onTap) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? theme.primaryColor : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? theme.primaryColor : theme.colorScheme.onSurface.withOpacity(0.1),
          ),
          boxShadow: isSelected ? [
            BoxShadow(
              color: theme.primaryColor.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            )
          ] : null,
        ),
        child: Text(
          label,
          style: GoogleFonts.outfit(
            color: isSelected ? Colors.white : theme.colorScheme.onSurface.withOpacity(0.7),
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
