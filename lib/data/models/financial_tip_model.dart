class FinancialTipModel {
  final String id;
  final String title;
  final String summary;
  final String details;
  final String category;
  final bool shareable;
  final bool savable;
  final String? imageUrl;
  final String icon;
  final bool isDaily;
  final DateTime? featuredDate;

  const FinancialTipModel({
    required this.id,
    required this.title,
    required this.summary,
    required this.details,
    required this.category,
    required this.shareable,
    required this.savable,
    this.imageUrl,
    required this.icon,
    this.isDaily = false,
    this.featuredDate,
  });

  factory FinancialTipModel.fromJson(Map<String, dynamic> json) {
    return FinancialTipModel(
      id: json['id'],
      title: json['title'],
      summary: json['summary'],
      details: json['details'],
      category: json['category'],
      shareable: json['shareable'] ?? false,
      savable: json['savable'] ?? false,
      imageUrl: json['imageUrl'],
      icon: json['icon'],
      isDaily: json['isDaily'] ?? false,
      featuredDate: json['featuredDate'] != null
          ? DateTime.tryParse(json['featuredDate'])
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'summary': summary,
        'details': details,
        'category': category,
        'shareable': shareable,
        'savable': savable,
        'imageUrl': imageUrl,
        'icon': icon,
        'isDaily': isDaily,
        'featuredDate': featuredDate?.toIso8601String(),
      };

  FinancialTipModel copyWith({
    String? id,
    String? title,
    String? summary,
    String? details,
    String? category,
    bool? shareable,
    bool? savable,
    String? imageUrl,
    String? icon,
    bool? isDaily,
    DateTime? featuredDate,
  }) {
    return FinancialTipModel(
      id: id ?? this.id,
      title: title ?? this.title,
      summary: summary ?? this.summary,
      details: details ?? this.details,
      category: category ?? this.category,
      shareable: shareable ?? this.shareable,
      savable: savable ?? this.savable,
      imageUrl: imageUrl ?? this.imageUrl,
      icon: icon ?? this.icon,
      isDaily: isDaily ?? this.isDaily,
      featuredDate: featuredDate ?? this.featuredDate,
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