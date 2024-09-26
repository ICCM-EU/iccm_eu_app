import 'package:flutter/material.dart';
import 'dart:async';

class CountdownPage extends StatefulWidget {
  const CountdownPage({super.key});

  @override
  CountdownPageState createState() => CountdownPageState();
}

class CountdownPageState extends State<CountdownPage> {
  Timer? _timer;
  int _start = 10; // Initial countdown value

  void startTimer() {
    const oneSec = Duration(seconds: 1);
    _timer = Timer.periodic(
      oneSec,
          (Timer timer) {
        if (_start == 0) {
          setState(() {
            timer.cancel();
          });
        } else {
          setState(() {
            _start--;
          });
        }
      },
    );
  }

  @override
  void initState() {
    super.initState();
    startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Set Scaffold background to black
      appBar: AppBar(
        automaticallyImplyLeading: false, // Remove default back button
        backgroundColor: Colors.black, // Set AppBar background to black
        actions: [
          IconButton(
            icon: Icon(
              Icons.filter_alt,
              color: Colors.grey[700],
            ),
            onPressed: () {
            },
          ),
          IconButton(
            icon: Icon(
              Icons.close,
              color: Colors.grey[700],
            ),
            onPressed: () {
              Navigator.pop(context); // Close fullscreen page
            },
          ),
        ],
      ),
      body: Center(
        child: Text(
          '$_start',
          style: const TextStyle(fontSize: 48),
        ),
      ),
    );
  }
}
