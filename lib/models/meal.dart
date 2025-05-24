import 'package:flutter/foundation.dart';
import 'dart:math';

class Meal {
  final String id;
  final String name;
  final String description;
  final String category; // 'starter', 'main', 'dessert'
  final String? imageUrl;
  final String creatorId;
  final DateTime createdAt;
  final DateTime? lastUsed;
  double averageRating;
  int ratingCount;
  final List<Map<String, dynamic>> ratings;

  Meal({
  String? id,
  required this.name,
  this.description = '',
  required this.category,
  this.imageUrl,
  required this.creatorId,
  DateTime? createdAt,
  this.lastUsed,
  this.averageRating = 0.0,
  this.ratingCount = 0,
  List<Map<String, dynamic>>? ratings,
})  : id = id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      createdAt = createdAt ?? DateTime.now(),
      ratings = ratings ?? [];


  // Simple constructor for basic meal creation (backward compatibility)
  factory Meal.simple({
    required String name,
    required String imageUrl,
    required String category,
  }) {
    return Meal(
      name: name,
      description: '',
      category: category,
      imageUrl: imageUrl,
      creatorId: 'system', // Default creator
    );
  }

  // Convert Meal to Map (for Firestore)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'category': category,
      'imageUrl': imageUrl,
      'creatorId': creatorId,
      'createdAt': createdAt.toIso8601String(),
      'lastUsed': lastUsed?.toIso8601String(),
      'averageRating': averageRating,
      'ratingCount': ratingCount,
      'ratings': ratings,
    };
  }

  // Create Meal from Map (from Firestore)
  factory Meal.fromMap(Map<String, dynamic> map) {
    // Get the imageUrl from the map
    final String? rawImageUrl = map['imageUrl'];
    final String category = map['category'] ?? 'other';
    
    // If imageUrl is null or empty, use a default image
    final String imageUrl = (rawImageUrl == null || rawImageUrl.isEmpty) 
        ? ""
        : rawImageUrl;
    
    debugPrint('Creating meal from map with imageUrl: ${imageUrl.substring(0, min(30, imageUrl.length))}...');
    
    return Meal(
      id: map['id'],
      name: map['name'] ?? 'Unknown',
      description: map['description'] ?? '',
      category: category,
      imageUrl: imageUrl,
      creatorId: map['creatorId'] ?? 'system',
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'])
          : DateTime.now(),
      lastUsed:
          map['lastUsed'] != null ? DateTime.parse(map['lastUsed']) : null,
      averageRating: (map['averageRating'] as num?)?.toDouble() ?? 0.0,
      ratingCount: (map['ratingCount'] as int?) ?? 0,
      ratings:
          (map['ratings'] as List<dynamic>?)?.cast<Map<String, dynamic>>() ??
              [],
    );
  }

  // Convert to JSON (for API calls)
  Map<String, dynamic> toJson() => toMap();

  // Create from JSON (from API calls)
  factory Meal.fromJson(Map<String, dynamic> json) => Meal.fromMap(json);

  // Helper for updates
  Meal copyWith({
    String? id,
    String? name,
    String? description,
    String? category,
    String? time,
    String? imageUrl,
    String? creatorId,
    DateTime? createdAt,
    DateTime? lastUsed,
    double? averageRating,
    int? ratingCount,
    List<Map<String, dynamic>>? ratings,
  }) {
    return Meal(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      category: category ?? this.category,
      imageUrl: imageUrl ?? this.imageUrl,
      creatorId: creatorId ?? this.creatorId,
      createdAt: createdAt ?? this.createdAt,
      lastUsed: lastUsed ?? this.lastUsed,
      averageRating: averageRating ?? this.averageRating,
      ratingCount: ratingCount ?? this.ratingCount,
      ratings: ratings ?? List.from(this.ratings),
    );
  }

  // Helper to get star rating (for UI)
  List<bool> getStarRating() {
    return List.generate(5, (index) => index < averageRating.round());
  }

  // Mark meal as used now
  Meal markAsUsed() {
    return copyWith(lastUsed: DateTime.now());
  }

  // Add or update a rating
  void updateRating(double newRating, String userId, {String? comment}) {
    // Remove existing rating from this user if it exists
    ratings.removeWhere((rating) => rating['userId'] == userId);

    // Add new rating
    ratings.add({
      'rating': newRating,
      'userId': userId,
      'comment': comment,
      'timestamp': DateTime.now().toIso8601String(),
    });

    // Recalculate average rating
    _calculateAverageRating();
  }

  // Edit a review
  void editReview(String userId, double newRating, {String? newComment}) {
    final reviewIndex = ratings.indexWhere((rating) => rating['userId'] == userId);
    if (reviewIndex != -1) {
      ratings[reviewIndex]['rating'] = newRating;
      if (newComment != null) {
        ratings[reviewIndex]['comment'] = newComment;
      }
      _calculateAverageRating();
    }
  }

  // Delete a review
  void deleteReview(String userId) {
    ratings.removeWhere((rating) => rating['userId'] == userId);
    _calculateAverageRating();
  }

  // Calculate average rating
  void _calculateAverageRating() {
    if (ratings.isEmpty) {
      averageRating = 0.0;
      ratingCount = 0;
      return;
    }

    final total = ratings.fold(
        0.0, (sum, rating) => sum + (rating['rating'] as num).toDouble());
    averageRating = total / ratings.length;
    ratingCount = ratings.length;
  }

  // Get a user's rating if it exists
  double? getUserRating(String userId) {
    try {
      final rating = ratings.firstWhere((r) => r['userId'] == userId);
      return (rating['rating'] as num).toDouble();
    } catch (e) {
      return null;
    }
  }

  // Helper to get day name from weekday number
  static String _getDayName(int weekday) {
    const days = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday'
    ];
    return days[weekday - 1];
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Meal &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          description == other.description &&
          category == other.category &&
          imageUrl == other.imageUrl &&
          creatorId == other.creatorId;

  @override
  int get hashCode =>
      id.hashCode ^
      name.hashCode ^
      description.hashCode ^
      category.hashCode ^
      imageUrl.hashCode ^
      creatorId.hashCode;

  
}
