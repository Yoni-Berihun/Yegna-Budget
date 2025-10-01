import 'package:flutter_riverpod/flutter_riverpod.dart';

final navProvider = NotifierProvider<NavNotifier, int>(NavNotifier.new);

class NavNotifier extends Notifier<int> {
  @override
  int build() {
    // Safe place to access ref or other providers
    return 0;
  }

  void setIndex(int index) {
    state = index;
  }
}