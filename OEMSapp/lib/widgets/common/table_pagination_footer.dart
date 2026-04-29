import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TablePaginationFooter extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final int totalItems;
  final int itemsPerPage;
  final List<int> itemsPerPageOptions;
  final Function(int) onPageChanged;
  final Function(int) onItemsPerPageChanged;

  const TablePaginationFooter({
    super.key,
    required this.currentPage,
    required this.totalPages,
    required this.totalItems,
    required this.itemsPerPage,
    this.itemsPerPageOptions = const [5, 10, 25, 50],
    required this.onPageChanged,
    required this.onItemsPerPageChanged,
  });

  @override
  Widget build(BuildContext context) {
    if (totalItems == 0) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final startItem = (currentPage - 1) * itemsPerPage + 1;
    final endItem = (currentPage * itemsPerPage) > totalItems
        ? totalItems
        : (currentPage * itemsPerPage);

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        border: Border(top: BorderSide(color: theme.dividerColor.withOpacity(0.05))),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Showing $startItem-$endItem of $totalItems',
                style: GoogleFonts.outfit(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: theme.textTheme.bodySmall?.color,
                  letterSpacing: 0.5,
                ),
              ),
              InkWell(
                onTap: () async {
                  final int? result = await showModalBottomSheet<int>(
                    context: context,
                    backgroundColor: Colors.transparent,
                    isScrollControlled: true,
                    builder: (context) => _RowsPerPageSheet(
                      currentValue: itemsPerPage,
                      options: itemsPerPageOptions,
                    ),
                  );
                  if (result != null) onItemsPerPageChanged(result);
                },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.onSurface.withOpacity(0.04),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: theme.colorScheme.onSurface.withOpacity(0.08)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('ROWS:', style: GoogleFonts.outfit(fontSize: 10, fontWeight: FontWeight.w900, color: theme.primaryColor, letterSpacing: 0.5)),
                      const SizedBox(width: 8),
                      Text(
                        itemsPerPage.toString(),
                        style: GoogleFonts.outfit(fontSize: 13, color: theme.colorScheme.onSurface, fontWeight: FontWeight.w900),
                      ),
                      const SizedBox(width: 4),
                      Icon(Icons.keyboard_arrow_down_rounded, size: 16, color: theme.colorScheme.onSurface.withOpacity(0.5)),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _PageButton(
                icon: Icons.first_page_rounded,
                onPressed: currentPage > 1 ? () => onPageChanged(1) : null,
              ),
              const SizedBox(width: 4),
              _PageButton(
                icon: Icons.chevron_left_rounded,
                onPressed: currentPage > 1 ? () => onPageChanged(currentPage - 1) : null,
              ),
              const SizedBox(width: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: theme.primaryColor,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: theme.primaryColor.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Text(
                  '$currentPage / $totalPages',
                  style: GoogleFonts.outfit(
                    fontWeight: FontWeight.w900,
                    fontSize: 13,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              _PageButton(
                icon: Icons.chevron_right_rounded,
                onPressed: currentPage < totalPages ? () => onPageChanged(currentPage + 1) : null,
              ),
              const SizedBox(width: 4),
              _PageButton(
                icon: Icons.last_page_rounded,
                onPressed: currentPage < totalPages ? () => onPageChanged(totalPages) : null,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PageButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;

  const _PageButton({required this.icon, this.onPressed});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDisabled = onPressed == null;

    return Material(
      color: isDisabled ? Colors.transparent : theme.colorScheme.surface,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDisabled ? theme.dividerColor.withOpacity(0.05) : theme.dividerColor.withOpacity(0.1),
            ),
          ),
          child: Icon(
            icon,
            size: 20,
            color: isDisabled ? theme.disabledColor.withOpacity(0.3) : theme.primaryColor,
          ),
        ),
      ),
    );
  }
}

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
              Text("ROWS PER PAGE", style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 1.2, color: Colors.grey)),
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
