import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'dart:io';
import 'dart:convert';

void main() {
  runApp(const LanguageLearningApp());
}

class LanguageLearningApp extends StatelessWidget {
  const LanguageLearningApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WordlyEnglish',
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
    };
  }

  factory Word.fromMap(Map<String, dynamic> map) {
    return Word(
      id: map['id'],
      word: map['word'],
      translation: map['translation'],
      language: map['language'],
      topic: map['topic'],
      correctCount: map['correctCount'],
      wrongCount: map['wrongCount'],
      difficulty: map['difficulty'],
      lastReviewed: map['lastReviewed'] != null
          ? DateTime.parse(map['lastReviewed'])
          : null,
    );
  }
}

// Сервис для работы с SQLite
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
      version: 1, // Оставляем версию 1
      onCreate: _onCreate,
      // Убираем onUpgrade полностью
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
        lastReviewed TEXT
      )
    ''');

    await _insertInitialData(db);
  }

  Future<void> _insertInitialData(Database db) async {
    List<Map<String, dynamic>> initialWords = [
      // === ЖИВОТНЫЕ - АНГЛИЙСКИЕ ===
      {'word': 'Cat', 'translation': 'Кошка', 'language': 'en', 'topic': 'Животные'},
      {'word': 'Dog', 'translation': 'Собака', 'language': 'en', 'topic': 'Животные'},
      {'word': 'Hamster', 'translation': 'Хомяк', 'language': 'en', 'topic': 'Животные'},
      {'word': 'Rabbit', 'translation': 'Кролик', 'language': 'en', 'topic': 'Животные'},
      {'word': 'Lion', 'translation': 'Лев', 'language': 'en', 'topic': 'Животные'},
      {'word': 'Tiger', 'translation': 'Тигр', 'language': 'en', 'topic': 'Животные'},
      {'word': 'Elephant', 'translation': 'Слон', 'language': 'en', 'topic': 'Животные'},
      {'word': 'Giraffe', 'translation': 'Жираф', 'language': 'en', 'topic': 'Животные'},
      {'word': 'Monkey', 'translation': 'Обезьяна', 'language': 'en', 'topic': 'Животные'},
      {'word': 'Bear', 'translation': 'Медведь', 'language': 'en', 'topic': 'Животные'},
      {'word': 'Wolf', 'translation': 'Волк', 'language': 'en', 'topic': 'Животные'},
      {'word': 'Fox', 'translation': 'Лиса', 'language': 'en', 'topic': 'Животные'},
      {'word': 'Snake', 'translation': 'Змея', 'language': 'en', 'topic': 'Животные'},
      {'word': 'Eagle', 'translation': 'Орел', 'language': 'en', 'topic': 'Животные'},
      {'word': 'Dolphin', 'translation': 'Дельфин', 'language': 'en', 'topic': 'Животные'},
      {'word': 'Whale', 'translation': 'Кит', 'language': 'en', 'topic': 'Животные'},
      {'word': 'Shark', 'translation': 'Акула', 'language': 'en', 'topic': 'Животные'},

      // === ЖИВОТНЫЕ - ИСПАНСКИЕ ===
      {'word': 'Gato', 'translation': 'Кошка', 'language': 'es', 'topic': 'Животные'},
      {'word': 'Perro', 'translation': 'Собака', 'language': 'es', 'topic': 'Животные'},
      {'word': 'Hámster', 'translation': 'Хомяк', 'language': 'es', 'topic': 'Животные'},
      {'word': 'Conejo', 'translation': 'Кролик', 'language': 'es', 'topic': 'Животные'},
      {'word': 'León', 'translation': 'Лев', 'language': 'es', 'topic': 'Животные'},
      {'word': 'Tigre', 'translation': 'Тигр', 'language': 'es', 'topic': 'Животные'},
      {'word': 'Elefante', 'translation': 'Слон', 'language': 'es', 'topic': 'Животные'},
      {'word': 'Jirafa', 'translation': 'Жираф', 'language': 'es', 'topic': 'Животные'},
      {'word': 'Mono', 'translation': 'Обезьяна', 'language': 'es', 'topic': 'Животные'},
      {'word': 'Oso', 'translation': 'Медведь', 'language': 'es', 'topic': 'Животные'},
      {'word': 'Lobo', 'translation': 'Волк', 'language': 'es', 'topic': 'Животные'},
      {'word': 'Zorro', 'translation': 'Лиса', 'language': 'es', 'topic': 'Животные'},
      {'word': 'Serpiente', 'translation': 'Змея', 'language': 'es', 'topic': 'Животные'},
      {'word': 'Águila', 'translation': 'Орел', 'language': 'es', 'topic': 'Животные'},
      {'word': 'Delfín', 'translation': 'Дельфин', 'language': 'es', 'topic': 'Животные'},
      {'word': 'Ballena', 'translation': 'Кит', 'language': 'es', 'topic': 'Животные'},
      {'word': 'Tiburón', 'translation': 'Акула', 'language': 'es', 'topic': 'Животные'},

      // === ЕДА - АНГЛИЙСКАЯ ===
      {'word': 'Apple', 'translation': 'Яблоко', 'language': 'en', 'topic': 'Еда'},
      {'word': 'Banana', 'translation': 'Банан', 'language': 'en', 'topic': 'Еда'},
      {'word': 'Orange', 'translation': 'Апельсин', 'language': 'en', 'topic': 'Еда'},
      {'word': 'Strawberry', 'translation': 'Клубника', 'language': 'en', 'topic': 'Еда'},
      {'word': 'Grape', 'translation': 'Виноград', 'language': 'en', 'topic': 'Еда'},
      {'word': 'Watermelon', 'translation': 'Арбуз', 'language': 'en', 'topic': 'Еда'},
      {'word': 'Pineapple', 'translation': 'Ананас', 'language': 'en', 'topic': 'Еда'},
      {'word': 'Mango', 'translation': 'Манго', 'language': 'en', 'topic': 'Еда'},
      {'word': 'Peach', 'translation': 'Персик', 'language': 'en', 'topic': 'Еда'},
      {'word': 'Pear', 'translation': 'Груша', 'language': 'en', 'topic': 'Еда'},
      {'word': 'Potato', 'translation': 'Картофель', 'language': 'en', 'topic': 'Еда'},
      {'word': 'Tomato', 'translation': 'Помидор', 'language': 'en', 'topic': 'Еда'},
      {'word': 'Cucumber', 'translation': 'Огурец', 'language': 'en', 'topic': 'Еда'},
      {'word': 'Carrot', 'translation': 'Морковь', 'language': 'en', 'topic': 'Еда'},
      {'word': 'Meat', 'translation': 'Мясо', 'language': 'en', 'topic': 'Еда'},
      {'word': 'Chicken', 'translation': 'Курица', 'language': 'en', 'topic': 'Еда'},
      {'word': 'Fish', 'translation': 'Рыба', 'language': 'en', 'topic': 'Еда'},
      {'word': 'Milk', 'translation': 'Молоко', 'language': 'en', 'topic': 'Еда'},
      {'word': 'Bread', 'translation': 'Хлеб', 'language': 'en', 'topic': 'Еда'},
      {'word': 'Cheese', 'translation': 'Сыр', 'language': 'en', 'topic': 'Еда'},
      {'word': 'Egg', 'translation': 'Яйцо', 'language': 'en', 'topic': 'Еда'},

      // === ЕДА - ИСПАНСКАЯ ===
      {'word': 'Manzana', 'translation': 'Яблоко', 'language': 'es', 'topic': 'Еда'},
      {'word': 'Plátano', 'translation': 'Банан', 'language': 'es', 'topic': 'Еда'},
      {'word': 'Naranja', 'translation': 'Апельсин', 'language': 'es', 'topic': 'Еда'},
      {'word': 'Fresa', 'translation': 'Клубника', 'language': 'es', 'topic': 'Еда'},
      {'word': 'Uva', 'translation': 'Виноград', 'language': 'es', 'topic': 'Еда'},
      {'word': 'Sandía', 'translation': 'Арбуз', 'language': 'es', 'topic': 'Еда'},
      {'word': 'Piña', 'translation': 'Ананас', 'language': 'es', 'topic': 'Еда'},
      {'word': 'Mango', 'translation': 'Манго', 'language': 'es', 'topic': 'Еда'},
      {'word': 'Melocotón', 'translation': 'Персик', 'language': 'es', 'topic': 'Еда'},
      {'word': 'Pera', 'translation': 'Груша', 'language': 'es', 'topic': 'Еда'},
      {'word': 'Patata', 'translation': 'Картофель', 'language': 'es', 'topic': 'Еда'},
      {'word': 'Tomate', 'translation': 'Помидор', 'language': 'es', 'topic': 'Еда'},
      {'word': 'Pepino', 'translation': 'Огурец', 'language': 'es', 'topic': 'Еда'},
      {'word': 'Zanahoria', 'translation': 'Морковь', 'language': 'es', 'topic': 'Еда'},
      {'word': 'Carne', 'translation': 'Мясо', 'language': 'es', 'topic': 'Еда'},
      {'word': 'Pollo', 'translation': 'Курица', 'language': 'es', 'topic': 'Еда'},
      {'word': 'Pescado', 'translation': 'Рыба', 'language': 'es', 'topic': 'Еда'},
      {'word': 'Leche', 'translation': 'Молоко', 'language': 'es', 'topic': 'Еда'},
      {'word': 'Pan', 'translation': 'Хлеб', 'language': 'es', 'topic': 'Еда'},
      {'word': 'Queso', 'translation': 'Сыр', 'language': 'es', 'topic': 'Еда'},
      {'word': 'Huevo', 'translation': 'Яйцо', 'language': 'es', 'topic': 'Еда'},

      // === ОДЕЖДА - АНГЛИЙСКАЯ ===
      {'word': 'Shirt', 'translation': 'Рубашка', 'language': 'en', 'topic': 'Одежда'},
      {'word': 'T-shirt', 'translation': 'Футболка', 'language': 'en', 'topic': 'Одежда'},
      {'word': 'Pants', 'translation': 'Штаны', 'language': 'en', 'topic': 'Одежда'},
      {'word': 'Jeans', 'translation': 'Джинсы', 'language': 'en', 'topic': 'Одежда'},
      {'word': 'Dress', 'translation': 'Платье', 'language': 'en', 'topic': 'Одежда'},
      {'word': 'Skirt', 'translation': 'Юбка', 'language': 'en', 'topic': 'Одежда'},
      {'word': 'Jacket', 'translation': 'Куртка', 'language': 'en', 'topic': 'Одежда'},
      {'word': 'Coat', 'translation': 'Пальто', 'language': 'en', 'topic': 'Одежда'},
      {'word': 'Hat', 'translation': 'Шляпа', 'language': 'en', 'topic': 'Одежда'},
      {'word': 'Shoes', 'translation': 'Обувь', 'language': 'en', 'topic': 'Одежда'},
      {'word': 'Boots', 'translation': 'Ботинки', 'language': 'en', 'topic': 'Одежда'},
      {'word': 'Socks', 'translation': 'Носки', 'language': 'en', 'topic': 'Одежда'},

      // === ОДЕЖДА - ИСПАНСКАЯ ===
      {'word': 'Camisa', 'translation': 'Рубашка', 'language': 'es', 'topic': 'Одежда'},
      {'word': 'Camiseta', 'translation': 'Футболка', 'language': 'es', 'topic': 'Одежда'},
      {'word': 'Pantalones', 'translation': 'Штаны', 'language': 'es', 'topic': 'Одежда'},
      {'word': 'Vaqueros', 'translation': 'Джинсы', 'language': 'es', 'topic': 'Одежда'},
      {'word': 'Vestido', 'translation': 'Платье', 'language': 'es', 'topic': 'Одежда'},
      {'word': 'Falda', 'translation': 'Юбка', 'language': 'es', 'topic': 'Одежда'},
      {'word': 'Chaqueta', 'translation': 'Куртка', 'language': 'es', 'topic': 'Одежда'},
      {'word': 'Abrigo', 'translation': 'Пальто', 'language': 'es', 'topic': 'Одежда'},
      {'word': 'Sombrero', 'translation': 'Шляпа', 'language': 'es', 'topic': 'Одежда'},
      {'word': 'Zapatos', 'translation': 'Обувь', 'language': 'es', 'topic': 'Одежда'},
      {'word': 'Botas', 'translation': 'Ботинки', 'language': 'es', 'topic': 'Одежда'},
      {'word': 'Calcetines', 'translation': 'Носки', 'language': 'es', 'topic': 'Одежда'},

      // === ТРАНСПОРТ - АНГЛИЙСКИЙ ===
      {'word': 'Car', 'translation': 'Машина', 'language': 'en', 'topic': 'Транспорт'},
      {'word': 'Bus', 'translation': 'Автобус', 'language': 'en', 'topic': 'Транспорт'},
      {'word': 'Train', 'translation': 'Поезд', 'language': 'en', 'topic': 'Транспорт'},
      {'word': 'Plane', 'translation': 'Самолет', 'language': 'en', 'topic': 'Транспорт'},
      {'word': 'Bicycle', 'translation': 'Велосипед', 'language': 'en', 'topic': 'Транспорт'},
      {'word': 'Motorcycle', 'translation': 'Мотоцикл', 'language': 'en', 'topic': 'Транспорт'},
      {'word': 'Truck', 'translation': 'Грузовик', 'language': 'en', 'topic': 'Транспорт'},
      {'word': 'Ship', 'translation': 'Корабль', 'language': 'en', 'topic': 'Транспорт'},
      {'word': 'Boat', 'translation': 'Лодка', 'language': 'en', 'topic': 'Транспорт'},
      {'word': 'Helicopter', 'translation': 'Вертолет', 'language': 'en', 'topic': 'Транспорт'},

      // === ТРАНСПОРТ - ИСПАНСКИЙ ===
      {'word': 'Coche', 'translation': 'Машина', 'language': 'es', 'topic': 'Транспорт'},
      {'word': 'Autobús', 'translation': 'Автобус', 'language': 'es', 'topic': 'Транспорт'},
      {'word': 'Tren', 'translation': 'Поезд', 'language': 'es', 'topic': 'Транспорт'},
      {'word': 'Avión', 'translation': 'Самолет', 'language': 'es', 'topic': 'Транспорт'},
      {'word': 'Bicicleta', 'translation': 'Велосипед', 'language': 'es', 'topic': 'Транспорт'},
      {'word': 'Moto', 'translation': 'Мотоцикл', 'language': 'es', 'topic': 'Транспорт'},
      {'word': 'Camión', 'translation': 'Грузовик', 'language': 'es', 'topic': 'Транспорт'},
      {'word': 'Barco', 'translation': 'Корабль', 'language': 'es', 'topic': 'Транспорт'},
      {'word': 'Bote', 'translation': 'Лодка', 'language': 'es', 'topic': 'Транспорт'},
      {'word': 'Helicóptero', 'translation': 'Вертолет', 'language': 'es', 'topic': 'Транспорт'},
    ];

    for (var word in initialWords) {
      await db.insert('words', word);
    }
  }

  // Получить все слова
  Future<List<Word>> getAllWords() async {
    Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query('words');
    return List.generate(maps.length, (i) => Word.fromMap(maps[i]));
  }

  // Получить слова по теме и языку
  Future<List<Word>> getWordsByTopic(String topic, {String language = 'en'}) async {
    Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'words',
      where: 'topic = ? AND language = ?',
      whereArgs: [topic, language],
    );
    return List.generate(maps.length, (i) => Word.fromMap(maps[i]));
  }

  // Получить все темы (только русские)
  Future<List<String>> getTopics() async {
    Database db = await database;
    final result = await db.rawQuery('SELECT DISTINCT topic FROM words');
    List<String> allTopics = result.map((e) => e['topic'] as String).toList();

    // Возвращаем только русские темы, которые есть в базе
    List<String> russianTopics = [];
    if (allTopics.contains('Животные')) russianTopics.add('Животные');
    if (allTopics.contains('Еда')) russianTopics.add('Еда');
    if (allTopics.contains('Одежда')) russianTopics.add('Одежда');
    if (allTopics.contains('Транспорт')) russianTopics.add('Транспорт');

    return russianTopics;
  }

  // Обновить прогресс слова
  Future<void> updateWordProgress(Word word, bool isCorrect) async {
    Database db = await database;

    if (isCorrect) {
      word.correctCount++;
      word.difficulty = (word.difficulty - 0.1).clamp(0.0, 1.0);
    } else {
      word.wrongCount++;
      word.difficulty = (word.difficulty + 0.2).clamp(0.0, 1.0);
    }

    word.lastReviewed = DateTime.now();

    await db.update(
      'words',
      word.toMap(),
      where: 'id = ?',
      whereArgs: [word.id],
    );
  }

  // Получить слова для тренировки
  Future<List<Word>> getWordsForTraining(String topic, {int limit = 20}) async {
    Database db = await database;

    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT * FROM words 
      WHERE topic = ? 
      ORDER BY difficulty DESC, lastReviewed ASC 
      LIMIT ?
    ''', [topic, limit]);

    return List.generate(maps.length, (i) => Word.fromMap(maps[i]));
  }

  // Получить слова для тренировки из нескольких тем
  Future<List<Word>> getWordsForMultipleTopics(List<String> topics, {int limit = 20}) async {
    Database db = await database;

    String placeholders = topics.map((_) => '?').join(',');
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT * FROM words 
      WHERE topic IN ($placeholders) 
      ORDER BY difficulty DESC, lastReviewed ASC 
      LIMIT ?
    ''', [...topics, limit]);

    return List.generate(maps.length, (i) => Word.fromMap(maps[i]));
  }
}

// Главная страница
class MainPage extends StatelessWidget {
  const MainPage({super.key});

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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '9:30',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[600],
                ),
              ),
              Text(
                'WordlyEnglish',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[800],
                ),
              ),
              const SizedBox(width: 40),
            ],
          ),
          const SizedBox(height: 60),
          _buildMenuButton(
            context,
            title: 'СЛОВАРЬ',
            color: Colors.blue,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const DictionaryPage()),
              );
            },
          ),
          const SizedBox(height: 20),
          _buildMenuButton(
            context,
            title: 'ТРЕНАЖЁР',
            color: Colors.green,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const TrainerPage()),
              );
            },
          ),
          const SizedBox(height: 20),
          _buildMenuButton(
            context,
            title: 'ГЛАГОЛЫ',
            color: Colors.orange,
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Раздел в разработке')),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLandscapeLayout(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '9:30',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[600],
                ),
              ),
              Text(
                'WordlyEnglish',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[800],
                ),
              ),
              const SizedBox(width: 40),
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
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const DictionaryPage()),
                    );
                  },
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: _buildCompactMenuButton(
                  context,
                  title: 'ТРЕНАЖЁР',
                  color: Colors.green,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const TrainerPage()),
                    );
                  },
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: _buildCompactMenuButton(
                  context,
                  title: 'ГЛАГОЛЫ',
                  color: Colors.orange,
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Раздел в разработке')),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMenuButton(BuildContext context, {
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 100,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color, width: 2),
        ),
        child: Center(
          child: Text(
            title,
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: color,
              letterSpacing: 2,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCompactMenuButton(BuildContext context, {
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 80,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: color, width: 2),
        ),
        child: Center(
          child: Text(
            title,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
              letterSpacing: 2,
            ),
          ),
        ),
      ),
    );
  }
}

// Страница словаря
class DictionaryPage extends StatefulWidget {
  const DictionaryPage({super.key});

  @override
  State<DictionaryPage> createState() => _DictionaryPageState();
}

class _DictionaryPageState extends State<DictionaryPage> {
  final DatabaseService _dbService = DatabaseService();

  // Данные
  Map<String, List<Word>> _groupedWords = {};
  List<String> _alphabetKeys = [];
  List<String> _topics = [];
  List<Word> _allWords = [];

  // Состояние
  String _selectedLanguage = 'en';
  String _selectedTopic = 'Все темы'; // Выбранная тема для фильтрации
  bool _showTopicFilter = false; // Показывать ли фильтр тем

  // Скролл
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
    // Загружаем все темы
    _topics = await _dbService.getTopics();

    // Загружаем все слова для выбранного языка
    await _loadWords();
  }

  Future<void> _loadWords() async {
    List<Word> allWords = [];

    if (_selectedTopic == 'Все темы') {
      // Загружаем слова из всех тем
      for (var topic in _topics) {
        allWords.addAll(await _dbService.getWordsByTopic(topic, language: _selectedLanguage));
      }
    } else {
      // Загружаем слова только из выбранной темы
      allWords = await _dbService.getWordsByTopic(_selectedTopic, language: _selectedLanguage);
    }

    _allWords = allWords;
    _groupWordsByLetter();
  }

  void _groupWordsByLetter() {
    _allWords.sort((a, b) => a.word.compareTo(b.word));
    final Map<String, List<Word>> grouped = {};

    for (var word in _allWords) {
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
          // Кнопка фильтра по темам
          IconButton(
            icon: Icon(_showTopicFilter ? Icons.filter_list : Icons.filter_list_off),
            onPressed: () {
              setState(() {
                _showTopicFilter = !_showTopicFilter;
              });
            },
            tooltip: 'Фильтр по темам',
          ),

          // Выбор языка
          DropdownButton<String>(
            value: _selectedLanguage,
            items: const [
              DropdownMenuItem(value: 'en', child: Text('Английский')),
              DropdownMenuItem(value: 'es', child: Text('Испанский')),
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
          // Панель фильтрации по темам (появляется при нажатии на кнопку)
          if (_showTopicFilter)
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
                        // Кнопка "Все темы"
                        FilterChip(
                          label: Text('Все темы'),
                          selected: _selectedTopic == 'Все темы',
                          onSelected: (selected) {
                            setState(() {
                              _selectedTopic = 'Все темы';
                              _loadWords();
                            });
                          },
                        ),
                        const SizedBox(width: 8),
                        // Кнопки для каждой темы
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
                        )).toList(),
                      ],
                    ),
                  ),
                ],
              ),
            ),

          // Основной список слов
          Expanded(
            child: Stack(
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
                            trailing: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: _getDifficultyColor(word.difficulty),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                '${(word.difficulty * 100).toInt()}%',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          )),
                        ],
                      );
                    },
                  ),
                ),

                // Алфавитный скроллбар
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

          // Информация о количестве слов
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

  Color _getDifficultyColor(double difficulty) {
    if (difficulty < 0.3) return Colors.green;
    if (difficulty < 0.6) return Colors.orange;
    return Colors.red;
  }
}

// Страница тренажера
class TrainerPage extends StatefulWidget {
  const TrainerPage({super.key});

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
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadTopics();
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadTopics() async {
    _topics = await _dbService.getTopics();
    setState(() {
      for (var topic in _topics) {
        _selectedTopics[topic] = true;
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
      var words = await _dbService.getWordsForTraining(topic, limit: 20);
      allWords.addAll(words);
    }

    allWords = allWords.where((word) => word.language == _selectedLanguage).toList();
    allWords.shuffle();
    _trainingWords = allWords.take(20).toList();

    setState(() {
      _currentIndex = 0;
      _currentWord = _trainingWords.isNotEmpty ? _trainingWords[0] : null;
      _showTranslation = false;
      _controller.clear();
      _feedback = '';
      _showTopicsPanel = false;
    });
  }

  void _checkAnswer() {
    if (_currentWord == null) return;

    String userAnswer = _controller.text.trim().toLowerCase();
    String correctAnswer = _currentWord!.translation.toLowerCase();

    bool isCorrect = userAnswer == correctAnswer;

    setState(() {
      _showTranslation = true;
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
    } else {
      setState(() {
        _currentWord = null;
        _showTranslation = false;
        _feedback = 'Тренировка завершена!';
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
    final isKeyboardVisible = mediaQuery.viewInsets.bottom > 0;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: isLandscape
          ? null
          : AppBar(
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
              DropdownMenuItem(value: 'en', child: Text('Английский')),
              DropdownMenuItem(value: 'es', child: Text('Испанский')),
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
        child: isLandscape && _currentWord != null
            ? _buildLandscapeTrainingLayout(context)
            : _buildDefaultLayout(context, isLandscape, isKeyboardVisible),
      ),
    );
  }

  Widget _buildDefaultLayout(BuildContext context, bool isLandscape, bool isKeyboardVisible) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        children: [
          if (_showTopicsPanel && _topics.isNotEmpty)
            _buildTopicsPanel(isLandscape),
          if (!_showTopicsPanel && _currentWord == null && _topics.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: ElevatedButton(
                onPressed: _toggleTopicsPanel,
                child: const Text('Выбрать темы'),
              ),
            ),
          if (_currentWord != null)
            Expanded(
              child: _buildTrainingContent(isLandscape, isKeyboardVisible),
            ),
        ],
      ),
    );
  }

  Widget _buildLandscapeTrainingLayout(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.pop(context),
                tooltip: 'Назад',
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.blue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blue, width: 1.5),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Flexible(
                        child: Text(
                          _currentWord!.word,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (_showTranslation) ...[
                        const SizedBox(width: 16),
                        Flexible(
                          child: Text(
                            '→ ${_currentWord!.translation}',
                            style: const TextStyle(
                              fontSize: 20,
                              color: Colors.green,
                            ),
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              DropdownButton<String>(
                value: _selectedLanguage,
                items: const [
                  DropdownMenuItem(value: 'en', child: Text('🇬🇧 EN')),
                  DropdownMenuItem(value: 'es', child: Text('🇪🇸 ES')),
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
              const SizedBox(width: 4),
              IconButton(
                icon: Icon(_showTopicsPanel ? Icons.folder_open : Icons.folder),
                onPressed: _toggleTopicsPanel,
                tooltip: 'Выбор тем',
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (_showTopicsPanel && _topics.isNotEmpty)
            _buildTopicsPanel(true),
          const SizedBox(height: 12),
          Expanded(
            child: SingleChildScrollView(
              controller: _scrollController,
              child: Column(
                children: [
                  TextField(
                    controller: _controller,
                    focusNode: _focusNode,
                    decoration: InputDecoration(
                      hintText: 'Введите перевод',
                      border: const OutlineInputBorder(),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12.0,
                        vertical: 8.0,
                      ),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.check),
                        onPressed: _checkAnswer,
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
                  const SizedBox(height: 8.0),
                  Text(
                    _feedback,
                    style: TextStyle(
                      fontSize: 14.0,
                      color: _feedback.contains('✓') ? Colors.green : Colors.red,
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  if (_showTranslation)
                    Center(
                      child: ElevatedButton(
                        onPressed: _nextWord,
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(200.0, 36.0),
                        ),
                        child: const Text('Далее'),
                      ),
                    ),
                  const SizedBox(height: 20.0),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopicsPanel(bool isLandscape) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          ListTile(
            dense: true,
            title: Text(
              'Темы',
              style: TextStyle(
                fontSize: isLandscape ? 14.0 : 16.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Text(
              '${getSelectedTopics().length} из ${_topics.length}',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: isLandscape ? 12.0 : 14.0,
              ),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextButton(
                  onPressed: () => _selectAllTopics(true),
                  child: Text(
                    'Все',
                    style: TextStyle(fontSize: isLandscape ? 12.0 : 14.0),
                  ),
                ),
                TextButton(
                  onPressed: () => _selectAllTopics(false),
                  child: Text(
                    'Нет',
                    style: TextStyle(fontSize: isLandscape ? 12.0 : 14.0),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: _toggleTopicsPanel,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),
          SizedBox(
            height: isLandscape ? 100.0 : 120.0,
            child: ListView(
              children: _topics.map((topic) => CheckboxListTile(
                title: Text(
                  topic,
                  style: TextStyle(fontSize: isLandscape ? 12.0 : 14.0),
                ),
                value: _selectedTopics[topic] ?? false,
                onChanged: (bool? value) {
                  setState(() {
                    _selectedTopics[topic] = value ?? false;
                  });
                },
                dense: true,
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: const EdgeInsets.symmetric(horizontal: 8),
              )).toList(),
            ),
          ),
          if (_currentWord == null)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                onPressed: hasSelectedTopics() ? _startTraining : null,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 36),
                ),
                child: Text(
                  'Начать',
                  style: TextStyle(fontSize: isLandscape ? 14.0 : 16.0),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTrainingContent(bool isLandscape, bool isKeyboardVisible) {
    return SingleChildScrollView(
      controller: _scrollController,
      child: Column(
        children: [
          if (!isLandscape)
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(isLandscape ? 16.0 : 24.0),
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(isLandscape ? 12.0 : 16.0),
                border: Border.all(
                  color: Colors.blue,
                  width: isLandscape ? 1.5 : 2.0,
                ),
              ),
              child: Column(
                children: [
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      _currentWord!.word,
                      style: TextStyle(
                        fontSize: isLandscape ? 32.0 : 40.0,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  if (_showTranslation) ...[
                    SizedBox(height: isLandscape ? 8.0 : 16.0),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        _currentWord!.translation,
                        style: TextStyle(
                          fontSize: isLandscape ? 24.0 : 28.0,
                          color: Colors.green,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          SizedBox(height: isLandscape ? 8.0 : 16.0),
          TextField(
            controller: _controller,
            focusNode: _focusNode,
            decoration: InputDecoration(
              hintText: 'Введите перевод',
              border: const OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 12.0,
                vertical: isLandscape ? 8.0 : 12.0,
              ),
              suffixIcon: IconButton(
                icon: Icon(isLandscape ? Icons.check : Icons.check),
                onPressed: _checkAnswer,
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
          SizedBox(height: isLandscape ? 4.0 : 8.0),
          Text(
            _feedback,
            style: TextStyle(
              fontSize: isLandscape ? 14.0 : 16.0,
              color: _feedback.contains('✓') ? Colors.green : Colors.red,
            ),
          ),
          SizedBox(height: isLandscape ? 8.0 : 16.0),
          if (_showTranslation)
            Center(
              child: ElevatedButton(
                onPressed: _nextWord,
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(
                    isLandscape ? 200.0 : double.infinity,
                    isLandscape ? 36.0 : 48.0,
                  ),
                ),
                child: Text(
                  'Далее',
                  style: TextStyle(fontSize: isLandscape ? 14.0 : 16.0),
                ),
              ),
            ),
          SizedBox(height: isKeyboardVisible ? 20.0 : 40.0),
        ],
      ),
    );
  }
}