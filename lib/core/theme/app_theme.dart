import 'package:flutter/material.dart';

final lightTheme = ThemeData(
  brightness: Brightness.light,
  useMaterial3: true,
  primarySwatch: Colors.indigo,
  scaffoldBackgroundColor: Colors.white,
  cardColor: Colors.indigo[50],
  textTheme: const TextTheme(
    bodyMedium: TextStyle(color: Colors.black87),
  ),
);

final darkTheme = ThemeData(
  brightness: Brightness.dark,
  useMaterial3: true,
  primarySwatch: Colors.indigo,
  scaffoldBackgroundColor: Colors.black,
  cardColor: Colors.grey[900],
  textTheme: const TextTheme(
    bodyMedium: TextStyle(color: Colors.white70),
  ),
);