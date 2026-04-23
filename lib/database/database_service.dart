import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'dart:io';
import '../data/words_en.dart';
import '../data/words_es.dart';
import '../data/words_de.dart';
import '../data/words_it.dart';
import '../main.dart' show Word;

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, 'words.db');

    return await openDatabase(
      path,
      version: 2,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE words(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        word TEXT NOT NULL,
        translation TEXT NOT NULL,
        language TEXT NOT NULL,
        topic TEXT NOT NULL,
        correctCount INTEGER DEFAULT 0,
        wrongCount INTEGER DEFAULT 0,
        difficulty REAL DEFAULT 0.5,
        lastReviewed TEXT,
        streak INTEGER DEFAULT 0,
        nextReviewDate TEXT
      )
    ''');

    await _insertInitialData(db);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      try {
        await db.execute('ALTER TABLE words ADD COLUMN streak INTEGER DEFAULT 0');
      } catch (e) {
        // Колонка уже существует
      }
      try {
        await db.execute('ALTER TABLE words ADD COLUMN nextReviewDate TEXT');
      } catch (e) {
        // Колонка уже существует
      }
    }
  }

  Future<void> _insertInitialData(Database db) async {
    // Загружаем слова для всех языков
    await _insertWordsForLanguage(db, wordsEn, 'en');
    await _insertWordsForLanguage(db, wordsEs, 'es');
    await _insertWordsForLanguage(db, wordsDe, 'de');
    await _insertWordsForLanguage(db, wordsIt, 'it');
  }

  Future<void> _insertWordsForLanguage(Database db, List<Map<String, dynamic>> words, String language) async {
    for (var word in words) {
      // Добавляем язык к каждому слову перед вставкой
      final wordWithLang = Map<String, dynamic>.from(word);
      wordWithLang['language'] = language;
      await db.insert('words', wordWithLang);
    }
  }

  Future<List<Map<String, dynamic>>> getAllWordsRaw() async {
    Database db = await database;
    return await db.query('words');
  }

  Future<List<Word>> getAllWords() async {
    Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query('words');
    return List.generate(maps.length, (i) => Word.fromMap(maps[i]));
  }

  Future<List<Word>> getWordsByTopic(String topic, {String language = 'en'}) async {
    Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'words',
      where: 'topic = ? AND language = ?',
      whereArgs: [topic, language],
    );
    return List.generate(maps.length, (i) => Word.fromMap(maps[i]));
  }

  Future<List<String>> getTopics() async {
    Database db = await database;
    final result = await db.rawQuery('SELECT DISTINCT topic FROM words ORDER BY topic');
    return result.map((e) => e['topic'] as String).toList();
  }

  Future<List<String>> getTopicsByLanguage(String language) async {
    Database db = await database;
    final result = await db.rawQuery(
      'SELECT DISTINCT topic FROM words WHERE language = ? ORDER BY topic',
      [language],
    );
    return result.map((e) => e['topic'] as String).toList();
  }

  Future<void> updateWordProgress(Word word, bool isCorrect) async {
    Database db = await database;
    DateTime now = DateTime.now();

    if (isCorrect) {
      word.correctCount++;
      word.difficulty = (word.difficulty - 0.1).clamp(0.0, 1.0);
      word.streak = (word.streak ?? 0) + 1;

      int daysToAdd = _calculateReviewInterval(word.streak ?? 0, word.difficulty);
      word.nextReviewDate = now.add(Duration(days: daysToAdd));
    } else {
      word.wrongCount++;
      word.difficulty = (word.difficulty + 0.2).clamp(0.0, 1.0);
      word.streak = 0;
      word.nextReviewDate = now.add(Duration(hours: 12));
    }

    word.lastReviewed = now;

    await db.update(
      'words',
      word.toMap(),
      where: 'id = ?',
      whereArgs: [word.id],
    );
  }

  int _calculateReviewInterval(int streak, double difficulty) {
    int baseDays = (7 * (1 - difficulty)).ceil().clamp(1, 7);
    int streakBonus = (streak / 2).floor().clamp(0, 14);
    return baseDays + streakBonus;
  }

  Future<List<Word>> getWordsForTraining(String topic, {int limit = 20}) async {
    Database db = await database;
    DateTime now = DateTime.now();

    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT * FROM words 
      WHERE topic = ? 
      ORDER BY 
        CASE 
          WHEN nextReviewDate IS NULL THEN 0
          WHEN nextReviewDate <= ? THEN 0
          ELSE 1
        END,
        difficulty DESC,
        lastReviewed ASC NULLS FIRST
      LIMIT ?
    ''', [topic, now.toIso8601String(), limit]);

    return List.generate(maps.length, (i) => Word.fromMap(maps[i]));
  }

  Future<List<Word>> getWordsDueForReview({String? topic, String? language}) async {
    Database db = await database;
    DateTime now = DateTime.now();

    String whereClause = 'nextReviewDate <= ?';
    List<Object?> whereArgs = [now.toIso8601String()];

    if (topic != null) {
      whereClause += ' AND topic = ?';
      whereArgs.add(topic);
    }

    if (language != null) {
      whereClause += ' AND language = ?';
      whereArgs.add(language);
    }

    final List<Map<String, dynamic>> maps = await db.query(
      'words',
      where: whereClause,
      whereArgs: whereArgs,
      orderBy: 'difficulty DESC, lastReviewed ASC',
    );

    return List.generate(maps.length, (i) => Word.fromMap(maps[i]));
  }

  Future<List<Word>> getHardWords({double threshold = 0.7, String? topic, String? language}) async {
    Database db = await database;

    String whereClause = 'difficulty > ?';
    List<Object?> whereArgs = [threshold];

    if (topic != null) {
      whereClause += ' AND topic = ?';
      whereArgs.add(topic);
    }

    if (language != null) {
      whereClause += ' AND language = ?';
      whereArgs.add(language);
    }

    final List<Map<String, dynamic>> maps = await db.query(
      'words',
      where: whereClause,
      whereArgs: whereArgs,
      orderBy: 'difficulty DESC',
    );

    return List.generate(maps.length, (i) => Word.fromMap(maps[i]));
  }

  Future<Map<String, dynamic>> getOverallStatistics() async {
    Database db = await database;

    final result = await db.rawQuery('''
      SELECT 
        COUNT(*) as totalWords,
        SUM(correctCount) as totalCorrect,
        SUM(wrongCount) as totalWrong,
        AVG(difficulty) as avgDifficulty,
        COUNT(CASE WHEN difficulty < 0.3 THEN 1 END) as learnedWords,
        COUNT(CASE WHEN difficulty > 0.7 THEN 1 END) as hardWords
      FROM words
    ''');

    return result.first;
  }

  Future<Map<String, dynamic>> getTopicStatistics(String topic, String language) async {
    Database db = await database;

    final result = await db.rawQuery('''
      SELECT 
        COUNT(*) as totalWords,
        SUM(correctCount) as totalCorrect,
        SUM(wrongCount) as totalWrong,
        AVG(difficulty) as avgDifficulty,
        COUNT(CASE WHEN difficulty < 0.3 THEN 1 END) as learnedWords,
        COUNT(CASE WHEN difficulty > 0.7 THEN 1 END) as hardWords
      FROM words
      WHERE topic = ? AND language = ?
    ''', [topic, language]);

    return result.first;
  }

  Future<List<Word>> getWordsByLanguage(String language) async {
    Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'words',
      where: 'language = ?',
      whereArgs: [language],
    );
    return List.generate(maps.length, (i) => Word.fromMap(maps[i]));
  }

  Future<bool> hasWordsForTopic(String topic, String language) async {
    Database db = await database;
    final result = await db.query(
      'words',
      where: 'topic = ? AND language = ?',
      whereArgs: [topic, language],
      limit: 1,
    );
    return result.isNotEmpty;
  }

  Future<int> addWord(Word word) async {
    Database db = await database;
    return await db.insert('words', word.toMap());
  }

  Future<void> addWords(List<Word> words) async {
    Database db = await database;
    Batch batch = db.batch();
    for (var word in words) {
      batch.insert('words', word.toMap());
    }
    await batch.commit();
  }

  Future<int> deleteWord(int id) async {
    Database db = await database;
    return await db.delete('words', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> updateWord(Word word) async {
    Database db = await database;
    return await db.update(
      'words',
      word.toMap(),
      where: 'id = ?',
      whereArgs: [word.id],
    );
  }

  Future<void> resetAllProgress() async {
    Database db = await database;
    await db.update(
      'words',
      {
        'correctCount': 0,
        'wrongCount': 0,
        'difficulty': 0.5,
        'lastReviewed': null,
        'streak': 0,
        'nextReviewDate': null,
      },
    );
  }
}