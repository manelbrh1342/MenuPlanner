import 'package:flutter/material.dart';
import 'package:menu_planner/pages/edit.dart';
import 'package:menu_planner/pages/delete.dart';
import 'package:menu_planner/models/meal.dart';
import 'package:menu_planner/pages/review_meal.dart';
import 'dart:convert';

class MealItem extends StatefulWidget {
  final Meal meal;
  final String imagePath;

  const MealItem({
    super.key,
    required this.meal,
    required this.imagePath,
  });

  @override
  State<MealItem> createState() => _MealItemState();
}

class _MealItemState extends State<MealItem> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.8,
      height: 200, // Adjusted height for better layout
      decoration: BoxDecoration(
        color: const Color(0xFFECECEC),
        borderRadius: BorderRadius.circular(20),
        // Removed shadow from the main card container
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Stack(
            children: [
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  width: constraints.maxWidth,
                  height: constraints.maxHeight * 0.7,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 16, top: 12, right: 120), // Increased right padding to prevent text from going behind image
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.meal.category.toUpperCase(),
                          style: const TextStyle(
                            color: Color(0xFF888888),
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                            decoration: TextDecoration.none,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.meal.name,
                          style: const TextStyle(
                            color: Color(0xFF02197D),
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.none,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis, // Added to ensure proper text wrapping
                        ),
                        const SizedBox(height: 6),
                        Text(
                          widget.meal.description,
                          style: const TextStyle(
                            color: Color(0xFF888888),
                            fontSize: 10,
                            height: 1.4,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 3,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                right: 10,
                top: 10,
                child: _buildImageWithShadow(),
              ),
              Positioned(
                bottom: 12,
                right: 16,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildActionButton(
                      icon: Icons.star_rounded,
                      color: const Color(0xFFFFAA01),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ReviewMealPage(meal: widget.meal),
                          ),
                        );
                      },
                    ),
                    const SizedBox(width: 16),
                    _buildActionButton(
                      icon: Icons.edit_rounded,
                      color: const Color(0xFF5E9EFF),
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return EditPage(
                              meal: widget.meal,
                            );
                          },
                        );
                      },
                    ),
                    const SizedBox(width: 16),
                    _buildActionButton(
                      icon: Icons.delete_outline_rounded,
                      color: const Color(0xFFFF7D7D),
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return DeletePage(
                              meal: widget.meal,
                            );
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          );
        },
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

  Widget _buildImageWithShadow() {
    return Container(
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
      child: _buildImage(),
    );
  }

  Widget _buildImage() {
    debugPrint('Building image for meal: ${widget.meal.name}');
    debugPrint('Image path: ${widget.imagePath}');

    if (widget.imagePath.isEmpty) {
      debugPrint('Empty image path, using placeholder');
      return _buildPlaceholder();
    }

    // Handle base64 images
    if (widget.imagePath.startsWith('data:image')) {
      debugPrint('Loading base64 image');
      try {
        // Extract the base64 part from the data URL
        final base64String = widget.imagePath.split(',')[1];
        final bytes = base64Decode(base64String);
        debugPrint('Base64 image decoded successfully, size: ${bytes.length} bytes');
        
        return Container(
          width: 120,
          height: 120,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.grey,
            // Removed white border
          ),
          child: ClipOval(
            child: Image.memory(
              bytes,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                debugPrint('Error loading base64 image: $error');
                return _buildPlaceholder();
              },
            ),
          ),
        );
      } catch (e) {
        debugPrint('Error processing base64 image: $e');
        return _buildPlaceholder();
      }
    }

    // Handle asset images
    if (widget.imagePath.startsWith('assets/')) {
      debugPrint('Loading asset image: ${widget.imagePath}');
      return Container(
        width: 120,
        height: 120,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.grey,
          // Removed white border
        ),
        child: ClipOval(
          child: Image.asset(
            widget.imagePath,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              debugPrint('Error loading asset image: $error');
              return _buildPlaceholder();
            },
          ),
        ),
      );
    }

    // For any other path, use placeholder
    debugPrint('Unknown image path format, using placeholder');
    return _buildPlaceholder();
  }

  Widget _buildPlaceholder() {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.grey[300],
        // Removed white border
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: const Icon(Icons.restaurant_menu_rounded, size: 40, color: Color(0xFFBBBBBB)),
    );
  }
}