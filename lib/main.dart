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
                backgroundColor: Color.fromARGB(255, 203, 192, 192),
                textStyle: TextStyle(
                  fontWeight: FontWeight.bold, // Make text bold
                  fontSize: 28, // Increase font size
                ),
              ),
              child: Text('QR Scan'),
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
      body: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: Image.asset(
              'assets/railway1.jpg', // Path to your background image
              fit: BoxFit.cover, // Cover the entire screen
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: 100),
                Container(
                  // padding: EdgeInsets.all(8),
                  height: 40,
                  width: 390,
                  color: Color.fromARGB(255, 48, 150, 233),
                  child: Center(
                    child: Text(
                      'Scanned Message',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                  ),
                ), // Add spacing
                // Result Container
                Container(
                  padding: EdgeInsets.all(8),
                  height: 330,
                  width: 390,
                  color: Color.fromARGB(255, 212, 217, 220),
                  child: Center(
                  child: OverflowBox(
                    maxWidth: double.infinity,
                    maxHeight: double.infinity,
                    child: Text(
                      result,
                      textAlign: TextAlign.center, // Center-align the text
                      style: TextStyle(fontSize: 18, color: Color.fromARGB(255, 23, 23, 23)),
                    ),
                  ),
                ),
                ),
                SizedBox(height: 220), // Add spacing
                // Go Back Container
                ElevatedButton(
                  onPressed: () {
                    Navigator.popUntil(context, ModalRoute.withName('/'));
                  },
                  style: ButtonStyle(
                    fixedSize: MaterialStateProperty.all<Size>(
                      Size(280, 50), // Adjust width and height as needed
                    ),
                    backgroundColor: MaterialStateProperty.all<Color>(
                      const Color.fromARGB(255, 160, 194, 222),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.arrow_back, color: Colors.black),
                      SizedBox(width: 5),
                      Text(
                        'Go Back',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
         ),
        ],
      ),
    );
  }
}
