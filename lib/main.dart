import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'dart:io';

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
      version: 1,
      onCreate: _onCreate,
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
      {'word': 'Penguin', 'translation': 'Пингвин', 'language': 'en', 'topic': 'Животные'},
      {'word': 'Kangaroo', 'translation': 'Кенгуру', 'language': 'en', 'topic': 'Животные'},
      {'word': 'Zebra', 'translation': 'Зебра', 'language': 'en', 'topic': 'Животные'},

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
      {'word': 'Pingüino', 'translation': 'Пингвин', 'language': 'es', 'topic': 'Животные'},
      {'word': 'Canguro', 'translation': 'Кенгуру', 'language': 'es', 'topic': 'Животные'},
      {'word': 'Cebra', 'translation': 'Зебра', 'language': 'es', 'topic': 'Животные'},

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
      {'word': 'Rice', 'translation': 'Рис', 'language': 'en', 'topic': 'Еда'},
      {'word': 'Pasta', 'translation': 'Паста', 'language': 'en', 'topic': 'Еда'},
      {'word': 'Soup', 'translation': 'Суп', 'language': 'en', 'topic': 'Еда'},
      {'word': 'Salad', 'translation': 'Салат', 'language': 'en', 'topic': 'Еда'},

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
      {'word': 'Arroz', 'translation': 'Рис', 'language': 'es', 'topic': 'Еда'},
      {'word': 'Pasta', 'translation': 'Паста', 'language': 'es', 'topic': 'Еда'},
      {'word': 'Sopa', 'translation': 'Суп', 'language': 'es', 'topic': 'Еда'},
      {'word': 'Ensalada', 'translation': 'Салат', 'language': 'es', 'topic': 'Еда'},

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
      {'word': 'Sweater', 'translation': 'Свитер', 'language': 'en', 'topic': 'Одежда'},
      {'word': 'Scarf', 'translation': 'Шарф', 'language': 'en', 'topic': 'Одежда'},
      {'word': 'Gloves', 'translation': 'Перчатки', 'language': 'en', 'topic': 'Одежда'},

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
      {'word': 'Suéter', 'translation': 'Свитер', 'language': 'es', 'topic': 'Одежда'},
      {'word': 'Bufanda', 'translation': 'Шарф', 'language': 'es', 'topic': 'Одежда'},
      {'word': 'Guantes', 'translation': 'Перчатки', 'language': 'es', 'topic': 'Одежда'},

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
      {'word': 'Taxi', 'translation': 'Такси', 'language': 'en', 'topic': 'Транспорт'},
      {'word': 'Subway', 'translation': 'Метро', 'language': 'en', 'topic': 'Транспорт'},
      {'word': 'Tram', 'translation': 'Трамвай', 'language': 'en', 'topic': 'Транспорт'},

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
      {'word': 'Taxi', 'translation': 'Такси', 'language': 'es', 'topic': 'Транспорт'},
      {'word': 'Metro', 'translation': 'Метро', 'language': 'es', 'topic': 'Транспорт'},
      {'word': 'Tranvía', 'translation': 'Трамвай', 'language': 'es', 'topic': 'Транспорт'},
    ];

    for (var word in initialWords) {
      await db.insert('words', word);
    }
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
    final result = await db.rawQuery('SELECT DISTINCT topic FROM words');
    List<String> allTopics = result.map((e) => e['topic'] as String).toList();

    List<String> russianTopics = [];
    if (allTopics.contains('Животные')) russianTopics.add('Животные');
    if (allTopics.contains('Еда')) russianTopics.add('Еда');
    if (allTopics.contains('Одежда')) russianTopics.add('Одежда');
    if (allTopics.contains('Транспорт')) russianTopics.add('Транспорт');

    return russianTopics;
  }

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
          const SizedBox(height: 40),
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
          const SizedBox(height: 16),
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
          const SizedBox(height: 16),
          _buildMenuButton(
            context,
            title: 'ВЫБОР ПЕРЕВОДА',
            color: Colors.orange,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const MultipleChoicePage()),
              );
            },
          ),
          const SizedBox(height: 16),
          _buildMenuButton(
            context,
            title: 'С РУССКОГО',
            color: Colors.purple,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ReverseTranslationPage()),
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
          const SizedBox(height: 16),
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
              const SizedBox(width: 12),
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
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildCompactMenuButton(
                  context,
                  title: 'ВЫБОР ПЕРЕВОДА',
                  color: Colors.orange,
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
                child: _buildCompactMenuButton(
                  context,
                  title: 'С РУССКОГО',
                  color: Colors.purple,
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
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: color,
              letterSpacing: 1.5,
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
        height: 70,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: color, width: 2),
        ),
        child: Center(
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
              letterSpacing: 1.5,
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
                        'Выберите темы и начните тренировку',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey.shade600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 30),
                      ElevatedButton.icon(
                        onPressed: hasSelectedTopics() ? _startTraining : null,
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
            'Выберите темы и начните тренировку',
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: hasSelectedTopics() ? _startTraining : null,
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

// Страница выбора перевода
class MultipleChoicePage extends StatefulWidget {
  const MultipleChoicePage({super.key});

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
                        'Выберите темы и начните тренировку',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey.shade600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 30),
                      ElevatedButton.icon(
                        onPressed: hasSelectedTopics() ? _startTraining : null,
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
            'Выберите темы и начните тренировку',
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: hasSelectedTopics() ? _startTraining : null,
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

// Страница обратного перевода (с русского на иностранный)
class ReverseTranslationPage extends StatefulWidget {
  const ReverseTranslationPage({super.key});

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
                        'Выберите темы и начните тренировку',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey.shade600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 30),
                      ElevatedButton.icon(
                        onPressed: hasSelectedTopics() ? _startTraining : null,
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
            'Выберите темы и начните тренировку',
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: hasSelectedTopics() ? _startTraining : null,
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