import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

void main() => runApp(const BaroBTApp());

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
            ElevatedButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const DonemSonuEkrani())), child: const Text('Dönem Sonu (Karne)')),
            const SizedBox(height: 15),
            ElevatedButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const YilSonuEkrani())), child: const Text('Yıl Sonu Ortalaması')),
          ],
        ),
      ),
    );
  }
}

// --- YARDIMCI FONKSİYONLAR ---
double _notOku(String t) {
  if (t.trim().isEmpty || t.trim().toUpperCase() == 'G') return -1;
  double? val = double.tryParse(t);
  if (val == null || val < 0) return -1;
  if (val > 100) return 100;
  return val;
}

String _belgeMesaji(double ort, int zayif) {
  if (zayif > 0) return "TEBRİKLER HİÇBİR ŞEY ALAMADIN MAŞALLAH!\n($zayif zayıf dersin var)";
  if (ort >= 85) return "TEBRİKLER TAKDİR BELGESİ ALDIN! ÇOK İYİ!";
  if (ort >= 70) return "TEBRİKLER TEŞEKKÜR BELGESİ ALDIN! İYİ!";
  return "TEBRİKLER HİÇBİR ŞEY ALAMADIN MAŞALLAH!";
}

class Ders {
  String ad; int saat; double n1, n2, sz, pr;
  Ders(this.ad, this.saat, {this.n1 = -1, this.n2 = -1, this.sz = -1, this.pr = -1});
  Map<String, dynamic> toJson() => {'ad': ad, 'saat': saat, 'n1': n1, 'n2': n2, 'sz': sz, 'pr': pr};
  factory Ders.fromJson(Map<String, dynamic> json) => Ders(
    json['ad'], (json['saat'] as num).toInt(),
    n1: (json['n1'] as num).toDouble(), n2: (json['n2'] as num).toDouble(),
    sz: (json['sz'] as num).toDouble(), pr: (json['pr'] as num).toDouble()
  );
}

// --- GENEL NOT HESAPLAMA (Sadece 1. Sınav ve Sözlü Mantığı) ---
class GenelNotEkrani extends StatefulWidget {
  const GenelNotEkrani({Key? key}) : super(key: key);
  @override
  State<GenelNotEkrani> createState() => _GenelNotEkraniState();
}

class _GenelNotEkraniState extends State<GenelNotEkrani> {
  List<Ders> dersler = [];
  final _adC = TextEditingController(); final _saatC = TextEditingController();
  String _sonuc = "";

  @override
  void initState() { super.initState(); _yukle(); }

  Future<void> _yukle() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? json = prefs.getString('dersler');
    if (json != null) {
      setState(() => dersler = (jsonDecode(json) as List).map((e) => Ders.fromJson(e)).toList());
    } else {
      setState(() => dersler = [Ders('Matematik', 6), Ders('Türkçe', 5), Ders('Fen Bilimleri', 4), Ders('Sosyal Bilgiler', 3)]);
      _kaydet();
    }
  }

  Future<void> _kaydet() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('dersler', jsonEncode(dersler.map((e) => e.toJson()).toList()));
  }

  double _ort(Ders d) {
    double t = 0; int s = 0;
    if (d.n1 >= 0) { t += d.n1; s++; }
    if (d.sz >= 0) { t += d.sz; s++; }
    return s == 0 ? -1 : t / s;
  }

  @override
  Widget build(BuildContext context) {
    double gT = 0; int tS = 0;
    for (var d in dersler) {
      double o = _ort(d);
      if (o != -1) { gT += o * d.saat; tS += d.saat; }
    }
    double gOrt = tS == 0 ? -1 : gT / tS;

    return Scaffold(
      appBar: AppBar(title: const Text('Genel Not Hesaplama')),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: dersler.length,
                itemBuilder: (context, i) {
                  final d = dersler[i]; double o = _ort(d);
                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    child: ListTile(
                      title: Text('${d.ad} (${d.saat} Saat)'),
                      subtitle: Text(o == -1 ? 'Not girilmedi' : '1. Sınav Ort: ${o.toStringAsFixed(2)}'),
                      trailing: IconButton(icon: const Icon(Icons.edit, color: Colors.blue), onPressed: () => _dialog(context, i)),
                      leading: IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () { setState(() => dersler.removeAt(i)); _kaydet(); }),
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
                      Expanded(child: TextField(controller: _adC, decoration: const InputDecoration(hintText: 'Ders Adı', isDense: true))),
                      const SizedBox(width: 10),
                      Expanded(child: TextField(controller: _saatC, keyboardType: TextInputType.number, decoration: const InputDecoration(hintText: 'Saat (Max 40)', isDense: true))),
                      IconButton(
                        icon: const Icon(Icons.add, color: Colors.green),
                        onPressed: () {
                          if (_adC.text.isNotEmpty && _saatC.text.isNotEmpty) {
                            int s = int.tryParse(_saatC.text) ?? 1;
                            if (s > 40) s = 40; if (s < 1) s = 1;
                            setState(() { dersler.add(Ders(_adC.text, s)); _adC.clear(); _saatC.clear(); });
                            _kaydet();
                          }
                        },
                      )
                    ],
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        if (gOrt == -1) { _sonuc = "Henüz hiçbir derse not girilmedi."; return; }
                        String y = "";
                        if (gOrt >= 90) { y = "OHA BU NOT NE! 🤯"; }
                        else if (gOrt >= 80) { y = "ÇOK İYİ LAN! 🔥"; }
                        else if (gOrt >= 70) { y = "İYİ 👍"; }
                        else if (gOrt >= 60) { y = "ORTA 😐"; }
                        else if (gOrt >= 50) { y = "EH İŞTE 🤷‍♂️"; }
                        else { y = "İDARE EDER... (Geçtin sayılır) 😬"; }
                        _sonuc = "1. Sınav Ortalaman: ${gOrt.toStringAsFixed(2)}\n$y";
                      });
                    },
                    child: const Text('Hesapla'),
                  ),
                  const SizedBox(height: 8),
                  Text(_sonuc, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo, fontSize: 16)),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  void _dialog(BuildContext context, int i) {
    final n1 = TextEditingController(text: dersler[i].n1 >= 0 ? dersler[i].n1.toString() : '');
    final sz = TextEditingController(text: dersler[i].sz >= 0 ? dersler[i].sz.toString() : '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${dersler[i].ad} 1. Sınav Notu'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: n1, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: '1. Sınav')),
            TextField(controller: sz, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Sözlü')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('İptal')),
          ElevatedButton(
            onPressed: () {
              setState(() {
                dersler[i].n1 = _notOku(n1.text);
                dersler[i].sz = _notOku(sz.text);
              });
              _kaydet(); Navigator.pop(context);
            },
            child: const Text('Kaydet'),
          ),
        ],
      ),
    );
  }
}

// --- DÖNEM SONU (KARNE) EKRANI (1. ve 2. Sınav + Proje) ---
class DonemSonuEkrani extends StatefulWidget {
  const DonemSonuEkrani({Key? key}) : super(key: key);
  @override
  State<DonemSonuEkrani> createState() => _DonemSonuEkraniState();
}

class _DonemSonuEkraniState extends State<DonemSonuEkrani> {
  List<Ders> dersler = [];
  final _adC = TextEditingController(); final _saatC = TextEditingController();
  String _sonuc = "";

  @override
  void initState() { super.initState(); _yukle(); }

  Future<void> _yukle() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? json = prefs.getString('dersler');
    if (json != null) {
      setState(() => dersler = (jsonDecode(json) as List).map((e) => Ders.fromJson(e)).toList());
    } else {
      setState(() => dersler = [Ders('Matematik', 6), Ders('Türkçe', 5), Ders('Fen Bilimleri', 4), Ders('Sosyal Bilgiler', 3)]);
      _kaydet();
    }
  }

  Future<void> _kaydet() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('dersler', jsonEncode(dersler.map((e) => e.toJson()).toList()));
  }

  double _dersOrt(Ders d) {
    double t = 0; int s = 0;
    if (d.n1 >= 0) { t += d.n1; s++; }
    if (d.n2 >= 0) { t += d.n2; s++; }
    if (d.sz >= 0) { t += d.sz; s++; }
    if (d.pr >= 0) { t += d.pr; s++; }
    return s == 0 ? -1 : t / s;
  }

  @override
  Widget build(BuildContext context) {
    double gT = 0; int tS = 0; int zayif = 0;
    for (var d in dersler) {
      double o = _dersOrt(d);
      if (o != -1) { 
        gT += o * d.saat; tS += d.saat; 
        if (o < 50) zayif++;
      }
    }
    double gOrt = tS == 0 ? -1 : gT / tS;

    return Scaffold(
      appBar: AppBar(title: const Text('Dönem Sonu (Karne)')),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: dersler.length,
                itemBuilder: (context, i) {
                  final d = dersler[i]; double o = _dersOrt(d);
                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    child: ListTile(
                      title: Text('${d.ad} (${d.saat} Saat)'),
                      subtitle: Text(o == -1 ? 'Not girilmedi' : 'Dönem Ort: ${o.toStringAsFixed(2)}'),
                      trailing: IconButton(icon: const Icon(Icons.edit, color: Colors.blue), onPressed: () => _dialog(context, i)),
                      leading: IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () { setState(() => dersler.removeAt(i)); _kaydet(); }),
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
                      Expanded(child: TextField(controller: _adC, decoration: const InputDecoration(hintText: 'Ders Adı', isDense: true))),
                      const SizedBox(width: 10),
                      Expanded(child: TextField(controller: _saatC, keyboardType: TextInputType.number, decoration: const InputDecoration(hintText: 'Saat (Max 40)', isDense: true))),
                      IconButton(
                        icon: const Icon(Icons.add, color: Colors.green),
                        onPressed: () {
                          if (_adC.text.isNotEmpty && _saatC.text.isNotEmpty) {
                            int s = int.tryParse(_saatC.text) ?? 1;
                            if (s > 40) s = 40; if (s < 1) s = 1;
                            setState(() { dersler.add(Ders(_adC.text, s)); _adC.clear(); _saatC.clear(); });
                            _kaydet();
                          }
                        },
                      )
                    ],
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        if (gOrt == -1) { _sonuc = "Henüz hiçbir derse not girilmedi."; return; }
                        _sonuc = "Dönem Ortalaması: ${gOrt.toStringAsFixed(2)}\n${_belgeMesaji(gOrt, zayif)}";
                      });
                    },
                    child: const Text('Karnemi Hesapla'),
                  ),
                  const SizedBox(height: 8),
                  Text(_sonuc, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo, fontSize: 16)),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  void _dialog(BuildContext context, int i) {
    final n1 = TextEditingController(text: dersler[i].n1 >= 0 ? dersler[i].n1.toString() : '');
    final n2 = TextEditingController(text: dersler[i].n2 >= 0 ? dersler[i].n2.toString() : '');
    final sz = TextEditingController(text: dersler[i].sz >= 0 ? dersler[i].sz.toString() : '');
    final pr = TextEditingController(text: dersler[i].pr >= 0 ? dersler[i].pr.toString() : '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${dersler[i].ad} Karne Notları'),
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
                dersler[i].n1 = _notOku(n1.text);
                dersler[i].n2 = _notOku(n2.text);
                dersler[i].sz = _notOku(sz.text);
                dersler[i].pr = _notOku(pr.text);
              });
              _kaydet(); Navigator.pop(context);
            },
            child: const Text('Kaydet'),
          ),
        ],
      ),
    );
  }
}

class TekDersEkrani extends StatefulWidget {
  const TekDersEkrani({Key? key}) : super(key: key);
  @override
  State<TekDersEkrani> createState() => _TekDersEkraniState();
}
class _TekDersEkraniState extends State<TekDersEkrani> {
  bool _ikinci = false;
  final _s1 = TextEditingController(); final _s2 = TextEditingController();
  final _sz = TextEditingController(); final _pr = TextEditingController();
  String _sonuc = "";

  void _hesapla() {
    double t = 0; int s = 0;
    double n1 = _notOku(_s1.text); if (n1 >= 0) { t += n1; s++; }
    if (_ikinci) { double n2 = _notOku(_s2.text); if (n2 >= 0) { t += n2; s++; } }
    double nS = _notOku(_sz.text); if (nS >= 0) { t += nS; s++; }
    double nP = _notOku(_pr.text); if (nP >= 0) { t += nP; s++; }
    setState(() => _sonuc = s == 0 ? "Hiç not girilmedi!" : "Ortalama: ${(t / s).toStringAsFixed(2)}");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tek Ders'),
        actions: [ Row(children: [ const Text('2. Sınav', style: TextStyle(fontSize: 12)), Switch(value: _ikinci, onChanged: (v) => setState(() => _ikinci = v)) ]) ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextField(controller: _s1, keyboardType: TextInputTy
