import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PremiumDropdown<T> extends FormField<T> {
  final String label;
  final String? hintText;
  final List<PremiumDropdownItem<T>> items;
  final ValueChanged<T?>? onChanged;
  final IconData? prefixIcon;
  PremiumDropdown({
    super.key,
    required this.label,
    required this.items,
    this.hintText,
    this.onChanged,
    this.prefixIcon,
    super.initialValue,
    super.validator,
  }) : super(
          builder: (FormFieldState<T> state) {
            final theme = Theme.of(state.context);
            final hasError = state.hasError;
            final selectedItem = items.where((i) => i.value == state.value).firstOrNull;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InkWell(
                  onTap: () async {
                    final T? result = await showModalBottomSheet<T>(
                      context: state.context,
                      backgroundColor: Colors.transparent,
                      isScrollControlled: true,
                      builder: (context) => _DropdownSheet<T>(
                        title: label,
                        items: items,
                        selectedValue: state.value,
                      ),
                    );

                    if (result != null) {
                      state.didChange(result);
                      onChanged?.call(result);
                    }
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.onSurface.withOpacity(0.04),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: hasError 
                          ? Colors.red 
                          : (state.value != null ? theme.primaryColor.withOpacity(0.5) : Colors.transparent),
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      children: [
                        if (prefixIcon != null) ...[
                          Icon(
                            prefixIcon,
                            size: 20,
                            color: state.value != null ? theme.primaryColor : theme.colorScheme.onSurface.withOpacity(0.4),
                          ),
                          const SizedBox(width: 12),
                        ],
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                label,
                                style: GoogleFonts.outfit(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w900,
                                  color: state.value != null ? theme.primaryColor : theme.colorScheme.onSurface.withOpacity(0.4),
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                selectedItem?.label ?? hintText ?? "Tap to select",
                                style: GoogleFonts.outfit(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: state.value != null 
                                    ? theme.colorScheme.onSurface 
                                    : theme.colorScheme.onSurface.withOpacity(0.3),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: theme.colorScheme.onSurface.withOpacity(0.3),
                        ),
                      ],
                    ),
                  ),
                ),
                if (hasError)
                  Padding(
                    padding: const EdgeInsets.only(top: 6, left: 12),
                    child: Text(
                      state.errorText!,
                      style: const TextStyle(color: Colors.red, fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                  ),
              ],
            );
          },
        );
}

class PremiumDropdownItem<T> {
  final T value;
  final String label;
  final IconData? icon;
  final String? subtitle;

  PremiumDropdownItem({
    required this.value,
    required this.label,
    this.icon,
    this.subtitle,
  });
}

class _DropdownSheet<T> extends StatelessWidget {
  final String title;
  final List<PremiumDropdownItem<T>> items;
  final T? selectedValue;

  const _DropdownSheet({
    required this.title,
    required this.items,
    this.selectedValue,
  });

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
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: theme.colorScheme.onSurface.withOpacity(0.1),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Text(
                title.toUpperCase(),
                style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 1.2, color: Colors.grey),
              ),
              const Spacer(),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close_rounded),
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                final isSelected = item.value == selectedValue;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: InkWell(
                    onTap: () => Navigator.pop(context, item.value),
                    borderRadius: BorderRadius.circular(16),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      decoration: BoxDecoration(
                        color: isSelected ? theme.primaryColor.withOpacity(0.08) : Colors.transparent,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected ? theme.primaryColor : Colors.transparent,
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        children: [
                          if (item.icon != null) ...[
                            Icon(
                              item.icon,
                              color: isSelected ? theme.primaryColor : theme.colorScheme.onSurface.withOpacity(0.5),
                              size: 24,
                            ),
                            const SizedBox(width: 16),
                          ],
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.label,
                                  style: GoogleFonts.outfit(
                                    fontWeight: isSelected ? FontWeight.w900 : FontWeight.w700,
                                    fontSize: 16,
                                    color: isSelected ? theme.primaryColor : theme.colorScheme.onSurface,
                                  ),
                                ),
                                if (item.subtitle != null)
                                  Text(
                                    item.subtitle!,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: theme.colorScheme.onSurface.withOpacity(0.5),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          if (isSelected)
                            Icon(Icons.check_circle_rounded, color: theme.primaryColor),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
