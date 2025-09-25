import 'package:flutter/material.dart';

void main() {
  runApp(YegnaBudget());
}

class YegnaBudget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.lightBlue[150], // Move the color here
        appBar: AppBar(title: Text('Yegna Budget')),
        bottomNavigationBar: BottomNavigationBar(
          fixedColor: Colors.blueAccent[350],
          items: [
            // Button one (home/dashboard)
            BottomNavigationBarItem(
              backgroundColor: Color.fromARGB(255, 244, 200, 3),
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            // Button two (financial tips)
            BottomNavigationBarItem(
              backgroundColor: Color.fromARGB(255, 244, 200, 3),
              icon: Icon(Icons.tips_and_updates),
              label: 'FinTips',
            ),
            // Button three (analysis)
            BottomNavigationBarItem(
              backgroundColor: Color.fromARGB(255, 244, 200, 3),
              icon: Icon(Icons.bar_chart),
              label: 'Analysis',
            ),
            // Button four (splitter)
            BottomNavigationBarItem(
              backgroundColor: Color.fromARGB(255, 244, 200, 3),
              icon: Icon(Icons.group),
              label: 'Splitter',
            ),
            // Button five (settings)
            BottomNavigationBarItem(
              backgroundColor: Color.fromARGB(255, 244, 200, 3),
              icon: Icon(Icons.settings),
              label: 'Settings',
            ),
          ],
        ),
      ),
    );
  }
}