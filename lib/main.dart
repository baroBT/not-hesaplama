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

// --- 1. AÇILIŞ EKRANI ---
class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
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
          style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.cyanAccent, letterSpacing: 2.0),
        ),
      ),
    );
  }
}

// --- 2. İSİM SORMA VE ANA MENÜ ---
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
    if (!_isimGirildiMi) {
      return Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Uygulamaya Hoş Geldin!\nBaşlamak için adını yaz:', textAlign: TextAlign.center, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              TextField(controller: _isimController, decoration: const InputDecoration(border: OutlineInputBorder(), labelText: 'Adın Soyadın')),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_isimController.text.isNotEmpty) {
                    setState(() { _kullaniciAdi = _isimController.text; _isimGirildiMi = true; });
                  }
                },
                child: const Text('Devam Et'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text('Hoş geldin, $_kullaniciAdi'), backgroundColor: Colors.blueAccent),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const GenelNotEkrani())) , child: const Text('Genel Not Hesaplama')),
            const SizedBox(height: 15),
            ElevatedButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const TekDersEkrani())) , child: const Text('Tek Ders Ortalama Hesaplama')),
            const SizedBox(height: 15),
            ElevatedButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const DonemEkrani(kullaniciAdi: 'Öğrenci'))) , child: const Text('Dönem Hesaplama')),
          ],
        ),
      ),
    );
  }
}

// --- 3. GENEL NOT HESAPLAMA EKRANI ---
class Ders {
  String ad;
  int saat;
  Ders(this.ad, this.saat);
}

class GenelNotEkrani extends StatefulWidget {
  const GenelNotEkrani({Key? key}) : super(key: key);
  @override
  State<GenelNotEkrani> createState() => _GenelNotEkraniState();
}

class _GenelNotEkraniState extends State<GenelNotEkrani> {
  List<Ders> dersler = [
    Ders('Matematik', 6), Ders('Türkçe', 5), Ders('Fen Bilimleri', 4), Ders('Sosyal Bilgiler', 3),
  ];
  final TextEditingController _dersAdController = TextEditingController();
  final TextEditingController _dersSaatController = TextEditingController();
  String _sonuc = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Genel Not Hesaplama')),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: dersler.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text('${dersler[index].ad} (${dersler[index].saat} Saat)'),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () { setState(() { dersler.removeAt(index); }); },
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(child: TextField(controller: _dersAdController, decoration: const InputDecoration(hintText: 'Ders Adı'))),
                    const SizedBox(width: 10),
                    Expanded(child: TextField(controller: _dersSaatController, keyboardType: TextInputType.number, decoration: const InputDecoration(hintText: 'Saat'))),
                    IconButton(
                      icon: const Icon(Icons.add, color: Colors.green),
                      onPressed: () {
                        if (_dersAdController.text.isNotEmpty && _dersSaatController.text.isNotEmpty) {
                          setState(() {
                            dersler.add(Ders(_dersAdController.text, int.parse(_dersSaatController.text)));
                            _dersAdController.clear(); _dersSaatController.clear();
                          });
                        }
                      },
                    )
                  ],
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() { _sonuc = "Dersler başarıyla listelendi. (Not girme ekranı bir sonraki adımda eklenecek)"; });
                  },
                  child: const Text('Hesapla'),
                ),
                Text(_sonuc, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
              ],
            ),
          )
        ],
      ),
    );
  }
}

// --- 4. TEK DERS EKRANI (Sağ üstte 2. sınav aç/kapa) ---
class TekDersEkrani extends StatefulWidget {
  const TekDersEkrani({Key? key}) : super(key: key);
  @override
  State<TekDersEkrani> createState() => _TekDersEkraniState();
}

class _TekDersEkraniState extends State<TekDersEkrani> {
  bool _ikinciSinavAcik = false;
  String _sonuc = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tek Ders Hesaplama'),
        actions: [
          Row(
            children: [
              const Text('2. Sınav', style: TextStyle(fontSize: 12)),
              Switch(
                value: _ikinciSinavAcik,
                onChanged: (val) { setState(() { _ikinciSinavAcik = val; }); },
              ),
            ],
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const TextField(decoration: InputDecoration(labelText: '1. Sınav Notu')),
            const SizedBox(height: 10),
            if (_ikinciSinavAcik) ...[
              const TextField(decoration: InputDecoration(labelText: '2. Sınav Notu')),
              const SizedBox(height: 10),
            ],
            const TextField(decoration: InputDecoration(labelText: 'Sözlü Notu')),
            const SizedBox(height: 10),
            const TextField(decoration: InputDecoration(labelText: 'Proje Notu (0 yazarsan 0 sayılır, G yazarsan sayılmaz)')),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: () { setState(() { _sonuc = "Hesaplandı (Kod eklenecek)"; }); }, child: const Text('Hesapla')),
            Text(_sonuc, style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}

// --- 5. DÖNEM HESAPLAMA EKRANI (Tebrik Mesajları) ---
class DonemEkrani extends StatefulWidget {
  final String kullaniciAdi;
  const DonemEkrani({Key? key, required this.kullaniciAdi}) : super(key: key);
  @override
  State<DonemEkrani> createState() => _DonemEkraniState();
}

class _DonemEkraniState extends State<DonemEkrani> {
  String _sonuc = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dönem Hesaplama')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const TextField(decoration: InputDecoration(labelText: 'Ortalama Girin (Test için)')),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                setState(() { 
                  // Buraya senin o meşhur mesajları koyduk
                  _sonuc = "TEBRİKLER HİÇBİR ŞEY ALAMADIN MAŞALLAH! (Test Mesajı)"; 
                });
              }, 
              child: const Text('Hesapla ve Belgeyi Gör')
            ),
            const SizedBox(height: 20),
            Text(_sonuc, textAlign: TextAlign.center, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.redAccent)),
          ],
        ),
      ),
    );
  }
}
