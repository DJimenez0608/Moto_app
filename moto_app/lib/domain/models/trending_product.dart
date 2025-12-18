class TrendingProduct {
  TrendingProduct({
    required this.title,
    required this.thumbnail,
    this.rating,
    this.reviews,
    this.price,
    this.link,
  });

  final String title;
  final String thumbnail;
  final double? rating;
  final int? reviews;
  final String? price;
  final String? link;

  factory TrendingProduct.fromJson(Map<String, dynamic> json) {
    // Parsear rating - puede venir como double, int, o string
    double? parsedRating;
    if (json['rating'] != null) {
      if (json['rating'] is num) {
        parsedRating = (json['rating'] as num).toDouble();
      } else if (json['rating'] is String) {
        parsedRating = double.tryParse(json['rating'] as String);
      }
    }

    // Parsear reviews - puede venir como int o string
    int? parsedReviews;
    if (json['reviews'] != null) {
      if (json['reviews'] is int) {
        parsedReviews = json['reviews'] as int;
      } else if (json['reviews'] is String) {
        parsedReviews = int.tryParse(json['reviews'] as String);
      }
    }

    return TrendingProduct(
      title: json['title'] as String? ?? '',
      thumbnail: json['thumbnail'] as String? ?? '',
      rating: parsedRating,
      reviews: parsedReviews,
      price: json['price'] as String?,
      link: json['link'] as String?,
    );
  }
}

