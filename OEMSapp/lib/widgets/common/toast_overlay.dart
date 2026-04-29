import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/toast_provider.dart';
import 'erp_toast.dart';

class ToastOverlay extends ConsumerWidget {
  final Widget child;

  const ToastOverlay({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final toasts = ref.watch(toastProvider);

    return Stack(
      children: [
        child,
        Positioned(
          top: MediaQuery.of(context).padding.top + 10,
          left: 0,
          right: 0,
          child: Column(
            children: toasts.take(3).map((toast) => ERPToast(
              key: ValueKey(toast.id),
              message: toast.message,
              type: toast.type,
              duration: toast.duration,
              onDismiss: () => ref.read(toastProvider.notifier).dismiss(toast.id),
            )).toList(),
          ),
        ),
      ],
    );
  }
}
