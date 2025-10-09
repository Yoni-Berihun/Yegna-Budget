import 'package:flutter_riverpod/flutter_riverpod.dart';

final userNameProvider = NotifierProvider<UserNameNotifier, String>(
  UserNameNotifier.new,
);

class UserNameNotifier extends Notifier<String> {
  @override
  String build() => '';

  void setUserName(String name) {
    state = name;
  }
}
