import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PreferencesHelper {
  static const String _welcomeKey = 'welcome_seen';
  
  // Check if user has seen welcome screen
  static Future<bool> isFirstTime() async {
    final prefs = await SharedPreferences.getInstance();
    return !(prefs.getBool(_welcomeKey) ?? false);
  }
  
  // Mark welcome screen as seen
  static Future<void> markWelcomeSeen() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_welcomeKey, true);
  }
  
  // Optional: Reset for testing
  static Future<void> resetWelcome() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_welcomeKey);
  }
}
void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF1A4B7D),
        brightness: Brightness.light,
      ),
      useMaterial3: true,
    ),
    darkTheme: ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF1A4B7D),
        brightness: Brightness.dark,
      ),
      useMaterial3: true,
    ),
    home: WelcomeScreen(),
  ));
}

class WelcomeScreen extends StatefulWidget {
  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final TextEditingController _controller = TextEditingController();
  String UserName = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Welcome to Yegna Budget'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            child: Text('What is Your name?'),
          ),
          TextField(
            controller: _controller,
            decoration: const InputDecoration(
              labelText: "Enter your name",
              border: OutlineInputBorder(),
            ),
          ),
          SizedBox(height: 25),
          ElevatedButton(
            onPressed: () {
              String enteredName = _controller.text;
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => YegnaBudget(userName: enteredName)),
              );
            },
            child: Text('Lets Goooo'),
          )
        ],
      ),
    );
  }
}

class YegnaBudget extends StatelessWidget {
  final String userName;
  YegnaBudget({required this.userName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlue[150],
      appBar: AppBar(
        
         leading: IconButton(  // ← Left side, before title
        icon: Icon(Icons.calendar_today),
        onPressed: () {
      // Open calendar function
    },
  ),
        actions: [
          IconButton(
            icon: Icon(Icons.language ),
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
        type: BottomNavigationBarType.fixed,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        selectedItemColor: Color.fromARGB(255, 249, 220, 146),
        unselectedItemColor: const Color.fromARGB(179, 233, 231, 231),
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.tips_and_updates),
            label: 'FinTips',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: 'Analysis',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.group),
            label: 'Splitter',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            child: Text('Hello $userName'),
          ),
        ],
      ),
    );
  }
}