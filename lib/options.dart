import 'package:bestbybuddy/manualadd.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

import 'camera.dart';

// Define a separate class for your color scheme
class AppColors {
  static const Color appBarColor = Color(0xFF36D582);
  static const Color backgroundColor = Color(0xFF000000);
  static const Color containerColor = Color(0xFF252525);
  static const Color textColor = Color(0xFFDDF7EB);
  static const Color buttonColor = Colors.grey;
}

class OptionsPage extends StatelessWidget {
  const OptionsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        title: const Text('Options'),
        backgroundColor: AppColors.appBarColor,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                // Navigate to Add Item page (replace with your actual implementation)
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) =>InputPage()),
                );
              },
              child: const Text('Add Item'),
              style: ElevatedButton.styleFrom(
                foregroundColor: AppColors.textColor, backgroundColor: AppColors.buttonColor,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                await availableCameras().then((value) =>
                Navigator.pushReplacement(context,
                MaterialPageRoute(
                  builder: (_) => CameraPage(cameras: value))));
               },
              child: const Text('Take Picture'),
              style: ElevatedButton.styleFrom(
                foregroundColor: AppColors.textColor, backgroundColor: AppColors.buttonColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Placeholder pages for navigation (replace with your actual content)
class AddItemPage extends StatelessWidget {
  const AddItemPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Item'),
        backgroundColor: AppColors.appBarColor,
      ),
      body: Center(
        child: Text(
          'Add Item Page',
          style: TextStyle(color: AppColors.textColor),
        ),
      ),
    );
  }
}

class TakePicturePage extends StatelessWidget {
  const TakePicturePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Take Picture'),
        backgroundColor: AppColors.appBarColor,
      ),
      body: Center(
        child: Text(
          'Take Picture Page',
          style: TextStyle(color: AppColors.textColor),
        ),
      ),
    );
  }
}
