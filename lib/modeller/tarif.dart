import 'package:cloud_firestore/cloud_firestore.dart';

class Tarif {
  final String id;
  final String baslik;
  final String aciklama;
  final List<String> malzemeler;
  final List<String> yapilis;
  final String resimUrl;
  final String kategori;
  final int hazirlamaSuresi;
  final int porsiyon;
  final String zorluk;
  final String ekleyenId;
  final DateTime eklenmeTarihi;
  final int begeniSayisi;

  Tarif({
    required this.id,
    required this.baslik,
    required this.aciklama,
    required this.malzemeler,
    required this.yapilis,
    required this.resimUrl,
    required this.kategori,
    required this.hazirlamaSuresi,
    required this.porsiyon,
    required this.zorluk,
    required this.ekleyenId,
    required this.eklenmeTarihi,
    this.begeniSayisi = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'baslik': baslik,
      'aciklama': aciklama,
      'malzemeler': malzemeler,
      'yapilis': yapilis,
      'resimUrl': resimUrl,
      'kategori': kategori,
      'hazirlama_suresi': hazirlamaSuresi,
      'porsiyon': porsiyon,
      'zorluk': zorluk,
      'ekleyen_id': ekleyenId,
      'eklenme_tarihi': FieldValue.serverTimestamp(),
      'begeni_sayisi': begeniSayisi,
    };
  }

  factory Tarif.fromMap(String id, Map<dynamic, dynamic> map) {
    return Tarif(
      id: id,
      baslik: map['baslik'] ?? '',
      aciklama: map['aciklama'] ?? '',
      malzemeler: List<String>.from(map['malzemeler'] ?? []),
      yapilis: List<String>.from(map['yapilis'] ?? []),
      resimUrl: map['resimUrl'] ?? '',
      kategori: map['kategori'] ?? '',
      hazirlamaSuresi: map['hazirlama_suresi']?.toInt() ?? 0,
      porsiyon: map['porsiyon']?.toInt() ?? 0,
      zorluk: map['zorluk'] ?? '',
      ekleyenId: map['ekleyen_id'] ?? '',
      eklenmeTarihi: DateTime.fromMillisecondsSinceEpoch(
          map['eklenme_tarihi'] ?? DateTime.now().millisecondsSinceEpoch),
      begeniSayisi: map['begeni_sayisi']?.toInt() ?? 0,
    );
  }
}
