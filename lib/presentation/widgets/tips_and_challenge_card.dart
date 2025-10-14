import 'package:flutter/material.dart';

class TipsAndChallengeCard extends StatefulWidget {
  final String tipTitle;
  final String tipPreview;
  final String tipDetail;
  final List<String> challengeOptions;
  final int correctAnswerIndex;

  const TipsAndChallengeCard({
    super.key,
    required this.tipTitle,
    required this.tipPreview,
    required this.tipDetail,
    required this.challengeOptions,
    required this.correctAnswerIndex,
  });

  @override
  State<TipsAndChallengeCard> createState() => _TipsAndChallengeCardState();
}

class _TipsAndChallengeCardState extends State<TipsAndChallengeCard> {
  bool showDetail = false;
  bool showChallenge = false;
  int? selectedAnswer;
  int streakCount = 0;

  void _checkAnswer(int index) {
    setState(() {
      selectedAnswer = index;
      if (index == widget.correctAnswerIndex) {
        streakCount++;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Correct! 🔥 Streak: $streakCount")),
        );
      } else {
        streakCount = 0;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Oops, try again tomorrow!")),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with streak
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Tips & Challenge",
                    style: Theme.of(context).textTheme.titleLarge),
                Row(
                  children: [
                    const Icon(Icons.local_fire_department, color: Colors.orange),
                    Text(" $streakCount-day streak"),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Tip preview
            Text(widget.tipTitle,
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 6),
            Text(widget.tipPreview,
                style: Theme.of(context).textTheme.bodyMedium),

            const SizedBox(height: 12),

            // Buttons
            Row(
              children: [
                ElevatedButton(
                  onPressed: () => setState(() {
                    showChallenge = true;
                    showDetail = false;
                  }),
                  child: const Text("Challenge Me"),
                ),
                const SizedBox(width: 12),
                OutlinedButton(
                  onPressed: () => setState(() {
                    showDetail = true;
                    showChallenge = false;
                  }),
                  child: const Text("Read More"),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Expanded detail
            if (showDetail)
              Text(widget.tipDetail,
                  style: Theme.of(context).textTheme.bodyLarge),

            // Challenge question
            if (showChallenge)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Quick Challenge:",
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  ...List.generate(widget.challengeOptions.length, (index) {
                    return ListTile(
                      title: Text(widget.challengeOptions[index]),
                      leading: Radio<int>(
                        value: index,
                        groupValue: selectedAnswer,
                        onChanged: (val) => _checkAnswer(index),
                      ),
                    );
                  }),
                ],
              ),
          ],
        ),
      ),
    );
  }
}