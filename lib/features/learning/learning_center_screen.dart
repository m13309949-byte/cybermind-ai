import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class LearningCenterScreen extends StatefulWidget {
  const LearningCenterScreen({super.key});
  @override
  State<LearningCenterScreen> createState() => _LearningCenterScreenState();
}

class _LearningCenterScreenState extends State<LearningCenterScreen> with SingleTickerProviderStateMixin {
  late final TabController _tab = TabController(length: 3, vsync: this);

  // Structured as data so it can be swapped for a Firestore `lessons`
  // collection query without changing the UI.
  final Map<String, List<_Lesson>> _lessons = {
    'Beginner': [
      _Lesson('What is Phishing?', 'Recognize deceptive emails and messages'),
      _Lesson('Password Basics', 'Why length and uniqueness matter'),
      _Lesson('Safe Browsing 101', 'Spotting fake websites'),
    ],
    'Intermediate': [
      _Lesson('Understanding Malware', 'Viruses, worms, trojans explained'),
      _Lesson('Two-Factor Authentication', 'Adding a second layer of defense'),
      _Lesson('Social Engineering', 'How attackers manipulate trust'),
    ],
    'Advanced': [
      _Lesson('Ransomware Defense', 'Backups, segmentation, incident response'),
      _Lesson('Network Security Fundamentals', 'Firewalls, VPNs, zero trust'),
      _Lesson('Threat Intelligence', 'Reading IOCs and CVE reports'),
    ],
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Learning Center'),
        bottom: TabBar(
          controller: _tab,
          tabs: const [Tab(text: 'Beginner'), Tab(text: 'Intermediate'), Tab(text: 'Advanced')],
        ),
      ),
      body: TabBarView(
        controller: _tab,
        children: _lessons.entries.map((entry) {
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: entry.value.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, i) {
              final lesson = entry.value[i];
              return Card(
                child: ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: AppColors.neonViolet,
                    child: Icon(Icons.menu_book_rounded, color: Colors.white, size: 18),
                  ),
                  title: Text(lesson.title, style: const TextStyle(fontWeight: FontWeight.w700)),
                  subtitle: Text(lesson.subtitle, style: const TextStyle(color: AppColors.textSecondary)),
                  trailing: TextButton(
                    onPressed: () => _openQuiz(context, lesson.title),
                    child: const Text('Take Quiz'),
                  ),
                ),
              );
            },
          );
        }).toList(),
      ),
    );
  }

  void _openQuiz(BuildContext context, String title) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Quiz: $title', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
            const SizedBox(height: 12),
            const Text(
              'Full quiz engine (multiple-choice, scoring, and a downloadable/shareable '
              'certificate on completion) plugs into a `quizzes` + `quiz_results` Firestore '
              'schema — structure included in README, ready to populate with real questions.',
              style: TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: () => Navigator.pop(context), child: const Text('Got it')),
          ],
        ),
      ),
    );
  }
}

class _Lesson {
  final String title;
  final String subtitle;
  _Lesson(this.title, this.subtitle);
}
