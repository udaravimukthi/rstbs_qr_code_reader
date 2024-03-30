import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';

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
  void _navigateToScanPage() async {
    // Get the scanned QR code result
    String barcodeScanResult = await FlutterBarcodeScanner.scanBarcode(
      '#ff6666', // Customize the scanner overlay color
      'Cancel', // Text for the cancel button
      true, // Enable flash
      ScanMode.QR, // Specify the scan mode (QR code in this case)
    );

    // Navigate to a new page to display the scanned message
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ScanResultPage(result: barcodeScanResult),
      ),
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

class ScanResultPage extends StatelessWidget {
  final String result;

  const ScanResultPage({Key? key, required this.result}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Scanned Result'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Scanned Message:', style: TextStyle(fontSize: 20)),
            SizedBox(height: 10),
            Text(result, style: TextStyle(fontSize: 18)),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.popUntil(context, ModalRoute.withName('/'));
              },
              child: Text('Go Back to First Page'),
            ),
          ],
        ),
      ),
    );
  }
}
