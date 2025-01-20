import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../widgets/yorum_karti.dart';

class TarifDetay extends StatefulWidget {
  final String tarifId;

  const TarifDetay({super.key, required this.tarifId});

  @override
  State<TarifDetay> createState() => _TarifDetayState();
}

class _TarifDetayState extends State<TarifDetay> {
  final _yorumController = TextEditingController();

  Future<void> _yorumEkle() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Yorum yapmak için giriş yapmalısınız'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    if (_yorumController.text.trim().isEmpty) {
      return;
    }

    try {
      await FirebaseFirestore.instance
          .collection('tarifler')
          .doc(widget.tarifId)
          .collection('yorumlar')
          .add({
        'kullanici_id': user.uid,
        'kullanici_adi': user.displayName ?? 'Anonim',
        'yorum': _yorumController.text.trim(),
        'tarih': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        _yorumController.clear();
        FocusScope.of(context).unfocus();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Yorum eklenirken bir hata oluştu: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _yorumSil(String yorumId) async {
    try {
      await FirebaseFirestore.instance
          .collection('tarifler')
          .doc(widget.tarifId)
          .collection('yorumlar')
          .doc(yorumId)
          .delete();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Yorum başarıyla silindi'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Yorum silinirken bir hata oluştu: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _yorumDuzenle(String yorumId, String yeniYorum) async {
    try {
      await FirebaseFirestore.instance
          .collection('tarifler')
          .doc(widget.tarifId)
          .collection('yorumlar')
          .doc(yorumId)
          .update({
        'yorum': yeniYorum,
        'duzenleme_tarihi': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Yorum başarıyla güncellendi'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Yorum güncellenirken bir hata oluştu: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _yorumController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red[900],
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('tarifler')
            .doc(widget.tarifId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Bir hata oluştu'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('Tarif bulunamadı'));
          }

          final tarif = snapshot.data!.data() as Map<String, dynamic>;
          final ekleyenId = tarif['ekleyen_id'] as String?;

          return StreamBuilder<DocumentSnapshot>(
            stream: ekleyenId != null
                ? FirebaseFirestore.instance
                    .collection('kullanicilar')
                    .doc(ekleyenId)
                    .snapshots()
                : null,
            builder: (context, userSnapshot) {
              String kullaniciAdi = 'Bilinmiyor';

              if (userSnapshot.hasData && userSnapshot.data!.exists) {
                final userData =
                    userSnapshot.data!.data() as Map<String, dynamic>;
                kullaniciAdi =
                    userData['ad'] ?? tarif['ekleyen_ad'] ?? 'Bilinmiyor';
              } else {
                kullaniciAdi = tarif['ekleyen_ad'] ?? 'Bilinmiyor';
              }

              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (tarif['resimUrl'] != null &&
                              tarif['resimUrl'].isNotEmpty)
                            Container(
                              width: double.infinity,
                              height: 200,
                              child: Image.network(
                                tarif['resimUrl'],
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  print('Resim yükleme hatası: $error');
                                  return Container(
                                    color: Colors.grey[200],
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.error_outline,
                                            color: Colors.red[900], size: 48),
                                        const SizedBox(height: 8),
                                        const Text('Resim yüklenemedi'),
                                      ],
                                    ),
                                  );
                                },
                                loadingBuilder:
                                    (context, child, loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return Container(
                                    color: Colors.grey[200],
                                    child: Center(
                                      child: CircularProgressIndicator(
                                        value: loadingProgress
                                                    .expectedTotalBytes !=
                                                null
                                            ? loadingProgress
                                                    .cumulativeBytesLoaded /
                                                loadingProgress
                                                    .expectedTotalBytes!
                                            : null,
                                        color: Colors.red[900],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  tarif['baslik'] ?? 'Tarif başlığı bulunamadı',
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              StreamBuilder<DocumentSnapshot>(
                                stream:
                                    FirebaseAuth.instance.currentUser != null
                                        ? FirebaseFirestore.instance
                                            .collection('kullanicilar')
                                            .doc(FirebaseAuth
                                                .instance.currentUser!.uid)
                                            .collection('favoriler')
                                            .doc(widget.tarifId)
                                            .snapshots()
                                        : null,
                                builder: (context, favoriSnapshot) {
                                  final favoriDurumu = favoriSnapshot.hasData &&
                                      favoriSnapshot.data!.exists;

                                  return IconButton(
                                    icon: Icon(
                                      favoriDurumu
                                          ? Icons.favorite
                                          : Icons.favorite_border,
                                      color: Colors.red,
                                      size: 30,
                                    ),
                                    onPressed: () async {
                                      final user =
                                          FirebaseAuth.instance.currentUser;
                                      if (user == null) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                                'Favorilere eklemek için giriş yapın'),
                                            backgroundColor: Colors.red,
                                          ),
                                        );
                                        return;
                                      }

                                      final favoriRef = FirebaseFirestore
                                          .instance
                                          .collection('kullanicilar')
                                          .doc(user.uid)
                                          .collection('favoriler')
                                          .doc(widget.tarifId);

                                      if (favoriDurumu) {
                                        await favoriRef.delete();
                                        if (context.mounted) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                  'Favorilerden çıkarıldı'),
                                              backgroundColor: Colors.red,
                                            ),
                                          );
                                        }
                                      } else {
                                        await favoriRef.set({
                                          'ekleme_tarihi':
                                              FieldValue.serverTimestamp(),
                                        });
                                        if (context.mounted) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            const SnackBar(
                                              content:
                                                  Text('Favorilere eklendi'),
                                              backgroundColor: Colors.green,
                                            ),
                                          );
                                        }
                                      }
                                    },
                                  );
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.person_outline,
                                  color: Colors.grey),
                              const SizedBox(width: 8),
                              Text(
                                'Ekleyen: $kullaniciAdi',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            tarif['aciklama'] ?? 'Açıklama bulunmuyor',
                            style: const TextStyle(fontSize: 16),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.timer, color: Colors.red),
                                  const SizedBox(width: 8),
                                  Text(
                                    '${tarif['hazirlama_suresi'] ?? 0} dakika',
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  const Icon(Icons.people, color: Colors.red),
                                  const SizedBox(width: 8),
                                  Text(
                                    '${tarif['kisi_sayisi'] ?? 1} kişilik',
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          const Text(
                            'Malzemeler',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          ...List.from(tarif['malzemeler'] ?? []).map(
                            (malzeme) => Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(top: 6),
                                    child: Icon(Icons.fiber_manual_record,
                                        size: 8, color: Colors.red[900]),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      malzeme,
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          const Text(
                            'Hazırlanışı',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          ...List.from(tarif['hazirlanis'] ?? [])
                              .asMap()
                              .entries
                              .map(
                                (entry) => Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 8),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        width: 24,
                                        height: 24,
                                        decoration: BoxDecoration(
                                          color: Colors.red[900],
                                          shape: BoxShape.circle,
                                        ),
                                        child: Center(
                                          child: Text(
                                            '${entry.key + 1}',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          entry.value,
                                          style: const TextStyle(fontSize: 16),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                          const SizedBox(height: 24),
                          ExpansionTile(
                            title: const Text(
                              'Yorumlar',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            initiallyExpanded: true,
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(16),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: TextField(
                                        controller: _yorumController,
                                        decoration: const InputDecoration(
                                          hintText: 'Yorum yaz...',
                                          border: OutlineInputBorder(),
                                        ),
                                        maxLines: null,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    IconButton(
                                      onPressed: _yorumEkle,
                                      icon: const Icon(Icons.send),
                                      color: Colors.red[900],
                                    ),
                                  ],
                                ),
                              ),
                              StreamBuilder<QuerySnapshot>(
                                stream: FirebaseFirestore.instance
                                    .collection('tarifler')
                                    .doc(widget.tarifId)
                                    .collection('yorumlar')
                                    .orderBy('tarih', descending: true)
                                    .snapshots(),
                                builder: (context, yorumSnapshot) {
                                  if (yorumSnapshot.hasError) {
                                    return const Center(
                                        child: Text('Yorumlar yüklenemedi'));
                                  }

                                  if (yorumSnapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return const Center(
                                        child: CircularProgressIndicator());
                                  }

                                  final yorumlar =
                                      yorumSnapshot.data?.docs ?? [];

                                  if (yorumlar.isEmpty) {
                                    return const Padding(
                                      padding: EdgeInsets.all(16),
                                      child: Text('Henüz yorum yapılmamış'),
                                    );
                                  }

                                  return Column(
                                    children: [
                                      ...yorumlar.map((yorum) {
                                        final yorumData = yorum.data()
                                            as Map<String, dynamic>;
                                        return YorumKarti(
                                          kullaniciAdi:
                                              yorumData['kullanici_adi'] ??
                                                  'Anonim',
                                          yorum: yorumData['yorum'] ?? '',
                                          tarih:
                                              (yorumData['tarih'] as Timestamp)
                                                  .toDate(),
                                          kullaniciId:
                                              yorumData['kullanici_id'],
                                          yorumId: yorum.id,
                                          onYorumSil: _yorumSil,
                                          onYorumDuzenle: _yorumDuzenle,
                                        );
                                      }).toList(),
                                    ],
                                  );
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
