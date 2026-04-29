import 'package:flutter_riverpod/flutter_riverpod.dart';

class TabNotifier extends StateNotifier<Map<String, int>> {
  TabNotifier() : super({});

  void setTab(String dashboard, int index) {
    state = {...state, dashboard: index};
  }

  int getTab(String dashboard) {
    return state[dashboard] ?? 0;
  }
}

final tabProvider = StateNotifierProvider<TabNotifier, Map<String, int>>((ref) {
  return TabNotifier();
});
