import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart' as sql;

class SQLHelper {
  static const double _money = 1;
  static const int _lemon = 0;
  static const double _lemonPrice = 0.50;
  static const int _sugar = 0;
  static const double _sugarPrice = 1;
  static const double _price = 1.0;
  static const double _clickValue = 0.01;

  static Future<sql.Database> db() async {
    return sql.openDatabase(
      'main.db',
      version: 1,
      onCreate: (sql.Database database, int version) async {
        await createTables(database);
      },
    );
  }

  static Future<void> createTables(sql.Database database) async {
    await database.execute("""CREATE TABLE items(
        money REAL,
        lemon INTEGER,
        lemonPrice REAL,
        sugar INTEGER,
        sugarPrice REAL,
        price REAL,
        clickValue REAL
      )
      """);

    await database.rawInsert(
        'INSERT INTO items (money, lemon, lemonPrice, sugar, sugarPrice, price, clickValue) VALUES($_money, $_lemon, $_lemonPrice, $_sugar, $_sugarPrice, $_price, $_clickValue)');

    await database.execute("""CREATE TABLE carts(
        lemon INTEGER,
        sugar INTEGER,
        water INTEGER,
        price REAL,
        quantity INTEGER
      )
      """);

    await database.rawInsert(
        'INSERT INTO carts (lemon, sugar, price, quantity) VALUES(0, 0, 0, 0)');
  }

  // Delete
  static Future<void> deleteItem() async {
    final db = await SQLHelper.db();
    try {
      updateItem(
          money: _money,
          lemon: _lemon,
          lemonPrice: _lemonPrice,
          sugar: _sugar,
          sugarPrice: _sugarPrice,
          price: _price,
          clickValue: _clickValue);
    } catch (err) {
      debugPrint("Something went wrong when deleting an item: $err");
    }
  }

  // Read items
  static Future<List<Map<String, dynamic>>> getItems() async {
    final db = await SQLHelper.db();
    return db.query('items');
  }

  // Update item
  static Future<int> updateItem(
      {double? money,
      int? lemon,
      double? lemonPrice,
      int? sugar,
      double? sugarPrice,
      double? price,
      double? clickValue}) async {
    final db = await SQLHelper.db();

    final Map<String, num> data = {};

    if (money != null) data['money'] = money;
    if (lemon != null) data['lemon'] = lemon;
    if (lemonPrice != null) data['lemonPrice'] = lemonPrice;
    if (sugar != null) data['sugar'] = sugar;
    if (sugarPrice != null) data['sugarPrice'] = sugarPrice;
    if (price != null) data['price'] = price;
    if (clickValue != null) data['clickValue'] = clickValue;

    final result = await db.update('items', data);
    return result;
  }

  // Read carts
  static Future<List<Map<String, dynamic>>> getCarts() async {
    final db = await SQLHelper.db();
    return db.query('carts');
  }

  // Update cart
  static Future<int> updateCart(
      {required int lemon,
      required int sugar,
      required int water,
      required double price,
      required int quantity}) async {
    final db = await SQLHelper.db();

    final Map<String, num> data = {};

    data['lemon'] = lemon;
    data['sugar'] = sugar;
    data['water'] = water;
    data['price'] = price;
    data['quantity'] = quantity;

    final result = await db.update('carts', data);
    return result;
  }
}
