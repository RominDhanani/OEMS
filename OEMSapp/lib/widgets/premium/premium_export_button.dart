import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

enum ExportType { pdf, excel, standard }

class PremiumExportButton extends StatelessWidget {
  final ExportType type;
  final VoidCallback onPressed;
  final bool isIconOnly;
  final String? tooltip;
  final String? customLabel;

  const PremiumExportButton({
    super.key,
    required this.type,
    required this.onPressed,
    this.isIconOnly = false,
    this.tooltip,
    this.customLabel,
  });

  @override
  Widget build(BuildContext context) {
    Color btnColor;
    IconData icon;
    String label;

    switch (type) {
      case ExportType.pdf:
        btnColor = Colors.red.shade600;
        icon = Icons.picture_as_pdf_rounded;
        label = "Export PDF";
        break;
      case ExportType.excel:
        btnColor = Colors.green.shade600;
        icon = Icons.table_view_rounded;
        label = "Export Excel";
        break;
      case ExportType.standard:
        btnColor = Theme.of(context).primaryColor;
        icon = Icons.file_download_rounded;
        label = "Download";
        break;
    }

    if (customLabel != null) {
      label = customLabel!;
    }

    if (isIconOnly) {
      return Tooltip(
        message: tooltip ?? label,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: btnColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: btnColor.withOpacity(0.4), width: 1.5),
                boxShadow: [
                  BoxShadow(color: btnColor.withOpacity(0.15), blurRadius: 8, offset: const Offset(0, 2)),
                ],
              ),
              child: Icon(icon, size: 20, color: btnColor),
            ),
          ),
        ),
      );
    }

    return Tooltip(
      message: tooltip ?? label,
      child: OutlinedButton.icon(
        icon: Icon(icon, size: 18, color: btnColor),
        label: Text(
          label,
          style: GoogleFonts.outfit(
            fontSize: 13,
            fontWeight: FontWeight.w800,
            color: btnColor,
            letterSpacing: 0.5,
          ),
        ),
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          side: BorderSide(color: btnColor.withOpacity(0.45), width: 1.8),
          backgroundColor: btnColor.withOpacity(0.1),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }
}
