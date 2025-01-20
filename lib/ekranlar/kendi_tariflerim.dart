import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../widgets/tarif_karti.dart';

class KendiTariflerim extends StatelessWidget {
  const KendiTariflerim({super.key});

  Future<void> _tarifSil(BuildContext context, String tarifId) async {
    try {
      await FirebaseFirestore.instance
          .collection('tarifler')
          .doc(tarifId)
          .delete();

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tarif başarıyla silindi'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Tarif silinirken bir hata oluştu: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Kendi Tariflerim'),
        ),
        body: const Center(
          child: Text('Lütfen önce giriş yapın'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kendi Tariflerim'),
        backgroundColor: Colors.red[900],
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('tarifler')
            .where('ekleyen_id', isEqualTo: user.uid)
            .orderBy('ekleme_tarihi', descending: true)
            .snapshots(),
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
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.no_meals,
                    size: 64,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Henüz tarif eklememişsiniz',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pushNamed(context, '/tarif_ekle');
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Yeni Tarif Ekle'),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: tarifler.length,
            itemBuilder: (context, index) {
              final tarif = tarifler[index].data() as Map<String, dynamic>;
              final tarifId = tarifler[index].id;

              return Dismissible(
                key: Key(tarifId),
                direction: DismissDirection.endToStart,
                background: Container(
                  color: Colors.red,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 16),
                  child: const Icon(
                    Icons.delete,
                    color: Colors.white,
                  ),
                ),
                confirmDismiss: (direction) async {
                  return await showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Tarifi Sil'),
                      content: const Text(
                        'Bu tarifi silmek istediğinizden emin misiniz?',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('İptal'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text(
                            'Sil',
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                    ),
                  );
                },
                onDismissed: (direction) => _tarifSil(context, tarifId),
                child: TarifKarti(
                  tarifId: tarifId,
                  baslik: tarif['baslik'] ?? 'İsimsiz Tarif',
                  aciklama: tarif['aciklama'],
                  hazirlamaSuresi: tarif['hazirlama_suresi'],
                  resimUrl: tarif['resimUrl'],
                  kategori: tarif['kategori'] ?? 'Kategorisiz',
                  eklemeTarihi: (tarif['ekleme_tarihi'] as Timestamp).toDate(),
                  kisiSayisi: tarif['kisi_sayisi'] ?? 1,
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/tarif_ekle');
        },
        backgroundColor: Colors.red[900],
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
