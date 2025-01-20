import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:firebase_auth/firebase_auth.dart';

class YorumKarti extends StatelessWidget {
  final String kullaniciAdi;
  final String yorum;
  final DateTime tarih;
  final String kullaniciId;
  final String yorumId;
  final Function(String) onYorumSil;
  final Function(String, String) onYorumDuzenle;

  const YorumKarti({
    super.key,
    required this.kullaniciAdi,
    required this.yorum,
    required this.tarih,
    required this.kullaniciId,
    required this.yorumId,
    required this.onYorumSil,
    required this.onYorumDuzenle,
  });

  void _yorumDuzenle(BuildContext context) {
    final textController = TextEditingController(text: yorum);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Yorumu Düzenle'),
        content: TextField(
          controller: textController,
          decoration: const InputDecoration(
            hintText: 'Yorumunuzu düzenleyin',
            border: OutlineInputBorder(),
          ),
          maxLines: null,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () {
              if (textController.text.trim().isNotEmpty) {
                onYorumDuzenle(yorumId, textController.text.trim());
                Navigator.pop(context);
              }
            },
            child: const Text('Kaydet'),
          ),
        ],
      ),
    );
  }

  void _yorumSil(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Yorumu Sil'),
        content: const Text('Bu yorumu silmek istediğinizden emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () {
              onYorumSil(yorumId);
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Sil'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;
    final isYorumSahibi = currentUser?.uid == kullaniciId;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 0),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.red[900],
                  radius: 16,
                  child: Text(
                    kullaniciAdi[0].toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        kullaniciAdi,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        timeago.format(tarih, locale: 'tr'),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                if (isYorumSahibi) ...[
                  IconButton(
                    icon: const Icon(Icons.edit, size: 20),
                    onPressed: () => _yorumDuzenle(context),
                    color: Colors.grey[600],
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, size: 20),
                    onPressed: () => _yorumSil(context),
                    color: Colors.red[900],
                  ),
                ],
              ],
            ),
            const SizedBox(height: 8),
            Text(yorum),
          ],
        ),
      ),
    );
  }
}
