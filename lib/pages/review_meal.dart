import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:menu_planner/models/meal.dart';
import 'package:menu_planner/pages/favorites.dart';
import 'package:menu_planner/pages/review.dart';
import 'package:menu_planner/providers/menu_provider.dart';
import 'package:provider/provider.dart';
import 'package:menu_planner/services/auth.dart';

class ReviewMealPage extends StatefulWidget {
  final Meal meal;

  const ReviewMealPage({super.key, required this.meal});

  @override
  State<ReviewMealPage> createState() => _ReviewMealPageState();
}

class _ReviewMealPageState extends State<ReviewMealPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _commentController = TextEditingController();
  double _rating = 0;
  bool _isLoading = false;
  bool _isFavorite = false;

  @override
  void initState() {
    super.initState();
    _checkIfFavorite();
  }

  Future<void> _checkIfFavorite() async {
    final userId = Auth().firebaseUser?.uid;
    if (userId == null) return;

    final favoritesRef = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('favorites');

    final doc = await favoritesRef.doc(widget.meal.id).get();
    setState(() {
      _isFavorite = doc.exists;
    });
  }

  Future<void> _toggleFavorite() async {
    final userId = Auth().firebaseUser?.uid;
    if (userId == null) return;

    final favoritesRef = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('favorites');

    if (_isFavorite) {
      // Remove from favorites
      await favoritesRef.doc(widget.meal.id).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Meal removed from favorites')),
      );
    } else {
      // Add to favorites
      await favoritesRef.doc(widget.meal.id).set({'mealId': widget.meal.id});
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Meal added to favorites')),
      );
    }

    setState(() {
      _isFavorite = !_isFavorite;
    });

    // Navigate to the FavoritesPage
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FavoritesPage(userId: userId),
      ),
    );
  }

  Future<void> _submitReview() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final userId = Auth().firebaseUser?.uid;
        if (userId == null) {
          throw Exception('User not logged in');
        }

        final menuProvider = Provider.of<MenuProvider>(context, listen: false);

        // Add the rating
        await menuProvider.addRating(
          mealId: widget.meal.id,
          rating: _rating,
          userId: userId,
          comment: _commentController.text.isNotEmpty ? _commentController.text : null,
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Review submitted successfully')),
          );

          // Navigate to the reviews page
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const EvaluationScreen()),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error submitting review: $e')),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      backgroundColor: const Color(0xFFECECEC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFECECEC),
        toolbarHeight: MediaQuery.of(context).size.height * 0.15,
        automaticallyImplyLeading: false,
        title: const Text(
          'Rate this meal',
          style: TextStyle(
            color: Color(0xFF02197D),
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          // Favorite button
          GestureDetector(
            onTap: _toggleFavorite,
            child: Container(
              width: 40,
              height: 40,
              margin: const EdgeInsets.only(right: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 5,
                    spreadRadius: 1,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Center(
                child: Icon(
                  _isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: _isFavorite ? Colors.red : const Color(0xFFFFAC06),
                  size: 24,
                ),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Meal info
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 5,
                        spreadRadius: 1,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.meal.name,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF02197D),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.meal.description,
                        style: const TextStyle(
                          color: Color(0xFF9D9B9B),
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF1D4),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Text(
                          widget.meal.category.toUpperCase(),
                          style: const TextStyle(
                            color: Color(0xFFFFAA01),
                            fontWeight: FontWeight.w500,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Rating section
                const Text(
                  "How was this meal?",
                  style: TextStyle(
                    color: Color(0xFF9D9B9B),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 5,
                        spreadRadius: 1,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Your Rating",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFFFAC06),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(5, (index) {
                          return IconButton(
                            icon: Icon(
                              index < _rating ? Icons.star : Icons.star_border,
                              color: const Color(0xFFFFAC06),
                              size: 36,
                            ),
                            onPressed: () {
                              setState(() {
                                _rating = index + 1;
                              });
                            },
                          );
                        }),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Comment section
                const Text(
                  "Share your experience",
                  style: TextStyle(
                    color: Color(0xFF9D9B9B),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 5,
                        spreadRadius: 1,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Your Comment",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFFFAC06),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _commentController,
                        maxLines: 4,
                        style: const TextStyle(color: Color(0xFF9D9B9B)),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                              color: Color(0xFFFFAC06),
                              width: 2.0,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          hintText: "Share your thoughts about this meal...",
                          hintStyle: const TextStyle(color: Color(0xFF9D9B9B)),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),

                // Submit button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _submitReview,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFAC06),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      elevation: 3,
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            'Submit Review',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 70),
              ],
            ),
          ),
        ),
      ),
    );
  }
}