import 'dart:io';
import 'dart:convert';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:menu_planner/models/meal.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

class MealService {
  final FirebaseFirestore _firestore;

  MealService() : _firestore = FirebaseFirestore.instance;

  CollectionReference get _mealsRef => _firestore.collection('meals');

  Future<String> addMeal(Meal meal, {dynamic imageFile}) async {
    try {
      final docRef = _mealsRef.doc();
      String? imageBase64;

      // If an image was uploaded, compress it and convert to base64
      if (imageFile != null) {
        try {
          // Get the file path
          String filePath;
          if (imageFile is XFile) {
            filePath = imageFile.path;
          } else if (imageFile is File) {
            filePath = imageFile.path;
          } else {
            throw Exception(
                'Unsupported image file type: ${imageFile.runtimeType}');
          }

          debugPrint('Processing image file: $filePath');

          // Compress the image
          final compressedBytes = await _compressImage(File(filePath));
          debugPrint('Image compressed, size: ${compressedBytes.length} bytes');

          // Convert to base64 and create data URL
          final base64String = base64Encode(compressedBytes);
          imageBase64 = 'data:image/jpeg;base64,$base64String';
          debugPrint(
              'Successfully converted image to base64 string, length: ${base64String.length}');

          // Check if the base64 string is too large (close to 1MB)
          if (base64String.length > 900000) {
            debugPrint(
                'Image still too large after compression (${base64String.length} bytes), using default image');
            imageBase64 = null;
          }
        } catch (e) {
          debugPrint('Error processing image: $e');
          // Continue without the image if processing fails
        }
      }

      // Create a new meal with the document ID and image base64
      final mealWithId = meal.copyWith(
        id: docRef.id,
        imageUrl: imageBase64 ?? null,
      );

      // Safely log the image URL (truncate if needed)
      final imageUrlLog = mealWithId.imageUrl ?? '';
      final truncatedUrl = imageUrlLog.length > 30
          ? '${imageUrlLog.substring(0, 30)}...'
          : imageUrlLog;
      debugPrint(
          'Adding meal with ID: ${mealWithId.id} and image URL: $truncatedUrl');

      await docRef.set(mealWithId.toMap());
      return docRef.id;
    } catch (e) {
      debugPrint('Error adding meal: $e');
      throw Exception('Failed to add meal: $e');
    }
  }

  // Helper method to compress an image
  Future<Uint8List> _compressImage(File imageFile) async {
    try {
      // Read the image file
      final bytes = await imageFile.readAsBytes();

      // Compress the image
      final compressedBytes = await FlutterImageCompress.compressWithList(
        bytes,
        minHeight: 800,
        minWidth: 800,
        quality: 70,
      );

      return compressedBytes;
    } catch (e) {
      debugPrint('Error compressing image: $e');
      // If compression fails, return the original bytes
      return await imageFile.readAsBytes();
    }
  }

  

  // Get all meals
  Future<List<Meal>> getMeals() async {
    try {
      final snapshot = await _mealsRef.get();
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return Meal.fromMap(data);
      }).toList();
    } catch (e) {
      debugPrint('Error getting meals: $e');
      throw Exception('Failed to get meals: $e');
    }
  }

  // Get meals by category
  Future<List<Meal>> getMealsByCategory(String category) async {
    try {
      final snapshot =
          await _mealsRef.where('category', isEqualTo: category).get();
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return Meal.fromMap(data);
      }).toList();
    } catch (e) {
      debugPrint('Error getting meals by category: $e');
      throw Exception('Failed to get meals by category: $e');
    }
  }

  // Get user meals
  Future<List<Meal>> getUserMeals(String userId) async {
    try {
      final snapshot =
          await _mealsRef.where('creatorId', isEqualTo: userId).get();
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>; // Explicit cast
        return Meal.fromMap(data);
      }).toList();
    } catch (e) {
      throw Exception('Failed to get user meals: $e');
    }
  }

  // Get random meal
  Future<Meal> getRandomMeal(String category) async {
    try {
      // First get a random index
      final countQuery =
          await _mealsRef.where('category', isEqualTo: category).count().get();

      final count = countQuery.count;
      if (count == 0) throw Exception('No meals in category $category');

      final randomIndex = Random().nextInt(count!);

      // Get all documents and select the random one
      final snapshot =
          await _mealsRef.where('category', isEqualTo: category).get();

      if (snapshot.docs.isEmpty) {
        throw Exception('No meals found after query');
      }

      // Safely get the random document
      final randomDoc = snapshot.docs[randomIndex % snapshot.docs.length];
      return Meal.fromMap(randomDoc.data() as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Failed to get random meal: $e');
    }
  }

  // Get meal history
  Future<List<Meal>> getMealHistory() async {
    try {
      final snapshot =
          await _mealsRef.orderBy('lastUsed', descending: true).limit(50).get();
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>; // Explicit cast
        return Meal.fromMap(data);
      }).toList();
    } catch (e) {
      throw Exception('Failed to get meal history: $e');
    }
  }

  // Update meal
  Future<void> updateMeal(Meal meal, {File? imageFile}) async {
    try {
      debugPrint('Updating meal: ${meal.name} with ID: ${meal.id}');

      // If there's a new image, process it first
      String? imageUrl = meal.imageUrl;
      if (imageFile != null) {
        debugPrint('Processing new image for meal: ${meal.name}');

        // Compress the image to reduce size
        final compressedBytes = await _compressImage(imageFile);
        debugPrint('Image compressed, size: ${compressedBytes.length} bytes');

        // Convert to base64 and create data URL
        final base64String = base64Encode(compressedBytes);
        imageUrl = 'data:image/jpeg;base64,$base64String';

        debugPrint(
            'Image processed and converted to base64, length: ${base64String.length}');
      } else {
        // If no new image is provided, keep the existing image URL
        debugPrint(
            'No new image provided, keeping existing image URL: ${meal.imageUrl?.substring(0, min(30, meal.imageUrl?.length ?? 0))}...');
      }

      // Create a map of the meal data with the image URL
      final mealData = {
        'id': meal.id,
        'name': meal.name,
        'description': meal.description,
        'category': meal.category,
        'imageUrl': imageUrl ??
            meal.imageUrl ??
            null,
        'creatorId': meal.creatorId,
        'createdAt': meal.createdAt.toIso8601String(),
        'lastUsed': meal.lastUsed?.toIso8601String(),
        'averageRating': meal.averageRating,
        'ratingCount': meal.ratingCount,
        'ratings': meal.ratings,
      };

      // Check if the document exists
      final docRef = _firestore.collection('meals').doc(meal.id);
      final docSnapshot = await docRef.get();

      if (docSnapshot.exists) {
        // Update the existing document
        debugPrint('Document exists, updating meal: ${meal.name}');
        await docRef.update(mealData);
        debugPrint('Meal updated successfully: ${meal.name}');
      } else {
        // Create a new document with the same ID
        debugPrint('Document does not exist, creating new meal: ${meal.name}');
        await docRef.set(mealData);
        debugPrint('New meal created successfully: ${meal.name}');
      }

      // Verify the update by reading the document back
      final updatedDoc = await docRef.get();
      if (updatedDoc.exists) {
        final updatedData = updatedDoc.data() as Map<String, dynamic>;
        debugPrint(
            'Verified update - Meal data: ${updatedData['name']}, Image URL: ${updatedData['imageUrl']?.toString().substring(0, min(30, updatedData['imageUrl'].toString().length))}...');
      } else {
        debugPrint(
            'Warning: Could not verify update - Document not found after update');
      }

      // Update all daily menus that reference this meal
      await _updateDailyMenusWithMeal(
          meal.copyWith(imageUrl: imageUrl ?? meal.imageUrl));
    } catch (e) {
      debugPrint('Error in updateMeal: $e');
      throw Exception('Failed to update meal: $e');
    }
  }

  // Helper method to update all daily menus that reference a meal
  Future<void> _updateDailyMenusWithMeal(Meal updatedMeal) async {
    try {
      debugPrint('Updating daily menus that reference meal: ${updatedMeal.id}');

      // Get all users
      final usersSnapshot = await _firestore.collection('users').get();

      for (final userDoc in usersSnapshot.docs) {
        final userId = userDoc.id;
        debugPrint('Checking daily menus for user: $userId');

        // Get all daily menus for this user
        final dailyMenusRef = _firestore
            .collection('users')
            .doc(userId)
            .collection('daily_menus');
        final dailyMenusSnapshot = await dailyMenusRef.get();

        int updatedCount = 0;

        for (final menuDoc in dailyMenusSnapshot.docs) {
          final menuData = menuDoc.data();
          bool menuUpdated = false;

          // Create a map of the updated meal data
          final updatedMealData = updatedMeal.toMap();

          // Check lunch meals
          if (menuData['lunch'] != null) {
            final lunchMeals = (menuData['lunch'] as List<dynamic>)
                .cast<Map<String, dynamic>>();
            for (int i = 0; i < lunchMeals.length; i++) {
              if (lunchMeals[i]['id'] == updatedMeal.id) {
                // Replace the meal with the updated version
                lunchMeals[i] = updatedMealData;
                menuUpdated = true;
                debugPrint('Updated meal in lunch for menu: ${menuDoc.id}');
              }
            }
            if (menuUpdated) {
              menuData['lunch'] = lunchMeals;
            }
          }

          // Check dinner meals
          if (menuData['dinner'] != null) {
            final dinnerMeals = (menuData['dinner'] as List<dynamic>)
                .cast<Map<String, dynamic>>();
            for (int i = 0; i < dinnerMeals.length; i++) {
              if (dinnerMeals[i]['id'] == updatedMeal.id) {
                // Replace the meal with the updated version
                dinnerMeals[i] = updatedMealData;
                menuUpdated = true;
                debugPrint('Updated meal in dinner for menu: ${menuDoc.id}');
              }
            }
            if (menuUpdated) {
              menuData['dinner'] = dinnerMeals;
            }
          }

          // Update the menu if it was modified
          if (menuUpdated) {
            await dailyMenusRef.doc(menuDoc.id).update(menuData);
            updatedCount++;
            debugPrint('Updated daily menu: ${menuDoc.id}');
          }
        }

        debugPrint('Updated $updatedCount daily menus for user: $userId');
      }

      debugPrint('Finished updating daily menus for meal: ${updatedMeal.id}');
    } catch (e) {
      debugPrint('Error updating daily menus: $e');
      // Don't throw an exception here, as we don't want to fail the meal update
      // if the daily menu update fails
    }
  }

  // Delete meal
  Future<void> deleteMeal(String mealId) async {
    try {
      debugPrint('Deleting meal with ID: $mealId');

      // First, remove this meal from all daily menus
      final usersSnapshot = await _firestore.collection('users').get();

      for (final userDoc in usersSnapshot.docs) {
        final userId = userDoc.id;
        debugPrint('Checking daily menus for user: $userId');

        // Get all daily menus for this user
        final dailyMenusRef = _firestore
            .collection('users')
            .doc(userId)
            .collection('daily_menus');
        final dailyMenusSnapshot = await dailyMenusRef.get();

        int updatedCount = 0;

        for (final menuDoc in dailyMenusSnapshot.docs) {
          final menuData = menuDoc.data();
          bool menuUpdated = false;

          // Check lunch meals
          if (menuData['lunch'] != null) {
            final lunchMeals = (menuData['lunch'] as List<dynamic>)
                .cast<Map<String, dynamic>>();
            final updatedLunchMeals =
                lunchMeals.where((meal) => meal['id'] != mealId).toList();
            if (updatedLunchMeals.length != lunchMeals.length) {
              menuData['lunch'] = updatedLunchMeals;
              menuUpdated = true;
              debugPrint('Removed meal from lunch for menu: ${menuDoc.id}');
            }
          }

          // Check dinner meals
          if (menuData['dinner'] != null) {
            final dinnerMeals = (menuData['dinner'] as List<dynamic>)
                .cast<Map<String, dynamic>>();
            final updatedDinnerMeals =
                dinnerMeals.where((meal) => meal['id'] != mealId).toList();
            if (updatedDinnerMeals.length != dinnerMeals.length) {
              menuData['dinner'] = updatedDinnerMeals;
              menuUpdated = true;
              debugPrint('Removed meal from dinner for menu: ${menuDoc.id}');
            }
          }

          // Update the menu if it was modified
          if (menuUpdated) {
            await dailyMenusRef.doc(menuDoc.id).update(menuData);
            updatedCount++;
            debugPrint('Updated daily menu: ${menuDoc.id}');
          }
        }

        debugPrint('Updated $updatedCount daily menus for user: $userId');
      }

      // Now delete the meal document
      await _firestore.collection('meals').doc(mealId).delete();
      debugPrint('Successfully deleted meal: $mealId');
    } catch (e) {
      debugPrint('Error deleting meal: $e');
      throw Exception('Failed to delete meal: $e');
    }
  }

  // Get meal by ID
  Future<Meal> getMealById(String mealId) async {
    try {
      final doc = await _mealsRef.doc(mealId).get();
      if (!doc.exists) {
        throw Exception('Meal not found');
      }
      return Meal.fromMap(doc.data() as Map<String, dynamic>);
    } catch (e) {
      debugPrint('Error getting meal by ID: $e');
      throw Exception('Failed to get meal: $e');
    }
  }

  // Add to meal_service.dart
  Future<bool> mealExists(String mealId) async {
    try {
      final doc = await _mealsRef.doc(mealId).get();
      return doc.exists;
    } catch (e) {
      debugPrint('Error checking if meal exists: $e');
      return false;
    }
  }

  Future<void> savePredefinedMeal(Meal meal) async {
    try {
      // Only save if doesn't exist
      if (!await mealExists(meal.id)) {
        await _mealsRef.doc(meal.id).set(meal.toMap());
        debugPrint('Saved predefined meal: ${meal.name} (ID: ${meal.id})');
      }
    } catch (e) {
      debugPrint('Error saving predefined meal: $e');
      throw Exception('Failed to save predefined meal: $e');
    }
  }
}
