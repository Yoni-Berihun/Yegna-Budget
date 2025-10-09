class FinancialTipModel {
  final String id;
  final String title;
  final String summary;
  final String details;
  final String category;
  final bool shareable;
  final bool savable;
  final String? imageUrl;

  FinancialTipModel({
    required this.id,
    required this.title,
    required this.summary,
    required this.details,
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
      category: json['category'],
      shareable: json['shareable'],
      savable: json['savable'],
      imageUrl: json['imageUrl'],
    );
  }
}

/* - assets/images/goal_setting.png
    - assets/images/smart_shopping.png
    - assets/images/debt_management.png
    - assets/images/student_saving.png
    - assets/images/free_tools.png
    - assets/images/small_wins.png
    - assets/images/holiday_budget.png
    */