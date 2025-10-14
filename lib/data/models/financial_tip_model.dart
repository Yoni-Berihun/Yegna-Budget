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
  final String details;
  final String category;
  final bool shareable;
  final bool savable;
  final String? imageUrl;
  final String icon;
  final bool isDaily;
  final DateTime? featuredDate;
  final Quiz? quiz;

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
      quiz: json['quiz'] != null ? Quiz.fromJson(json['quiz']) : null,
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
      };
}
/* - assets/images/goal_setting.png
    - assets/images/smart_shopping.png
    - assets/images/debt_management.png
    - assets/images/student_saving.png
    - assets/images/free_tools.png
    - assets/images/small_wins.png
    - assets/images/holiday_budget.png
    */