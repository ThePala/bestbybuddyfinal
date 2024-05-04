import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:async';
import 'package:bestbybuddy/options.dart';

class ViewMenu extends StatefulWidget {

  @override
  State<ViewMenu> createState() => _ViewMenuState();
}

class _ViewMenuState extends State<ViewMenu> {
  Color appbarcolour = Color(0xFF36D582);
  Color bgcolour = Color(0xFF000000);
  Color containercolour = Color(0xFF252525);
  Color textcolour = Color(0xFFDDF7EB);
  Color buttoncolour = Colors.grey;

  List<String> itemNames = []; // List to store item names
  List<String> expiryDates = [];

  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 1), () {
      fetchItemsFromDatabase();
    });
  }

  Future<void> deleteItemFromDatabase(dismissname) async {
    String path = await getDatabasesPath();
    Database database = await openDatabase(
      join(path, 'databasename.db'),
    );
    await database.delete(
      'foods',
      where: 'name = ?',
      whereArgs: [dismissname],
    );

    print("deleted");
    print(dismissname);

    List<Map<String, dynamic>> rows = await database.query('foods');

    // Print each row
    for (Map<String, dynamic> row in rows) {
      print("READING FROM DATABASE VIEW MENU");
      print('Food UID: ${row['food_uid']}');
      print('Food Name: ${row['name']}');
      print('Bought On: ${row['bought_on']}');
      print('Expires On: ${row['expires_on']}');
      print('Days Notify Before: ${row['days_before_notify']}');
      print('-----------------------');
    }
  }


  // Function to fetch items from the database
  Future<void> fetchItemsFromDatabase() async {
    // Open the database
    String path = await getDatabasesPath();
    Database database = await openDatabase(
      join(path, 'databasename.db'),
    );

    //await database.delete('foods');

    // Query the database to retrieve item names
    List<Map<String, dynamic>> items = await database.query('foods');

    // Extract item names from the query result
    List<String> names = items.map((item) => item['name'] as String).toList();
    List<String> dates = items.map((item) => item['expires_on'] as String)
        .toList();

    print("VIEW MENU DEBUG INIT");
    print(names);
    print(dates);

    // Update the state with the fetched item names
    setState(() {
      itemNames = names;
      expiryDates = dates;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgcolour,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(
          'Items in Your Pantry',
          style: TextStyle(fontFamily: 'Gotham',
              color: appbarcolour,
              fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: ListView.builder(
        itemCount: itemNames.length,
        itemBuilder: (context, index) {
          return Dismissible(
            key: Key(itemNames[index]),
            // Unique key for each item
            direction: DismissDirection.horizontal,
            // Allow horizontal swiping only
            onDismissed: (direction) async {

              final String itemDel = itemNames[index];
              await deleteItemFromDatabase(itemDel);
              // Remove the item from the list when swiped
              setState(() {
                itemNames.removeAt(index);
                expiryDates.removeAt(index);
              });
            },
            background: Container( // Background when swiping to the left
              color: Colors.red,
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: EdgeInsets.only(left: 20),
                child: Icon(Icons.delete, color: Colors.white),
              ),
            ),
            secondaryBackground: Container( // Background when swiping to the right
              color: Colors.red,
              alignment: Alignment.centerRight,
              child: Padding(
                padding: EdgeInsets.only(right: 20),
                child: Icon(Icons.delete, color: Colors.white),
              ),
            ),
            child: Container(
              padding: EdgeInsets.all(10),
              margin: EdgeInsets.fromLTRB(15, 20, 15, 0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(7),
                color: containercolour,
              ),
              child: Row(
                children: <Widget>[
                  Text(
                    itemNames[index],
                    style: TextStyle(color: textcolour, fontSize: 23),
                  ),
                  Spacer(),
                  ElevatedButton.icon(
                    onPressed: (){
                      // Show alert dialog with expiry date
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text('Expiry Date'),
                            content: Text('Expiry Date: ${expiryDates[index].substring(0, 10)}',
                                style: TextStyle(fontSize: 20)),
                            actions: <Widget>[
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: Text('Close'),
                              ),
                            ],
                          );
                        },
                      );
                    },
                    icon: Icon(Icons.info_outline, color: textcolour),
                    label: Text(
                      'View',
                      style: TextStyle(fontSize: 17, color: textcolour),
                    ),
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all<Color>(
                          appbarcolour),
                    ),
                  ),
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
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => OptionsPage(), // Pass widget.my_list here
                ),
              );
            },
            label: Text(
              'Add Items',
              style: TextStyle(color: appbarcolour,
                  fontWeight: FontWeight.bold,
                  fontSize: 18),
            ),
            icon: Icon(Icons.add_a_photo, color: appbarcolour),
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all<Color>(
                  containercolour),
            ),
          ),
        ],
      ),
    );
  }
}