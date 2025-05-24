import 'package:flutter/material.dart';
import 'package:menu_planner/models/meal.dart';
import 'package:menu_planner/services/meal_service.dart';
import 'package:menu_planner/providers/menu_provider.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:convert';

class EditPage extends StatefulWidget {
  final Meal meal;

  const EditPage({super.key, required this.meal});

  @override
  State<EditPage> createState() => _EditPageState();
}

class _EditPageState extends State<EditPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _selectedCategory = '';
  File? _imageFile;
  bool _isLoading = false;
  String? _existingImageUrl;
  final _mealService = MealService();

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.meal.name;
    _descriptionController.text = widget.meal.description;
    _selectedCategory = widget.meal.category;
    _existingImageUrl = widget.meal.imageUrl;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);

      if (pickedFile != null) {
        setState(() {
          _imageFile = File(pickedFile.path);
          _existingImageUrl = null;
        });
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking image: $e')),
      );
    }
  }

  Widget _buildImagePreview() {
    if (_imageFile != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Image.file(
          _imageFile!,
          height: 150,
          width: double.infinity,
          fit: BoxFit.cover,
        ),
      );
    } else if (_existingImageUrl != null && _existingImageUrl!.startsWith('data:image')) {
      try {
        final base64String = _existingImageUrl!.split(',')[1];
        final bytes = base64Decode(base64String);
        return ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Image.memory(
            bytes,
            height: 150,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
        );
      } catch (e) {
        debugPrint('Error displaying existing image: $e');
        return _buildPlaceholder();
      }
    } else if (_existingImageUrl != null && _existingImageUrl!.startsWith('assets/')) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Image.asset(
          _existingImageUrl!,
          height: 150,
          width: double.infinity,
          fit: BoxFit.cover,
        ),
      );
    } else {
      return _buildPlaceholder();
    }
  }

  Widget _buildPlaceholder() {
    return Container(
      height: 150,
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFD9D9D9),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFFFAC06),
          width: 1.0,
        ),
      ),
      child: const Center(
        child: Icon(Icons.image, size: 50, color: Colors.black54),
      ),
    );
  }

  Future<void> _updateMeal() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final updatedMeal = Meal(
        id: widget.meal.id,
        name: _nameController.text,
        description: _descriptionController.text,
        category: _selectedCategory,
        imageUrl: _existingImageUrl,
        creatorId: widget.meal.creatorId,
        createdAt: widget.meal.createdAt,
        lastUsed: widget.meal.lastUsed,
        averageRating: widget.meal.averageRating,
        ratingCount: widget.meal.ratingCount,
        ratings: widget.meal.ratings,
      );

      if (_imageFile != null) {
        await _mealService.updateMeal(updatedMeal, imageFile: _imageFile);
      } else {
        await _mealService.updateMeal(updatedMeal);
      }

      final refreshedMeal = await _mealService.getMealById(widget.meal.id);
      debugPrint('Meal updated successfully. New image URL: ${refreshedMeal.imageUrl}');

      if (mounted) {
        final menuProvider = Provider.of<MenuProvider>(context, listen: false);
        
        await menuProvider.fetchWeeklyMenu();
        debugPrint('Weekly menu refreshed after meal update');
        
        final today = DateTime.now();
        for (int i = 0; i < 7; i++) {
          final date = today.add(Duration(days: i));
          await menuProvider.refreshDayMenu(date);
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Meal updated successfully')),
        );
      }

      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      debugPrint('Error updating meal: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating meal: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFFECECEC),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Edit Meal',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF02197D),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: Container(
                        width: 30,
                        height: 30,
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
                          child: Image.asset(
                            "assets/Icons/cancel.png",
                            width: 20,
                            height: 20,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                
                // Image section
                GestureDetector(
                  onTap: _pickImage,
                  child: _buildImagePreview(),
                ),
                const SizedBox(height: 16),
                // Meal Name
                const Text(
                  "Name",
                  style: TextStyle(
                    color: Color(0xFFFFAC06),
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _nameController,
                  style: const TextStyle(color: Color(0xFF9D9B9B)),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide.none,
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(
                        color: Color(0xFFFFAC06),
                        width: 2.0,
                      ),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    hintText: "Enter meal name",
                    hintStyle: const TextStyle(color: Color(0xFF9D9B9B)),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a meal name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                
                // Description
                const Text(
                  "Description",
                  style: TextStyle(
                    color: Color(0xFFFFAC06),
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _descriptionController,
                  style: const TextStyle(color: Color(0xFF9D9B9B)),
                  maxLines: 3,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide.none,
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(
                        color: Color(0xFFFFAC06),
                        width: 2.0,
                      ),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    hintText: "Enter meal description",
                    hintStyle: const TextStyle(color: Color(0xFF9D9B9B)),
                  ),
                ),
                const SizedBox(height: 24),
                
                // Update button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _updateMeal,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFAA01),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 3,
                    ),
                    child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Update Meal',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}