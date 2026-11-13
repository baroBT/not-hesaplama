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
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
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
      if (!mounted) return; // Çökme engellendi
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const IsimEkrani()));
    });
  }
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.black87,
      body: Center(
        child: Text('BaroBT Studios', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.cyanAccent)),
      ),
    );
  }
}

// --- 2. İSİM SORMA ---
class IsimEkrani extends StatefulWidget {
  const IsimEkrani({Key? key}) : super(key: key);
  @override
  State<IsimEkrani> createState() => _IsimEkraniState();
}
class _IsimEkraniState extends State<IsimEkrani> {
  final TextEditingController _isimController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Adını yaz:', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            TextField(controller: _isimController, decoration: const InputDecoration(border: OutlineInputBorder())),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (_isimController.text.isNotEmpty) {
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => AnaMenuEkrani(kullaniciAdi: _isimController.text)));
                }
              },
              child: const Text('Devam Et'),
            ),
          ],
        ),
      ),
    );
  }
}

// --- 3. ANA MENÜ ---
class AnaMenuEkrani extends StatelessWidget {
  final String kullaniciAdi;
  const AnaMenuEkrani({Key? key, required this.kullaniciAdi}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Hoş geldin, $kullaniciAdi'), backgroundColor: Colors.blueAccent),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const GenelNotEkrani())), child: const Text('Genel Not Hesaplama')),
            const SizedBox(height: 15),
            ElevatedButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const TekDersEkrani())), child: const Text('Tek Ders Ortalama')),
            const SizedBox(height: 15),
            ElevatedButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => DonemEkrani(kullaniciAdi: kullaniciAdi))), child: const Text('Dönem Hesaplama')),
          ],
        ),
      ),
    );
  }
}

// --- 4. GENEL NOT HESAPLAMA (MATEMATİKSEL OLARAK KUSURSUZ) ---
class Ders {
  String ad;
  int saat;
  double not1;
  double not2;
  double sozlu;
  double proje;
  
  // -1 = Girilmedi, 0 = Gerçek 0
  Ders(this.ad, this.saat, {this.not1 = -1, this.not2 = -1, this.sozlu = -1, this.proje = -1});
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

  double _dersOrtalama(Ders d) {
    double toplam = 0;
    int sayac = 0;
    if (d.not1 >= 0) { toplam += d.not1; sayac++; }
    if (d.not2 >= 0) { toplam += d.not2; sayac++; }
    if (d.sozlu >= 0) { toplam += d.sozlu; sayac++; }
    if (d.proje >= 0) { toplam += d.proje; sayac++; }
    return sayac == 0 ? -1 : toplam / sayac; // -1: Hiç not yok
  }

  @override
  Widget build(BuildContext context) {
    double genelToplam = 0;
    int toplamSaat = 0;
    
    for (var d in dersler) {
      double ort = _dersOrtalama(d);
      if (ort != -1) { // Sadece notu girilmiş dersleri ortalamaya kat
        genelToplam += ort * d.saat;
        toplamSaat += d.saat;
      }
    }
    double genelOrtalama = toplamSaat == 0 ? -1 : genelToplam / toplamSaat;
    
    // Sadece notu girilmiş VE 50 altı olanları zayıf say
    int zayifSayisi = dersler.where((d) {
      double o = _dersOrtalama(d);
      return o != -1 && o < 50;
    }).length;

    return Scaffold(
      appBar: AppBar(title: const Text('Genel Not Hesaplama')),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: dersler.length,
              itemBuilder: (context, index) {
                final d = dersler[index];
                double ort = _dersOrtalama(d);
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  child: ListTile(
                    title: Text('${d.ad} (${d.saat} Saat)'),
                    subtitle: Text(ort == -1 ? 'Not girilmedi' : 'Ortalama: ${ort.toStringAsFixed(2)}'),
                    trailing: IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blue),
                      onPressed: () => _notGirDialog(context, index),
                    ),
                    leading: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () { setState(() { dersler.removeAt(index); }); },
                    ),
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
                    Expanded(child: TextField(controller: _dersAdController, decoration: const InputDecoration(hintText: 'Ders Adı', isDense: true))),
                    const SizedBox(width: 10),
                    Expanded(child: TextField(controller: _dersSaatController, keyboardType: TextInputType.number, decoration: const InputDecoration(hintText: 'Saat', isDense: true))),
                    IconButton(
                      icon: const Icon(Icons.add, color: Colors.green),
                      onPressed: () {
                        if (_dersAdController.text.isNotEmpty && _dersSaatController.text.isNotEmpty) {
                          setState(() {
                            dersler.add(Ders(_dersAdController.text, int.tryParse(_dersSaatController.text) ?? 1));
                            _dersAdController.clear(); _dersSaatController.clear();
                          });
                        }
                      },
                    )
                  ],
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      if (genelOrtalama == -1) {
                        _sonuc = "Henüz hiçbir derse not girilmedi.";
                        return;
                      }
                      _sonuc = "Dönem Ortalaması: ${genelOrtalama.toStringAsFixed(2)}\n";
                      if (zayifSayisi > 0) {
                        _sonuc += "TEBRİKLER HİÇBİR ŞEY ALAMADIN MAŞALLAH!\n($zayifSayisi zayıf dersin var)";
                      } else if (genelOrtalama >= 85) {
                        _sonuc += "TEBRİKLER TAKDİR BELGESİ ALDIN! ÇOK İYİ!";
                      } else if (genelOrtalama >= 70) {
                        _sonuc += "TEBRİKLER TEŞEKKÜR BELGESİ ALDIN! İYİ!";
                      } else {
                        _sonuc += "TEBRİKLER HİÇBİR ŞEY ALAMADIN MAŞALLAH!";
                      }
                    });
                  },
                  child: const Text('Hesapla'),
                ),
                Text(_sonuc, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo)),
              ],
            ),
          )
        ],
      ),
    );
  }

  void _notGirDialog(BuildContext context, int index) {
    final n1 = TextEditingController(text: dersler[index].not1 >= 0 ? dersler[index].not1.toString() : '');
    final n2 = TextEditingController(text: dersler[index].not2 >= 0 ? dersler[index].not2.toString() : '');
    final sz = TextEditingController(text: dersler[index].sozlu >= 0 ? dersler[index].sozlu.toString() : '');
    final pr = TextEditingController(text: dersler[index].proje >= 0 ? dersler[index].proje.toString() : '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${dersler[index].ad} Notları'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: n1, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: '1. Sınav')),
              TextField(controller: n2, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: '2. Sınav')),
              TextField(controller: sz, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Sözlü')),
              TextField(controller: pr, decoration: const InputDecoration(labelText: 'Proje (0 veya G)')),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('İptal')),
          ElevatedButton(
            onPressed: () {
              setState(() {
                dersler[index].not1 = double.tryParse(n1.text) ?? -1;
                dersler[index].not2 = double.tryParse(n2.text) ?? -1;
                dersler[index].sozlu = double.tryParse(sz.text) ?? -1;
                if (pr.text.trim().toUpperCase() == 'G' || pr.text.trim().isEmpty) {
                  dersler[index].proje = -1; // G veya boşsa girilmedi say
                } else {
                  dersler[index].proje = double.tryParse(pr.text) ?? 0;
                }
              });
              Navigator.pop(context);
            },
            child: const Text('Kaydet'),
          ),
        ],
      ),
    );
  }
}

// --- 5. TEK DERS EKRANI ---
class TekDersEkrani extends StatefulWidget {
  const TekDersEkrani({Key? key}) : super(key: key);
  @override
  State<TekDersEkrani> createState() => _TekDersEkraniState();
}
class _TekDersEkraniState extends State<TekDersEkrani> {
  bool _ikinciSinav = false;
  final _s1 = TextEditingController();
  final _s2 = TextEditingController();
  final _sozlu = TextEditingController();
  final _proje = TextEditingController();
  String _sonuc = "";

  double _notOku(String text, {bool projeMi = false}) {
    if (text.trim().isEmpty) return -1; 
    if (projeMi && text.trim().toUpperCase() == 'G') return -1; 
    return double.tryParse(text) ?? -1; // Harf girilirse boş say
  }

  void _hesapla() {
    double toplam = 0;
    int sayac = 0;

    double n1 = _notOku(_s1.text);
    if (n1 >= 0) { toplam += n1; sayac++; }

    if (_ikinciSinav) {
      double n2 = _notOku(_s2.text);
      if (n2 >= 0) { toplam += n2; sayac++; }
    }

    double nSozlu = _notOku(_sozlu.text);
    if (nSozlu >= 0) { toplam += nSozlu; sayac++; }

    double nProje = _notOku(_proje.text, projeMi: true);
    if (nProje >= 0) { toplam += nProje; sayac++; }

    if (sayac == 0) {
      setState(() { _sonuc = "Hiç not girilmedi!"; });
    } else {
      double ort = toplam / sayac;
      setState(() { _sonuc = "Ortalama: ${ort.toStringAsFixed(2)}"; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tek Ders'),
        actions: [
          Row(
            children: [
              const Text('2. Sınav', style: TextStyle(fontSize: 12)),
              Switch(value: _ikinciSinav, onChanged: (v) => setState(() => _ikinciSinav = v)),
            ],
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(controller: _s1, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: '1. Sınav')),
              if (_ikinciSinav) TextField(controller: _s2, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: '2. Sınav')),
              TextField(controller: _sozlu, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Sözlü')),
              TextField(controller: _proje, decoration: const InputDecoration(labelText: 'Proje (0 veya G)')),
              const SizedBox(height: 20),
              ElevatedButton(onPressed: _hesapla, child: const Text('Hesapla')),
              const SizedBox(height: 20),
              Text(_sonuc, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }
}

// --- 6. DÖNEM HESAPLAMA EKRANI ---
class DonemEkrani extends StatefulWidget {
  final String kullaniciAdi;
  const DonemEkrani({Key? key, required this.kullaniciAdi}) : super(key: key);
  @override
  State<DonemEkrani> createState() => _DonemEkraniState();
}

class _DonemEkraniState extends State<DonemEkrani> {
  final _ort = TextEditingController();
  final _zayif = TextEditingController();
  String _sonuc = "";

  void _hesapla() {
    double? ort = double.tryParse(_ort.text);
    int? zayif = int.tryParse(_zayif.text);

    if (ort == null || zayif == null) {
      setState(() => _sonuc = "Lütfen geçerli sayılar girin.");
      return;
    }

    if (zayif > 0) {
      setState(() => _sonuc = "TEBRİKLER HİÇBİR ŞEY ALAMADIN MAŞALLAH!\n(Zayıf dersin var)");
    } else if (ort >= 85) {
      setState(() => _sonuc = "TEBRİKLER TAKDİR BELGESİ ALDIN! ÇOK İYİ!");
    } else if (ort >= 70) {
      setState(() => _sonuc = "TEBRİKLER TEŞEKKÜR BELGESİ ALDIN! İYİ!");
    } else {
      setState(() => _sonuc = "TEBRİKLER HİÇBİR ŞEY ALAMADIN MAŞALLAH!");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dönem Hesaplama')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(controller: _ort, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Dönem Ortalaması (Örn: 85)')),
            TextField(controller: _zayif, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Zayıf Ders Sayısı (50 altı)')),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: _hesapla, child: const Text('Belgeyi Hesapla')),
            const SizedBox(height: 20),
            Text(_sonuc, textAlign: TextAlign.center, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.indigo)),
          ],
        ),
      ),
    );
  }
}
