import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Profil extends StatelessWidget {
  const Profil({super.key});

  Future<void> _cikisYap(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    if (context.mounted) {
      Navigator.pushReplacementNamed(context, '/giris');
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Profil'),
          backgroundColor: Colors.red[900],
          foregroundColor: Colors.white,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.account_circle, size: 100, color: Colors.grey[400]),
              const SizedBox(height: 16),
              Text(
                'Profili görüntülemek için giriş yapın',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.pushNamed(context, '/giris'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red[900],
                  foregroundColor: Colors.white,
                ),
                child: const Text('Giriş Yap'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Profilim',
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
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Profil Bilgileri
            StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('kullanicilar')
                  .doc(user.uid)
                  .snapshots(),
              builder: (context, snapshot) {
                String? profilResmi;

                if (snapshot.hasData && snapshot.data!.exists) {
                  final data = snapshot.data!.data() as Map<String, dynamic>?;
                  profilResmi = data?['profil_resmi'] as String?;
                }

                return Column(
                  children: [
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.grey),
                      ),
                      child: ClipOval(
                        child: profilResmi != null && profilResmi.isNotEmpty
                            ? Image.network(
                                profilResmi,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    color: Colors.red[100],
                                    child: Icon(Icons.person,
                                        size: 50, color: Colors.red[900]),
                                  );
                                },
                              )
                            : Container(
                                color: Colors.red[100],
                                child: Icon(Icons.person,
                                    size: 50, color: Colors.red[900]),
                              ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      user.displayName ??
                          user.email?.split('@')[0] ??
                          'İsimsiz Kullanıcı',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      user.email ?? '',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 32),

            // HESAP Kategorisi
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.only(left: 16, bottom: 8),
                child: Text(
                  'HESAP',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            ListTile(
              tileColor: Colors.white,
              selectedTileColor: Colors.red[50],
              leading: const Icon(Icons.edit, color: Colors.red),
              title: const Text('Profilimi Düzenle'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.pushNamed(context, '/profil_duzenle'),
            ),
            ListTile(
              tileColor: Colors.white,
              selectedTileColor: Colors.red[50],
              leading: const Icon(Icons.favorite, color: Colors.red),
              title: const Text('Favorilerim'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.pushNamed(context, '/favoriler'),
            ),
            ListTile(
              tileColor: Colors.white,
              selectedTileColor: Colors.red[50],
              leading: const Icon(Icons.restaurant_menu, color: Colors.red),
              title: const Text('Tariflerim'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.pushNamed(context, '/kendi_tariflerim'),
            ),
            const Divider(),
            // YARDIM VE GERİ BİLDİRİM Kategorisi
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.only(left: 16, bottom: 8, top: 8),
                child: Text(
                  'YARDIM VE GERİ BİLDİRİM',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            ListTile(
              tileColor: Colors.white,
              selectedTileColor: Colors.red[50],
              leading: const Icon(Icons.help_outline, color: Colors.red),
              title: const Text('Destek'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Destek'),
                    content: const Text(
                        'Bu uygulama, Yönetim Bilişim Sistemleri 3. sınıf öğrencisi Merve Subaşı tarafından Mobil Programlama dersi kapsamında geliştirilmiştir.\n\n'
                        'Herhangi bir sorunuz veya geri bildiriminiz için mervesubasi67@gmail.com adresinden bana ulaşabilirsiniz.\n\n'
                        'Teşekkürler! 😊'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Tamam'),
                      ),
                    ],
                  ),
                );
              },
            ),
            ListTile(
              tileColor: Colors.white,
              selectedTileColor: Colors.red[50],
              leading:
                  const Icon(Icons.description_outlined, color: Colors.red),
              title: const Text('Kullanım Koşulları'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    backgroundColor: Colors.white,
                    title: const Text('Kullanım Koşulları'),
                    content: SingleChildScrollView(
                      child: const Text(
                        'Tarif Defterim Uygulaması Kullanım Koşulları\n\n'
                        '1. Uygulama kullanımı ücretsizdir.\n'
                        '2. Paylaşılan tariflerin sorumluluğu kullanıcıya aittir.\n'
                        '3. Uygunsuz içerikler kaldırılacaktır.\n'
                        '4. Kullanıcı bilgileri gizli tutulacaktır.\n'
                        '5. Uygulama güncellemeleri yapılabilir.',
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Anladım'),
                      ),
                    ],
                  ),
                );
              },
            ),
            const Divider(),
            ListTile(
              tileColor: Colors.white,
              selectedTileColor: Colors.red[50],
              leading: const Icon(Icons.exit_to_app, color: Colors.red),
              title: const Text('Çıkış Yap'),
              onTap: () => _cikisYap(context),
            ),
          ],
        ),
      ),
    );
  }
}
