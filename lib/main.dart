import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

void main() {
  runApp(const BaroBTApp());
}

class BaroBTApp extends StatelessWidget {
  const BaroBTApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Notlarını Hesapla',
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      home: const SplashScreen(),
    );
  }
}

// --- AÇILIŞ EKRANI ---
class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkUser();
  }

  Future<void> _checkUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? isim = prefs.getString('kullanici_adi');
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    if (isim != null && isim.isNotEmpty) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => AnaMenuEkrani(kullaniciAdi: isim)));
    } else {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const IsimEkrani()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.black87,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Baro-BT Studios', style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.cyanAccent, letterSpacing: 2.0)),
            SizedBox(height: 15),
            Text('Notlarını Hesapla', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500, color: Colors.white70, letterSpacing: 1.5)),
          ],
        ),
      ),
    );
  }
}

// --- İSİM SORMA ---
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
              onPressed: () async {
                if (_isimController.text.isNotEmpty) {
                  SharedPreferences prefs = await SharedPreferences.getInstance();
                  await prefs.setString('kullanici_adi', _isimController.text);
                  if (!mounted) return;
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

// --- ANA MENÜ ---
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
            ElevatedButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const GenelNotEkrani())), child: const Text('Genel Not Hesaplama (Bilgi)')),
            const SizedBox(height: 15),
            ElevatedButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const TekDersEkrani())), child: const Text('Tek Ders Ortalama')),
            const SizedBox(height: 15),
            // YENİ EKLENEN AYRI SEKMELER
            ElevatedButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const DonemSonuEkrani())), child: const Text('Dönem Sonu (Karne)')),
            const SizedBox(height: 15),
            ElevatedButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const YilSonuEkrani())), child: const Text('Yıl Sonu Ortalaması')),
          ],
        ),
      ),
    );
  }
}

// --- YARDIMCI FONKSİYON ---
double _guvenliNotOku(String text) {
  if (text.trim().isEmpty) return -1;
  if (text.trim().toUpperCase() == 'G') return -1;
  double? val = double.tryParse(text);
  if (val == null || val < 0) return -1;
  if (val > 100) return 100;
  return val;
}

// --- GENEL NOT HESAPLAMA (Sadece Yorum Yazar, Takdir Yok) ---
class Ders {
  String ad;
  int saat;
  double not1, not2, sozlu, proje;
  Ders(this.ad, this.saat, {this.not1 = -1, this.not2 = -1, this.sozlu = -1, this.proje = -1});
  Map<String, dynamic> toJson() => {'ad': ad, 'saat': saat, 'not1': not1, 'not2': not2, 'sozlu': sozlu, 'proje': proje};
  factory Ders.fromJson(Map<String, dynamic> json) => Ders(json['ad'], (json['saat'] as num).toInt(), not1: (json['not1'] as num).toDouble(), not2: (json['not2'] as num).toDouble(), sozlu: (json['sozlu'] as num).toDouble(), proje: (json['proje'] as num).toDouble());
}

class GenelNotEkrani extends StatefulWidget {
  const GenelNotEkrani({Key? key}) : super(key: key);
  @override
  State<GenelNotEkrani> createState() => _GenelNotEkraniState();
}

class _GenelNotEkraniState extends State<GenelNotEkrani> {
  List<Ders> dersler = [];
  final TextEditingController _dersAdController = TextEditingController();
  final TextEditingController _dersSaatController = TextEditingController();
  String _sonuc = "";

  @override
  void initState() {
    super.initState();
    _dersleriYukle();
  }

  Future<void> _dersleriYukle() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? dersJson = prefs.getString('dersler');
    if (dersJson != null) {
      List<dynamic> list = jsonDecode(dersJson);
      setState(() => dersler = list.map((e) => Ders.fromJson(e)).toList());
    } else {
      setState(() => dersler = [Ders('Matematik', 6), Ders('Türkçe', 5), Ders('Fen Bilimleri', 4), Ders('Sosyal Bilgiler', 3)]);
      _dersleriKaydet();
    }
  }

  Future<void> _dersleriKaydet() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('dersler', jsonEncode(dersler.map((e) => e.toJson()).toList()));
  }

  double _dersOrtalama(Ders d) {
    double toplam = 0; int sayac = 0;
    if (d.not1 >= 0) { toplam += d.not1; sayac++; }
    if (d.not2 >= 0) { toplam += d.not2; sayac++; }
    if (d.sozlu >= 0) { toplam += d.sozlu; sayac++; }
    if (d.proje >= 0) { toplam += d.proje; sayac++; }
    return sayac == 0 ? -1 : toplam / sayac;
  }

  @override
  Widget build(BuildContext context) {
    double genelToplam = 0; int toplamSaat = 0;
    for (var d in dersler) {
      double ort = _dersOrtalama(d);
      if (ort != -1) { genelToplam += ort * d.saat; toplamSaat += d.saat; }
    }
    double genelOrtalama = toplamSaat == 0 ? -1 : genelToplam / toplamSaat;

    return Scaffold(
      appBar: AppBar(title: const Text('Genel Not Hesaplama')),
      body: SafeArea( // EKRANIN ALTININ KESİLMESİNİ ENGELLER
        child: Column(
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
                      trailing: IconButton(icon: const Icon(Icons.edit, color: Colors.blue), onPressed: () => _notGirDialog(context, index)),
                      leading: IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () { setState(() => dersler.removeAt(index)); _dersleriKaydet(); }),
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
                      Expanded(child: TextField(controller: _dersSaatController, keyboardType: TextInputType.number, decoration: const InputDecoration(hintText: 'Saat (Max 40)', isDense: true))),
                      IconButton(
                        icon: const Icon(Icons.add, color: Colors.green),
                        onPressed: () {
                          if (_dersAdController.text.isNotEmpty && _dersSaatController.text.isNotEmpty) {
                            int saat = int.tryParse(_dersSaatController.text) ?? 1;
                            if (saat > 40) saat = 40; if (saat < 1) saat = 1;
                            setState(() { dersler.add(Ders(_dersAdController.text, saat)); _dersAdController.clear(); _dersSaatController.clear(); });
                            _dersleriKaydet();
                          }
                        },
                      )
                    ],
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        if (genelOrtalama == -1) { _sonuc = "Henüz hiçbir derse not girilmedi."; return; }
                        String yorum = "";
                        if (genelOrtalama >= 90) { yorum = "OHA BU NOT NE! 🤯"; }
                        else if (genelOrtalama >= 80) { yorum = "ÇOK İYİ LAN! 🔥"; }
                        else if (genelOrtalama >= 70) { yorum = "İYİ 👍"; }
                        else if (genelOrtalama >= 60) { yorum = "ORTA 😐"; }
                        else if (genelOrtalama >= 50) { yorum = "EH İŞTE 🤷‍♂️"; }
                        else { yorum = "İDARE EDER... (Geçtin sayılır) 😬"; }
                        
                        _sonuc = "Ortalaman: ${genelOrtalama.toStringAsFixed(2)}\n$yorum";
                      });
                    },
                    child: const Text('Hesapla'),
                  ),
                  const SizedBox(height: 8),
                  Text(_sonuc, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo, fontSize: 16)),
                  const SizedBox(height: 10), // Navigasyon tuşları için ekstra boşluk
                ],
              ),
            )
          ],
        ),
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
                dersler[index].not1 = _guvenliNotOku(n1.text);
                dersler[index].not2 = _guvenliNotOku(n2.text);
                dersler[index].sozlu = _guvenliNotOku(sz.text);
                dersler[index].proje = _guvenliNotOku(pr.text);
              });
              _dersleriKaydet();
              Navigator.pop(context);
            },
            child: const Text('Kaydet'),
          ),
        ],
      ),
    );
  }
}

// --- TEK DERS EKRANI ---
class TekDersEkrani extends StatefulWidget {
  const TekDersEkrani({Key? key}) : super(key: key);
  @override
  State<TekDersEkrani> createState() => _TekDersEkraniState();
}
class _TekDersEkraniState extends State<TekDersEkrani> {
  bool _ikinciSinav = false;
  final _s1 = TextEditingController(); final _s2 = TextEditingController();
  final _sozlu = TextEditingController(); final _proje = TextEditingController();
  String _sonuc = "";

  void _hesapla() {
    double toplam = 0; int sayac = 0;
    double n1 = _guvenliNotOku(_s1.text); if (n1 >= 0) { toplam += n1; sayac++; }
    if (_ikinciSinav) { double n2 = _guvenliNotOku(_s2.text); if (n2 >= 0) { toplam += n2; sayac++; } }
    double nSozlu = _guvenliNotOku(_sozlu.text); if (nSozlu >= 0) { toplam += nSozlu; sayac++; }
    double nProje = _guvenliNotOku(_proje.text); if (nProje >= 0) { toplam += nProje; sayac++; }
    setState(() { _sonuc = sayac == 0 ? "Hiç not girilmedi!" : "Ortalama: ${(toplam / sayac).toStringAsFixed(2)}"; });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tek Ders'),
        actions: [ Row(children: [ const Text('2. Sınav', style: TextStyle(fontSize: 12)), Switch(value: _ikinciSinav, onChanged: (v) => setState(() => _ikinciSinav = v)) ]) ],
      ),
      body: SafeArea(
        child: Padding(
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
      ),
    );
  }
}

// --- AYRI SEKME: DÖNEM SONU (KARNE) ---
class DonemSonuEkrani extends StatefulWidget {
  const DonemSonuEkrani({Key? key}) : super(key: key);
  @override
  State<DonemSonuEkrani> createState() => _DonemSonuEkraniState();
}

class _DonemSonuEkraniState extends State<DonemSonuEkrani> {
  bool _tekTekGir = false; // Sağ üstteki buton
  // Genel girilecekse
  final _s1Ort = TextEditingController();
  final _s2Ort = TextEditingController();
  // Tek tek girilecekse
  final _s1_1 = TextEditingController(); final _s1_2 = TextEditingController();
  final _s2_1 = TextEditingController(); final _s2_2 = TextEditingController();
  final _sozlu = TextEditingController(); final _proje = TextEditingController();
  
  String _sonuc = "";

  void _hesapla() {
    double toplam = 0; int sayac = 0;
    if (!_tekTekGir) {
      // Direkt ortalama girildiyse
      double n1 = _guvenliNotOku(_s1Ort.text); if (n1 >= 0) { toplam += n1; sayac++; }
      double n2 = _guvenliNotOku(_s2Ort.text); if (n2 >= 0) { toplam += n2; sayac++; }
    } else {
      // Tek tek girildiyse
      double n1_1 = _guvenliNotOku(_s1_1.text); if (n1_1 >= 0) { toplam += n1_1; sayac++; }
      double n1_2 = _guvenliNotOku(_s1_2.text); if (n1_2 >= 0) { toplam += n1_2; sayac++; }
      double n2_1 = _guvenliNotOku(_s2_1.text); if (n2_1 >= 0) { toplam += n2_1; sayac++; }
      double n2_2 = _guvenliNotOku(_s2_2.text); if (n2_2 >= 0) { toplam += n2_2; sayac++; }
      double nSoz = _guvenliNotOku(_sozlu.text); if (nSoz >= 0) { toplam += nSoz; sayac++; }
      double nPrj = _guvenliNotOku(_proje.text); if (nPrj >= 0) { toplam += nPrj; sayac++; }
    }

    if (sayac == 0) { setState(() => _sonuc = "Not girilmedi!"); return; }
    setState(() => _sonuc = "DÖNEM SONU ORTALAMASI:\n${(toplam / sayac).toStringAsFixed(2)}");
  }

  Widget _alan(TextEditingController c, String label) {
    return TextField(controller: c, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: label));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dönem Sonu (Karne)'),
        actions: [
          Row(children: [
            const Text('Tek Tek', style: TextStyle(fontSize: 12)),
            Switch(value: _tekTekGir, onChanged: (v) => setState(() { _tekTekGir = v; _sonuc = ""; })),
          ])
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              children: [
                if (!_tekTekGir) ...[
                  const Text('Sınav Ortalamalarını Gir', style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
                  _alan(_s1Ort, '1. Sınav Ortalaması'),
                  _alan(_s2Ort, '2. Sınav Ortalaması'),
                ] else ...[
                  const Text('1. Sınav Notları', style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
                  _alan(_s1_1, '1. Sınav'),
                  _alan(_s1_2, '2. Sınav'),
                  const Text('2. Sınav Notları', style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
                  _alan(_s2_1, '1. Sınav'),
                  _alan(_s2_2, '2. Sınav'),
                  const SizedBox(height: 10),
                  _alan(_sozlu, 'Sözlü Notu'),
                  _alan(_proje, 'Proje (0 veya G)'),
                ],
                const SizedBox(height: 20),
                ElevatedButton(onPressed: _hesapla, child: const Text('Karneyi Hesapla')),
                const SizedBox(height: 20),
                Text(_sonuc, textAlign: TextAlign.center, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.indigo)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// --- AYRI SEKME: YIL SONU ORTALAMASI ---
class YilSonuEkrani extends StatefulWidget {
  const YilSonuEkrani({Key? key}) : super(key: key);
  @override
  State<YilSonuEkrani> createState() => _YilSonuEkraniState();
}
class _YilSonuEkraniState extends State<YilSonuEkrani> {
