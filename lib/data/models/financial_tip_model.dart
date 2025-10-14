class Quiz {
  final String question;
  final List<String> options;
  final int correctIndex;

  const Quiz({
    required this.question,
    required this.options,
    required this.correctIndex,
  });

  factory Quiz.fromJson(Map<String, dynamic> json) {
    return Quiz(
      question: json['question'] as String,
      options: List<String>.from(json['options'] as List),
      correctIndex: json['correctIndex'] as int,
    );
  }

  Map<String, dynamic> toJson() => {
        'question': question,
        'options': options,
        'correctIndex': correctIndex,
      };
}

class FinancialTipModel {
  final String id;
  final String title;
  final String summary;
  final String details;     // deep dive content
  final String category;    // e.g., "Budgeting Basics"
  final bool shareable;
  final bool savable;
  final String? imageUrl;
  final String icon;        // emoji or short label

  // Daily tip metadata
  final bool isDaily;
  final DateTime? featuredDate;

  // Optional learning extras
  final Quiz? quiz;
  final List<String>? quotes;

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
    this.quiz,
    this.quotes,
  });

  factory FinancialTipModel.fromJson(Map<String, dynamic> json) {
    return FinancialTipModel(
      id: json['id'] as String,
      title: json['title'] as String,
      summary: json['summary'] as String,
      details: json['details'] as String,
      category: json['category'] as String,
      shareable: (json['shareable'] as bool?) ?? false,
      savable: (json['savable'] as bool?) ?? false,
      imageUrl: json['imageUrl'] as String?,
      icon: json['icon'] as String,
      isDaily: (json['isDaily'] as bool?) ?? false,
      featuredDate: json['featuredDate'] != null
          ? DateTime.tryParse(json['featuredDate'] as String)
          : null,
      quiz: json['quiz'] != null ? Quiz.fromJson(json['quiz'] as Map<String, dynamic>) : null,
      quotes: json['quotes'] != null ? List<String>.from(json['quotes'] as List) : null,
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
        'quiz': quiz?.toJson(),
        'quotes': quotes,
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
    Quiz? quiz,
    List<String>? quotes,
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
      quiz: quiz ?? this.quiz,
      quotes: quotes ?? this.quotes,
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