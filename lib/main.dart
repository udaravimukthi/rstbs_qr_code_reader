import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Add this import

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key});

  @override
  Widget build(BuildContext context) {
    precacheImage(AssetImage("assets/railway1.jpg"), context); // Precache the image
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Color.fromARGB(255, 112, 103, 243)),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'RSTBS QR Code Reader'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  void _navigateToScanPage() {
    // Navigate to the scan page
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ScanPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(
          widget.title,
          style: TextStyle(fontWeight: FontWeight.bold), // Apply bold font weight
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("assets/railway1.jpg"),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: _navigateToScanPage,
              style: ElevatedButton.styleFrom(
                textStyle: TextStyle(
                  fontWeight: FontWeight.bold, // Make text bold
                  fontSize: 20, // Increase font size
                ),
              ),
              child: Text('Check QR Updates'),
            ),
          ),
        ],
      ),
    );
  }
}

class ScanPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('QR Scan'),
      ),
      body: Center(
        child: Text('This is the QR Scan page'),
      ),
    );
  }
}
