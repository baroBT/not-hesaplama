import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

void main() { runApp(const BaroBTApp()); }

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

double _guvenliNotOku(String text) {
  if (text.trim().isEmpty || text.trim().toUpperCase() == 'G') return -1;
  double? val = double.tryParse(text);
  if (val == null || val < 0) return -1;
  if (val > 100) return 100;
  return val;
}

class Ders {
  String ad; int saat; double not1, not2, sozlu, proje;
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
    if (d.not1 >= 0) { t += d.not1; s++; }
    if (d.not2 >= 0) { t += d.not2; s++; }
    if (d.sozlu >= 0) { t += d.sozlu; s++; }
    if (d.proje >= 0) { t += d.proje; s++; }
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
                      subtitle: Text(o == -1 ? 'Not girilmedi' : 'Ortalama: ${o.toStringAsFixed(2)}'),
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
                        _sonuc = "Ortalaman: ${gOrt.toStringAsFixed(2)}\n$y";
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
    final n1 = TextEditingController(text: dersler[i].not1 >= 0 ? dersler[i].not1.toString() : '');
    final n2 = TextEditingController(text: dersler[i].not2 >= 0 ? dersler[i].not2.toString() : '');
    final sz = TextEditingController(text: dersler[i].sozlu >= 0 ? dersler[i].sozlu.toString() : '');
    final pr = TextEditingController(text: dersler[i].proje >= 0 ? dersler[i].proje.toString() : '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${dersler[i].ad} Notları'),
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
                dersler[i].not1 = _guvenliNotOku(n1.text);
                dersler[i].not2 = _guvenliNotOku(n2.text);
                dersler[i].sozlu = _guvenliNotOku(sz.text);
                dersler[i].proje = _guvenliNotOku(pr.text);
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
    double n1 = _guvenliNotOku(_s1.text); if (n1 >= 0) { t += n1; s++; }
    if (_ikinci) { double n2 = _guvenliNotOku(_s2.text); if (n2 >= 0) { t += n2; s++; } }
    double nS = _guvenliNotOku(_sz.text); if (nS >= 0) { t += nS; s++; }
    double nP = _guvenliNotOku(_pr.text); if (nP >= 0) { t += nP; s++; }
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
                TextField(controller: _s1, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: '1. Sınav')),
                if (_ikinci) TextField(controller: _s2, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: '2. Sınav')),
                TextField(controller: _sz, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Sözlü')),
                TextField(controller: _pr, decoration: const InputDecoration(labelText: 'Proje (0 veya G)')),
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

class DonemSonuEkrani extends StatefulWidget {
  const DonemSonuEkrani({Key? key}) : super(key: key);
  @override
  State<DonemSonuEkrani> createState() => _DonemSonuEkraniState();
}
class _DonemSonuEkraniState extends State<DonemSonuEkrani> {
  bool _tekTek = false;
  final _o1 = TextEditingController(); final _o2 = TextEditingController();
  final _s1_1 = TextEditingController(); final _s1_2 = TextEditingController();
  final _s2_1 = TextEditingController(); final _s2_2 = TextEditingController();
  final _sz = TextEditingController(); final _pr = TextEditingController();
  String _sonuc = "";

  void _hesapla() {
    double t = 0; int s = 0;
    if (!_tekTek) {
      double n1 = _guvenliNotOku(_o1.text); if (n1 >= 0) { t += n1; s++; }
      double n2 = _guvenliNotOku(_o2.text); if (n2 >= 0) { t += n2; s++; }
    } else {
      double n1_1 = _guvenliNotOku(_s1_1.text); if (n1_1 >= 0) { t += n1_1; s++; }
      double n1_2 = _guvenliNotOku(_s1_2.text); if (n1_2 >= 0) { t += n1_2; s++; }
      double n2_1 = _guvenliNotOku(_s2_1.text); if (n2_1 >= 0) { t += n2_1; s++; }
      double n2_2 = _guvenliNotOku(_s2_2.text); if (n2_2 >= 0) { t += n2_2; s++; }
      double nS = _guvenliNotOku(_sz.text); if (nS >= 0) { t += nS; s++; }
      double nP = _guvenliNotOku(_pr.text); if (nP >= 0) { t += nP; s++; }
    }
    if (s == 0) { setState(() => _sonuc = "Not girilmedi!"); return; }
    setState(() => _sonuc = "DÖNEM SONU ORTALAMASI:\n${(t / s).toStringAsFixed(2)}");
  }

  Widget _alan(TextEditingController c, String l) => TextField(controller: c, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: l));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dönem Sonu (Karne)'),
        actions: [ Row(children: [ const Text('Tek Tek', style: TextStyle(fontSize: 12)), Switch(value: _tekTek, onChanged: (v) => setState(() { _tekTek = v; _sonuc = ""; })) ]) ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              children: [
                if (!_tekTek) ...[
                  const Text('Sınav Ortalamalarını Gir', style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
                  _alan(_o1, '1. Sınav Ortalaması'),
                  _alan(_o2, '2. Sınav Ortalaması'),
                ] else ...[
                  const Text('1. Sınav Notları', style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
                  _alan(_s1_1, '1. Sınav'), _alan(_s1_2, '2. Sınav'),
                  const Text('2. Sınav Notları', style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
                  _alan(_s2_1, '1. Sınav'), _alan(_s2_2, '2. Sınav'),
                  const SizedBox(height: 10),
                  _alan(_sz, 'Sözlü Notu'), _alan(_pr, 'Proje (0 veya G)'),
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

class YilSonuEkrani extends StatefulWidget {
  const YilSonuEkrani({Key? key}) : super(key: key);
  @override
  State<YilSonuEkrani> createState() => _YilSonuEkraniState();
}

class _YilSonuEkraniState extends State<YilSonuEkrani> {
  final _d1 = TextEditingController(); final _d2 = TextEditingController();
  String _sonuc = "";

  void _hesapla() {
    double? n1 = double.tryParse(_d1.text); double? n2 = double.tryParse(_d2.text);
    if (n1 == null || n2 == null) { setState(() => _sonuc = "İki dönemi de gir!"); return; }
    if (n1 > 100) n1 = 100; if (n2 > 100) n2 = 100;
    setState(() => _sonuc = "YIL SONU ORTALAMASI:\n${((n1 + n2) / 2).toStringAsFixed(2)}");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Yıl Sonu Ortalaması')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextField(controller: _d1, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: '1. Dönem Ortalaması')),
              TextField(controller: _d2, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: '2. Dönem Ortalaması')),
              const SizedBox(height: 20),
              ElevatedButton(onPressed: _hesapla, child: const Text('Hesapla')),
              const SizedBox(height: 20),
              Text(_sonuc, textAlign: TextAlign.center, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.indigo)),
            ],
          ),
        ),
      ),
    );
  }
}
