class FinancialTipModel {
  final String id;
  final String title;
  final String summary;
  final String details;
  final String icon;
  final String category;
  final bool shareable;
  final bool savable;
  final String? imageUrl;

  FinancialTipModel({
    required this.id,
    required this.title,
    required this.summary,
    required this.details,
    required this.icon,
    required this.category,
    required this.shareable,
    required this.savable,
    this.imageUrl,
  });

  factory FinancialTipModel.fromJson(Map<String, dynamic> json) {
    return FinancialTipModel(
      id: json['id'],
      title: json['title'],
      summary: json['summary'],
      details: json['details'],
      icon: json['icon'],
      category: json['category'],
      shareable: json['shareable'],
      savable: json['savable'],
      imageUrl: json['imageUrl'],
    );
  }
}