import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // for date formatting
import 'package:sqflite/sqflite.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';



// Define a separate class for your color scheme
class AppColors {
  static const Color appBarColor = Color(0xFF36D582);
  static const Color backgroundColor = Color(0xFF000000);
  static const Color containerColor = Color(0xFF252525);
  static const Color textColor = Color(0xFFDDF7EB);
  static const Color buttonColor = Colors.grey;
}

class Item {
  final String name;
  final DateTime expiryDate;

  Item(this.name, this.expiryDate);
}

class InputPage extends StatefulWidget {
  const InputPage({Key? key}) : super(key: key);

  @override
  State<InputPage> createState() => _InputPageState();
}

class _InputPageState extends State<InputPage> {

  @override
  void initState() {
    super.initState();
    _openDatabase();
  }

  Future<String> generateUniqueId(String itemName) async {
    try {
      //print(itemName);
      final response = await http.post(
        Uri.parse('http://bhindi1.ddns.net/bbb_newitemuid'),
        body: {
          'name': itemName,
        },
      );

      if (response.statusCode == 200) {
        print("Inside generator: ");
        print(response.body);
        return response.body;
      } else {
        // If the request fails, throw an error
        throw Exception('Failed to generate unique ID');
      }
    } catch (e) {
      // Handle any errors that occur during the HTTP request
      print("Error generating unique ID: $e");
      throw Exception('Failed to generate unique ID');
    }
  }

  static const String tableName = 'foods';
  static const String columnFoodUid = 'food_uid';
  static const String columnName = 'name';
  static const String columnBoughtOn = 'bought_on';
  static const String columnExpiresOn = 'expires_on';
  static const String columnDaysBeforeNotify = 'days_before_notify';

  late Database _database;

  Future<void> _openDatabase() async {
    //print(appusername);
    _database = await openDatabase(
      join(await getDatabasesPath(), 'databasename.db'),
      onCreate: (db, version) {
        // Create the table if not exists
        return db.execute(
          "CREATE TABLE IF NOT EXISTS foods(food_uid TEXT PRIMARY KEY, name TEXT, bought_on TEXT, expires_on TEXT, days_before_notify INTEGER)",
        );
      },
      version: 1,
    );
  }
  Future<void> insertItem(Item item) async {
    print("Enters insert item");
    final db = _database;
    final foodUid = generateUniqueId(item.name);
    final boughtOn = DateTime.now().toIso8601String();
    print("Manually inserted data is: ");
    print(foodUid);
    print(item.name);
    print(item.expiryDate.toIso8601String());

    await db.insert(
      tableName,
      {
        columnFoodUid: foodUid,
        columnName: item.name,
        columnBoughtOn: boughtOn,
        columnExpiresOn: item.expiryDate.toIso8601String(),
        columnDaysBeforeNotify: 5,
      },
    );
  }

  final _items = <Item>[];
  DateTime _selectedDate = DateTime.now();

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (pickedDate != null && pickedDate != _selectedDate) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  void _addItem() {
    final name = _itemNameController.text;
    // print(name);   DEBUGG CHECK
    if (name.isNotEmpty) {
      setState(() {
        _items.add(Item(name, _selectedDate));
       // _itemNameController.text = ''; // Clear the input field after adding
      });
    }
  }

  final TextEditingController _itemNameController = TextEditingController();

/*  void _submitData() async {
    print('Submitted items:');
    for (var item in _items) {
      print(item);
      await insertItem(item);
      print("Inserted successfully");
    }
  }*/

  Future<void> _addAndInsertItem() async {
    //print("Enters add and insert funcs");  COMPLETE CHECK
    _addItem(); // Add the item to the list
    final name = _itemNameController.text;
    if (name.isNotEmpty) {
      final item = Item(name, _selectedDate);
      insertItem(item); // Insert the item into the database
      _itemNameController.text = '';  //CLEAR INPUT FIELD
    }

      // Query the table to retrieve all rows
      List<Map<String, dynamic>> rows = await _database.query('foods');

      // Print each row
      for (Map<String, dynamic> row in rows) {
        print("READING FROM DATABASE");
        print('Food UID: ${row['food_uid']}');
        print('Food Name: ${row['name']}');
        print('Bought On: ${row['bought_on']}');
        print('Expires On: ${row['expires_on']}');
        print('Days Notify Before: ${row['days_before_notify']}');
        print('-----------------------');
      }

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        title: const Text('Add Items'),
        backgroundColor: AppColors.appBarColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            for (var item in _items)
              ListTile(
                title: Text(item.name),
                subtitle: Text(DateFormat('y MMMM d').format(item.expiryDate)),
              ),
            TextField(
              controller: _itemNameController,
              decoration: InputDecoration(
                labelText: 'Item Name',
                labelStyle: TextStyle(color: AppColors.textColor),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: AppColors.textColor),
                ),
              ),
              style: TextStyle(color: AppColors.textColor),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Text('Expiry Date: ', style: TextStyle(color: AppColors.textColor)),
                TextButton(
                  onPressed: () => _selectDate(context),
                  child: Text(DateFormat('y MMMM d').format(_selectedDate)),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _addAndInsertItem,
              child: const Icon(Icons.add),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.buttonColor,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed:null, // Call the submit function
              child: const Text('Submit'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.buttonColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}