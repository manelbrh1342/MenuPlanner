import 'package:flutter/material.dart';
import 'package:menu_planner/models/meal.dart';
import 'package:menu_planner/providers/menu_provider.dart';
import 'package:menu_planner/widget/appBar.dart';
import 'package:menu_planner/widget/edit_review_dialog.dart';
import 'package:provider/provider.dart';
import 'dart:convert';

class EvaluationScreen extends StatefulWidget {
  const EvaluationScreen({super.key});

  @override
  _EvaluationScreenState createState() => _EvaluationScreenState();
}

class _EvaluationScreenState extends State<EvaluationScreen>
    with TickerProviderStateMixin {
  bool _isLoading = true;
  Map<String, List<Meal>> _mealsByCategory = {};
  late TabController _tabController;
  final List<String> _categories = ['starter', 'main', 'dessert'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _categories.length, vsync: this);
    _loadReviews();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadReviews() async {
    final menuProvider = Provider.of<MenuProvider>(context, listen: false);
    setState(() => _isLoading = true);

    try {
      final meals = await menuProvider.getAllRatedMeals();

      _mealsByCategory = {
        'starter': meals.where((m) => m.category == 'starter').toList(),
        'main': meals.where((m) => m.category == 'main').toList(),
        'dessert': meals.where((m) => m.category == 'dessert').toList(),
      };

      _mealsByCategory.forEach((category, meals) {
        meals.sort((a, b) => b.averageRating.compareTo(a.averageRating));
      });

      for (int i = 0; i < _categories.length; i++) {
        if (_mealsByCategory[_categories[i]]!.isNotEmpty) {
          _tabController.animateTo(i);
          break;
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading reviews: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFECECEC),
      extendBody: true,
      appBar: const CustomAppBar(
        title: "Meal Evaluations",
        actions: [],
      ),
      body: Column(
        children: [
          _buildTabBar(),
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF02197D)),
                    ),
                  )
                : _buildTabBarView(),
          ),
          const SizedBox(height: 100),
        ],
        
      ),
      
    );
  }

 Widget _buildTabBar() {
  return Container(
    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    height: 50,
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(10),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 5,
          spreadRadius: 1,
          offset: const Offset(0, 2),
        ),
      ],
    ),
    child: LayoutBuilder(
      builder: (context, constraints) {
        final tabBarWidth = constraints.maxWidth;
        final indicatorWidth = tabBarWidth / 3;
        
        return Stack(
          children: [
            // TabBar with all dividers removed
            TabBar(
              controller: _tabController,
              overlayColor: WidgetStateProperty.all(Colors.transparent),
              indicatorColor: Colors.transparent,
              dividerColor: Colors.transparent, 
              labelColor: const Color(0xFF02197D),
              unselectedLabelColor: const Color(0xFF02197D).withOpacity(0.6),
              tabs: _categories.map((category) {
                return Tab(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Text(
                        category[0].toUpperCase() + category.substring(1),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            // Custom indicator
            AnimatedBuilder(
              animation: _tabController.animation!,
              builder: (context, child) {
                final position = _tabController.animation!.value;
                final left = indicatorWidth * position;
                
                // Smooth border radius transition
                final leftRadius = (1 - position.clamp(0, 1)).abs() * 10;
                final rightRadius = (position.clamp(0, _categories.length - 1) - 
                                  (_categories.length - 2)).abs() * 10;
                
                return Positioned(
                  left: left,
                  width: indicatorWidth,
                  height: 50,
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF1D4).withOpacity(0.7),
                      borderRadius: BorderRadius.horizontal(
                        left: Radius.circular(position <= 0.5 ? 10 : 0),
                        right: Radius.circular(position >= _categories.length - 1.5 ? 10 : 0),
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        );
      },
    ),
  );
}

  Widget _buildTabBarView() {
    return TabBarView(
      controller: _tabController,
      children: _categories.map((category) {
        final meals = _mealsByCategory[category] ?? [];

        if (meals.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.restaurant_menu_rounded, size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  "No rated ${category.toLowerCase()} meals found",
                  style: const TextStyle(
                    fontSize: 18,
                    color: Color(0xFF888888),
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: meals.length,
          itemBuilder: (context, index) => _buildMealCard(meals[index]),
        );
      }).toList(),
    );
  }

  Widget _buildMealCard(Meal meal) {
  return Container(
    margin: const EdgeInsets.only(bottom: 16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.08),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipOval(
                  child: _buildMealImage(meal),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      meal.category.toUpperCase(),
                      style: const TextStyle(
                        color: Color(0xFF888888),
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      meal.name,
                      style: const TextStyle(
                        color: Color(0xFF02197D),
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (meal.ratings.isNotEmpty)
          _buildRatingsList(meal) // Extracted ratings list to separate widget
        else
          _buildNoReviews(), // Extracted no reviews widget
      ],
    ),
  );
}
  
Widget _buildRatingsList(Meal meal) {
  return Column(
    children: [
      const Divider(height: 1, thickness: 1, color: Color(0xFFECECEC)),
      ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.only(top: 8, bottom: 8), // Reduced padding
        itemCount: meal.ratings.length,
        separatorBuilder: (context, index) => 
            const Divider(height: 1, thickness: 1, color: Color(0xFFECECEC)),
        itemBuilder: (context, index) => 
            _buildReviewItem(meal.ratings[index], meal),
      ),
    ],
  );
}

Widget _buildNoReviews() {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16), // Reduced padding
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.rate_review_outlined, 
            color: Colors.grey[400], size: 20),
        const SizedBox(width: 8),
        const Text(
          'No reviews yet',
          style: TextStyle(
            fontStyle: FontStyle.italic,
            color: Color(0xFF888888),
          ),
        ),
      ],
    ),
  );
}

  Widget _buildReviewItem(Map<String, dynamic> review, Meal meal) {
  final rating = (review['rating'] as num).toDouble();
  final comment = review['comment'] as String? ?? 'No comment';

  return Padding(
    padding: const EdgeInsets.fromLTRB(16, 8, 16, 12), // Adjusted padding
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: List.generate(5, (index) {
            return Icon(
              index < rating ? Icons.star : Icons.star_border,
              color: const Color(0xFFFFAA01),
              size: 16,
            );
          }),
        ),
        if (comment.isNotEmpty) ...[
          const SizedBox(height: 6), // Reduced spacing
          Text(
            comment,
            style: const TextStyle(
              color: Color(0xFF888888),
              fontSize: 14,
            ),
          ),
        ],
        const SizedBox(height: 8), // Reduced spacing
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            _buildActionButton(
              icon: Icons.edit_rounded,
              color: const Color(0xFF5E9EFF),
              onTap: () => _editReview(context, meal, review),
            ),
            const SizedBox(width: 12), // Reduced spacing
            _buildActionButton(
              icon: Icons.delete_outline_rounded,
              color: const Color(0xFFFF7D7D),
              onTap: () => _deleteReview(context, meal, review),
            ),
          ],
        ),
      ],
    ),
  );
}

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(
          icon,
          size: 20,
          color: color,
        ),
      ),
    );
  }

  Widget _buildMealImage(Meal meal) {
    if (meal.imageUrl == null || meal.imageUrl!.isEmpty) {
      return _buildPlaceholder();
    }

    if (meal.imageUrl!.startsWith('data:image')) {
      try {
        final bytes = base64Decode(meal.imageUrl!.split(',')[1]);
        return Image.memory(
          bytes,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _buildPlaceholder(),
        );
      } catch (e) {
        return _buildPlaceholder();
      }
    }

    return Image.asset(
      meal.imageUrl!,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => _buildPlaceholder(),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: Colors.grey[200],
      child: const Center(
        child: Icon(
          Icons.restaurant_menu_rounded,
          size: 32,
          color: Color(0xFFBBBBBB),
        ),
      ),
    );
  }

  void _editReview(
      BuildContext context, Meal meal, Map<String, dynamic> review) {
    final userId = review['userId'];
    final initialRating = (review['rating'] as num).toDouble();
    final initialComment = review['comment'] as String?;

    showDialog(
      context: context,
      builder: (context) => EditReviewDialog(
        initialRating: initialRating,
        initialComment: initialComment,
        onSubmit: (newRating, newComment) async {
          try {
            await Provider.of<MenuProvider>(context, listen: false).editReview(
              mealId: meal.id,
              userId: userId,
              newRating: newRating,
              newComment: newComment,
            );

            // Update local state
            final reviewIndex = meal.ratings.indexWhere(
              (r) => r['userId'] == userId,
            );
            if (reviewIndex != -1) {
              setState(() {
                meal.ratings[reviewIndex] = {
                  'userId': userId,
                  'rating': newRating,
                  'comment': newComment,
                };
              });
            }

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Review updated successfully'),
                backgroundColor: Colors.green,
              ),
            );
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error updating review: $e'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
      ),
    );
  }
  void _deleteReview(BuildContext context, Meal meal, Map<String, dynamic> review) {
  final userId = review['userId'];

  showDialog(
    context: context,
    builder: (context) => Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      elevation: 0,
      backgroundColor: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Delete Review',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF02197D),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Are you sure you want to delete this review?',
              style: TextStyle(
                color: Color(0xFF888888),
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFF888888),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  ),
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () async {
                    try {
                      await Provider.of<MenuProvider>(context, listen: false)
                          .deleteReview(
                        mealId: meal.id,
                        userId: userId,
                      );

                      setState(() {
                        meal.ratings.removeWhere(
                            (r) => r['userId'].toString() == userId.toString());
                      });

                      Navigator.pop(context);
                    } catch (e) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Error deleting review: $e'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF7D7D),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                  ),
                  child: const Text(
                    'Delete',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}
    }