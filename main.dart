import 'package:flutter/material.dart';

void main() {
  runApp(const BaroBTApp());
}

class BaroBTApp extends StatelessWidget {
  const BaroBTApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Not Hesaplama',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const SplashScreen(),
    );
  }
}

// 1-2 Saniyelik Açılış Ekranı
class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // 2 saniye sonra ana menüye yönlendir
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const AnaMenuEkrani()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.black87,
      body: Center(
        child: Text(
          'BaroBT Studios',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.cyanAccent,
            letterSpacing: 2.0,
          ),
        ),
      ),
    );
  }
}

// 3. Adım: İsmin sorulacağı ve ana menünün olacağı ekran
class AnaMenuEkrani extends StatefulWidget {
  const AnaMenuEkrani({Key? key}) : super(key: key);

  @override
  State<AnaMenuEkrani> createState() => _AnaMenuEkraniState();
}

class _AnaMenuEkraniState extends State<AnaMenuEkrani> {
  final TextEditingController _isimController = TextEditingController();
  String _kullaniciAdi = "";
  bool _isimGirildiMi = false;

  @override
  Widget build(BuildContext context) {
    // Eğer isim girilmediyse isim sorma ekranını göster
    if (!_isimGirildiMi) {
      return Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Uygulamaya Hoş Geldin!\nBaşlamak için adını yaz:',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _isimController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Adın Soyadın',
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_isimController.text.isNotEmpty) {
                    setState(() {
                      _kullaniciAdi = _isimController.text;
                      _isimGirildiMi = true;
                    });
                  }
                },
                child: const Text('Devam Et'),
              ),
            ],
          ),
        ),
      );
    }

    // İsim girildikten sonraki Ana Menü
    return Scaffold(
      appBar: AppBar(
        title: Text('Hoş geldin, $_kullaniciAdi'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                // Buraya Genel Not Hesaplama kodları gelecek
              },
              child: const Text('Genel Not Hesaplama'),
            ),
            const SizedBox(height: 15),
            ElevatedButton(
              onPressed: () {
                // Buraya Tek Ders Ortalama kodları gelecek
              },
              child: const Text('Tek Ders Ortalama Hesaplama'),
            ),
            const SizedBox(height: 15),
            ElevatedButton(
              onPressed: () {
                // Buraya Dönem Hesaplama kodları gelecek
              },
              child: const Text('Dönem Hesaplama'),
            ),
          ],
        ),
      ),
    );
  }
}
