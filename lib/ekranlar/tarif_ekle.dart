import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TarifEkle extends StatefulWidget {
  const TarifEkle({super.key});

  @override
  State<TarifEkle> createState() => _TarifEkleState();
}

class _TarifEkleState extends State<TarifEkle> {
  final _formKey = GlobalKey<FormState>();
  final _baslikController = TextEditingController();
  final _aciklamaController = TextEditingController();
  final _hazirlamaSuresiController = TextEditingController();
  final _kisiSayisiController = TextEditingController();
  final _malzemelerController = TextEditingController();
  final _hazirlanisController = TextEditingController();
  final _resimUrlController = TextEditingController();
  String _secilenKategori = 'Çorba';
  bool _yukleniyor = false;

  final List<String> _kategoriler = [
    'Çorba',
    'Bakliyat',
    'Sebze',
    'Et',
    'Hamur İşi',
    'Hızlı',
    'Bebek',
    'Kahvaltı',
    'Kurabiye',
    'Makarna',
    'Salata',
    'Dolma',
    'Tatlı',
  ];

  Future<void> _tarifKaydet() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Resim URL'si boşsa onay al
    if (_resimUrlController.text.trim().isEmpty) {
      final onay = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Dikkat'),
          content: const Text(
              'Tarifi resim eklemeden kaydetmek istediğinize emin misiniz?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('İptal'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Evet, Resimsiz Kaydet'),
            ),
          ],
        ),
      );

      if (onay != true) {
        return;
      }
    }

    setState(() => _yukleniyor = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('Kullanıcı girişi yapılmamış');
      }

      await FirebaseFirestore.instance.collection('tarifler').add({
        'baslik': _baslikController.text.trim(),
        'aciklama': _aciklamaController.text.trim(),
        'hazirlama_suresi': int.tryParse(_hazirlamaSuresiController.text) ?? 0,
        'kisi_sayisi': int.tryParse(_kisiSayisiController.text) ?? 1,
        'malzemeler': _malzemelerController.text
            .split('\n')
            .where((m) => m.trim().isNotEmpty)
            .toList(),
        'hazirlanis': _hazirlanisController.text
            .split('\n')
            .where((h) => h.trim().isNotEmpty)
            .toList(),
        'kategori': _secilenKategori,
        'resimUrl': _resimUrlController.text.trim(),
        'ekleyen_id': user.uid,
        'ekleyen_ad': user.displayName,
        'ekleme_tarihi': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tarif başarıyla eklendi'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
        // Ana sayfaya dön
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/ana_ekran',
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Tarif eklenirken bir hata oluştu: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _yukleniyor = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Tarif Ekle',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        toolbarHeight: 80,
        centerTitle: true,
        backgroundColor: Colors.red[900],
        foregroundColor: Colors.white,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(20),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _resimUrlController,
                decoration: InputDecoration(
                  labelText: 'Resim URL',
                  hintText:
                      'Resmin direkt linkini girin (örn: https://i.ibb.co/xxx/resim.jpg)',
                  border: const OutlineInputBorder(),
                  suffixIcon: _resimUrlController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () => setState(() {
                            _resimUrlController.clear();
                          }),
                        )
                      : null,
                ),
                onChanged: (value) => setState(() {}),
              ),
              if (_resimUrlController.text.isNotEmpty) ...[
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  height: 200,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      _resimUrlController.text,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey[200],
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.error_outline,
                                  color: Colors.red[900], size: 48),
                              const SizedBox(height: 8),
                              const Text('Resim yüklenemedi'),
                              const SizedBox(height: 8),
                              const Text(
                                  'Geçerli bir resim URL\'si girdiğinizden emin olun'),
                            ],
                          ),
                        );
                      },
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          color: Colors.grey[200],
                          child: Center(
                            child: CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                      loadingProgress.expectedTotalBytes!
                                  : null,
                              color: Colors.red[900],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 16),
              TextFormField(
                controller: _baslikController,
                decoration: const InputDecoration(
                  labelText: 'Tarif Başlığı',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Başlık boş bırakılamaz';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _aciklamaController,
                decoration: const InputDecoration(
                  labelText: 'Tarif Açıklaması',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Açıklama boş bırakılamaz';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _hazirlamaSuresiController,
                      decoration: const InputDecoration(
                        labelText: 'Hazırlama Süresi (dk)',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Süre boş bırakılamaz';
                        }
                        if (int.tryParse(value) == null) {
                          return 'Geçerli bir sayı girin';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _kisiSayisiController,
                      decoration: const InputDecoration(
                        labelText: 'Kaç Kişilik',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Kişi sayısı boş bırakılamaz';
                        }
                        if (int.tryParse(value) == null) {
                          return 'Geçerli bir sayı girin';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _secilenKategori,
                decoration: const InputDecoration(
                  labelText: 'Kategori',
                  border: OutlineInputBorder(),
                ),
                items: _kategoriler.map((kategori) {
                  return DropdownMenuItem(
                    value: kategori,
                    child: Text(kategori),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _secilenKategori = value;
                    });
                  }
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _malzemelerController,
                decoration: const InputDecoration(
                  labelText: 'Malzemeler (Her satıra bir malzeme)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 5,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Malzemeler boş bırakılamaz';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _hazirlanisController,
                decoration: const InputDecoration(
                  labelText: 'Hazırlanış (Her satıra bir adım)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 5,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Hazırlanış boş bırakılamaz';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _yukleniyor ? null : _tarifKaydet,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red[900],
                    foregroundColor: Colors.white,
                  ),
                  child: _yukleniyor
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Tarifi Kaydet'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _baslikController.dispose();
    _aciklamaController.dispose();
    _hazirlamaSuresiController.dispose();
    _kisiSayisiController.dispose();
    _malzemelerController.dispose();
    _hazirlanisController.dispose();
    _resimUrlController.dispose();
    super.dispose();
  }
}
