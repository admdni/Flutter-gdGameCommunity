import 'package:flutter/material.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

import 'home_screen.dart';

class PinCodeScreen extends StatefulWidget {
  @override
  _PinCodeScreenState createState() => _PinCodeScreenState();
}

class _PinCodeScreenState extends State<PinCodeScreen> {
  final TextEditingController _pinController = TextEditingController();
  String _currentPin = "";
  final String _correctPin = "5252";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey[50],
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.lock_outlined,
                size: 80,
                color: Colors.blueGrey[700],
              ),
              SizedBox(height: 40),
              Text(
                "Enter your PIN code",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueGrey[800],
                ),
              ),
              SizedBox(height: 40),
              PinCodeTextField(
                appContext: context,
                length: 4,
                obscureText: true,
                obscuringCharacter: '*',
                blinkWhenObscuring: true,
                animationType: AnimationType.scale,
                pinTheme: PinTheme(
                  shape: PinCodeFieldShape.box,
                  borderRadius: BorderRadius.circular(10),
                  fieldHeight: 60,
                  fieldWidth: 60,
                  activeFillColor: Colors.white,
                  inactiveFillColor: Colors.blueGrey[50],
                  selectedFillColor: Colors.blueGrey[100],
                  activeColor: Colors.blueGrey[400],
                  inactiveColor: Colors.blueGrey[300],
                  selectedColor: Colors.blueGrey[600],
                ),
                cursorColor: Colors.blueGrey[800],
                animationDuration: Duration(milliseconds: 300),
                enableActiveFill: true,
                controller: _pinController,
                keyboardType: TextInputType.number,
                boxShadows: [
                  BoxShadow(
                    offset: Offset(0, 1),
                    color: Colors.black12,
                    blurRadius: 10,
                  )
                ],
                onCompleted: (pin) {
                  if (pin == _correctPin) {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (_) => HomeScreen()),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text('Incorrect PIN. Please try again.'),
                      backgroundColor: Colors.red[400],
                    ));
                    _pinController.clear();
                  }
                },
                onChanged: (value) {
                  setState(() {
                    _currentPin = value;
                  });
                },
              ),
              SizedBox(height: 40),
              ElevatedButton(
                child: Text("Login", style: TextStyle(fontSize: 18)),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.blueGrey[600],
                  padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () {
                  if (_currentPin == _correctPin) {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (_) => HomeScreen()),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text('Incorrect PIN. Please try again.'),
                      backgroundColor: Colors.red[400],
                    ));
                    _pinController.clear();
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
