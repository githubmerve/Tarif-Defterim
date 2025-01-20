import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class KategoriDetay extends StatelessWidget {
  final String kategoriAdi;

  const KategoriDetay({Key? key, required this.kategoriAdi}) : super(key: key);

  Future<void> _favoriDurumunuGuncelle(
      BuildContext context, String tarifId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Favorilere eklemek için giriş yapın'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final favoriRef = FirebaseFirestore.instance
        .collection('kullanicilar')
        .doc(user.uid)
        .collection('favoriler')
        .doc(tarifId);

    final favoriDoc = await favoriRef.get();

    if (favoriDoc.exists) {
      await favoriRef.delete();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Favorilerden çıkarıldı'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } else {
      await favoriRef.set({
        'ekleme_tarihi': FieldValue.serverTimestamp(),
      });
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Favorilere eklendi'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text(kategoriAdi),
        backgroundColor: Colors.red[900],
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/beyaz_pattern.png',
              fit: BoxFit.cover,
              color: Colors.black.withOpacity(0.05),
              colorBlendMode: BlendMode.srcOver,
            ),
          ),
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.7),
              ),
            ),
          ),
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('tarifler')
                .where('kategori', isEqualTo: kategoriAdi)
                .orderBy('ekleme_tarihi', descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(
                  child: Text('Bir hata oluştu: ${snapshot.error}'),
                );
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final tarifler = snapshot.data?.docs ?? [];

              if (tarifler.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.no_meals, size: 64, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text(
                        'Bu kategoride henüz tarif yok',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(8),
                itemCount: tarifler.length,
                itemBuilder: (context, index) {
                  final tarif = tarifler[index];
                  final tarifData = tarif.data() as Map<String, dynamic>;

                  return StreamBuilder<DocumentSnapshot>(
                    stream: user != null
                        ? FirebaseFirestore.instance
                            .collection('kullanicilar')
                            .doc(user.uid)
                            .collection('favoriler')
                            .doc(tarif.id)
                            .snapshots()
                        : null,
                    builder: (context, favoriSnapshot) {
                      final favoriDurumu =
                          favoriSnapshot.hasData && favoriSnapshot.data!.exists;

                      return Card(
                        margin: const EdgeInsets.symmetric(
                          vertical: 8,
                          horizontal: 4,
                        ),
                        elevation: 2,
                        child: InkWell(
                          onTap: () => Navigator.pushNamed(
                            context,
                            '/tarif_detay',
                            arguments: tarif.id,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (tarifData['resimUrl'] != null &&
                                  tarifData['resimUrl'].toString().isNotEmpty)
                                ClipRRect(
                                  borderRadius: const BorderRadius.vertical(
                                      top: Radius.circular(4)),
                                  child: Image.network(
                                    tarifData['resimUrl'],
                                    width: double.infinity,
                                    height: 200,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        width: double.infinity,
                                        height: 200,
                                        color: Colors.grey[200],
                                        child: Icon(
                                          Icons.broken_image,
                                          size: 64,
                                          color: Colors.grey[400],
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              Padding(
                                padding: const EdgeInsets.all(12),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            tarifData['baslik'] ??
                                                'İsimsiz Tarif',
                                            style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          if (tarifData['hazirlama_suresi'] !=
                                              null)
                                            Padding(
                                              padding:
                                                  const EdgeInsets.only(top: 8),
                                              child: Row(
                                                children: [
                                                  const Icon(
                                                    Icons.timer_outlined,
                                                    size: 16,
                                                    color: Colors.grey,
                                                  ),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    '${tarifData['hazirlama_suresi']} dk',
                                                    style: const TextStyle(
                                                      color: Colors.grey,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 16),
                                                  const Icon(
                                                    Icons.people_outline,
                                                    size: 16,
                                                    color: Colors.grey,
                                                  ),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    '${tarifData['kisi_sayisi'] ?? 1} kişilik',
                                                    style: const TextStyle(
                                                      color: Colors.grey,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                    IconButton(
                                      icon: Icon(
                                        favoriDurumu
                                            ? Icons.favorite
                                            : Icons.favorite_border,
                                        color: Colors.red,
                                      ),
                                      onPressed: () => _favoriDurumunuGuncelle(
                                          context, tarif.id),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
