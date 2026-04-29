import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/settings_provider.dart';
import '../status_badge.dart';
import 'premium_skeleton.dart';
import 'premium_export_button.dart';

class PremiumTable<T> extends ConsumerStatefulWidget {
  final List<T> data; // Changed from items to data to match screen usage
  final List<TableColumn<T>> columns;
  final List<String>? searchFields;
  final String? searchTerm;
  final ValueChanged<String>? onSearchChanged;
  final DateTime? startDate;
  final DateTime? endDate;
  final Function(DateTime?, DateTime?)? onDateRangeChanged;
  final Function(List<T>)? onExportPdf;
  final Function(List<T>)? onExportExcel;
  final String placeholder;
  final bool showDateFilters;
  final Widget? extraActions;
  final Function(T)? onTap;
  final List<Widget> Function(T)? customRowActions;
  final bool isLoading;

  const PremiumTable({
    super.key,
    required this.data,
    required this.columns,
    this.searchFields,
    this.searchTerm,
    this.onSearchChanged,
    this.startDate,
    this.endDate,
    this.onDateRangeChanged,
    this.onExportPdf,
    this.onExportExcel,
    this.placeholder = "Search...",
    this.showDateFilters = true,
    this.extraActions,
    this.onTap,
    this.customRowActions,
    this.isLoading = false,
  });

  @override
  ConsumerState<PremiumTable<T>> createState() => _PremiumTableState<T>();
}

class _PremiumTableState<T> extends ConsumerState<PremiumTable<T>> {
  int _currentPage = 1;
  int _itemsPerPage = 10;
  String _internalSearchTerm = "";

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    ref.watch(settingsProvider);

    // Apply internal filtering if searchFields is provided
    List<T> filteredData = widget.data;
    final activeSearch = widget.searchTerm ?? _internalSearchTerm;

    if (activeSearch.isNotEmpty) {
      final List<String> fieldsToSearch = widget.searchFields != null 
          ? List<String>.from(widget.searchFields!) 
          : widget.columns
              .map((c) => c.key)
              .where((k) => k != null)
              .cast<String>()
              .toList();
      
      // Always include 'id' in broad search if it exists in the data
      if (widget.searchFields == null && !fieldsToSearch.contains('id')) {
        fieldsToSearch.add('id');
      }

      filteredData = widget.data.where((item) {
        final query = activeSearch.toLowerCase();
        
        return fieldsToSearch.any((field) {
          try {
            final dynamic dItem = item;
            Map<String, dynamic>? map;
            try {
              map = dItem.toJson();
            } catch (_) {
              try {
                map = dItem.toMap();
              } catch (_) {}
            }
            
            final value = (item is Map ? item[field] : map?[field])?.toString().toLowerCase() ?? "";
            return value.contains(query);
          } catch (e) {
            return false;
          }
        });
      }).toList();
    }

    // Pagination logic
    final totalItems = filteredData.length;
    final totalPages = (totalItems / _itemsPerPage).ceil().clamp(1, 999999);
    
    if (_currentPage > totalPages) {
      _currentPage = 1;
    }

    final startIndex = (_currentPage - 1) * _itemsPerPage;
    final endIndex = (startIndex + _itemsPerPage).clamp(0, totalItems);
    final displayedItems = filteredData.isEmpty ? <T>[] : filteredData.sublist(startIndex, endIndex);

    return Column(
      children: [
        // Table Controls (Search, Dates, Download)
        _buildControls(theme),
        
        const SizedBox(height: 16),
        
        // Data Table
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: theme.cardTheme.color,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(theme.brightness == Brightness.dark ? 0.2 : 0.03),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
              border: Border.all(color: theme.colorScheme.onSurface.withOpacity(0.06)),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: widget.isLoading 
                ? _buildLoadingState()
                : filteredData.isEmpty
                  ? _buildEmptyState(theme)
                  : _buildDataTable(context, theme, displayedItems),
            ),
          ),
        ),
        
        // Pagination
        _buildPagination(theme, totalItems, totalPages),
      ],
    );
  }

  Widget _buildLoadingState() {
    return ListView.builder(
      itemCount: _itemsPerPage,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: SkeletonLine(width: double.infinity, height: 60),
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: theme.primaryColor.withOpacity(0.05),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.folder_open_outlined, size: 48, color: theme.primaryColor.withOpacity(0.3)),
          ),
          const SizedBox(height: 16),
          Text(
            "No Records Found",
            style: GoogleFonts.outfit(
              fontSize: 16,
              fontWeight: FontWeight.w900,
              color: theme.colorScheme.onSurface.withOpacity(0.75),
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Try adjusting your filters or search term",
            style: TextStyle(
              fontSize: 13,
              color: theme.colorScheme.onSurface.withOpacity(0.55),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDataTable(BuildContext context, ThemeData theme, List<T> displayedItems) {
    final settingsNotifier = ref.read(settingsProvider.notifier);
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SingleChildScrollView(
        child: DataTable(
          showCheckboxColumn: false,
          columnSpacing: 24,
          horizontalMargin: 16,
          headingRowHeight: 48,
          dataRowMinHeight: 56,
          dataRowMaxHeight: 64,
          headingRowColor: WidgetStateProperty.all(
            theme.brightness == Brightness.dark 
                ? theme.colorScheme.secondary.withOpacity(0.06)
                : theme.primaryColor.withOpacity(0.015)
          ),
          headingTextStyle: GoogleFonts.outfit(
            color: theme.colorScheme.onSurface.withOpacity(0.7),
            fontWeight: FontWeight.w900,
            letterSpacing: 1.5,
            fontSize: 10,
          ),
          dataTextStyle: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface.withOpacity(0.9),
          ),
          columns: [
            ...widget.columns.map((col) => DataColumn(
              label: Text(col.label.toUpperCase()),
            )),
            if (widget.customRowActions != null)
              const DataColumn(label: Text("ACTIONS")),
          ],
          rows: displayedItems.map((item) => DataRow(
            onSelectChanged: widget.onTap != null ? (_) => widget.onTap!(item) : null,
            cells: [
              ...widget.columns.map((col) {
                if (col.builder != null) {
                  return DataCell(col.builder!(context, item));
                }
                
                // Default rendering based on key/format
                final Map<String, dynamic> itemMap = item is Map 
                    ? Map<String, dynamic>.from(item) 
                    : Map<String, dynamic>.from((item as dynamic).toJson());
                dynamic value = itemMap[col.key];
                
                if (col.isStatus) {
                  return DataCell(StatusBadge(status: value?.toString() ?? ""));
                }
                
                String displayValue = value?.toString() ?? "-";
                if (col.format != null) {
                  displayValue = col.format!(value);
                } else if (col.isCurrency) {
                  displayValue = settingsNotifier.formatCurrency(double.tryParse(value.toString()) ?? 0.0);
                }

                return DataCell(Text(displayValue));
              }),
              if (widget.customRowActions != null)
                DataCell(
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 250),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: widget.customRowActions!(item),
                    ),
                  ),
                ),
            ],
          )).toList(),
        ),
      ),
    );
  }

  Widget _buildControls(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.fromLTRB(5, 4, 5, 6),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(32), bottomRight: Radius.circular(32)),
      ),
      child: Row(
        children: [
          // Search Bar
          Expanded(
            flex: 3,
            child: Container(
              height: 56,
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
                onChanged: (val) {
                  setState(() => _internalSearchTerm = val);
                  widget.onSearchChanged?.call(val);
                },
                style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w600),
                decoration: InputDecoration(
                  hintText: widget.placeholder,
                  hintStyle: GoogleFonts.outfit(color: theme.colorScheme.onSurface.withOpacity(0.45), fontWeight: FontWeight.w500),
                  prefixIcon: Icon(Icons.search_rounded, size: 22, color: theme.colorScheme.secondary),
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
          
          if (widget.showDateFilters) ...[
            const SizedBox(width: 12),
            _DateRangeSelector(
              startDate: widget.startDate,
              endDate: widget.endDate,
              onChanged: widget.onDateRangeChanged,
            ),
          ],

          if (widget.onExportPdf != null) ...[
            const SizedBox(width: 12),
            PremiumExportButton(
              type: ExportType.pdf,
              isIconOnly: true,
              onPressed: () => widget.onExportPdf!(widget.data),
            ),
          ],

          if (widget.onExportExcel != null) ...[
            const SizedBox(width: 12),
            PremiumExportButton(
              type: ExportType.excel,
              isIconOnly: true,
              onPressed: () => widget.onExportExcel!(widget.data),
            ),
          ],
          
          if (widget.extraActions != null) ...[
            const SizedBox(width: 12),
            widget.extraActions!,
          ],
        ],
      ),
    );
  }

  Widget _buildPagination(ThemeData theme, int totalItems, int totalPages) {
    if (totalItems == 0) return const SizedBox.shrink();

    final startItem = (_currentPage - 1) * _itemsPerPage + 1;
    final endItem = (_currentPage * _itemsPerPage) > totalItems
        ? totalItems
        : (_currentPage * _itemsPerPage);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
        border: Border(top: BorderSide(color: theme.dividerColor.withOpacity(0.05))),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  'Showing $startItem-$endItem of $totalItems',
                  style: GoogleFonts.outfit(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: theme.textTheme.bodySmall?.color,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              InkWell(
                onTap: () async {
                  final int? result = await showModalBottomSheet<int>(
                    context: context,
                    backgroundColor: Colors.transparent,
                    isScrollControlled: true,
                    builder: (context) => _RowsPerPageSheet(
                      currentValue: _itemsPerPage,
                      options: const [5, 10, 25, 50],
                    ),
                  );
                  if (result != null) {
                    setState(() {
                      _itemsPerPage = result;
                      _currentPage = 1; // Reset to first page
                    });
                  }
                },
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.onSurface.withOpacity(0.04),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: theme.colorScheme.onSurface.withOpacity(0.08)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('ROWS:', style: GoogleFonts.outfit(fontSize: 10, fontWeight: FontWeight.w900, color: theme.colorScheme.secondary, letterSpacing: 0.5)),
                      const SizedBox(width: 8),
                      Text(
                        _itemsPerPage.toString(),
                        style: GoogleFonts.outfit(fontSize: 13, color: theme.colorScheme.onSurface, fontWeight: FontWeight.w900),
                      ),
                      const SizedBox(width: 4),
                      Icon(Icons.keyboard_arrow_down_rounded, size: 14, color: theme.colorScheme.onSurface.withOpacity(0.5)),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Pagination controls
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _PaginationButton(
                  icon: Icons.first_page_rounded,
                  onPressed: _currentPage > 1 ? () => setState(() => _currentPage = 1) : null,
                ),
                const SizedBox(width: 4),
                _PaginationButton(
                  icon: Icons.chevron_left_rounded,
                  onPressed: _currentPage > 1 ? () => setState(() => _currentPage--) : null,
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.secondary.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Page $_currentPage / $totalPages',
                    style: GoogleFonts.outfit(
                      fontWeight: FontWeight.w900,
                      fontSize: 12,
                      color: theme.colorScheme.secondary,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                _PaginationButton(
                  icon: Icons.chevron_right_rounded,
                  onPressed: _currentPage < totalPages ? () => setState(() => _currentPage++) : null,
                ),
                const SizedBox(width: 4),
                _PaginationButton(
                  icon: Icons.last_page_rounded,
                  onPressed: _currentPage < totalPages ? () => setState(() => _currentPage = totalPages) : null,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DateRangeSelector extends StatelessWidget {
  final DateTime? startDate;
  final DateTime? endDate;
  final Function(DateTime?, DateTime?)? onChanged;

  const _DateRangeSelector({
    this.startDate,
    this.endDate,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool isActive = startDate != null && endDate != null;
    
    return Material(
      color: isActive ? theme.colorScheme.secondary : theme.colorScheme.onSurface.withOpacity(0.08),
      borderRadius: BorderRadius.circular(20),
      elevation: isActive ? 6 : 0,
      shadowColor: theme.colorScheme.secondary.withOpacity(0.3),
      child: InkWell(
        onTap: () async {
          final picked = await showDateRangePicker(
            context: context,
            firstDate: DateTime(2023),
            lastDate: DateTime(2030),
            initialDateRange: isActive
                ? DateTimeRange(start: startDate!, end: endDate!)
                : null,
            builder: (context, child) {
              return Theme(
                data: theme.copyWith(
                  colorScheme: theme.colorScheme.copyWith(
                    primary: theme.primaryColor,
                    onPrimary: Colors.white,
                  ),
                ),
                child: child!,
              );
            },
          );
          if (picked != null) {
            onChanged?.call(picked.start, picked.end);
          }
        },
        borderRadius: BorderRadius.circular(20),
        child: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: isActive ? null : Border.all(color: theme.colorScheme.onSurface.withOpacity(0.15)),
          ),
          child: Icon(
            Icons.calendar_month_rounded, 
            size: 22, 
            color: isActive ? Colors.white : theme.colorScheme.onSurface.withOpacity(0.85),
          ),
        ),
      ),
    );
  }
}

class _PaginationButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;

  const _PaginationButton({required this.icon, this.onPressed});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: theme.colorScheme.onSurface.withOpacity(0.12),
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(8),
          child: Icon(icon, size: 20, color: onPressed == null ? theme.disabledColor.withOpacity(0.3) : theme.colorScheme.onSurface.withOpacity(0.95)),
        ),
      ),
    );
  }
}

class TableColumn<T> {
  final String label;
  final String? key;
  final Widget Function(BuildContext context, T item)? builder;
  final String Function(dynamic)? format;
  final bool isCurrency;
  final bool isStatus;

  TableColumn({
    required this.label,
    this.key,
    this.builder,
    this.format,
    this.isCurrency = false,
    this.isStatus = false,
  });
}

typedef PremiumTableColumn<T> = TableColumn<T>;

class _RowsPerPageSheet extends StatelessWidget {
  final int currentValue;
  final List<int> options;

  const _RowsPerPageSheet({required this.currentValue, required this.options});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 40, height: 4, decoration: BoxDecoration(color: theme.colorScheme.onSurface.withOpacity(0.1), borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 24),
          Row(
            children: [
              Text("ROWS PER PAGE", style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 1.5, color: theme.colorScheme.secondary)),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: options.map((opt) {
              final isSelected = opt == currentValue;
              return InkWell(
                onTap: () => Navigator.pop(context, opt),
                borderRadius: BorderRadius.circular(16),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  decoration: BoxDecoration(
                    color: isSelected ? theme.primaryColor : theme.colorScheme.onSurface.withOpacity(0.04),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: isSelected ? [BoxShadow(color: theme.primaryColor.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))] : null,
                  ),
                  child: Text(
                    opt.toString(),
                    style: GoogleFonts.outfit(
                      color: isSelected ? Colors.white : theme.colorScheme.onSurface,
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
