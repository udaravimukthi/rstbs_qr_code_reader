import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key});

  @override
  Widget build(BuildContext context) {
    precacheImage(AssetImage("assets/railway1.jpg"), context);
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Color.fromARGB(255, 19, 3, 241)),
        useMaterial3: true,
      ),
      // Define routes for navigation
      initialRoute: '/',
      routes: {
        '/': (context) => LoginPage(), // Login/signup page route
        '/main': (context) => MyHomePage(title: 'RSTBS QR Code Reader'), // Main page route
      },
    );
  }
}

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController otpController = TextEditingController();
  bool showOTPField = false;

  Future<void> login(String email) async {
    var url = Uri.parse('https://rstbs-be.onrender.com/v1/api/auth/checker-login');
    var response = await http.post(
      url,
      body: {'email': email},
    );

    if (response.statusCode == 200) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Login Successful'),
          content: Text('You have successfully logged in.'),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pushReplacementNamed(context, '/main');
              },
              child: Text('OK'),
            ),
          ],
        ),
      );
    } else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Login Failed'),
          content: Text('Failed to log in. Please try again.'),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'RSTBS QR Code Reader',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Color.fromARGB(255, 177, 173, 244),
      ),
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/railway1.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Center(
            child: Container(
              width: MediaQuery.of(context).size.width * 0.8,
              height: 325,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.all(40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (!showOTPField) ...[
                    Text(
                      'Username',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    TextField(
                      controller: usernameController,
                      decoration: InputDecoration(
                        hintText: 'Enter your username',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          showOTPField = true;
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[300],
                        textStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      child: Text('Login'),
                    ),
                  ],
                  if (showOTPField) ...[
                    Text(
                      'OTP',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    TextField(
                      controller: otpController,
                      decoration: InputDecoration(
                        hintText: 'Enter OTP',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () {
                        // Check if OTP is correct (hardcoded for simplicity)
                        if (otpController.text.trim() == '0000') {
                          login(usernameController.text.trim());
                        } else {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: Text('Invalid OTP'),
                              content: Text('Please enter correct OTP.'),
                              actions: [
                                ElevatedButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: Text('OK'),
                                ),
                              ],
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[300],
                        textStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      child: Text('Verify OTP'),
                    ),
                    SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          showOTPField = false;
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[300],
                        textStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      child: Text('Go back'),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
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
      '#ff6666',
      'Cancel',
      true,
      ScanMode.QR,
    );

    var response = await http.get(Uri.parse('https://rstbs-be.onrender.com/v1/api/season-tickets/active/`${barcodeScanResult}`'));

    var responseBody = jsonDecode(response.body);
    print(response.statusCode);

    var finalResult;

    if (response.statusCode == 200) {
      var duration = responseBody['duration'];
      var stations = responseBody['applicationId']['stations'];
      var start = duration['start'];
      var end = duration['end'];
      var origin = stations['origin'];
      var destination = stations['destination'];

      DateTime startDate = DateTime.parse(start);
      DateTime endDate = DateTime.parse(end);

      DateFormat dateFormat = DateFormat('yyyy-MM-dd');
      String formattedStartDate = dateFormat.format(startDate);
      String formattedEndDate = dateFormat.format(endDate);

      finalResult = '''

      Duration:

      Start: $formattedStartDate
      End: $formattedEndDate
      

      Stations:

      Origin: $origin
      Destination: $destination
      ''';

    } else if (response.statusCode == 400) {
      var message = responseBody['message'];
      print(message);
      finalResult = message;
    } else {
       var responseBody = response.body;
      finalResult = responseBody;

    }
    Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => ScanResultPage(result: finalResult),
    ),
  ).then((_) {
    
    if (!ModalRoute.of(context)!.isCurrent) {
      Navigator.popUntil(context, ModalRoute.withName('/'));
    }
  });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(
          widget.title,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            // Navigate to the login/signup page
            Navigator.pushReplacementNamed(context, '/');
          },
        ),
        actions: [
          PopupMenuButton<int>(
            icon: CircleAvatar(
              radius: 24,
              backgroundImage: AssetImage("assets/profileUpdated.jpg"),
            ),
            offset: Offset(0, 50), // Adjust the vertical offset as needed
            itemBuilder: (BuildContext context) => <PopupMenuEntry<int>>[
              const PopupMenuItem<int>(
                value: 1,
                child: Text('Profile'),
              ),
              const PopupMenuItem<int>(
                value: 2,
                child: Text('LogOut'),
              ),
            ],
            onSelected: (int value) {
              if (value == 2) {
                Navigator.pushReplacementNamed(context, '/');
              } else {
                
              }
            },
          ),
        ],
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
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
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
        title: Row(
          children: [
            Expanded(
              child: Text('Scanned Result', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            PopupMenuButton<int>(
              icon: CircleAvatar(
                radius: 24,
                backgroundImage: AssetImage("assets/profileUpdated.jpg"),
              ),
              offset: Offset(0, 50), // Adjust the vertical offset as needed
              itemBuilder: (BuildContext context) => <PopupMenuEntry<int>>[
                const PopupMenuItem<int>(
                  value: 1,
                  child: Text('Profile'),
                ),
                const PopupMenuItem<int>(
                  value: 2,
                  child: Text('LogOut'),
                ),
              ],
              onSelected: (int value) {
                if (value == 2) {
                  Navigator.pushReplacementNamed(context, '/');
                } else {
                  // Handle Profile option
                }
              },
            ),
          ],
        ),
        backgroundColor: Color.fromARGB(255, 177, 173, 244),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/railway1.jpg',
              fit: BoxFit.cover,
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: 100),
                Container(
                  height: 40,
                  width: 350,
                  color: Color.fromARGB(255, 48, 150, 233),
                  child: Center(
                    child: Text(
                      'Scanned Message',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(8),
                  height: 330,
                  width: 350,
                  color: Color.fromARGB(255, 212, 217, 220),
                  alignment: Alignment.topLeft,
                  child: Text(
                    result,
                    textAlign: TextAlign.left,
                    style: TextStyle(fontSize: 18, color: Color.fromARGB(255, 23, 23, 23)),
                  ),
                ),
                SizedBox(height: 5),
                Padding(
                  padding: EdgeInsets.only(left: 70),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: ElevatedButton(
                      onPressed: () async {
                        var url = Uri.parse('https://rstbs-be.onrender.com/v1/api/season-tickets-usage');
                        var body = {'seasonTicketId': '2324243234'};

                        var response = await http.post(
                          url,
                          body: body,
                        );

                        if (response.statusCode == 200) {
                          print('Season ticket usage verified successfully.');
                        } else {
                          print('Error verifying season ticket usage: ${response.statusCode}');
                        }
                      },
                      style: ButtonStyle(
                        fixedSize: MaterialStateProperty.all<Size>(
                          Size(239, 20),
                        ),
                        backgroundColor: MaterialStateProperty.all<Color>(
                          Colors.grey[500]!,
                        ),
                      ),
                      child: Text(
                        'Verify Season Ticket',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),

                SizedBox(height: 50),
                ElevatedButton(
                  onPressed: () {
                    Navigator.popUntil(context, ModalRoute.withName('/main'));
                  },
                  style: ButtonStyle(
                    fixedSize: MaterialStateProperty.all<Size>(
                      Size(240, 35),
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
