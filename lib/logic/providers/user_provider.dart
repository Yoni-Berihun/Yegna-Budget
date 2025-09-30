import 'package:flutter_riverpod/flutter_riverpod.dart';

final userNameProvider = NotifierProvider<UserNameNotifier, String>(
  () => UserNameNotifier(),
);

class UserNameNotifier extends Notifier<String> {
  @override
  String build() => '';
}
