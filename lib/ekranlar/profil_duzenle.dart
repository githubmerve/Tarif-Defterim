import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfilDuzenle extends StatefulWidget {
  const ProfilDuzenle({super.key});

  @override
  State<ProfilDuzenle> createState() => _ProfilDuzenleState();
}

class _ProfilDuzenleState extends State<ProfilDuzenle> {
  final _formKey = GlobalKey<FormState>();
  final _adController = TextEditingController();
  final _profilResmiController = TextEditingController();
  bool _yukleniyor = false;

  @override
  void initState() {
    super.initState();
    _kullaniciBilgileriniYukle();
  }

  Future<void> _kullaniciBilgileriniYukle() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance
          .collection('kullanicilar')
          .doc(user.uid)
          .get();

      if (mounted) {
        setState(() {
          if (doc.exists) {
            _adController.text = doc.data()?['ad'] ?? user.displayName ?? '';
            _profilResmiController.text = doc.data()?['profil_resmi'] ?? '';
          } else {
            _adController.text = user.displayName ?? '';
            _profilResmiController.text = '';
          }
        });
      }
    }
  }

  Future<void> _profilGuncelle() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _yukleniyor = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('Kullanıcı girişi yapılmamış');

      final ad = _adController.text.trim();

      // Firebase Auth'da ismi günceller
      await user.updateDisplayName(ad);

      // Firestore'da kullanıcı bilgilerini günceller
      await FirebaseFirestore.instance
          .collection('kullanicilar')
          .doc(user.uid)
          .set({
        'ad': ad,
        'profil_resmi': _profilResmiController.text.trim(),
        'guncelleme_tarihi': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profil başarıyla güncellendi'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Profil güncellenirken bir hata oluştu: $e'),
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
  void dispose() {
    _adController.dispose();
    _profilResmiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Profili Düzenle',
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
            children: [
              // Profil Resmi Önizleme
              if (_profilResmiController.text.isNotEmpty) ...[
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.grey),
                  ),
                  child: ClipOval(
                    child: Image.network(
                      _profilResmiController.text,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey[200],
                          child:
                              Icon(Icons.error_outline, color: Colors.red[900]),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Profil Resmi URL
              TextFormField(
                controller: _profilResmiController,
                decoration: InputDecoration(
                  labelText: 'Profil Resmi URL',
                  hintText: 'Resmin direkt linkini girin',
                  border: const OutlineInputBorder(),
                  suffixIcon: _profilResmiController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () => setState(() {
                            _profilResmiController.clear();
                          }),
                        )
                      : null,
                ),
                onChanged: (value) => setState(() {}),
              ),
              const SizedBox(height: 16),

              // Ad Soyad Alanı
              TextFormField(
                controller: _adController,
                decoration: const InputDecoration(
                  labelText: 'Ad Soyad',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Ad Soyad boş bırakılamaz';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Kaydet Butonu
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _yukleniyor ? null : _profilGuncelle,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red[900],
                    foregroundColor: Colors.white,
                  ),
                  child: _yukleniyor
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Değişiklikleri Kaydet'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
