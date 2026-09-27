import 'package:equatable/equatable.dart';

/// A lightweight, self-contained snapshot of a chalet or building saved to
/// favorites — enough to render a card in the Favorites tab and navigate to
/// the detail page, without needing another network call. Synced with the
/// backend (see FavoritesService) so favorites persist across devices and
/// reinstalls; this class itself is unchanged from when it was purely
/// local, since the API shares the same flat shape.
class FavoriteItem extends Equatable {
  final String id;
  final String type; // 'chalet' or 'building'
  final String name;
  final String image;
  final String price;
  final String location;
  final double? rating;

  const FavoriteItem({
    required this.id,
    required this.type,
    required this.name,
    required this.image,
    required this.price,
    required this.location,
    this.rating,
  });

  /// Unique key across both chalets and buildings — a chalet and a building
  /// that happen to share a numeric id must never collide.
  String get key => '${type}_$id';

  bool get isChalet => type == 'chalet';

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type,
        'name': name,
        'image': image,
        'price': price,
        'location': location,
        'rating': rating,
      };

  factory FavoriteItem.fromJson(Map<String, dynamic> json) => FavoriteItem(
        id: '${json['id']}',
        type: '${json['type']}',
        name: '${json['name'] ?? ''}',
        image: '${json['image'] ?? ''}',
        price: '${json['price'] ?? ''}',
        location: '${json['location'] ?? ''}',
        rating: json['rating'] is num ? (json['rating'] as num).toDouble() : null,
      );

  @override
  List<Object?> get props => [id, type, name, image, price, location, rating];
}
