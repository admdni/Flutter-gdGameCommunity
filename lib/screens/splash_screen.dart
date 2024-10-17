import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  int screenStatus = 0; // Varsayılan değeri 0 olarak ayarladık
  bool isLoading = true; // Yükleniyor durumu

  @override
  void initState() {
    super.initState();
    _fetchScreenStatus();
  }

  Future<void> _fetchScreenStatus() async {
    try {
      final response = await http
          .get(Uri.parse('https://appledeveloper.com.tr/screen/screen.json'));

      // JSON verisi başarıyla alındıysa
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          screenStatus = data['screen']; // screen değerini al
        });
      } else {
        print('Failed to load JSON data: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching data: $e');
    } finally {
      setState(() {
        isLoading = false; // Yükleme tamamlandı
      });
      _navigateToNextScreen(); // Sonrasında yönlendirme
    }
  }

  void _navigateToNextScreen() async {
    await Future.delayed(Duration(seconds: 4), () {});

    // Eğer internet bağlantısı yoksa ya da JSON erişilemiyorsa
    if (isLoading) {
      // Varsayılan olarak ana ekrana yönlendir
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      // Elde edilen screenStatus'a göre yönlendirme
      if (screenStatus == 1) {
        Navigator.pushReplacementNamed(
            context, '/pincode'); // Pincode ekranına yönlendirme
      } else {
        Navigator.pushReplacementNamed(
            context, '/home'); // Ana ekranına yönlendirme
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepPurple[900],
      body: Center(
        child: FutureBuilder(
          future: _fetchAnimation(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator(); // Yükleme devam ediyorsa döngü
            } else if (snapshot.hasError) {
              return Center(
                  child: Text(
                      'Animasyon yüklenemedi: ${snapshot.error}')); // Hata durumu
            } else {
              return Lottie.network(
                'https://lottie.host/637b1087-2cc5-48cd-8cb1-cd0e75c7723f/IH9DItAyml.json', // URL'yi buraya ekleyin
                width: 300,
                height: 300,
                fit: BoxFit.contain,
              );
            }
          },
        ),
      ),
    );
  }

  Future<void> _fetchAnimation() async {
    // Lottie animasyonunu yüklemek için kullanılır
    await Future.delayed(
        Duration(seconds: 1)); // Buraya yükleme süresi ekleyebilirsiniz
  }
}
