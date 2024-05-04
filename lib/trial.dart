//ITEMLIST.DART LAST WORKING FILE

import 'dart:convert';
import 'package:bestbybuddy/view_menu.dart';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:http/http.dart' as http;
//import 'package:intl/intl.dart;
import 'package:intl/intl.dart';
import 'package:bestbybuddy/database_helper.dart';

class ItemList extends StatefulWidget {
  final Map list_data;

  const ItemList({Key? key, required this.list_data}) : super(key: key);

  @override
  State<ItemList> createState() => _ItemListState();
}

class _ItemListState extends State<ItemList> {

  late Database _database;

  @override
  void initState() {
    super.initState();
    _openDatabase();
  }

  // Function to open the database
  Future<void> _openDatabase() async {
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

  // Function to close the database
  Future<void> _closeDatabase() async {
    await _database.close();
  }

  Future<void> printAllData() async {
    try {
      // Query the table to retrieve all rows
      List<Map<String, dynamic>> rows = await _database.query('foods');

      // Print each row
      for (Map<String, dynamic> row in rows) {
        print('Food UID: ${row['food_uid']}');
        print('Food Name: ${row['name']}');
        print('Bought On: ${row['bought_on']}');
        print('Expires On: ${row['expires_on']}');
        print('Days Notify Before: ${row['days_before_notify']}');
        print('-----------------------');
      }
    } catch (e) {
      // Handle any errors that occur during database querying
      print("Error querying data from database: $e");
    }
  }

  Future<void> insertDataIntoDatabase(Map<String, Map<String, dynamic>> data) async {
    //await _database.delete('foods');
    try {
      // Get the current date
      DateTime currentDate = DateTime.now();

      // Iterate over each item in the map
      for (var entry in data.entries) {
        String key = entry.key;
        Map<String, dynamic> value = entry.value;

        // Extract the item name and expiry date directly from the value map
        String itemName = value["NAME"];
        String expiryDate = value["EXPIRES"];

        // Calculate expires_on date
        String expiresOn = DateTime.parse(expiryDate).toIso8601String();

        // Calculate days_before_notify (default: 5)
        int daysBeforeNotify = 5;

        // Insert data into the database
        await _database.insert(
          'foods',
          {
            'food_uid': key,
            'name': itemName,
            'bought_on': currentDate.toIso8601String(),
            'expires_on': expiresOn,
            'days_before_notify': daysBeforeNotify,
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    } catch (e) {
      // Handle any errors that occur during database insertion
      print("Error inserting data into database: $e");
    }
  }

  Future<void> addNewItemToDatabase(String itemName, String formattedExpiryDate) async {
    try {
      // Get the current date
      DateTime currentDate = DateTime.now();

      // Insert data into the database
      await _database.insert(
        'foods',
        {
          'food_uid': generateUniqueId(itemName), // You need to define a function to generate a unique ID
          'name': itemName,
          'bought_on': currentDate.toIso8601String(),
          'expires_on': formattedExpiryDate,
          'days_before_notify': 5, // Default days before notify
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      // Handle any errors that occur during database insertion
      print("Error inserting data into database: $e");
    }
  }

  Future<String> generateUniqueId(String itemName) async {
    try {
      final response = await http.post(
        Uri.parse('http://bhindi1.ddns.net/bbb_imgrecv'),
        body: {
          'name': itemName,
        },
      );

      if (response.statusCode == 200) {
        // If the request is successful, extract and return the unique ID
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

  @override
  void dispose() {
    _closeDatabase();
    super.dispose();
  }


  Color appbarcolour=Color(0xFF36D582);
  Color bgcolour=Color(0xFF000000);
  Color containercolour=Color(0xFF252525);
  Color textcolour=Color(0xFFDDF7EB);
  Color buttoncolour=Colors.grey;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgcolour,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(
          'List of Items',
          style: TextStyle(
            fontFamily: 'Gotham',
            color: appbarcolour,
            fontWeight: FontWeight.normal,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop(); // Navigate back to previous screen
          },
        ),
      ),
      body: ListView.builder(
        itemCount: widget.list_data.length,
        itemBuilder: (context, index) {
          // Extract the name from the map and display it
          String itemName = widget.list_data.values.elementAt(index)["NAME"];
          String expiryDate = widget.list_data.values.elementAt(index)["EXPIRES"];
          return Container(
            padding: EdgeInsets.all(10),
            margin: EdgeInsets.fromLTRB(15, 20, 15, 0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(7),
              color: containercolour,
            ),
            child: Row(
                children: <Widget>[
                  Text(itemName,
                      style: TextStyle(color: textcolour, fontSize: 23)),
                  Spacer(),
                  Text(expiryDate,
                      style: TextStyle(color: textcolour, fontSize: 23)),
                ]
            ),
          );
        },
      ),
      bottomNavigationBar: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          TextButton.icon(
            onPressed: () async {
              // Show a dialog to input item details
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  TextEditingController itemNameController = TextEditingController();
                  TextEditingController expiryDateController = TextEditingController();

                  return AlertDialog(
                    title: Text("Add Item"),
                    content: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          TextField(
                            controller: itemNameController,
                            decoration: InputDecoration(
                              hintText: "Item Name",
                            ),
                          ),
                          SizedBox(height: 20),
                          TextField(
                            controller: expiryDateController,
                            decoration: InputDecoration(
                              hintText: "Expiry Date",
                            ),
                          ),
                        ],
                      ),
                    ),
                    actions: <Widget>[
                      TextButton(
                        onPressed: () {
                          // Add item to the list and database
                          String itemName = itemNameController.text;
                          String expiryDateString = expiryDateController.text;

                          // Parse the expiryDate string into a DateTime object
                          DateTime expiryDate = DateFormat("yyyy-MM-dd").parse(expiryDateString);

                          // Format the expiryDate into a string in ISO8601 format
                          String formattedExpiryDate = expiryDate.toIso8601String();

                          setState(() {
                            // Update the state synchronously
                            // Perform any synchronous operations here
                          });

                          // Perform any asynchronous operations outside of setState()
                          addNewItemToDatabase(itemName, formattedExpiryDate);

                          // Close the dialog
                          Navigator.of(context).pop();
                        },
                        child: Text("Add"),
                      ),
                      TextButton(
                        onPressed: () {
                          // Close the dialog without adding item
                          Navigator.of(context).pop();
                        },
                        child: Text("Cancel"),
                      ),
                    ],
                  );
                },
              );
            },
            label: Text(
              'Add Items',
              style: TextStyle(color: appbarcolour, fontWeight: FontWeight.bold, fontSize: 18),
            ),
            icon: Icon(Icons.add, color: appbarcolour),
            style: ButtonStyle(backgroundColor: MaterialStateProperty.all<Color>(containercolour)),
          ),
          TextButton.icon(
            onPressed: () async {

              print("LIST OF ITEMS ARE");
              print(widget.list_data);
              Map<String, Map<String, dynamic>> convertedData = widget.list_data.map(
                      (key, value) => MapEntry(key.toString(), value.cast<String, dynamic>())
              );
              insertDataIntoDatabase(convertedData);
              printAllData();
              print("INSERTED DATA");

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ViewMenu(), // Pass widget.my_list here
                ),
              );
            },
            label: Text(
              'Confirm',
              style: TextStyle(color: appbarcolour, fontWeight: FontWeight.bold, fontSize: 18),
            ),
            icon: Icon(Icons.check, color: appbarcolour),
            style: ButtonStyle(backgroundColor: MaterialStateProperty.all<Color>(containercolour)),
          ),
        ],
      ),
    );
  }
}

//ITEMLIST WORKING NO PARAMETERS. DBNAME FROZEN
import 'dart:convert';
import 'package:bestbybuddy/view_menu.dart';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:http/http.dart' as http;
import 'package:bestbybuddy/loginpage.dart';
import 'package:sprintf/sprintf.dart';
import 'package:intl/intl.dart';
//import 'package:bestbybuddy/database_helper.dart';

class ItemList extends StatefulWidget {
  final Map list_data;

  const ItemList({Key? key, required this.list_data}) : super(key: key);

  @override
  State<ItemList> createState() => _ItemListState();
}

class _ItemListState extends State<ItemList> {

  late Database _database;
  //String dbname = username;
  //get username => username;

  @override
  void initState() {
    super.initState();
    _openDatabase();
  }

  // Function to open the database
  Future<void> _openDatabase() async {
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

  // Function to close the database
  Future<void> _closeDatabase() async {
    await _database.close();
  }

  Future<void> printAllData() async {
    try {
      // Query the table to retrieve all rows
      List<Map<String, dynamic>> rows = await _database.query('foods');

      // Print each row
      for (Map<String, dynamic> row in rows) {
        print('Food UID: ${row['food_uid']}');
        print('Food Name: ${row['name']}');
        print('Bought On: ${row['bought_on']}');
        print('Expires On: ${row['expires_on']}');
        print('Days Notify Before: ${row['days_before_notify']}');
        print('-----------------------');
      }
    } catch (e) {
      // Handle any errors that occur during database querying
      print("Error querying data from database: $e");
    }
  }

  Future<void> insertDataIntoDatabase(Map<String, Map<String, dynamic>> data) async {
    //await _database.delete('foods');
    try {
      // Get the current date
      DateTime currentDate = DateTime.now();

      // Iterate over each item in the map
      for (var entry in data.entries) {
        String key = entry.key;
        Map<String, dynamic> value = entry.value;

        // Extract the item name and expiry date directly from the value map
        String itemName = value["NAME"];
        String expiryDate = value["EXPIRES"];

        // Calculate expires_on date
        String expiresOn = DateTime.parse(expiryDate).toIso8601String();

        // Calculate days_before_notify (default: 5)
        int daysBeforeNotify = 5;

        // Insert data into the database
        await _database.insert(
          'foods',
          {
            'food_uid': key,
            'name': itemName,
            'bought_on': currentDate.toIso8601String(),
            'expires_on': expiresOn,
            'days_before_notify': daysBeforeNotify,
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    } catch (e) {
      // Handle any errors that occur during database insertion
      print("Error inserting data into database: $e");
    }
  }

  Future<void> addNewItemToDatabase(String itemName, String formattedExpiryDate) async {
    try {
      // Get the current date
      DateTime currentDate = DateTime.now();

      // Insert data into the database
      await _database.insert(
        'foods',
        {
          'food_uid': generateUniqueId(itemName), // You need to define a function to generate a unique ID
          'name': itemName,
          'bought_on': currentDate.toIso8601String(),
          'expires_on': formattedExpiryDate,
          'days_before_notify': 5, // Default days before notify
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      // Handle any errors that occur during database insertion
      print("Error inserting data into database: $e");
    }
  }

  Future<String> generateUniqueId(String itemName) async {
    try {
      final response = await http.post(
        Uri.parse('http://bhindi1.ddns.net/bbb_imgrecv'),
        body: {
          'name': itemName,
        },
      );

      if (response.statusCode == 200) {
        // If the request is successful, extract and return the unique ID
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

  @override
  void dispose() {
    _closeDatabase();
    super.dispose();
  }
  Future<void> _showDatePicker(BuildContext context, int index) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );

    if (picked != null && picked != DateTime.now()) {
      setState(() {
        String formattedDate = DateFormat('yyyy-MM-dd').format(picked);
        widget.list_data.values.elementAt(index)["EXPIRES"] = formattedDate;
      });
    }
  }


  Color appbarcolour=Color(0xFF36D582);
  Color bgcolour=Color(0xFF000000);
  Color containercolour=Color(0xFF252525);
  Color textcolour=Color(0xFFDDF7EB);
  Color buttoncolour=Colors.grey;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgcolour,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(
          'List of Items',
          style: TextStyle(
            fontFamily: 'Gotham',
            color: appbarcolour,
            fontWeight: FontWeight.normal,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop(); // Navigate back to previous screen
          },
        ),
      ),
      body: ListView.builder(
        itemCount: widget.list_data.length,
        itemBuilder: (context, index) {
          String itemName = widget.list_data.values.elementAt(index)["NAME"];
          String expiryDate = widget.list_data.values.elementAt(index)["EXPIRES"];
          return GestureDetector(
            onTap: () {
              _showDatePicker(context, index);
            },
            child: Container(
              padding: EdgeInsets.all(10),
              margin: EdgeInsets.fromLTRB(15, 20, 15, 0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(7),
                color: containercolour,
              ),
              child: Row(
                children: <Widget>[
                  Text(itemName, style: TextStyle(color: textcolour, fontSize: 23)),
                  Spacer(),
                  Text(expiryDate, style: TextStyle(color: textcolour, fontSize: 23)),
                ],
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          TextButton.icon(
            onPressed: () async {
              // Show a dialog to input item details
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  TextEditingController itemNameController = TextEditingController();
                  TextEditingController expiryDateController = TextEditingController();

                  return AlertDialog(
                    title: Text("Add Item"),
                    content: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          TextField(
                            controller: itemNameController,
                            decoration: InputDecoration(
                              hintText: "Item Name",
                            ),
                          ),
                          SizedBox(height: 20),
                          TextField(
                            controller: expiryDateController,
                            decoration: InputDecoration(
                              hintText: "Expiry Date",
                            ),
                          ),
                        ],
                      ),
                    ),
                    actions: <Widget>[
                      TextButton(
                        onPressed: () {
                          // Add item to the list and database
                          String itemName = itemNameController.text;
                          String expiryDateString = expiryDateController.text;

                          // Parse the expiryDate string into a DateTime object
                          DateTime expiryDate = DateFormat("yyyy-MM-dd").parse(expiryDateString);

                          // Format the expiryDate into a string in ISO8601 format
                          String formattedExpiryDate = expiryDate.toIso8601String();

                          setState(() {
                            // Update the state synchronously
                            // Perform any synchronous operations here
                          });

                          // Perform any asynchronous operations outside of setState()
                          addNewItemToDatabase(itemName, formattedExpiryDate);

                          // Close the dialog
                          Navigator.of(context).pop();
                        },
                        child: Text("Add"),
                      ),
                      TextButton(
                        onPressed: () {
                          // Close the dialog without adding item
                          Navigator.of(context).pop();
                        },
                        child: Text("Cancel"),
                      ),
                    ],
                  );
                },
              );
            },
            label: Text(
              'Add Items',
              style: TextStyle(color: appbarcolour, fontWeight: FontWeight.bold, fontSize: 18),
            ),
            icon: Icon(Icons.add, color: appbarcolour),
            style: ButtonStyle(backgroundColor: MaterialStateProperty.all<Color>(containercolour)),
          ),
          TextButton.icon(
            onPressed: () async {

              print("LIST OF ITEMS ARE");
              print(widget.list_data);
              Map<String, Map<String, dynamic>> convertedData = widget.list_data.map(
                      (key, value) => MapEntry(key.toString(), value.cast<String, dynamic>())
              );
              insertDataIntoDatabase(convertedData);
              printAllData();
              print("INSERTED DATA");

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ViewMenu(), // Pass widget.my_list here
                ),
              );
            },
            label: Text(
              'Confirm',
              style: TextStyle(color: appbarcolour, fontWeight: FontWeight.bold, fontSize: 18),
            ),
            icon: Icon(Icons.check, color: appbarcolour),
            style: ButtonStyle(backgroundColor: MaterialStateProperty.all<Color>(containercolour)),
          ),
        ],
      ),
    );
  }
}


//DATEPICKER OLD BY STR ITEMLIST.DART
onPressed: () async {
// Show the date picker dialog
final selectedDate = await showDatePicker(
context: context,
initialDate: DateTime.now(),
firstDate: DateTime(2000),
lastDate: DateTime(2100),
);

if (selectedDate != null) {
// Format the selected date into a string
String formattedExpiryDate = DateFormat("yyyy-MM-dd").format(selectedDate);

setState(() {
// Update the state with the selected date
// ... Perform actions based on the selected date
});

// Perform any asynchronous operations outside of setState()
addNewItemToDatabase(itemNameController.text, formattedExpiryDate);

// Close the dialog
Navigator.of(context).pop();
}