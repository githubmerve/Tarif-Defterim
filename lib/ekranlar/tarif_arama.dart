import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../widgets/tarif_karti.dart';

class TarifArama extends StatefulWidget {
  const TarifArama({super.key});

  @override
  State<TarifArama> createState() => _TarifAramaState();
}

class _TarifAramaState extends State<TarifArama> {
  final _aramaController = TextEditingController();
  String _aramaMetni = '';

  @override
  void dispose() {
    _aramaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _aramaController,
          decoration: const InputDecoration(
            hintText: 'Tarif ara...',
            border: InputBorder.none,
            hintStyle: TextStyle(color: Colors.white70),
          ),
          style: const TextStyle(color: Colors.white),
          onChanged: (value) {
            setState(() {
              _aramaMetni = value;
            });
          },
        ),
      ),
      body: _aramaMetni.isEmpty
          ? const Center(
              child: Text('Aramak istediğiniz tarifi yazın'),
            )
          : StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('tarifler')
                  .orderBy('baslik')
                  .startAt([_aramaMetni]).endAt(
                      ['$_aramaMetni\uf8ff']).snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Text('Bir hata oluştu: ${snapshot.error}'),
                  );
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                final tarifler = snapshot.data?.docs ?? [];

                if (tarifler.isEmpty) {
                  return const Center(
                    child: Text('Aranan kriterlere uygun tarif bulunamadı'),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: tarifler.length,
                  itemBuilder: (context, index) {
                    final tarif =
                        tarifler[index].data() as Map<String, dynamic>;
                    final tarifId = tarifler[index].id;

                    return TarifKarti(
                      tarifId: tarifId,
                      baslik: tarif['baslik'] ?? 'İsimsiz Tarif',
                      aciklama: tarif['aciklama'],
                      hazirlamaSuresi: tarif['hazirlama_suresi'],
                      resimUrl: tarif['resimUrl'],
                      kategori: tarif['kategori'] ?? 'Kategorisiz',
                      eklemeTarihi:
                          (tarif['ekleme_tarihi'] as Timestamp).toDate(),
                      kisiSayisi: tarif['kisi_sayisi'] ?? 1,
                    );
                  },
                );
              },
            ),
    );
  }
}
