import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/expense_model.dart';
import '../core/utils/path_utils.dart';

class DocumentList extends StatelessWidget {
  final List<ExpenseDocument> documents;
  final Function(ExpenseDocument)? onDelete;
  const DocumentList({super.key, required this.documents, this.onDelete});

  @override
  Widget build(BuildContext context) {
    if (documents.isEmpty) return const SizedBox.shrink();
    final theme = Theme.of(context);

    return Column(
      children: documents.asMap().entries.map((entry) {
        final doc = entry.value;
        final isPdf = doc.fileType == 'application/pdf' || doc.documentPath.toLowerCase().endsWith('.pdf');
        
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: theme.dividerColor.withOpacity(0.1)),
          ),
          child: Row(
            children: [
              // Styled Icon Box
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: theme.dividerColor.withOpacity(0.1)),
                ),
                child: Icon(
                  isPdf ? Icons.insert_drive_file_outlined : Icons.image_outlined,
                  size: 16,
                  color: theme.colorScheme.onSurface.withOpacity(0.5),
                ),
              ),
              const SizedBox(width: 10),
              // Name and Type
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      doc.originalFilename,
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Text(
                      "Voucher",
                      style: TextStyle(fontSize: 10, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              // Actions
              Row(
                children: [
                   if (onDelete != null) ...[
                    _ActionButton(
                      icon: Icons.delete_outline,
                      color: Colors.red,
                      onPressed: () => onDelete!(doc),
                      tooltip: "Delete",
                    ),
                    const SizedBox(width: 8),
                  ],
                  _ActionButton(
                    icon: Icons.visibility_outlined,
                    color: theme.primaryColor,
                    onPressed: () => _showDocument(context, doc),
                    tooltip: "View",
                  ),
                  const SizedBox(width: 8),
                  _ActionButton(
                    icon: Icons.download_outlined,
                    color: theme.primaryColor,
                    backgroundColor: theme.primaryColor.withOpacity(0.1),
                    onPressed: () => _downloadDocument(doc),
                    tooltip: "Download",
                  ),
                ],
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  void _showDocument(BuildContext context, ExpenseDocument doc) {
    final url = PathUtils.normalizeImageUrl(doc.documentPath);
    final isPdf = doc.fileType == 'application/pdf' || doc.documentPath.toLowerCase().endsWith('.pdf');

    showDialog(
      context: context,
      builder: (context) => Dialog.fullscreen(
        child: Scaffold(
          appBar: AppBar(
            title: Text(doc.originalFilename, style: const TextStyle(fontSize: 16)),
            actions: [
              IconButton(
                icon: const Icon(Icons.close), 
                onPressed: () => Navigator.pop(context)
              )
            ],
          ),
          body: isPdf 
              ? SfPdfViewer.network(url)
              : Center(
                  child: InteractiveViewer(
                    child: Image.network(
                      url,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return const Center(child: CircularProgressIndicator());
                      },
                      errorBuilder: (context, error, stackTrace) => const Text("Failed to load image"),
                    ),
                  ),
                ),
        ),
      ),
    );
  }

  Future<void> _downloadDocument(ExpenseDocument doc) async {
    final url = Uri.parse(PathUtils.normalizeImageUrl(doc.documentPath));
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final Color? backgroundColor;
  final VoidCallback onPressed;
  final String tooltip;

  const _ActionButton({
    required this.icon,
    required this.color,
    this.backgroundColor,
    required this.onPressed,
    required this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(6),
        child: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: backgroundColor ?? Colors.transparent,
            border: Border.all(color: color.withOpacity(0.2)),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(icon, size: 16, color: color),
        ),
      ),
    );
  }
}

