import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'ekranlar/ana_ekran.dart';
import 'ekranlar/tarif_detay.dart';
import 'ekranlar/tarif_ekle.dart';
import 'ekranlar/tarif_arama.dart';
import 'ekranlar/kendi_tariflerim.dart';
import 'ekranlar/kategori_detay.dart';
import 'ekranlar/giris_ekrani.dart';
import 'ekranlar/favoriler.dart';
import 'ekranlar/profil.dart';
import 'ekranlar/kayit_ol.dart';
import 'ekranlar/hosgeldiniz.dart';
import 'ekranlar/profil_duzenle.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: 'AIzaSyBVhrC5NkBU08XadcvYucNOTN679ERm3lA',
      appId: '1:1046426835962:web:4820c18ae98e3bbc472243',
      messagingSenderId: '1046426835962',
      projectId: 'tarif-defterim-2f75d',
      authDomain: 'tarif-defterim-2f75d.firebaseapp.com',
    ),
  );

  timeago.setLocaleMessages('tr', timeago.TrMessages());
  timeago.setDefaultLocale('tr');

  runApp(const TarifDefterim());
}

class TarifDefterim extends StatelessWidget {
  const TarifDefterim({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tarif Defterim',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
        useMaterial3: true,
      ),
      initialRoute: '/hosgeldiniz',
      routes: {
        '/hosgeldiniz': (context) => const Hosgeldiniz(),
        '/giris': (context) => const GirisEkrani(),
        '/kayit_ol': (context) => const KayitOl(),
        '/ana_ekran': (context) => const AnaEkran(),
        '/tarif_ekle': (context) => const TarifEkle(),
        '/tarif_arama': (context) => const TarifArama(),
        '/kendi_tariflerim': (context) => const KendiTariflerim(),
        '/favoriler': (context) => const Favoriler(),
        '/profil': (context) => const Profil(),
        '/profil_duzenle': (context) => const ProfilDuzenle(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/tarif_detay') {
          final tarifId = settings.arguments as String;
          return MaterialPageRoute(
            builder: (context) => TarifDetay(tarifId: tarifId),
          );
        }
        if (settings.name == '/kategori_detay') {
          final kategoriAdi = settings.arguments as String;
          return MaterialPageRoute(
            builder: (context) => KategoriDetay(kategoriAdi: kategoriAdi),
          );
        }
        return null;
      },
    );
  }
}
