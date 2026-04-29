import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/common/erp_toast.dart';

class ToastMessage {
  final String id;
  final String message;
  final ToastType type;
  final Duration duration;

  ToastMessage({
    required this.id,
    required this.message,
    this.type = ToastType.info,
    this.duration = const Duration(seconds: 4),
  });
}

class ToastNotifier extends StateNotifier<List<ToastMessage>> {
  int _counter = 0;
  ToastNotifier() : super([]);

  void show({
    required String message,
    ToastType type = ToastType.info,
    Duration duration = const Duration(seconds: 4),
  }) {
    // Prevent duplicate messages if already showing
    final isDuplicate = state.any((t) => t.message == message && t.type == type);
    if (isDuplicate) return;

    _counter++;
    final id = "${DateTime.now().microsecondsSinceEpoch}_${_counter}_${message.hashCode}";
    final toast = ToastMessage(
      id: id,
      message: message,
      type: type,
      duration: duration,
    );
    
    state = [...state, toast];
  }

  void dismiss(String id) {
    state = state.where((t) => t.id != id).toList();
  }
}

final toastProvider = StateNotifierProvider<ToastNotifier, List<ToastMessage>>((ref) {
  return ToastNotifier();
});
