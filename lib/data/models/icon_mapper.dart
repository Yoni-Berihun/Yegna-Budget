import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Map of semantic keys to SVG asset paths
final Map<String, String> iconMap = {
  "apps": "assets/icons/apps.svg",
  "budget": "assets/icons/budget.svg",
  "calendar": "assets/icons/caleder_today.svg",
  "coffee": "assets/icons/coffee.svg",
  "credit": "assets/icons/credit_card.svg",
  "emergency": "assets/icons/emergency.svg",
  "award": "assets/icons/emoji_events.svg",
  "envelope": "assets/icons/envelope.svg",
  "event": "assets/icons/event.svg",
  "flag": "assets/icons/flag.svg",
  "meal": "assets/icons/meal.svg",
  "chart": "assets/icons/pie_chart.svg",
  "savings": "assets/icons/savings.svg",
  "shopping": "assets/icons/shopping_card.svg",
};

/// Helper to build the correct icon widget from a semantic key
Widget buildMappedIcon(String key, {double size = 32, Color? color}) {
  final path = iconMap[key];
  if (path == null) {
    return Icon(Icons.help_outline, size: size, color: color);
  }
  return SvgPicture.asset(path, height: size, width: size, color: color);
}
