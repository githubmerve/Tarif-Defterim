import 'package:flutter/material.dart';

class KategoriKarti extends StatefulWidget {
  final String baslik;
  final IconData ikon;
  final String kategoriAdi;

  const KategoriKarti({
    super.key,
    required this.baslik,
    required this.ikon,
    required this.kategoriAdi,
  });

  @override
  State<KategoriKarti> createState() => _KategoriKartiState();
}

class _KategoriKartiState extends State<KategoriKarti> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => Navigator.pushNamed(
            context,
            '/kategori_detay',
            arguments: widget.kategoriAdi,
          ),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: _isHovered ? Colors.grey[100] : Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(_isHovered ? 0.3 : 0.2),
                  spreadRadius: _isHovered ? 2 : 1,
                  blurRadius: _isHovered ? 6 : 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  widget.ikon,
                  size: 48,
                  color: Colors.red[900],
                ),
                const SizedBox(height: 8),
                Text(
                  widget.baslik,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
