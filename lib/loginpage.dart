import 'package:bestbybuddy/signup.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:bestbybuddy/view_menu.dart';
import 'dart:io';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
FlutterLocalNotificationsPlugin();
const String channelId = 'bestbybuddy';

//void main() => runApp(const LoginApp());
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  print("done1");
  // Initialize the plugin
  await initNotifications();
  print("done2");
  runApp(const LoginApp());
}

Future<void> initNotifications() async {
  const AndroidInitializationSettings initializationSettingsAndroid =
  AndroidInitializationSettings('@mipmap/ic_launcher');
  final InitializationSettings initializationSettings =
  InitializationSettings(android: initializationSettingsAndroid);
  await flutterLocalNotificationsPlugin.initialize(initializationSettings);

  // Define and create your custom notification channel
  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    channelId,
    'Custom Channel Name',
    'Custom Channel Description',
    importance: Importance.high,
  );
  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
      AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  // Show initial notification
  await showInitialNotification();
}

Future<void> showInitialNotification() async {
  // Define the notification details
  const AndroidNotificationDetails androidPlatformChannelSpecifics =
  AndroidNotificationDetails(
    channelId,
    'Your channel name',
    'Your channel description',
    importance: Importance.max,
    priority: Priority.high,
  );
  const NotificationDetails platformChannelSpecifics =
  NotificationDetails(android: androidPlatformChannelSpecifics);
  // Trigger the notification
  await flutterLocalNotificationsPlugin.show(
    0,
    'Welcome',
    'Congrats for not letting your products Expire!',
    platformChannelSpecifics,
    payload: 'Welcome to BestBy Buddy!',
  );
}

class LoginApp extends StatelessWidget {
  const LoginApp({Key? key}) : super(key: key);

  static const String _title = 'BestBy Buddy';

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: _title,
      home: Scaffold(
        body: MyStatefulWidget(),
      ),
    );
  }
}

class MyStatefulWidget extends StatefulWidget {
  const MyStatefulWidget({Key? key}) : super(key: key);

  @override
  State<MyStatefulWidget> createState() => _MyStatefulWidgetState();
}



class _MyStatefulWidgetState extends State<MyStatefulWidget> {
  Color appbarcolour = Color(0xFF36D582);
  Color bgcolour = Color(0xFF000000);
  Color containercolour = Color(0xFF252525);
  Color buttoncolour = Colors.grey;
  TextEditingController nameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  Future<void> _submitForm(String username, String password) async {
    final response = await http.post(
      Uri.parse('http://bhindi1.ddns.net/bbb_authraw'), // Replace with your API endpoint
      body: {
        'username': username,
        'password': password,
      },
    );

    if (response.statusCode == 200) {
      // Request successful, handle response here
      print('Login successful!');
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => ViewMenu()));
    }else if (response.statusCode == 403){
      // Passwords don't match, show an error message
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Invalid Credentials"),
            content: Text("Username or Password is incorrect. Please try again."),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text("Close"),
              ),
            ],
          );
        },
      );
      return;
    } else {
      // Request failed, handle error here
      print('Failed to login: ${response.reasonPhrase}');
    }

    // Save response body to a text file
    saveResponseBody(response.body);
    print(response.body);
  }

  Future<void> saveResponseBody(String body) async {
    try {
      // Parse the JSON response
      Map<String, dynamic> jsonResponse = jsonDecode(body);

      // Extract DEVICE-COOKIE and DEVICE-JWT
      String deviceJwt = jsonResponse['DATA']['JWT']['DEVICE-JWT'];

      // Get the directory for storing files
      final directory = await getApplicationDocumentsDirectory();
      print(directory);

      // Write response body to a text file
      final file = File('${directory.path}/response_body.txt');
      await file.writeAsString(body);

      // Write DEVICE-JWT to a text file
      final jwtFile = File('${directory.path}/device_jwt.txt');
      await jwtFile.writeAsString(deviceJwt);

      // If all writes are successful, print a success message
      print('Files saved successfully');
    } catch (e) {
      // If any error occurs, print the error message
      print('Error saving files: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(fontFamily: 'Gotham'),
      home: Scaffold(
        backgroundColor: bgcolour,
        body: Padding(
          padding: const EdgeInsets.all(10),
          child: ListView(
            children: <Widget>[
              //const SizedBox(height: 60),
              Image(
                //radius: 65,
                image: AssetImage('images/logo.png'),
                width: 275,
                height: 275,
              ),
              //const SizedBox(height: 30),
              Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.all(10),
                child: Text(
                  'BestBy Buddy',
                  style: TextStyle(
                    color: appbarcolour,
                    fontWeight: FontWeight.w500,
                    fontSize: 30,
                  ),
                ),
              ),
              Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.all(10),
                child: const Text(
                  'Sign In',
                  style: TextStyle(fontSize: 20, color: Color(0xFFDDF7EB)),
                ),
              ),
              Column(
                children: <Widget>[
                  //const SizedBox(height: 20),
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      hintText: "Username",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: SignupPage.containercolour,
                      prefixIcon: const Icon(Icons.person_outline, color: SignupPage.appbarcolour,),
                      hintStyle: TextStyle(color: Colors.grey), // Hint text color
                      // TextStyle for the input text color
                      // Adjust the color based on your preference
                      // For example, to make the input text white, you can use:
                      // textStyle: TextStyle(color: Colors.white),
                    ),
                    style: TextStyle(color: SignupPage.buttoncolour), // Input text color
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: passwordController,
                    decoration: InputDecoration(
                      hintText: "Password",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                        borderSide: BorderSide.none,
                      ),
                      fillColor: SignupPage.containercolour,
                      filled: true,
                      prefixIcon: const Icon(Icons.password, color: SignupPage.appbarcolour,),
                        hintStyle: TextStyle(color: Colors.grey)
                    ),
                    style: TextStyle(color: SignupPage.buttoncolour),
                    obscureText: true,
                  ),
                  //const SizedBox(height: 20),
                ],
              ),
              Container(
                height: 50,
                margin: EdgeInsets.fromLTRB(0, 22, 0, 0),
                child: ElevatedButton(
                  child: Text('Login', style: TextStyle(color: containercolour, fontSize: 18)),
                  onPressed: () {
                    //String appusername = "";
                    String username = nameController.text;
                    String password = passwordController.text;
                    _submitForm(username, password);

                    // Navigator.push(
                    //   context,
                    //   MaterialPageRoute(builder: (context) => const ViewMenu()),
                    // );
                  },
                ),
              ),
              Row(
                children: <Widget>[
                  Text(
                    'Do not have account?',
                    style: TextStyle(color: buttoncolour),
                  ),
                  TextButton(
                    child: Text(
                      'Sign Up',
                      style: TextStyle(fontSize: 20, color: appbarcolour),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => SignupPage()),);
                    },
                  )
                ],
                mainAxisAlignment: MainAxisAlignment.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
