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
        appBar: AppBar(title: Text('Yegna Budget'),
        actions: [
          IconButton(
            icon: Icon(Icons.language),
            onPressed: () {
              // Handle search action
            },
          ),
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              // Handle search action
            },
          ),
          IconButton(
            icon: Icon(Icons.night_shelter),
            onPressed: () {
              // Handle night or dark mode canges
            },
          ),
        ],
        
        ),
        bottomNavigationBar: BottomNavigationBar(
          backgroundColor: Color(0xFF973C00),
          type:BottomNavigationBarType.fixed,
          showSelectedLabels: true,
          showUnselectedLabels: true,
          selectedItemColor: Color.fromARGB(255, 249, 220, 146),
        unselectedItemColor: const Color.fromARGB(179, 233, 231, 231),
         
          items: [
            // Button one (home/dashboard)
            BottomNavigationBarItem(
              //backgroundColor: Color.fromARGB(255, 244, 200, 3),
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            // Button two (financial tips)
            BottomNavigationBarItem(
              //backgroundColor: Color.fromARGB(255, 244, 200, 3),
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