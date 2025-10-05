import 'package:flutter_riverpod/flutter_riverpod.dart';

final userNameProvider = NotifierProvider<UserNameNotifier, String>(
  () => UserNameNotifier(),
);

class UserNameNotifier extends Notifier<String> {
  final String initial;

  UserNameNotifier({String? initial}) : initial = initial ?? '';

  @override
  String build() => initial;
}