// Начальные данные для базы данных
// При первом запуске приложения эти слова загрузятся в SQLite
// В будущем можно просто добавлять новые слова в этот список

List<Map<String, dynamic>> initialWords = [
  // ============================================================
  // ТЕМА: ЖИВОТНЫЕ (АНГЛИЙСКИЙ)
  // ============================================================
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

  // ============================================================
  // ТЕМА: ЖИВОТНЫЕ (ИСПАНСКИЙ)
  // ============================================================
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

  // ============================================================
  // ТЕМА: ЕДА (АНГЛИЙСКИЙ)
  // ============================================================
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

  // ============================================================
  // ТЕМА: ЕДА (ИСПАНСКИЙ)
  // ============================================================
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

  // ============================================================
  // ТЕМА: ОДЕЖДА (АНГЛИЙСКИЙ)
  // ============================================================
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

  // ============================================================
  // ТЕМА: ОДЕЖДА (ИСПАНСКИЙ)
  // ============================================================
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

  // ============================================================
  // ТЕМА: ТРАНСПОРТ (АНГЛИЙСКИЙ)
  // ============================================================
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

  // ============================================================
  // ТЕМА: ТРАНСПОРТ (ИСПАНСКИЙ)
  // ============================================================
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

  // ============================================================
  // Формат:
  // {'word': 'Новое слово', 'translation': 'Перевод', 'language': 'en', 'topic': 'Новая тема'},

];

// Вспомогательная функция для получения всех уникальных тем
List<String> getAllTopics() {
  Set<String> topics = {};
  for (var word in initialWords) {
    topics.add(word['topic'] as String);
  }
  return topics.toList();
}

// Вспомогательная функция для получения слов по теме и языку
List<Map<String, dynamic>> getWordsByTopicAndLanguage(String topic, String language) {
  return initialWords.where((word) =>
  word['topic'] == topic && word['language'] == language
  ).toList();
}