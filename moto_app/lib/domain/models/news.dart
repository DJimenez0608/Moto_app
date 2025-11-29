import 'package:intl/intl.dart';

class News {
  News({
    required this.title,
    required this.link,
    required this.thumbnailSmall,
    required this.date,
  });

  final String title;
  final String link;
  final String thumbnailSmall;
  final DateTime date;

  String get formattedDate => DateFormat('dd/MM/yyyy').format(date);

  factory News.fromJson(Map<String, dynamic> json) {
    DateTime parsedDate;

    // Preferir iso_date si está disponible
    if (json['iso_date'] != null) {
      parsedDate = DateTime.parse(json['iso_date'] as String);
    } else if (json['date'] != null) {
      // Parsear formato "11/12/2024, 09:03 AM, +0200 EET"
      final dateString = json['date'] as String;
      try {
        // Intentar extraer la parte de fecha "11/12/2024"
        final datePart = dateString.split(',').first.trim();
        final parts = datePart.split('/');
        if (parts.length == 3) {
          final month = int.parse(parts[0]);
          final day = int.parse(parts[1]);
          final year = int.parse(parts[2]);
          parsedDate = DateTime(year, month, day);
        } else {
          parsedDate = DateTime.now();
        }
      } catch (e) {
        parsedDate = DateTime.now();
      }
    } else {
      parsedDate = DateTime.now();
    }

    return News(
      title: json['title'] as String? ?? '',
      link: json['link'] as String? ?? '',
      thumbnailSmall: json['thumbnail_small'] as String? ?? '',
      date: parsedDate,
    );
  }
}

