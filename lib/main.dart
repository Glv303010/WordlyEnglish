import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Импорт для базы данных
import 'database/database_service.dart';

void main() {
  runApp(const LanguageLearningApp());
}

class LanguageLearningApp extends StatelessWidget {
  const LanguageLearningApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Словко',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const MainPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

// Модель слова
class Word {
  int? id;
  String word;
  String translation;
  String language;
  String topic;
  int correctCount;
  int wrongCount;
  double difficulty;
  DateTime? lastReviewed;
  int? streak;
  DateTime? nextReviewDate;

  Word({
    this.id,
    required this.word,
    required this.translation,
    required this.language,
    required this.topic,
    this.correctCount = 0,
    this.wrongCount = 0,
    this.difficulty = 0.5,
    this.lastReviewed,
    this.streak = 0,
    this.nextReviewDate,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'word': word,
      'translation': translation,
      'language': language,
      'topic': topic,
      'correctCount': correctCount,
      'wrongCount': wrongCount,
      'difficulty': difficulty,
      'lastReviewed': lastReviewed?.toIso8601String(),
      'streak': streak,
      'nextReviewDate': nextReviewDate?.toIso8601String(),
    };
  }

  factory Word.fromMap(Map<String, dynamic> map) {
    return Word(
      id: map['id'],
      word: map['word'],
      translation: map['translation'],
      language: map['language'],
      topic: map['topic'],
      correctCount: map['correctCount'] ?? 0,
      wrongCount: map['wrongCount'] ?? 0,
      difficulty: map['difficulty'] ?? 0.5,
      lastReviewed: map['lastReviewed'] != null
          ? DateTime.parse(map['lastReviewed'])
          : null,
      streak: map['streak'] ?? 0,
      nextReviewDate: map['nextReviewDate'] != null
          ? DateTime.parse(map['nextReviewDate'])
          : null,
    );
  }
}

// ============================================================
// СЕРВИС ДЛЯ УПРАВЛЕНИЯ ПОДСКАЗКАМИ
// ============================================================

class TutorialService {
  static const String _keyMainTutorialShown = 'main_tutorial_shown';
  static const String _keyProgressTutorialShown = 'progress_tutorial_shown';

  static Future<bool> shouldShowMainTutorial() async {
    final prefs = await SharedPreferences.getInstance();
    final shown = prefs.getBool(_keyMainTutorialShown) ?? false;
    if (!shown) {
      await prefs.setBool(_keyMainTutorialShown, true);
      return true;
    }
    return false;
  }

  static Future<bool> shouldShowProgressTutorial() async {
    final prefs = await SharedPreferences.getInstance();
    final shown = prefs.getBool(_keyProgressTutorialShown) ?? false;
    if (!shown) {
      await prefs.setBool(_keyProgressTutorialShown, true);
      return true;
    }
    return false;
  }

  static Future<void> markMainTutorialShown() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyMainTutorialShown, true);
  }

  static Future<void> markProgressTutorialShown() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyProgressTutorialShown, true);
  }

  static void showMainTutorial(BuildContext context, {bool forceShow = false}) {
    showDialog(
      context: context,
      builder: (context) => _MainTutorialDialog(),
    );
  }

  static void showProgressTutorial(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => _ProgressTutorialDialog(),
    );
  }
}

// ============================================================
// ДИАЛОГ ПОДСКАЗКИ ДЛЯ ГЛАВНОЙ СТРАНИЦЫ
// ============================================================

class _MainTutorialDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        width: isLandscape ? 500 : null,
        constraints: BoxConstraints(
          maxHeight: isLandscape ? MediaQuery.of(context).size.height * 0.8 : double.infinity,
        ),
        padding: EdgeInsets.all(isLandscape ? 16 : 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Icon(Icons.lightbulb, color: Colors.amber, size: isLandscape ? 22 : 28),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Добро пожаловать в Словко!',
                    style: TextStyle(
                      fontSize: isLandscape ? 16 : 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close, size: isLandscape ? 18 : 22),
                  onPressed: () => Navigator.pop(context),
                  padding: EdgeInsets.zero,
                  constraints: BoxConstraints(minWidth: 30, minHeight: 30),
                ),
              ],
            ),
            SizedBox(height: isLandscape ? 12 : 20),
            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildSection(
                      icon: Icons.menu_book,
                      color: Colors.blue,
                      title: 'СЛОВАРЬ',
                      description: 'Просматривайте все слова по темам и языкам',
                      isLandscape: isLandscape,
                    ),
                    SizedBox(height: isLandscape ? 8 : 16),
                    _buildSection(
                      icon: Icons.fitness_center,
                      color: Colors.green,
                      title: 'ТРЕНИРОВКИ',
                      description: 'Здесь происходит основное изучение слов. Доступны три режима:',
                      isLandscape: isLandscape,
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: isLandscape ? 30 : 40, top: 4),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSubItem('ТРЕНАЖЁР', '— вводите перевод самостоятельно'),
                          _buildSubItem('ВЫБОР ПЕРЕВОДА', '— выбирайте из 4 вариантов'),
                          _buildSubItem('С РУССКОГО', '— переводите на изучаемый язык'),
                        ],
                      ),
                    ),
                    SizedBox(height: isLandscape ? 8 : 16),
                    _buildSection(
                      icon: Icons.insights,
                      color: Colors.teal,
                      title: 'ПРОГРЕСС',
                      description: 'Отслеживайте статистику изучения. Нажмите на тему — увидите детали по каждому слову',
                      isLandscape: isLandscape,
                    ),
                    SizedBox(height: isLandscape ? 8 : 16),
                    Container(
                      padding: EdgeInsets.all(isLandscape ? 8 : 12),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline, color: Colors.blue.shade700, size: isLandscape ? 16 : 20),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Нажмите на кнопку "?" справа вверху, чтобы снова увидеть эту подсказку',
                              style: TextStyle(
                                fontSize: isLandscape ? 11 : 13,
                                color: Colors.blue.shade700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: isLandscape ? 12 : 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: isLandscape ? 10 : 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(
                  'ПОНЯТНО',
                  style: TextStyle(fontSize: isLandscape ? 14 : 16, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required IconData icon,
    required Color color,
    required String title,
    required String description,
    required bool isLandscape,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: isLandscape ? 32 : 40,
          height: isLandscape ? 32 : 40,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: isLandscape ? 18 : 22),
        ),
        SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: isLandscape ? 13 : 15,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              Text(
                description,
                style: TextStyle(
                  fontSize: isLandscape ? 11 : 13,
                  color: Colors.grey.shade700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSubItem(String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Row(
        children: [
          Text('• ', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                children: [
                  TextSpan(text: title, style: TextStyle(fontWeight: FontWeight.w500, color: Colors.grey.shade800)),
                  TextSpan(text: description),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// ДИАЛОГ ПОДСКАЗКИ ДЛЯ СТРАНИЦЫ ПРОГРЕССА
// ============================================================

class _ProgressTutorialDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        width: isLandscape ? 450 : null,
        constraints: BoxConstraints(
          maxHeight: isLandscape ? MediaQuery.of(context).size.height * 0.8 : double.infinity,
        ),
        padding: EdgeInsets.all(isLandscape ? 16 : 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Icon(Icons.tips_and_updates, color: Colors.teal, size: isLandscape ? 22 : 28),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Как использовать раздел ПРОГРЕСС',
                    style: TextStyle(
                      fontSize: isLandscape ? 16 : 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close, size: isLandscape ? 18 : 22),
                  onPressed: () => Navigator.pop(context),
                  padding: EdgeInsets.zero,
                  constraints: BoxConstraints(minWidth: 30, minHeight: 30),
                ),
              ],
            ),
            SizedBox(height: isLandscape ? 12 : 20),
            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildTip(
                      icon: Icons.touch_app,
                      title: 'Просмотр деталей',
                      description: 'Нажмите на карточку темы, чтобы увидеть подробную статистику по каждому слову',
                      isLandscape: isLandscape,
                    ),
                    SizedBox(height: isLandscape ? 8 : 16),
                    _buildTip(
                      icon: Icons.repeat,
                      title: 'Повторение темы',
                      description: 'Нажмите на иконку 🔄 в карточке темы, чтобы быстро перейти к повторению этой темы',
                      isLandscape: isLandscape,
                    ),
                    SizedBox(height: isLandscape ? 4 : 8),
                    Padding(
                      padding: EdgeInsets.only(left: isLandscape ? 30 : 40),
                      child: Text(
                        'Можно выбрать любой из трёх режимов: Тренажёр, Выбор перевода или С русского',
                        style: TextStyle(
                          fontSize: isLandscape ? 11 : 12,
                          color: Colors.grey.shade600,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                    SizedBox(height: isLandscape ? 8 : 16),
                    _buildTip(
                      icon: Icons.delete_outline,
                      title: 'Сброс прогресса',
                      description: 'Красная иконка 🗑️ позволяет сбросить прогресс по теме или отдельному слову',
                      isLandscape: isLandscape,
                    ),
                    SizedBox(height: isLandscape ? 12 : 16),
                    Container(
                      padding: EdgeInsets.all(isLandscape ? 8 : 12),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.orange.shade200),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.warning_amber, color: Colors.orange.shade700, size: isLandscape ? 16 : 20),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Прогресс обновляется автоматически после каждой тренировки',
                              style: TextStyle(
                                fontSize: isLandscape ? 11 : 12,
                                color: Colors.orange.shade800,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: isLandscape ? 12 : 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: isLandscape ? 10 : 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(
                  'ПОНЯТНО',
                  style: TextStyle(fontSize: isLandscape ? 14 : 16, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTip({
    required IconData icon,
    required String title,
    required String description,
    required bool isLandscape,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: isLandscape ? 28 : 32,
          height: isLandscape ? 28 : 32,
          decoration: BoxDecoration(
            color: Colors.teal.shade50,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: Colors.teal.shade700, size: isLandscape ? 16 : 18),
        ),
        SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: isLandscape ? 13 : 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.teal.shade800,
                ),
              ),
              Text(
                description,
                style: TextStyle(
                  fontSize: isLandscape ? 11 : 13,
                  color: Colors.grey.shade700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ============================================================
// ГЛАВНАЯ СТРАНИЦА
// ============================================================

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  @override
  void initState() {
    super.initState();
    _checkFirstLaunch();
  }

  Future<void> _checkFirstLaunch() async {
    await Future.delayed(const Duration(milliseconds: 100));
    if (mounted) {
      final shouldShow = await TutorialService.shouldShowMainTutorial();
      if (shouldShow) {
        TutorialService.showMainTutorial(context);
      }
    }
  }

  void _showTutorial() {
    TutorialService.showMainTutorial(context, forceShow: true);
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final isLandscape = mediaQuery.orientation == Orientation.landscape;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: isLandscape
            ? _buildLandscapeLayout(context)
            : _buildPortraitLayout(context),
      ),
    );
  }

  Widget _buildPortraitLayout(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              const SizedBox(
                width: double.infinity,
                height: 40,
              ),
              Text(
                'Словко',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade800,
                ),
              ),
              Positioned(
                right: 0,
                child: IconButton(
                  icon: Icon(Icons.help_outline, color: Colors.blue.shade600, size: 26),
                  onPressed: _showTutorial,
                  tooltip: 'Показать подсказку',
                ),
              ),
            ],
          ),
          const SizedBox(height: 40),
          _buildMenuButton(
            context,
            title: 'СЛОВАРЬ',
            color: Colors.blue,
            icon: Icons.menu_book,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const DictionaryPage()),
              );
            },
          ),
          const SizedBox(height: 30),
          _buildDividerWithLabel('ТРЕНИРОВКИ'),
          const SizedBox(height: 20),
          _buildTrainingButton(
            context,
            title: 'ТРЕНАЖЁР',
            textColor: Colors.red,
            backgroundColor: Colors.green.shade700,
            icon: Icons.edit_note,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const TrainerPage()),
              );
            },
          ),
          const SizedBox(height: 16),
          _buildTrainingButton(
            context,
            title: 'ВЫБОР ПЕРЕВОДА',
            textColor: Colors.red,
            backgroundColor: Colors.green.shade700,
            icon: Icons.quiz,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const MultipleChoicePage()),
              );
            },
          ),
          const SizedBox(height: 16),
          _buildTrainingButton(
            context,
            title: 'С РУССКОГО',
            textColor: Colors.red,
            backgroundColor: Colors.green.shade700,
            icon: Icons.translate,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ReverseTranslationPage()),
              );
            },
          ),
          const SizedBox(height: 30),
          _buildSimpleDivider(),
          const SizedBox(height: 20),
          _buildMenuButton(
            context,
            title: 'ПРОГРЕСС',
            color: Colors.teal,
            icon: Icons.insights,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProgressPage()),
              );
            },
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildLandscapeLayout(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              const SizedBox(
                width: double.infinity,
                height: 32,
              ),
              Text(
                'Словко',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade800,
                ),
              ),
              Positioned(
                right: 0,
                child: IconButton(
                  icon: Icon(Icons.help_outline, color: Colors.blue.shade600, size: 22),
                  onPressed: _showTutorial,
                  tooltip: 'Показать подсказку',
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildCompactMenuButton(
                  context,
                  title: 'СЛОВАРЬ',
                  color: Colors.blue,
                  icon: Icons.menu_book,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const DictionaryPage()),
                    );
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildCompactMenuButton(
                  context,
                  title: 'ПРОГРЕСС',
                  color: Colors.teal,
                  icon: Icons.insights,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const ProgressPage()),
                    );
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildCompactDividerWithLabel('ТРЕНИРОВКИ'),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildCompactTrainingButton(
                  context,
                  title: 'ТРЕНАЖЁР',
                  textColor: Colors.red,
                  backgroundColor: Colors.green.shade700,
                  icon: Icons.edit_note,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const TrainerPage()),
                    );
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildCompactTrainingButton(
                  context,
                  title: 'ВЫБОР ПЕРЕВОДА',
                  textColor: Colors.red,
                  backgroundColor: Colors.green.shade700,
                  icon: Icons.quiz,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const MultipleChoicePage()),
                    );
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildCompactTrainingButton(
                  context,
                  title: 'С РУССКОГО',
                  textColor: Colors.red,
                  backgroundColor: Colors.green.shade700,
                  icon: Icons.translate,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const ReverseTranslationPage()),
                    );
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildCompactSimpleDivider(),
        ],
      ),
    );
  }

  Widget _buildDividerWithLabel(String label) {
    return Row(
      children: [
        Expanded(
          child: Divider(
            color: Colors.grey.shade300,
            thickness: 1,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade500,
              letterSpacing: 1,
            ),
          ),
        ),
        Expanded(
          child: Divider(
            color: Colors.grey.shade300,
            thickness: 1,
          ),
        ),
      ],
    );
  }

  Widget _buildSimpleDivider() {
    return Divider(
      color: Colors.grey.shade200,
      thickness: 1,
    );
  }

  Widget _buildMenuButton(BuildContext context, {
    required String title,
    required Color color,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 80,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color, width: 2),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 32,
              color: color,
            ),
            const SizedBox(width: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
                letterSpacing: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrainingButton(BuildContext context, {
    required String title,
    required Color textColor,
    required Color backgroundColor,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 70,
        decoration: BoxDecoration(
          color: backgroundColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: backgroundColor.withValues(alpha: 0.3), width: 1.5),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 28,
              color: textColor,
            ),
            const SizedBox(width: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: textColor,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompactDividerWithLabel(String label) {
    return Row(
      children: [
        Expanded(
          child: Divider(
            color: Colors.grey.shade300,
            thickness: 1,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade500,
              letterSpacing: 1,
            ),
          ),
        ),
        Expanded(
          child: Divider(
            color: Colors.grey.shade300,
            thickness: 1,
          ),
        ),
      ],
    );
  }

  Widget _buildCompactSimpleDivider() {
    return Divider(
      color: Colors.grey.shade200,
      thickness: 1,
    );
  }

  Widget _buildCompactMenuButton(BuildContext context, {
    required String title,
    required Color color,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 65,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: color, width: 2),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 24,
              color: color,
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompactTrainingButton(BuildContext context, {
    required String title,
    required Color textColor,
    required Color backgroundColor,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 55,
        decoration: BoxDecoration(
          color: backgroundColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: backgroundColor.withValues(alpha: 0.3), width: 1.5),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 20,
              color: textColor,
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// СТРАНИЦА СЛОВАРЯ
// ============================================================

class DictionaryPage extends StatefulWidget {
  const DictionaryPage({super.key});

  @override
  State<DictionaryPage> createState() => _DictionaryPageState();
}

class _DictionaryPageState extends State<DictionaryPage> {
  final DatabaseService _dbService = DatabaseService();

  Map<String, List<Word>> _groupedWords = {};
  List<String> _alphabetKeys = [];
  List<String> _topics = [];
  List<Word> _allWords = [];

  String _selectedLanguage = 'en';
  String _selectedTopic = 'Все темы';
  bool _showTopicFilter = false;

  final ScrollController _scrollController = ScrollController();
  final List<String> _alphabet = List.generate(26, (index) => String.fromCharCode(65 + index));

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    _topics = await _dbService.getTopics();
    await _loadWords();
  }

  Future<void> _loadWords() async {
    List<Word> allWords = [];

    if (_selectedTopic == 'Все темы') {
      for (var topic in _topics) {
        allWords.addAll(await _dbService.getWordsByTopic(topic, language: _selectedLanguage));
      }
    } else {
      allWords = await _dbService.getWordsByTopic(_selectedTopic, language: _selectedLanguage);
    }

    _allWords = allWords;
    _groupWordsByLetter();
  }

  void _groupWordsByLetter() {
    _allWords.sort((a, b) => a.word.compareTo(b.word));
    final Map<String, List<Word>> grouped = {};

    for (var word in _allWords) {
      if (word.word.isEmpty) continue;
      String firstLetter = word.word[0].toUpperCase();
      if (!grouped.containsKey(firstLetter)) {
        grouped[firstLetter] = [];
      }
      grouped[firstLetter]!.add(word);
    }

    setState(() {
      _groupedWords = grouped;
      _alphabetKeys = grouped.keys.toList()..sort();
    });
  }

  void _scrollToLetter(String letter) {
    if (!_alphabetKeys.contains(letter)) return;

    int index = _alphabetKeys.indexOf(letter);
    if (index != -1) {
      double position = 0;
      for (int i = 0; i < index; i++) {
        String currentLetter = _alphabetKeys[i];
        int wordCount = _groupedWords[currentLetter]?.length ?? 0;
        position += 40 + (wordCount * 60);
      }

      _scrollController.animateTo(
        position,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final isLandscape = mediaQuery.orientation == Orientation.landscape;

    return Scaffold(
      appBar: AppBar(
        title: const Text('СЛОВАРЬ'),
        actions: [
          IconButton(
            icon: Icon(_showTopicFilter ? Icons.filter_list : Icons.filter_list_off),
            onPressed: () {
              setState(() {
                _showTopicFilter = !_showTopicFilter;
              });
            },
            tooltip: 'Фильтр по темам',
          ),
          DropdownButton<String>(
            value: _selectedLanguage,
            items: const [
              DropdownMenuItem(value: 'en', child: Text('🇬🇧 Английский')),
              DropdownMenuItem(value: 'es', child: Text('🇪🇸 Испанский')),
            ],
            onChanged: (value) {
              setState(() {
                _selectedLanguage = value!;
                _loadWords();
              });
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          if (_showTopicFilter && _topics.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: Colors.grey.shade100,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Фильтр по теме:',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        FilterChip(
                          label: const Text('Все темы'),
                          selected: _selectedTopic == 'Все темы',
                          onSelected: (selected) {
                            setState(() {
                              _selectedTopic = 'Все темы';
                              _loadWords();
                            });
                          },
                        ),
                        const SizedBox(width: 8),
                        ..._topics.map((topic) => Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: FilterChip(
                            label: Text(topic),
                            selected: _selectedTopic == topic,
                            onSelected: (selected) {
                              setState(() {
                                _selectedTopic = topic;
                                _loadWords();
                              });
                            },
                          ),
                        )),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          Expanded(
            child: _allWords.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.search_off,
                    size: 64,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Нет слов для отображения',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Выберите другую тему или язык',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            )
                : Stack(
              children: [
                Padding(
                  padding: EdgeInsets.only(
                    right: isLandscape ? 40.0 : 30.0,
                  ),
                  child: ListView.builder(
                    controller: _scrollController,
                    itemCount: _alphabetKeys.length,
                    itemBuilder: (context, index) {
                      final letter = _alphabetKeys[index];
                      final words = _groupedWords[letter] ?? [];

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            color: Colors.grey.shade200,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16.0,
                              vertical: 8.0,
                            ),
                            child: Row(
                              children: [
                                Text(
                                  letter,
                                  style: TextStyle(
                                    fontSize: isLandscape ? 18.0 : 20.0,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue.shade800,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '(${words.length})',
                                  style: TextStyle(
                                    fontSize: isLandscape ? 14.0 : 16.0,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          ...words.map((word) => ListTile(
                            title: Text(
                              word.word,
                              style: TextStyle(
                                fontSize: isLandscape ? 14.0 : 16.0,
                              ),
                            ),
                            subtitle: Text(
                              word.translation,
                              style: TextStyle(
                                fontSize: isLandscape ? 12.0 : 14.0,
                              ),
                            ),
                            trailing: word.difficulty > 0.7
                                ? Icon(
                              Icons.warning_amber_rounded,
                              color: Colors.orange,
                              size: 20,
                            )
                                : null,
                          ))
                        ],
                      );
                    },
                  ),
                ),
                Positioned(
                  right: 0,
                  top: 0,
                  bottom: 0,
                  child: Container(
                    width: isLandscape ? 40.0 : 30.0,
                    color: Colors.white.withValues(alpha: 0.9),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: _alphabet.map((letter) {
                        final bool hasWords = _alphabetKeys.contains(letter);
                        return Expanded(
                          child: GestureDetector(
                            onTap: hasWords ? () => _scrollToLetter(letter) : null,
                            child: Container(
                              color: Colors.transparent,
                              child: Center(
                                child: Text(
                                  letter,
                                  style: TextStyle(
                                    fontSize: isLandscape ? 12.0 : 10.0,
                                    fontWeight: hasWords ? FontWeight.bold : FontWeight.normal,
                                    color: hasWords
                                        ? Colors.blue.shade800
                                        : Colors.grey.shade400,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            color: Colors.grey.shade100,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Всего слов: ${_allWords.length}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade700,
                  ),
                ),
                if (_selectedTopic != 'Все темы')
                  Chip(
                    label: Text(_selectedTopic),
                    onDeleted: () {
                      setState(() {
                        _selectedTopic = 'Все темы';
                        _loadWords();
                      });
                    },
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// СТРАНИЦА ТРЕНАЖЁРА
// ============================================================

class TrainerPage extends StatefulWidget {
  const TrainerPage({super.key, this.selectedTopic});

  final String? selectedTopic;

  @override
  State<TrainerPage> createState() => _TrainerPageState();
}

class _TrainerPageState extends State<TrainerPage> {
  final DatabaseService _dbService = DatabaseService();
  List<String> _topics = [];
  final Map<String, bool> _selectedTopics = {};
  String _selectedLanguage = 'en';
  List<Word> _trainingWords = [];
  Word? _currentWord;
  int _currentIndex = 0;
  bool _showTranslation = false;
  final TextEditingController _controller = TextEditingController();
  String _feedback = '';
  bool _showTopicsPanel = true;
  final FocusNode _focusNode = FocusNode();
  int _correctAnswers = 0;
  int _totalAnswers = 0;

  @override
  void initState() {
    super.initState();
    _loadTopics();
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _loadTopics() async {
    _topics = await _dbService.getTopics();
    setState(() {
      for (var topic in _topics) {
        _selectedTopics[topic] = true;
      }

      if (widget.selectedTopic != null && _topics.contains(widget.selectedTopic)) {
        for (var topic in _topics) {
          _selectedTopics[topic] = (topic == widget.selectedTopic);
        }
        _showTopicsPanel = false;
        _startTraining();
      }
    });
  }

  List<String> getSelectedTopics() {
    return _selectedTopics.entries
        .where((entry) => entry.value)
        .map((entry) => entry.key)
        .toList();
  }

  bool hasSelectedTopics() {
    return getSelectedTopics().isNotEmpty;
  }

  Future<void> _startTraining() async {
    if (!hasSelectedTopics()) return;

    List<String> selectedTopics = getSelectedTopics();
    List<Word> allWords = [];

    for (var topic in selectedTopics) {
      var words = await _dbService.getWordsForTraining(topic, limit: 30);
      allWords.addAll(words.where((word) => word.language == _selectedLanguage));
    }

    allWords.shuffle();
    _trainingWords = allWords.take(20).toList();

    setState(() {
      _currentIndex = 0;
      _currentWord = _trainingWords.isNotEmpty ? _trainingWords[0] : null;
      _showTranslation = false;
      _controller.clear();
      _feedback = '';
      _showTopicsPanel = false;
      _correctAnswers = 0;
      _totalAnswers = 0;
    });

    _focusNode.requestFocus();
  }

  void _checkAnswer() {
    if (_currentWord == null) return;

    String userAnswer = _controller.text.trim().toLowerCase();
    String correctAnswer = _currentWord!.translation.toLowerCase();

    bool isCorrect = userAnswer == correctAnswer;

    setState(() {
      _showTranslation = true;
      _totalAnswers++;
      if (isCorrect) _correctAnswers++;
      _feedback = isCorrect ? '✓ Правильно!' : '✗ Неправильно. Правильно: ${_currentWord!.translation}';
    });

    _dbService.updateWordProgress(_currentWord!, isCorrect);
    _focusNode.unfocus();
  }

  void _nextWord() {
    if (_currentIndex < _trainingWords.length - 1) {
      setState(() {
        _currentIndex++;
        _currentWord = _trainingWords[_currentIndex];
        _showTranslation = false;
        _controller.clear();
        _feedback = '';
      });
      _focusNode.requestFocus();
    } else {
      setState(() {
        _currentWord = null;
        _showTranslation = false;
        _feedback = 'Тренировка завершена! Правильно: $_correctAnswers из $_totalAnswers';
      });
    }
  }

  void _selectAllTopics(bool? value) {
    setState(() {
      for (var topic in _topics) {
        _selectedTopics[topic] = value ?? false;
      }
    });
  }

  void _toggleTopicsPanel() {
    setState(() {
      _showTopicsPanel = !_showTopicsPanel;
    });
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final isLandscape = mediaQuery.orientation == Orientation.landscape;

    return Scaffold(
      appBar: isLandscape ? null : AppBar(
        title: const Text('ТРЕНАЖЁР'),
        actions: [
          if (_currentWord != null)
            IconButton(
              icon: Icon(_showTopicsPanel ? Icons.folder_open : Icons.folder),
              onPressed: _toggleTopicsPanel,
              tooltip: 'Выбор тем',
            ),
          DropdownButton<String>(
            value: _selectedLanguage,
            items: const [
              DropdownMenuItem(value: 'en', child: Text('🇬🇧 Английский')),
              DropdownMenuItem(value: 'es', child: Text('🇪🇸 Испанский')),
            ],
            onChanged: (value) {
              setState(() {
                _selectedLanguage = value!;
                if (_currentWord != null) {
                  _startTraining();
                }
              });
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: isLandscape
            ? _buildLandscapeLayout(context)
            : _buildPortraitLayout(context),
      ),
    );
  }

  Widget _buildPortraitLayout(BuildContext context) {
    if (_currentWord == null && _feedback.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            if (_showTopicsPanel && _topics.isNotEmpty)
              Expanded(
                child: _buildTopicsPanel(false),
              )
            else
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.edit_note,
                        size: 80,
                        color: Colors.green.shade300,
                      ),
                      const SizedBox(height: 20),
                      Text(
                        _topics.isEmpty
                            ? 'Нет доступных тем\nДобавьте слова в базу данных'
                            : 'Выберите темы и начните тренировку',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey.shade600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 30),
                      ElevatedButton.icon(
                        onPressed: _topics.isEmpty ? null : (hasSelectedTopics() ? _startTraining : null),
                        icon: const Icon(Icons.play_arrow),
                        label: const Text('НАЧАТЬ'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                          textStyle: const TextStyle(fontSize: 18),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      );
    }

    if (_currentWord == null && _feedback.isNotEmpty) {
      return _buildCompletionScreen(false);
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          if (_showTopicsPanel && _topics.isNotEmpty)
            _buildTopicsPanel(false),

          if (!_showTopicsPanel)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: ElevatedButton.icon(
                onPressed: _toggleTopicsPanel,
                icon: const Icon(Icons.folder_open),
                label: const Text('Выбрать темы'),
              ),
            ),

          Padding(
            padding: const EdgeInsets.only(bottom: 24.0),
            child: Column(
              children: [
                LinearProgressIndicator(
                  value: (_currentIndex + 1) / _trainingWords.length,
                  backgroundColor: Colors.grey.shade200,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Слово ${_currentIndex + 1} из ${_trainingWords.length}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.green.shade100,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '✓ $_correctAnswers',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.green.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.green.shade300, Colors.teal.shade300],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                Text(
                  'Введите перевод:',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  _currentWord!.word,
                  style: const TextStyle(
                    fontSize: 44,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          TextField(
            controller: _controller,
            focusNode: _focusNode,
            decoration: InputDecoration(
              hintText: 'Введите перевод',
              border: const OutlineInputBorder(),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 16.0,
              ),
              suffixIcon: IconButton(
                icon: const Icon(Icons.check),
                onPressed: _showTranslation ? null : _checkAnswer,
              ),
            ),
            enabled: !_showTranslation,
            textInputAction: TextInputAction.done,
            onSubmitted: (value) {
              if (!_showTranslation && _currentWord != null) {
                _checkAnswer();
              }
            },
          ),

          const SizedBox(height: 16),

          if (_showTranslation)
            Column(
              children: [
                Text(
                  _feedback,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: _feedback.contains('✓') ? Colors.green : Colors.red,
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _nextWord,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: _feedback.contains('✓') ? Colors.green : Colors.orange,
                      foregroundColor: Colors.white,
                    ),
                    child: Text(
                      _currentIndex < _trainingWords.length - 1 ? 'ДАЛЕЕ' : 'ЗАВЕРШИТЬ',
                      style: const TextStyle(fontSize: 18, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),

          const Spacer(),
        ],
      ),
    );
  }

  Widget _buildLandscapeLayout(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 48,
          color: Colors.grey.shade50,
          child: Column(
            children: [
              const SizedBox(height: 4),
              IconButton(
                icon: const Icon(Icons.arrow_back, size: 20),
                onPressed: () => Navigator.pop(context),
                tooltip: 'Назад',
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              ),
              const SizedBox(height: 8),
              IconButton(
                icon: Icon(_showTopicsPanel ? Icons.folder_open : Icons.folder_outlined, size: 20),
                onPressed: _toggleTopicsPanel,
                tooltip: 'Темы',
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              ),
              const Spacer(),
              IconButton(
                icon: Text(
                  _selectedLanguage == 'en' ? '🇬🇧' : '🇪🇸',
                  style: const TextStyle(fontSize: 18),
                ),
                onPressed: () {
                  setState(() {
                    _selectedLanguage = _selectedLanguage == 'en' ? 'es' : 'en';
                    if (_currentWord != null) {
                      _startTraining();
                    }
                  });
                },
                tooltip: 'Сменить язык',
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              ),
              const SizedBox(height: 4),
            ],
          ),
        ),

        Expanded(
          child: _currentWord != null
              ? _buildLandscapeTrainingContent()
              : _feedback.isNotEmpty
              ? _buildCompletionScreen(true)
              : _buildLandscapeStartScreen(),
        ),

        if (_showTopicsPanel)
          Container(
            width: 200,
            color: Colors.grey.shade50,
            child: _buildTopicsPanel(true),
          ),
      ],
    );
  }

  Widget _buildLandscapeStartScreen() {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.edit_note,
            size: 40,
            color: Colors.green.shade300,
          ),
          const SizedBox(height: 8),
          Text(
            _topics.isEmpty
                ? 'Нет доступных тем\nДобавьте слова в базу данных'
                : 'Выберите темы и начните тренировку',
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: _topics.isEmpty ? null : (hasSelectedTopics() ? _startTraining : null),
            icon: const Icon(Icons.play_arrow, size: 16),
            label: const Text('НАЧАТЬ', style: TextStyle(fontSize: 13)),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLandscapeTrainingContent() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: LinearProgressIndicator(
                  value: (_currentIndex + 1) / _trainingWords.length,
                  backgroundColor: Colors.grey.shade200,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${_currentIndex + 1}/${_trainingWords.length}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.green.shade100,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '✓ $_correctAnswers',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.green.shade700,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          Expanded(
            child: Center(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    flex: 5,
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.green.shade300, Colors.teal.shade300],
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Введите перевод:',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white.withValues(alpha: 0.9),
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _currentWord!.word,
                            style: const TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(width: 16),

                  Expanded(
                    flex: 5,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TextField(
                          controller: _controller,
                          focusNode: _focusNode,
                          decoration: InputDecoration(
                            hintText: 'Введите перевод',
                            border: const OutlineInputBorder(),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12.0,
                              vertical: 12.0,
                            ),
                          ),
                          enabled: !_showTranslation,
                          textInputAction: TextInputAction.done,
                          onSubmitted: (value) {
                            if (!_showTranslation && _currentWord != null) {
                              _checkAnswer();
                            }
                          },
                        ),

                        if (_showTranslation) ...[
                          const SizedBox(height: 16),
                          Text(
                            _feedback,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: _feedback.contains('✓') ? Colors.green : Colors.red,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _nextWord,
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                backgroundColor: _feedback.contains('✓') ? Colors.green : Colors.orange,
                                foregroundColor: Colors.white,
                              ),
                              child: Text(
                                _currentIndex < _trainingWords.length - 1 ? 'ДАЛЕЕ' : 'ЗАВЕРШИТЬ',
                                style: const TextStyle(fontSize: 14, color: Colors.white),
                              ),
                            ),
                          ),
                        ] else ...[
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _checkAnswer,
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.white,
                              ),
                              child: const Text(
                                'ПРОВЕРИТЬ',
                                style: TextStyle(fontSize: 14, color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopicsPanel(bool isLandscape) {
    if (_topics.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'Нет доступных тем\nДобавьте слова через words_data.dart',
            style: TextStyle(
              fontSize: isLandscape ? 11 : 14,
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    if (isLandscape) {
      return Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Темы',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 18),
                  onPressed: _toggleTopicsPanel,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                TextButton(
                  onPressed: () => _selectAllTopics(true),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    minimumSize: Size.zero,
                  ),
                  child: const Text('Все', style: TextStyle(fontSize: 11)),
                ),
                TextButton(
                  onPressed: () => _selectAllTopics(false),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    minimumSize: Size.zero,
                  ),
                  child: const Text('Снять', style: TextStyle(fontSize: 11)),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView(
                children: _topics.map((topic) => CheckboxListTile(
                  title: Text(topic, style: const TextStyle(fontSize: 12)),
                  value: _selectedTopics[topic] ?? false,
                  onChanged: (bool? value) {
                    setState(() {
                      _selectedTopics[topic] = value ?? false;
                    });
                  },
                  dense: true,
                  visualDensity: VisualDensity.compact,
                  controlAffinity: ListTileControlAffinity.leading,
                  contentPadding: EdgeInsets.zero,
                )).toList(),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: hasSelectedTopics() ? () {
                  _startTraining();
                  setState(() {
                    _showTopicsPanel = false;
                  });
                } : null,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
                child: const Text('НАЧАТЬ', style: TextStyle(fontSize: 12, color: Colors.white)),
              ),
            ),
          ],
        ),
      );
    } else {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Выберите темы',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                TextButton(
                  onPressed: () => _selectAllTopics(true),
                  child: const Text('Выбрать все', style: TextStyle(fontSize: 15)),
                ),
                const SizedBox(width: 8),
                TextButton(
                  onPressed: () => _selectAllTopics(false),
                  child: const Text('Снять все', style: TextStyle(fontSize: 15)),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView(
                children: _topics.map((topic) => CheckboxListTile(
                  title: Text(topic, style: const TextStyle(fontSize: 16)),
                  value: _selectedTopics[topic] ?? false,
                  onChanged: (bool? value) {
                    setState(() {
                      _selectedTopics[topic] = value ?? false;
                    });
                  },
                  controlAffinity: ListTileControlAffinity.leading,
                )).toList(),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: hasSelectedTopics() ? () {
                  _startTraining();
                } : null,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
                child: const Text(
                  'НАЧАТЬ ТРЕНИРОВКУ',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      );
    }
  }

  Widget _buildCompletionScreen(bool isLandscape) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _correctAnswers >= 15 ? Icons.emoji_events : Icons.school,
              size: isLandscape ? 40 : 80,
              color: _correctAnswers >= 15 ? Colors.amber : Colors.green,
            ),
            SizedBox(height: isLandscape ? 8 : 20),
            Text(
              'Тренировка завершена!',
              style: TextStyle(
                fontSize: isLandscape ? 16 : 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: isLandscape ? 4 : 16),
            Text(
              'Правильных ответов: $_correctAnswers из $_totalAnswers',
              style: TextStyle(
                fontSize: isLandscape ? 12 : 20,
                color: Colors.grey.shade700,
              ),
            ),
            SizedBox(height: isLandscape ? 12 : 30),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      _feedback = '';
                      _showTopicsPanel = true;
                    });
                  },
                  icon: Icon(Icons.settings, size: isLandscape ? 14 : 20),
                  label: Text('Темы', style: TextStyle(fontSize: isLandscape ? 11 : 14)),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(
                        horizontal: isLandscape ? 10 : 20,
                        vertical: isLandscape ? 6 : 12
                    ),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _startTraining,
                  icon: Icon(Icons.replay, size: isLandscape ? 14 : 20),
                  label: Text('Ещё раз', style: TextStyle(fontSize: isLandscape ? 11 : 14)),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(
                        horizontal: isLandscape ? 10 : 20,
                        vertical: isLandscape ? 6 : 12
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// СТРАНИЦА ВЫБОРА ПЕРЕВОДА
// ============================================================

class MultipleChoicePage extends StatefulWidget {
  const MultipleChoicePage({super.key, this.selectedTopic});

  final String? selectedTopic;

  @override
  State<MultipleChoicePage> createState() => _MultipleChoicePageState();
}

class _MultipleChoicePageState extends State<MultipleChoicePage> {
  final DatabaseService _dbService = DatabaseService();
  List<String> _topics = [];
  final Map<String, bool> _selectedTopics = {};
  String _selectedLanguage = 'en';
  List<Word> _trainingWords = [];
  List<Word> _availableWords = [];
  Word? _currentWord;
  int _currentIndex = 0;
  List<String> _options = [];
  String? _selectedOption;
  bool _showResult = false;
  bool _isCorrect = false;
  String _feedback = '';
  bool _showTopicsPanel = true;
  int _correctAnswers = 0;
  int _totalAnswers = 0;

  @override
  void initState() {
    super.initState();
    _loadTopics();
  }

  Future<void> _loadTopics() async {
    _topics = await _dbService.getTopics();
    setState(() {
      for (var topic in _topics) {
        _selectedTopics[topic] = true;
      }

      if (widget.selectedTopic != null && _topics.contains(widget.selectedTopic)) {
        for (var topic in _topics) {
          _selectedTopics[topic] = (topic == widget.selectedTopic);
        }
        _showTopicsPanel = false;
        _startTraining();
      }
    });
  }

  List<String> getSelectedTopics() {
    return _selectedTopics.entries
        .where((entry) => entry.value)
        .map((entry) => entry.key)
        .toList();
  }

  bool hasSelectedTopics() {
    return getSelectedTopics().isNotEmpty;
  }

  Future<void> _startTraining() async {
    if (!hasSelectedTopics()) return;

    List<String> selectedTopics = getSelectedTopics();
    List<Word> allWords = [];

    for (var topic in selectedTopics) {
      var words = await _dbService.getWordsByTopic(topic, language: _selectedLanguage);
      allWords.addAll(words);
    }

    _availableWords = allWords;

    allWords.shuffle();
    _trainingWords = allWords.take(20).toList();

    setState(() {
      _currentIndex = 0;
      _currentWord = _trainingWords.isNotEmpty ? _trainingWords[0] : null;
      _showResult = false;
      _selectedOption = null;
      _feedback = '';
      _showTopicsPanel = false;
      _correctAnswers = 0;
      _totalAnswers = 0;

      if (_currentWord != null) {
        _generateOptions();
      }
    });
  }

  void _generateOptions() {
    if (_currentWord == null) return;

    List<Word> sameTopicWords = _availableWords
        .where((w) =>
    w.topic == _currentWord!.topic &&
        w.id != _currentWord!.id &&
        w.translation != _currentWord!.translation)
        .toList();

    sameTopicWords.shuffle();

    List<String> wrongOptions = sameTopicWords
        .take(3)
        .map((w) => w.translation)
        .toList();

    if (wrongOptions.length < 3) {
      List<Word> otherWords = _availableWords
          .where((w) =>
      w.id != _currentWord!.id &&
          w.translation != _currentWord!.translation &&
          !wrongOptions.contains(w.translation))
          .toList();

      otherWords.shuffle();
      wrongOptions.addAll(
          otherWords
              .take(3 - wrongOptions.length)
              .map((w) => w.translation)
      );
    }

    _options = [...wrongOptions, _currentWord!.translation];
    _options.shuffle();
  }

  void _checkAnswer(String selected) {
    if (_currentWord == null || _showResult) return;

    bool isCorrect = selected == _currentWord!.translation;

    setState(() {
      _selectedOption = selected;
      _showResult = true;
      _isCorrect = isCorrect;
      _totalAnswers++;

      if (isCorrect) {
        _correctAnswers++;
        _feedback = '🎉 Отлично! Правильно!';
      } else {
        _feedback = '❌ Неправильно. Правильный ответ: ${_currentWord!.translation}';
      }
    });

    _dbService.updateWordProgress(_currentWord!, isCorrect);
  }

  void _nextWord() {
    if (_currentIndex < _trainingWords.length - 1) {
      setState(() {
        _currentIndex++;
        _currentWord = _trainingWords[_currentIndex];
        _showResult = false;
        _selectedOption = null;
        _feedback = '';
        _generateOptions();
      });
    } else {
      setState(() {
        _currentWord = null;
        _showResult = false;
        _feedback = '🏆 Тренировка завершена! Правильно: $_correctAnswers из $_totalAnswers';
      });
    }
  }

  void _selectAllTopics(bool? value) {
    setState(() {
      for (var topic in _topics) {
        _selectedTopics[topic] = value ?? false;
      }
    });
  }

  void _toggleTopicsPanel() {
    setState(() {
      _showTopicsPanel = !_showTopicsPanel;
    });
  }

  Color _getOptionColor(String option) {
    if (!_showResult) {
      return Colors.blue.shade50;
    }

    if (option == _currentWord!.translation) {
      return Colors.green.shade100;
    }

    if (option == _selectedOption && !_isCorrect) {
      return Colors.red.shade100;
    }

    return Colors.grey.shade100;
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final isLandscape = mediaQuery.orientation == Orientation.landscape;

    return Scaffold(
      appBar: isLandscape ? null : AppBar(
        title: const Text('ВЫБОР ПЕРЕВОДА'),
        actions: [
          if (_currentWord != null)
            IconButton(
              icon: Icon(_showTopicsPanel ? Icons.folder_open : Icons.folder),
              onPressed: _toggleTopicsPanel,
              tooltip: 'Выбор тем',
            ),
          DropdownButton<String>(
            value: _selectedLanguage,
            items: const [
              DropdownMenuItem(value: 'en', child: Text('🇬🇧 Английский')),
              DropdownMenuItem(value: 'es', child: Text('🇪🇸 Испанский')),
            ],
            onChanged: (value) {
              setState(() {
                _selectedLanguage = value!;
                if (_currentWord != null) {
                  _startTraining();
                }
              });
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: isLandscape
            ? _buildLandscapeLayout(context)
            : _buildPortraitLayout(context),
      ),
    );
  }

  Widget _buildPortraitLayout(BuildContext context) {
    if (_currentWord == null && _feedback.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            if (_showTopicsPanel && _topics.isNotEmpty)
              Expanded(
                child: _buildTopicsPanel(false),
              )
            else
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.quiz,
                        size: 80,
                        color: Colors.orange.shade300,
                      ),
                      const SizedBox(height: 20),
                      Text(
                        _topics.isEmpty
                            ? 'Нет доступных тем\nДобавьте слова в базу данных'
                            : 'Выберите темы и начните тренировку',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey.shade600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 30),
                      ElevatedButton.icon(
                        onPressed: _topics.isEmpty ? null : (hasSelectedTopics() ? _startTraining : null),
                        icon: const Icon(Icons.play_arrow),
                        label: const Text('НАЧАТЬ'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                          textStyle: const TextStyle(fontSize: 18),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      );
    }

    if (_currentWord == null && _feedback.isNotEmpty) {
      return _buildCompletionScreen(false);
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          if (_showTopicsPanel && _topics.isNotEmpty)
            _buildTopicsPanel(false),

          if (!_showTopicsPanel)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: ElevatedButton.icon(
                onPressed: _toggleTopicsPanel,
                icon: const Icon(Icons.folder_open),
                label: const Text('Выбрать темы'),
              ),
            ),

          Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: Column(
              children: [
                LinearProgressIndicator(
                  value: (_currentIndex + 1) / _trainingWords.length,
                  backgroundColor: Colors.grey.shade200,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Слово ${_currentIndex + 1} из ${_trainingWords.length}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.green.shade100,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '✓ $_correctAnswers',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.green.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.orange.shade300, Colors.deepOrange.shade300],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                Text(
                  'Выберите перевод:',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  _currentWord!.word,
                  style: const TextStyle(
                    fontSize: 44,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          Expanded(
            child: ListView(
              children: [
                ..._options.map((option) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _buildOptionButton(option, false),
                )),

                if (_showResult)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Column(
                      children: [
                        Text(
                          _feedback,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: _isCorrect ? Colors.green : Colors.red,
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _nextWord,
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              backgroundColor: _isCorrect ? Colors.green : Colors.orange,
                              foregroundColor: Colors.white,
                            ),
                            child: Text(
                              _currentIndex < _trainingWords.length - 1 ? 'ДАЛЕЕ' : 'ЗАВЕРШИТЬ',
                              style: const TextStyle(fontSize: 18, color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLandscapeLayout(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 48,
          color: Colors.grey.shade50,
          child: Column(
            children: [
              const SizedBox(height: 4),
              IconButton(
                icon: const Icon(Icons.arrow_back, size: 20),
                onPressed: () => Navigator.pop(context),
                tooltip: 'Назад',
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              ),
              const SizedBox(height: 8),
              IconButton(
                icon: Icon(_showTopicsPanel ? Icons.folder_open : Icons.folder_outlined, size: 20),
                onPressed: _toggleTopicsPanel,
                tooltip: 'Темы',
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              ),
              const Spacer(),
              IconButton(
                icon: Text(
                  _selectedLanguage == 'en' ? '🇬🇧' : '🇪🇸',
                  style: const TextStyle(fontSize: 18),
                ),
                onPressed: () {
                  setState(() {
                    _selectedLanguage = _selectedLanguage == 'en' ? 'es' : 'en';
                    if (_currentWord != null) {
                      _startTraining();
                    }
                  });
                },
                tooltip: 'Сменить язык',
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              ),
              const SizedBox(height: 4),
            ],
          ),
        ),

        Expanded(
          child: _currentWord != null
              ? _buildLandscapeTrainingContent()
              : _feedback.isNotEmpty
              ? _buildCompletionScreen(true)
              : _buildLandscapeStartScreen(),
        ),

        if (_showTopicsPanel)
          Container(
            width: 200,
            color: Colors.grey.shade50,
            child: _buildTopicsPanel(true),
          ),
      ],
    );
  }

  Widget _buildLandscapeStartScreen() {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.quiz,
            size: 40,
            color: Colors.orange.shade300,
          ),
          const SizedBox(height: 8),
          Text(
            _topics.isEmpty
                ? 'Нет доступных тем\nДобавьте слова в базу данных'
                : 'Выберите темы и начните тренировку',
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: _topics.isEmpty ? null : (hasSelectedTopics() ? _startTraining : null),
            icon: const Icon(Icons.play_arrow, size: 16),
            label: const Text('НАЧАТЬ', style: TextStyle(fontSize: 13)),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLandscapeTrainingContent() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: LinearProgressIndicator(
                  value: (_currentIndex + 1) / _trainingWords.length,
                  backgroundColor: Colors.grey.shade200,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${_currentIndex + 1}/${_trainingWords.length}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.green.shade100,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '✓ $_correctAnswers',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.green.shade700,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          Expanded(
            child: Center(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    flex: 4,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.orange.shade300, Colors.deepOrange.shade300],
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Выберите перевод:',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white.withValues(alpha: 0.9),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _currentWord!.word,
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(width: 16),

                  Expanded(
                    flex: 6,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          children: [
                            Expanded(child: _buildOptionButton(_options[0], true)),
                            const SizedBox(width: 8),
                            Expanded(child: _buildOptionButton(_options[1], true)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(child: _buildOptionButton(_options[2], true)),
                            const SizedBox(width: 8),
                            Expanded(child: _buildOptionButton(_options[3], true)),
                          ],
                        ),

                        if (_showResult) ...[
                          const SizedBox(height: 16),
                          Text(
                            _feedback,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: _isCorrect ? Colors.green : Colors.red,
                            ),
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _nextWord,
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                backgroundColor: _isCorrect ? Colors.green : Colors.orange,
                                foregroundColor: Colors.white,
                              ),
                              child: Text(
                                _currentIndex < _trainingWords.length - 1 ? 'ДАЛЕЕ' : 'ЗАВЕРШИТЬ',
                                style: const TextStyle(fontSize: 14, color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionButton(String option, bool isLandscape) {
    return GestureDetector(
      onTap: _showResult ? null : () => _checkAnswer(option),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.all(isLandscape ? 14 : 18),
        decoration: BoxDecoration(
          color: _getOptionColor(option),
          borderRadius: BorderRadius.circular(isLandscape ? 10 : 15),
          border: Border.all(
            color: _showResult && option == _currentWord!.translation
                ? Colors.green
                : _showResult && option == _selectedOption && !_isCorrect
                ? Colors.red
                : Colors.grey.shade300,
            width: 2,
          ),
        ),
        child: Center(
          child: Text(
            option,
            style: TextStyle(
              fontSize: isLandscape ? 15 : 20,
              fontWeight: FontWeight.w500,
              color: _showResult && option == _currentWord!.translation
                  ? Colors.green.shade800
                  : Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  Widget _buildTopicsPanel(bool isLandscape) {
    if (_topics.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'Нет доступных тем\nДобавьте слова через words_data.dart',
            style: TextStyle(
              fontSize: isLandscape ? 11 : 14,
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    if (isLandscape) {
      return Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Темы',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 18),
                  onPressed: _toggleTopicsPanel,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                TextButton(
                  onPressed: () => _selectAllTopics(true),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    minimumSize: Size.zero,
                  ),
                  child: const Text('Все', style: TextStyle(fontSize: 11)),
                ),
                TextButton(
                  onPressed: () => _selectAllTopics(false),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    minimumSize: Size.zero,
                  ),
                  child: const Text('Снять', style: TextStyle(fontSize: 11)),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView(
                children: _topics.map((topic) => CheckboxListTile(
                  title: Text(topic, style: const TextStyle(fontSize: 12)),
                  value: _selectedTopics[topic] ?? false,
                  onChanged: (bool? value) {
                    setState(() {
                      _selectedTopics[topic] = value ?? false;
                    });
                  },
                  dense: true,
                  visualDensity: VisualDensity.compact,
                  controlAffinity: ListTileControlAffinity.leading,
                  contentPadding: EdgeInsets.zero,
                )).toList(),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: hasSelectedTopics() ? () {
                  _startTraining();
                  setState(() {
                    _showTopicsPanel = false;
                  });
                } : null,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                ),
                child: const Text('НАЧАТЬ', style: TextStyle(fontSize: 12, color: Colors.white)),
              ),
            ),
          ],
        ),
      );
    } else {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Выберите темы',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                TextButton(
                  onPressed: () => _selectAllTopics(true),
                  child: const Text('Выбрать все', style: TextStyle(fontSize: 15)),
                ),
                const SizedBox(width: 8),
                TextButton(
                  onPressed: () => _selectAllTopics(false),
                  child: const Text('Снять все', style: TextStyle(fontSize: 15)),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView(
                children: _topics.map((topic) => CheckboxListTile(
                  title: Text(topic, style: const TextStyle(fontSize: 16)),
                  value: _selectedTopics[topic] ?? false,
                  onChanged: (bool? value) {
                    setState(() {
                      _selectedTopics[topic] = value ?? false;
                    });
                  },
                  controlAffinity: ListTileControlAffinity.leading,
                )).toList(),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: hasSelectedTopics() ? () {
                  _startTraining();
                } : null,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                ),
                child: const Text(
                  'НАЧАТЬ ТРЕНИРОВКУ',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      );
    }
  }

  Widget _buildCompletionScreen(bool isLandscape) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _correctAnswers >= 15 ? Icons.emoji_events : Icons.school,
              size: isLandscape ? 40 : 80,
              color: _correctAnswers >= 15 ? Colors.amber : Colors.orange,
            ),
            SizedBox(height: isLandscape ? 8 : 20),
            Text(
              'Тренировка завершена!',
              style: TextStyle(
                fontSize: isLandscape ? 16 : 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: isLandscape ? 4 : 16),
            Text(
              'Правильных ответов: $_correctAnswers из $_totalAnswers',
              style: TextStyle(
                fontSize: isLandscape ? 12 : 20,
                color: Colors.grey.shade700,
              ),
            ),
            SizedBox(height: isLandscape ? 12 : 30),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      _feedback = '';
                      _showTopicsPanel = true;
                    });
                  },
                  icon: Icon(Icons.settings, size: isLandscape ? 14 : 20),
                  label: Text('Темы', style: TextStyle(fontSize: isLandscape ? 11 : 14)),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(
                        horizontal: isLandscape ? 10 : 20,
                        vertical: isLandscape ? 6 : 12
                    ),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _startTraining,
                  icon: Icon(Icons.replay, size: isLandscape ? 14 : 20),
                  label: Text('Ещё раз', style: TextStyle(fontSize: isLandscape ? 11 : 14)),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(
                        horizontal: isLandscape ? 10 : 20,
                        vertical: isLandscape ? 6 : 12
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// СТРАНИЦА ОБРАТНОГО ПЕРЕВОДА (с русского на иностранный)
// ============================================================

class ReverseTranslationPage extends StatefulWidget {
  const ReverseTranslationPage({super.key, this.selectedTopic});

  final String? selectedTopic;

  @override
  State<ReverseTranslationPage> createState() => _ReverseTranslationPageState();
}

class _ReverseTranslationPageState extends State<ReverseTranslationPage> {
  final DatabaseService _dbService = DatabaseService();
  List<String> _topics = [];
  final Map<String, bool> _selectedTopics = {};
  String _selectedLanguage = 'en';
  List<Word> _trainingWords = [];
  Word? _currentWord;
  int _currentIndex = 0;
  bool _showAnswer = false;
  final TextEditingController _controller = TextEditingController();
  String _feedback = '';
  bool _isCorrect = false;
  bool _showTopicsPanel = true;
  int _correctAnswers = 0;
  int _totalAnswers = 0;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _loadTopics();
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _loadTopics() async {
    _topics = await _dbService.getTopics();
    setState(() {
      for (var topic in _topics) {
        _selectedTopics[topic] = true;
      }

      if (widget.selectedTopic != null && _topics.contains(widget.selectedTopic)) {
        for (var topic in _topics) {
          _selectedTopics[topic] = (topic == widget.selectedTopic);
        }
        _showTopicsPanel = false;
        _startTraining();
      }
    });
  }

  List<String> getSelectedTopics() {
    return _selectedTopics.entries
        .where((entry) => entry.value)
        .map((entry) => entry.key)
        .toList();
  }

  bool hasSelectedTopics() {
    return getSelectedTopics().isNotEmpty;
  }

  Future<void> _startTraining() async {
    if (!hasSelectedTopics()) return;

    List<String> selectedTopics = getSelectedTopics();
    List<Word> allWords = [];

    for (var topic in selectedTopics) {
      var words = await _dbService.getWordsByTopic(topic, language: _selectedLanguage);
      allWords.addAll(words);
    }

    allWords.shuffle();
    _trainingWords = allWords.take(20).toList();

    setState(() {
      _currentIndex = 0;
      _currentWord = _trainingWords.isNotEmpty ? _trainingWords[0] : null;
      _showAnswer = false;
      _controller.clear();
      _feedback = '';
      _isCorrect = false;
      _showTopicsPanel = false;
      _correctAnswers = 0;
      _totalAnswers = 0;
    });

    _focusNode.requestFocus();
  }

  void _checkAnswer() {
    if (_currentWord == null || _showAnswer) return;

    String userAnswer = _controller.text.trim().toLowerCase();
    String correctAnswer = _currentWord!.word.toLowerCase();

    bool isCorrect = userAnswer == correctAnswer;

    setState(() {
      _showAnswer = true;
      _isCorrect = isCorrect;
      _totalAnswers++;

      if (isCorrect) {
        _correctAnswers++;
        _feedback = '🎉 Отлично! Правильно!';
      } else {
        _feedback = '❌ Неправильно. Правильный ответ: ${_currentWord!.word}';
      }
    });

    _dbService.updateWordProgress(_currentWord!, isCorrect);
    _focusNode.unfocus();
  }

  void _nextWord() {
    if (_currentIndex < _trainingWords.length - 1) {
      setState(() {
        _currentIndex++;
        _currentWord = _trainingWords[_currentIndex];
        _showAnswer = false;
        _controller.clear();
        _feedback = '';
        _isCorrect = false;
      });
      _focusNode.requestFocus();
    } else {
      setState(() {
        _currentWord = null;
        _showAnswer = false;
        _feedback = '🏆 Тренировка завершена! Правильно: $_correctAnswers из $_totalAnswers';
      });
    }
  }

  void _selectAllTopics(bool? value) {
    setState(() {
      for (var topic in _topics) {
        _selectedTopics[topic] = value ?? false;
      }
    });
  }

  void _toggleTopicsPanel() {
    setState(() {
      _showTopicsPanel = !_showTopicsPanel;
    });
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final isLandscape = mediaQuery.orientation == Orientation.landscape;

    return Scaffold(
      appBar: isLandscape ? null : AppBar(
        title: const Text('С РУССКОГО'),
        actions: [
          if (_currentWord != null)
            IconButton(
              icon: Icon(_showTopicsPanel ? Icons.folder_open : Icons.folder),
              onPressed: _toggleTopicsPanel,
              tooltip: 'Выбор тем',
            ),
          DropdownButton<String>(
            value: _selectedLanguage,
            items: const [
              DropdownMenuItem(value: 'en', child: Text('🇬🇧 Английский')),
              DropdownMenuItem(value: 'es', child: Text('🇪🇸 Испанский')),
            ],
            onChanged: (value) {
              setState(() {
                _selectedLanguage = value!;
                if (_currentWord != null) {
                  _startTraining();
                }
              });
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: isLandscape
            ? _buildLandscapeLayout(context)
            : _buildPortraitLayout(context),
      ),
    );
  }

  Widget _buildPortraitLayout(BuildContext context) {
    if (_currentWord == null && _feedback.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            if (_showTopicsPanel && _topics.isNotEmpty)
              Expanded(
                child: _buildTopicsPanel(false),
              )
            else
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.translate,
                        size: 80,
                        color: Colors.purple.shade300,
                      ),
                      const SizedBox(height: 20),
                      Text(
                        _topics.isEmpty
                            ? 'Нет доступных тем\nДобавьте слова в базу данных'
                            : 'Выберите темы и начните тренировку',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey.shade600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 30),
                      ElevatedButton.icon(
                        onPressed: _topics.isEmpty ? null : (hasSelectedTopics() ? _startTraining : null),
                        icon: const Icon(Icons.play_arrow),
                        label: const Text('НАЧАТЬ'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                          textStyle: const TextStyle(fontSize: 18),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      );
    }

    if (_currentWord == null && _feedback.isNotEmpty) {
      return _buildCompletionScreen(false);
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          if (_showTopicsPanel && _topics.isNotEmpty)
            _buildTopicsPanel(false),

          if (!_showTopicsPanel)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: ElevatedButton.icon(
                onPressed: _toggleTopicsPanel,
                icon: const Icon(Icons.folder_open),
                label: const Text('Выбрать темы'),
              ),
            ),

          Padding(
            padding: const EdgeInsets.only(bottom: 24.0),
            child: Column(
              children: [
                LinearProgressIndicator(
                  value: (_currentIndex + 1) / _trainingWords.length,
                  backgroundColor: Colors.grey.shade200,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.purple),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Слово ${_currentIndex + 1} из ${_trainingWords.length}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.green.shade100,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '✓ $_correctAnswers',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.green.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.purple.shade300, Colors.deepPurple.shade300],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                Text(
                  'Напишите слово на ${_selectedLanguage == 'en' ? 'английском' : 'испанском'}:',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  _currentWord!.translation,
                  style: const TextStyle(
                    fontSize: 44,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          TextField(
            controller: _controller,
            focusNode: _focusNode,
            decoration: InputDecoration(
              hintText: 'Введите слово',
              border: const OutlineInputBorder(),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 16.0,
              ),
              suffixIcon: IconButton(
                icon: const Icon(Icons.check),
                onPressed: _showAnswer ? null : _checkAnswer,
              ),
            ),
            enabled: !_showAnswer,
            textInputAction: TextInputAction.done,
            onSubmitted: (value) {
              if (!_showAnswer && _currentWord != null) {
                _checkAnswer();
              }
            },
          ),

          const SizedBox(height: 16),

          if (_showAnswer)
            Column(
              children: [
                Text(
                  _feedback,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: _isCorrect ? Colors.green : Colors.red,
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _nextWord,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: _isCorrect ? Colors.green : Colors.purple,
                      foregroundColor: Colors.white,
                    ),
                    child: Text(
                      _currentIndex < _trainingWords.length - 1 ? 'ДАЛЕЕ' : 'ЗАВЕРШИТЬ',
                      style: const TextStyle(fontSize: 18, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),

          const Spacer(),
        ],
      ),
    );
  }

  Widget _buildLandscapeLayout(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 48,
          color: Colors.grey.shade50,
          child: Column(
            children: [
              const SizedBox(height: 4),
              IconButton(
                icon: const Icon(Icons.arrow_back, size: 20),
                onPressed: () => Navigator.pop(context),
                tooltip: 'Назад',
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              ),
              const SizedBox(height: 8),
              IconButton(
                icon: Icon(_showTopicsPanel ? Icons.folder_open : Icons.folder_outlined, size: 20),
                onPressed: _toggleTopicsPanel,
                tooltip: 'Темы',
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              ),
              const Spacer(),
              IconButton(
                icon: Text(
                  _selectedLanguage == 'en' ? '🇬🇧' : '🇪🇸',
                  style: const TextStyle(fontSize: 18),
                ),
                onPressed: () {
                  setState(() {
                    _selectedLanguage = _selectedLanguage == 'en' ? 'es' : 'en';
                    if (_currentWord != null) {
                      _startTraining();
                    }
                  });
                },
                tooltip: 'Сменить язык',
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              ),
              const SizedBox(height: 4),
            ],
          ),
        ),

        Expanded(
          child: _currentWord != null
              ? _buildLandscapeTrainingContent()
              : _feedback.isNotEmpty
              ? _buildCompletionScreen(true)
              : _buildLandscapeStartScreen(),
        ),

        if (_showTopicsPanel)
          Container(
            width: 200,
            color: Colors.grey.shade50,
            child: _buildTopicsPanel(true),
          ),
      ],
    );
  }

  Widget _buildLandscapeStartScreen() {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.translate,
            size: 40,
            color: Colors.purple.shade300,
          ),
          const SizedBox(height: 8),
          Text(
            _topics.isEmpty
                ? 'Нет доступных тем\nДобавьте слова в базу данных'
                : 'Выберите темы и начните тренировку',
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: _topics.isEmpty ? null : (hasSelectedTopics() ? _startTraining : null),
            icon: const Icon(Icons.play_arrow, size: 16),
            label: const Text('НАЧАТЬ', style: TextStyle(fontSize: 13)),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLandscapeTrainingContent() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: LinearProgressIndicator(
                  value: (_currentIndex + 1) / _trainingWords.length,
                  backgroundColor: Colors.grey.shade200,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.purple),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${_currentIndex + 1}/${_trainingWords.length}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.green.shade100,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '✓ $_correctAnswers',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.green.shade700,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          Expanded(
            child: Center(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    flex: 5,
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.purple.shade300, Colors.deepPurple.shade300],
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Напишите слово на ${_selectedLanguage == 'en' ? 'английском' : 'испанском'}:',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white.withValues(alpha: 0.9),
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _currentWord!.translation,
                            style: const TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(width: 16),

                  Expanded(
                    flex: 5,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TextField(
                          controller: _controller,
                          focusNode: _focusNode,
                          decoration: InputDecoration(
                            hintText: 'Введите слово',
                            border: const OutlineInputBorder(),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12.0,
                              vertical: 12.0,
                            ),
                          ),
                          enabled: !_showAnswer,
                          textInputAction: TextInputAction.done,
                          onSubmitted: (value) {
                            if (!_showAnswer && _currentWord != null) {
                              _checkAnswer();
                            }
                          },
                        ),

                        if (_showAnswer) ...[
                          const SizedBox(height: 16),
                          Text(
                            _feedback,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: _isCorrect ? Colors.green : Colors.red,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _nextWord,
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                backgroundColor: _isCorrect ? Colors.green : Colors.purple,
                                foregroundColor: Colors.white,
                              ),
                              child: Text(
                                _currentIndex < _trainingWords.length - 1 ? 'ДАЛЕЕ' : 'ЗАВЕРШИТЬ',
                                style: const TextStyle(fontSize: 14, color: Colors.white),
                              ),
                            ),
                          ),
                        ] else ...[
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _checkAnswer,
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                backgroundColor: Colors.purple,
                                foregroundColor: Colors.white,
                              ),
                              child: const Text(
                                'ПРОВЕРИТЬ',
                                style: TextStyle(fontSize: 14, color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopicsPanel(bool isLandscape) {
    if (_topics.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'Нет доступных тем\nДобавьте слова через words_data.dart',
            style: TextStyle(
              fontSize: isLandscape ? 11 : 14,
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    if (isLandscape) {
      return Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Темы',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 18),
                  onPressed: _toggleTopicsPanel,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                TextButton(
                  onPressed: () => _selectAllTopics(true),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    minimumSize: Size.zero,
                  ),
                  child: const Text('Все', style: TextStyle(fontSize: 11)),
                ),
                TextButton(
                  onPressed: () => _selectAllTopics(false),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    minimumSize: Size.zero,
                  ),
                  child: const Text('Снять', style: TextStyle(fontSize: 11)),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView(
                children: _topics.map((topic) => CheckboxListTile(
                  title: Text(topic, style: const TextStyle(fontSize: 12)),
                  value: _selectedTopics[topic] ?? false,
                  onChanged: (bool? value) {
                    setState(() {
                      _selectedTopics[topic] = value ?? false;
                    });
                  },
                  dense: true,
                  visualDensity: VisualDensity.compact,
                  controlAffinity: ListTileControlAffinity.leading,
                  contentPadding: EdgeInsets.zero,
                )).toList(),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: hasSelectedTopics() ? () {
                  _startTraining();
                  setState(() {
                    _showTopicsPanel = false;
                  });
                } : null,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  backgroundColor: Colors.purple,
                  foregroundColor: Colors.white,
                ),
                child: const Text('НАЧАТЬ', style: TextStyle(fontSize: 12, color: Colors.white)),
              ),
            ),
          ],
        ),
      );
    } else {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Выберите темы',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                TextButton(
                  onPressed: () => _selectAllTopics(true),
                  child: const Text('Выбрать все', style: TextStyle(fontSize: 15)),
                ),
                const SizedBox(width: 8),
                TextButton(
                  onPressed: () => _selectAllTopics(false),
                  child: const Text('Снять все', style: TextStyle(fontSize: 15)),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView(
                children: _topics.map((topic) => CheckboxListTile(
                  title: Text(topic, style: const TextStyle(fontSize: 16)),
                  value: _selectedTopics[topic] ?? false,
                  onChanged: (bool? value) {
                    setState(() {
                      _selectedTopics[topic] = value ?? false;
                    });
                  },
                  controlAffinity: ListTileControlAffinity.leading,
                )).toList(),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: hasSelectedTopics() ? () {
                  _startTraining();
                } : null,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.purple,
                  foregroundColor: Colors.white,
                ),
                child: const Text(
                  'НАЧАТЬ ТРЕНИРОВКУ',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      );
    }
  }

  Widget _buildCompletionScreen(bool isLandscape) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _correctAnswers >= 15 ? Icons.emoji_events : Icons.school,
              size: isLandscape ? 40 : 80,
              color: _correctAnswers >= 15 ? Colors.amber : Colors.purple,
            ),
            SizedBox(height: isLandscape ? 8 : 20),
            Text(
              'Тренировка завершена!',
              style: TextStyle(
                fontSize: isLandscape ? 16 : 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: isLandscape ? 4 : 16),
            Text(
              'Правильных ответов: $_correctAnswers из $_totalAnswers',
              style: TextStyle(
                fontSize: isLandscape ? 12 : 20,
                color: Colors.grey.shade700,
              ),
            ),
            SizedBox(height: isLandscape ? 12 : 30),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      _feedback = '';
                      _showTopicsPanel = true;
                    });
                  },
                  icon: Icon(Icons.settings, size: isLandscape ? 14 : 20),
                  label: Text('Темы', style: TextStyle(fontSize: isLandscape ? 11 : 14)),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(
                        horizontal: isLandscape ? 10 : 20,
                        vertical: isLandscape ? 6 : 12
                    ),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _startTraining,
                  icon: Icon(Icons.replay, size: isLandscape ? 14 : 20),
                  label: Text('Ещё раз', style: TextStyle(fontSize: isLandscape ? 11 : 14)),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(
                        horizontal: isLandscape ? 10 : 20,
                        vertical: isLandscape ? 6 : 12
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// СТРАНИЦА ПРОГРЕССА
// ============================================================

class ProgressPage extends StatefulWidget {
  const ProgressPage({super.key});

  @override
  State<ProgressPage> createState() => _ProgressPageState();
}

class _ProgressPageState extends State<ProgressPage> {
  final DatabaseService _dbService = DatabaseService();

  List<String> _topics = [];
  String _selectedLanguage = 'en';
  final Map<String, Map<String, dynamic>> _topicStats = {};
  Map<String, dynamic> _overallStats = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
    _checkFirstLaunch();
  }

  Future<void> _checkFirstLaunch() async {
    await Future.delayed(const Duration(milliseconds: 100));
    if (mounted) {
      final shouldShow = await TutorialService.shouldShowProgressTutorial();
      if (shouldShow) {
        TutorialService.showProgressTutorial(context);
      }
    }
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    _topics = await _dbService.getTopics();
    _overallStats = await _dbService.getOverallStatistics();

    for (var topic in _topics) {
      var stats = await _dbService.getTopicStatistics(topic, _selectedLanguage);
      _topicStats[topic] = stats;
    }

    setState(() => _isLoading = false);
  }

  Future<void> _changeLanguage(String language) async {
    setState(() {
      _selectedLanguage = language;
      _topicStats.clear();
      _isLoading = true;
    });

    for (var topic in _topics) {
      var stats = await _dbService.getTopicStatistics(topic, _selectedLanguage);
      _topicStats[topic] = stats;
    }

    setState(() => _isLoading = false);
  }

  String _getDifficultyLevel(double difficulty) {
    if (difficulty < 0.3) return 'Легко';
    if (difficulty < 0.7) return 'Средне';
    return 'Сложно';
  }

  Color _getDifficultyColor(double difficulty) {
    if (difficulty < 0.3) return Colors.green;
    if (difficulty < 0.7) return Colors.orange;
    return Colors.red;
  }

  Future<void> _resetTopicProgress(String topic) async {
    final words = await _dbService.getWordsByTopic(topic, language: _selectedLanguage);

    if (words.isEmpty) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Сброс прогресса'),
        content: Text(
          'Вы уверены, что хотите сбросить прогресс для темы "$topic"?\n\n'
              'Все статистические данные (правильные/неправильные ответы, сложность, серии) будут удалены.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('ОТМЕНА'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('СБРОСИТЬ'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    for (var word in words) {
      word.correctCount = 0;
      word.wrongCount = 0;
      word.difficulty = 0.5;
      word.lastReviewed = null;
      word.streak = 0;
      word.nextReviewDate = null;
      await _dbService.updateWord(word);
    }

    await _loadData();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Прогресс по теме "$topic" сброшен'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Future<void> _resetAllProgress() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Сброс ВСЕГО прогресса'),
        content: const Text(
          '⚠️ ВНИМАНИЕ! ⚠️\n\n'
              'Вы уверены, что хотите сбросить ВЕСЬ прогресс?\n\n'
              'Будут удалены все данные о:\n'
              '• правильных и неправильных ответах\n'
              '• сложности слов\n'
              '• сериях правильных ответов\n'
              '• датах последнего повторения\n\n'
              'Это действие НЕЛЬЗЯ отменить!',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('ОТМЕНА'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('СБРОСИТЬ ВСЁ'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    await _dbService.resetAllProgress();
    await _loadData();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Весь прогресс сброшен'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _showRepeatOptions(String topic) {
    final mediaQuery = MediaQuery.of(context);
    final isLandscape = mediaQuery.orientation == Orientation.landscape;

    if (isLandscape) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          contentPadding: const EdgeInsets.all(16),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Повторить тему "$topic"',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              const Divider(height: 1),
              const SizedBox(height: 12),
              _buildRepeatOptionButton(
                icon: Icons.edit_note,
                title: 'ТРЕНАЖЁР',
                color: Colors.green,
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TrainerPage(selectedTopic: topic),
                    ),
                  );
                },
                isLandscape: true,
              ),
              const SizedBox(height: 8),
              _buildRepeatOptionButton(
                icon: Icons.quiz,
                title: 'ВЫБОР ПЕРЕВОДА',
                color: Colors.orange,
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MultipleChoicePage(selectedTopic: topic),
                    ),
                  );
                },
                isLandscape: true,
              ),
              const SizedBox(height: 8),
              _buildRepeatOptionButton(
                icon: Icons.translate,
                title: 'С РУССКОГО',
                color: Colors.purple,
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ReverseTranslationPage(selectedTopic: topic),
                    ),
                  );
                },
                isLandscape: true,
              ),
            ],
          ),
        ),
      );
    } else {
      showModalBottomSheet(
        context: context,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (context) => Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Повторить тему "$topic"',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Выберите способ повторения:',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 20),
              _buildRepeatOptionButton(
                icon: Icons.edit_note,
                title: 'ТРЕНАЖЁР',
                color: Colors.green,
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TrainerPage(selectedTopic: topic),
                    ),
                  );
                },
                isLandscape: false,
              ),
              const SizedBox(height: 12),
              _buildRepeatOptionButton(
                icon: Icons.quiz,
                title: 'ВЫБОР ПЕРЕВОДА',
                color: Colors.orange,
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MultipleChoicePage(selectedTopic: topic),
                    ),
                  );
                },
                isLandscape: false,
              ),
              const SizedBox(height: 12),
              _buildRepeatOptionButton(
                icon: Icons.translate,
                title: 'С РУССКОГО',
                color: Colors.purple,
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ReverseTranslationPage(selectedTopic: topic),
                    ),
                  );
                },
                isLandscape: false,
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      );
    }
  }

  Widget _buildRepeatOptionButton({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
    required bool isLandscape,
  }) {
    if (isLandscape) {
      return GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withValues(alpha: 0.3), width: 1.5),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                size: 20,
                color: color,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 12,
                color: color,
              ),
            ],
          ),
        ),
      );
    } else {
      return GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withValues(alpha: 0.3), width: 1.5),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                size: 28,
                color: color,
              ),
              const SizedBox(width: 16),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              const Spacer(),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: color,
              ),
            ],
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final isLandscape = mediaQuery.orientation == Orientation.landscape;

    return Scaffold(
      appBar: AppBar(
        title: const Text('ПРОГРЕСС'),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline, color: Colors.blue),
            onPressed: () => TutorialService.showProgressTutorial(context),
            tooltip: 'Показать подсказку',
          ),
          IconButton(
            icon: const Icon(Icons.delete_sweep, color: Colors.red),
            onPressed: _resetAllProgress,
            tooltip: 'Сбросить весь прогресс',
          ),
          DropdownButton<String>(
            value: _selectedLanguage,
            items: const [
              DropdownMenuItem(value: 'en', child: Text('🇬🇧 Английский')),
              DropdownMenuItem(value: 'es', child: Text('🇪🇸 Испанский')),
            ],
            onChanged: (value) {
              if (value != null) _changeLanguage(value);
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildContent(isLandscape),
    );
  }

  Widget _buildContent(bool isLandscape) {
    final totalWords = _overallStats['totalWords'] ?? 0;
    final totalCorrect = _overallStats['totalCorrect'] ?? 0;
    final totalWrong = _overallStats['totalWrong'] ?? 0;
    final learnedWords = _overallStats['learnedWords'] ?? 0;
    final hardWords = _overallStats['hardWords'] ?? 0;
    final avgDifficulty = _overallStats['avgDifficulty'] ?? 0.5;

    final progressPercent = totalWords > 0 ? (learnedWords / totalWords * 100) : 0;
    final accuracyPercent = (totalCorrect + totalWrong) > 0
        ? (totalCorrect / (totalCorrect + totalWrong) * 100)
        : 0;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.teal.shade400, Colors.teal.shade700],
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.insights, color: Colors.white, size: 28),
                  const SizedBox(width: 12),
                  Text(
                    'ОБЩАЯ СТАТИСТИКА',
                    style: TextStyle(
                      fontSize: isLandscape ? 14 : 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatItem(
                    '📚',
                    '$totalWords',
                    'всего слов',
                    isLandscape,
                  ),
                  _buildStatItem(
                    '✅',
                    '$learnedWords',
                    'изучено',
                    isLandscape,
                  ),
                  _buildStatItem(
                    '⚠️',
                    '$hardWords',
                    'сложных',
                    isLandscape,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Общий прогресс',
                        style: TextStyle(
                          fontSize: isLandscape ? 12 : 14,
                          color: Colors.white70,
                        ),
                      ),
                      Text(
                        '${progressPercent.toStringAsFixed(1)}%',
                        style: TextStyle(
                          fontSize: isLandscape ? 12 : 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: progressPercent / 100,
                    backgroundColor: Colors.white30,
                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Точность ответов',
                        style: TextStyle(
                          fontSize: isLandscape ? 12 : 14,
                          color: Colors.white70,
                        ),
                      ),
                      Text(
                        '${accuracyPercent.toStringAsFixed(1)}%',
                        style: TextStyle(
                          fontSize: isLandscape ? 12 : 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: accuracyPercent / 100,
                    backgroundColor: Colors.white30,
                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Средняя сложность: ${_getDifficultyLevel(avgDifficulty)}',
                    style: TextStyle(
                      fontSize: isLandscape ? 11 : 13,
                      color: Colors.white70,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: _getDifficultyColor(avgDifficulty).withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${(avgDifficulty * 100).toInt()}%',
                      style: TextStyle(
                        fontSize: isLandscape ? 11 : 13,
                        fontWeight: FontWeight.bold,
                        color: _getDifficultyColor(avgDifficulty),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        Row(
          children: [
            const Icon(Icons.folder, color: Colors.teal),
            const SizedBox(width: 8),
            Text(
              'ТЕМЫ',
              style: TextStyle(
                fontSize: isLandscape ? 16 : 20,
                fontWeight: FontWeight.bold,
                color: Colors.teal.shade800,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '(${_topics.length})',
              style: TextStyle(
                fontSize: isLandscape ? 13 : 16,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        if (_topics.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                children: [
                  Icon(Icons.inbox, size: 64, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  Text(
                    'Нет доступных тем',
                    style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Добавьте слова через words_data.dart',
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
                  ),
                ],
              ),
            ),
          )
        else
          ..._topics.map((topic) => _buildTopicCard(topic, isLandscape)),
      ],
    );
  }

  Widget _buildStatItem(String icon, String value, String label, bool isLandscape) {
    return Column(
      children: [
        Text(icon, style: const TextStyle(fontSize: 24)),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: isLandscape ? 20 : 28,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: isLandscape ? 10 : 12,
            color: Colors.white70,
          ),
        ),
      ],
    );
  }

  Widget _buildTopicCard(String topic, bool isLandscape) {
    final stats = _topicStats[topic] ?? {};
    final totalWords = stats['totalWords'] ?? 0;
    final learnedWords = stats['learnedWords'] ?? 0;
    final avgDifficulty = stats['avgDifficulty'] ?? 0.5;
    final totalCorrect = stats['totalCorrect'] ?? 0;
    final totalWrong = stats['totalWrong'] ?? 0;

    final progressPercent = totalWords > 0 ? (learnedWords / totalWords * 100) : 0;
    final accuracyPercent = (totalCorrect + totalWrong) > 0
        ? (totalCorrect / (totalCorrect + totalWrong) * 100)
        : 0;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TopicProgressPage(
              topic: topic,
              language: _selectedLanguage,
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade100,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.teal.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      topic.isNotEmpty ? topic[0] : '?',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.teal.shade700,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        topic,
                        style: TextStyle(
                          fontSize: isLandscape ? 16 : 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Выучено: $learnedWords из $totalWords',
                        style: TextStyle(
                          fontSize: isLandscape ? 11 : 13,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getDifficultyColor(avgDifficulty).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _getDifficultyLevel(avgDifficulty),
                    style: TextStyle(
                      fontSize: isLandscape ? 11 : 13,
                      color: _getDifficultyColor(avgDifficulty),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                  onPressed: () => _resetTopicProgress(topic),
                  tooltip: 'Сбросить прогресс по теме',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                ),
                IconButton(
                  icon: const Icon(Icons.repeat, color: Colors.blue, size: 20),
                  onPressed: () => _showRepeatOptions(topic),
                  tooltip: 'Повторить тему',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                ),
                const Icon(Icons.chevron_right, color: Colors.grey),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Прогресс',
                            style: TextStyle(
                              fontSize: isLandscape ? 11 : 13,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          Text(
                            '${progressPercent.toStringAsFixed(1)}%',
                            style: TextStyle(
                              fontSize: isLandscape ? 11 : 13,
                              fontWeight: FontWeight.w500,
                              color: Colors.teal,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      LinearProgressIndicator(
                        value: progressPercent / 100,
                        backgroundColor: Colors.grey.shade200,
                        valueColor: const AlwaysStoppedAnimation<Color>(Colors.teal),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Точность',
                            style: TextStyle(
                              fontSize: isLandscape ? 11 : 13,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          Text(
                            '${accuracyPercent.toStringAsFixed(1)}%',
                            style: TextStyle(
                              fontSize: isLandscape ? 11 : 13,
                              fontWeight: FontWeight.w500,
                              color: Colors.teal,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      LinearProgressIndicator(
                        value: accuracyPercent / 100,
                        backgroundColor: Colors.grey.shade200,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.teal.shade300),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// СТРАНИЦА ПРОГРЕССА ПО КОНКРЕТНОЙ ТЕМЕ
// ============================================================

class TopicProgressPage extends StatefulWidget {
  final String topic;
  final String language;

  const TopicProgressPage({
    super.key,
    required this.topic,
    required this.language,
  });

  @override
  State<TopicProgressPage> createState() => _TopicProgressPageState();
}

class _TopicProgressPageState extends State<TopicProgressPage> {
  final DatabaseService _dbService = DatabaseService();
  List<Word> _words = [];
  bool _isLoading = true;
  String _sortBy = 'word';

  @override
  void initState() {
    super.initState();
    _loadWords();
  }

  Future<void> _loadWords() async {
    setState(() => _isLoading = true);
    _words = await _dbService.getWordsByTopic(widget.topic, language: widget.language);
    _sortWords();
    setState(() => _isLoading = false);
  }

  void _sortWords() {
    switch (_sortBy) {
      case 'word':
        _words.sort((a, b) => a.word.compareTo(b.word));
        break;
      case 'difficulty':
        _words.sort((a, b) => b.difficulty.compareTo(a.difficulty));
        break;
      case 'correctCount':
        _words.sort((a, b) => b.correctCount.compareTo(a.correctCount));
        break;
      case 'wrongCount':
        _words.sort((a, b) => b.wrongCount.compareTo(a.wrongCount));
        break;
    }
  }

  String _getDifficultyLevel(double difficulty) {
    if (difficulty < 0.3) return 'Легко';
    if (difficulty < 0.7) return 'Средне';
    return 'Сложно';
  }

  Color _getDifficultyColor(double difficulty) {
    if (difficulty < 0.3) return Colors.green;
    if (difficulty < 0.7) return Colors.orange;
    return Colors.red;
  }

  IconData _getMasteryIcon(double difficulty) {
    if (difficulty < 0.3) return Icons.emoji_events;
    if (difficulty < 0.7) return Icons.trending_up;
    return Icons.warning_amber_rounded;
  }

  Future<void> _resetWordProgress(Word word) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Сброс прогресса слова'),
        content: Text(
          'Вы уверены, что хотите сбросить прогресс для слова "${word.word}"?\n\n'
              'Будут удалены: правильные/неправильные ответы, сложность, серия.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('ОТМЕНА'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('СБРОСИТЬ'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    word.correctCount = 0;
    word.wrongCount = 0;
    word.difficulty = 0.5;
    word.lastReviewed = null;
    word.streak = 0;
    word.nextReviewDate = null;
    await _dbService.updateWord(word);

    await _loadWords();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Прогресс для "${word.word}" сброшен'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Future<void> _resetAllWordsInTopic() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Сброс прогресса в теме "${widget.topic}"'),
        content: const Text(
          'Вы уверены, что хотите сбросить прогресс для ВСЕХ слов в этой теме?\n\n'
              'Это действие НЕЛЬЗЯ отменить!',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('ОТМЕНА'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('СБРОСИТЬ ВСЁ'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    for (var word in _words) {
      word.correctCount = 0;
      word.wrongCount = 0;
      word.difficulty = 0.5;
      word.lastReviewed = null;
      word.streak = 0;
      word.nextReviewDate = null;
      await _dbService.updateWord(word);
    }

    await _loadWords();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Весь прогресс в теме "${widget.topic}" сброшен'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final totalWords = _words.length;
    final learnedWords = _words.where((w) => w.difficulty < 0.3).length;
    final totalCorrect = _words.fold<int>(0, (sum, w) => sum + w.correctCount);
    final totalWrong = _words.fold<int>(0, (sum, w) => sum + w.wrongCount);
    final progressPercent = totalWords > 0 ? (learnedWords / totalWords * 100) : 0;
    final accuracyPercent = (totalCorrect + totalWrong) > 0
        ? (totalCorrect / (totalCorrect + totalWrong) * 100)
        : 0;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.topic),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep, color: Colors.red),
            onPressed: _resetAllWordsInTopic,
            tooltip: 'Сбросить прогресс всех слов в теме',
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.sort),
            onSelected: (value) {
              setState(() {
                _sortBy = value;
                _sortWords();
              });
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'word', child: Text('По алфавиту')),
              const PopupMenuItem(value: 'difficulty', child: Text('По сложности')),
              const PopupMenuItem(value: 'correctCount', child: Text('По правильным ответам')),
              const PopupMenuItem(value: 'wrongCount', child: Text('По ошибкам')),
            ],
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: Colors.teal.shade50,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildCompactStat('📚', '$totalWords'),
                _buildCompactStat('✅', '$learnedWords'),
                _buildCompactStat('📊', '${progressPercent.toStringAsFixed(0)}%'),
                _buildCompactStat('✓', '$totalCorrect'),
                _buildCompactStat('✗', '$totalWrong'),
                _buildCompactStat('🎯', '${accuracyPercent.toStringAsFixed(0)}%'),
              ],
            ),
          ),
          Expanded(
            child: _words.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.search_off, size: 64, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  Text(
                    'Нет слов в этой теме',
                    style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
                  ),
                ],
              ),
            )
                : ListView.builder(
              itemCount: _words.length,
              itemBuilder: (context, index) {
                final word = _words[index];
                final totalAttempts = word.correctCount + word.wrongCount;
                final accuracy = totalAttempts > 0
                    ? (word.correctCount / totalAttempts * 100).round()
                    : 0;

                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: _getDifficultyColor(word.difficulty).withValues(alpha: 0.2),
                      child: Icon(
                        _getMasteryIcon(word.difficulty),
                        color: _getDifficultyColor(word.difficulty),
                        size: 20,
                      ),
                    ),
                    title: Row(
                      children: [
                        Expanded(
                          child: Text(
                            word.word,
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: _getDifficultyColor(word.difficulty).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            _getDifficultyLevel(word.difficulty),
                            style: TextStyle(
                              fontSize: 11,
                              color: _getDifficultyColor(word.difficulty),
                            ),
                          ),
                        ),
                      ],
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          word.translation,
                          style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.check_circle, size: 14, color: Colors.green.shade400),
                            const SizedBox(width: 4),
                            Text(
                              '${word.correctCount}',
                              style: TextStyle(fontSize: 12, color: Colors.green.shade600),
                            ),
                            const SizedBox(width: 12),
                            Icon(Icons.cancel, size: 14, color: Colors.red.shade400),
                            const SizedBox(width: 4),
                            Text(
                              '${word.wrongCount}',
                              style: TextStyle(fontSize: 12, color: Colors.red.shade600),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Точность: $accuracy%',
                              style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                            ),
                          ],
                        ),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (word.streak != null && word.streak! > 0)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.amber.shade100,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.local_fire_department, size: 14, color: Colors.amber),
                                const SizedBox(width: 2),
                                Text(
                                  '${word.streak}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.amber.shade800,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline, color: Colors.red, size: 18),
                          onPressed: () => _resetWordProgress(word),
                          tooltip: 'Сбросить прогресс слова',
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactStat(String icon, String value) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(icon, style: const TextStyle(fontSize: 14)),
        Text(
          value,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.teal),
        ),
      ],
    );
  }
}