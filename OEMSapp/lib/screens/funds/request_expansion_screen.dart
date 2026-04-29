import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/expansion_provider.dart';
import '../../providers/toast_provider.dart';
import '../../widgets/common/erp_toast.dart';
import '../../widgets/common/sticky_bottom_cta.dart';
import '../../models/expansion_model.dart';
import '../../widgets/premium/glass_card.dart';
import '../../widgets/common/shake_widget.dart';


class RequestExpansionScreen extends ConsumerStatefulWidget {
  final ExpansionModel? expansion;
  final String? preFillExpenseId;
  final String? preFillAmount;
  final String? preFillJustification;

  const RequestExpansionScreen({
    super.key,
    this.expansion,
    this.preFillExpenseId,
    this.preFillAmount,
    this.preFillJustification,
  });

  @override
  ConsumerState<RequestExpansionScreen> createState() => _RequestExpansionScreenState();
}

class _RequestExpansionScreenState extends ConsumerState<RequestExpansionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _justificationController = TextEditingController();

  final _amountShakeKey = GlobalKey<ShakeWidgetState>();
  final _justificationShakeKey = GlobalKey<ShakeWidgetState>();

  @override
  void initState() {
    super.initState();
    if (widget.expansion != null) {
      _amountController.text = widget.expansion!.requestedAmount.toString();
      _justificationController.text = widget.expansion!.justification;
    } else {
      if (widget.preFillAmount != null) {
        _amountController.text = widget.preFillAmount!;
      }
      if (widget.preFillJustification != null) {
        _justificationController.text = widget.preFillJustification!;
      } else if (widget.preFillExpenseId != null) {
        _justificationController.text = "Expansion fund for approved expense: (ID: ${widget.preFillExpenseId})";
      }
    }
  }

  Future<void> _handleSubmit() async {
    bool isValid = _formKey.currentState!.validate();
    if (_amountController.text.isEmpty) _amountShakeKey.currentState?.shake();
    if (_justificationController.text.trim().isEmpty) _justificationShakeKey.currentState?.shake();

    if (isValid) {
      final data = {
        'requested_amount': double.parse(_amountController.text),
        'justification': _justificationController.text.trim(),
      };

      bool success;
      if (widget.expansion != null) {
        success = await ref.read(expansionProvider.notifier).updateExpansion(widget.expansion!.id, data);
      } else {
        success = await ref.read(expansionProvider.notifier).requestExpansion(data);
      }

      if (success && mounted) {
        ref.read(toastProvider.notifier).show(
          message: widget.expansion != null ? "Request updated" : "Request sent",
          type: ToastType.success,
        );
        context.pop();
      } else if (mounted) {
        ref.read(toastProvider.notifier).show(
          message: "Action failed",
          type: ToastType.error,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLoading = ref.watch(expansionProvider).isLoading;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.expansion != null ? "Edit Expansion Request" : "Request Expansion", style: GoogleFonts.outfit(fontWeight: FontWeight.w900, fontSize: 18, letterSpacing: -0.5)),
        centerTitle: true,
      ),
      bottomNavigationBar: StickyBottomCTA(
        label: widget.expansion != null ? "UPDATE REQUEST" : "SUBMIT REQUEST",
        loadingLabel: widget.expansion != null ? "UPDATING..." : "SUBMITTING...",
        icon: Icons.rocket_launch_rounded,
        isLoading: isLoading,
        onPressed: _handleSubmit,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 100),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              GlassCard(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: theme.primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Icon(Icons.rocket_launch_rounded, color: theme.primaryColor, size: 24),
                        ),
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Expansion Request",
                              style: GoogleFonts.outfit(fontWeight: FontWeight.w900, letterSpacing: -0.5, fontSize: 16),
                            ),
                            Text(
                              "Details for additional fund request",
                              style: TextStyle(fontSize: 11, color: theme.colorScheme.onSurface.withOpacity(0.5)),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    ShakeWidget(
                      key: _amountShakeKey,
                      child: TextFormField(
                        controller: _amountController,
                        style: GoogleFonts.outfit(fontSize: 28, fontWeight: FontWeight.w900, letterSpacing: -1),
                        decoration: InputDecoration(
                          labelText: "Requested Amount",
                          prefixIcon: Icon(Icons.payments_rounded, color: theme.primaryColor),
                          floatingLabelBehavior: FloatingLabelBehavior.always,
                          filled: true,
                          fillColor: theme.colorScheme.onSurface.withOpacity(0.03),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
                        ),
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        validator: (val) => (val == null || val.isEmpty) ? "Enter required amount" : null,
                      ),
                    ),
                    const SizedBox(height: 20),
                    ShakeWidget(
                      key: _justificationShakeKey,
                      child: TextFormField(
                        controller: _justificationController,
                        decoration: InputDecoration(
                          labelText: "Justification",
                          hintText: "Provide a detailed justification for the additional funds...",
                          hintStyle: TextStyle(fontSize: 13, color: Colors.grey.withOpacity(0.5)),
                          prefixIcon: const Icon(Icons.auto_awesome_rounded),
                          filled: true,
                          fillColor: theme.colorScheme.onSurface.withOpacity(0.03),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
                        ),
                        maxLines: 6,
                        validator: (val) => (val == null || val.isEmpty) ? "Justification is mandatory" : null,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              const AlertBanner(
                message: "This request will be queued for Executive Review. Upon approval, the approved request will be visible in your Fund Management dashboard.",
                type: AlertType.info,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

enum AlertType { info, warning, error }

class AlertBanner extends StatelessWidget {
  final String message;
  final AlertType type;
  const AlertBanner({super.key, required this.message, this.type = AlertType.info});

  @override
  Widget build(BuildContext context) {
    Color color = Colors.blue;
    IconData icon = Icons.info_outline;
    if (type == AlertType.warning) {
      color = Colors.orange;
      icon = Icons.warning_amber;
    } else if (type == AlertType.error) {
      color = Colors.red;
      icon = Icons.error_outline;
    }

    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      borderRadius: 16,
      color: color.withOpacity(0.05),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 16),
          ),
          const SizedBox(width: 16),
          Expanded(child: Text(message, style: TextStyle(color: color, fontSize: 13, height: 1.4, fontWeight: FontWeight.w500))),
        ],
      ),
    );
  }
}

