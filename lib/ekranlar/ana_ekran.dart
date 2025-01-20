import 'package:flutter/material.dart';
import 'favoriler.dart';
import 'profil.dart';
import '../widgets/kategori_karti.dart';
import 'tarif_ekle.dart';

class AnaEkran extends StatefulWidget {
  const AnaEkran({super.key});

  @override
  State<AnaEkran> createState() => _AnaEkranState();
}

class _AnaEkranState extends State<AnaEkran> {
  int _secilenIndeks = 0;

  final List<Widget> _sayfalar = [
    const _AnaSayfa(),
    const TarifEkle(),
    const Favoriler(),
    const Profil(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _secilenIndeks == 0
          ? AppBar(
              title: const Text(
                'Tarif Defterim',
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
              actions: const [],
            )
          : null,
      body: _sayfalar[_secilenIndeks],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 0,
              blurRadius: 10,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(20),
          ),
          child: BottomNavigationBar(
            currentIndex: _secilenIndeks,
            onTap: (indeks) {
              setState(() {
                _secilenIndeks = indeks;
              });
            },
            type: BottomNavigationBarType.fixed,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: 'Ana Sayfa',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.add_circle_outline),
                label: 'Tarif Ekle',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.favorite),
                label: 'Favoriler',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person),
                label: 'Profil',
              ),
            ],
            selectedItemColor: Colors.red[900],
            unselectedItemColor: Colors.grey,
            showUnselectedLabels: true,
          ),
        ),
      ),
    );
  }
}

class _AnaSayfa extends StatelessWidget {
  const _AnaSayfa();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Arka plan resmi ekledim
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
        // Ana içerik
        CustomScrollView(
          slivers: [
            const SliverPadding(
              padding: EdgeInsets.all(16),
              sliver: SliverToBoxAdapter(
                child: Text(
                  'Kategoriler',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 1.2,
                ),
                delegate: SliverChildListDelegate([
                  const KategoriKarti(
                    baslik: 'Çorba',
                    ikon: Icons.soup_kitchen,
                    kategoriAdi: 'Çorba',
                  ),
                  const KategoriKarti(
                    baslik: 'Bakliyat',
                    ikon: Icons.grain,
                    kategoriAdi: 'Bakliyat',
                  ),
                  const KategoriKarti(
                    baslik: 'Sebze',
                    ikon: Icons.eco,
                    kategoriAdi: 'Sebze',
                  ),
                  const KategoriKarti(
                    baslik: 'Et',
                    ikon: Icons.restaurant_menu,
                    kategoriAdi: 'Et',
                  ),
                  const KategoriKarti(
                    baslik: 'Hamur İşi',
                    ikon: Icons.bakery_dining,
                    kategoriAdi: 'Hamur İşi',
                  ),
                  const KategoriKarti(
                    baslik: 'Hızlı',
                    ikon: Icons.timer,
                    kategoriAdi: 'Hızlı',
                  ),
                  const KategoriKarti(
                    baslik: 'Bebek',
                    ikon: Icons.child_care,
                    kategoriAdi: 'Bebek',
                  ),
                  const KategoriKarti(
                    baslik: 'Kahvaltı',
                    ikon: Icons.free_breakfast,
                    kategoriAdi: 'Kahvaltı',
                  ),
                  const KategoriKarti(
                    baslik: 'Kurabiye',
                    ikon: Icons.cookie,
                    kategoriAdi: 'Kurabiye',
                  ),
                  const KategoriKarti(
                    baslik: 'Makarna',
                    ikon: Icons.ramen_dining,
                    kategoriAdi: 'Makarna',
                  ),
                  const KategoriKarti(
                    baslik: 'Salata',
                    ikon: Icons.local_dining,
                    kategoriAdi: 'Salata',
                  ),
                  const KategoriKarti(
                    baslik: 'Dolma',
                    ikon: Icons.lunch_dining,
                    kategoriAdi: 'Dolma',
                  ),
                  const KategoriKarti(
                    baslik: 'Tatlı',
                    ikon: Icons.cake,
                    kategoriAdi: 'Tatlı',
                  ),
                ]),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
