import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:menu_planner/models/meal.dart';
import 'package:menu_planner/services/meal_service.dart';
import 'package:menu_planner/widget/appBarButtons.dart';
import 'package:menu_planner/widget/category.dart';
import 'package:menu_planner/widget/chooseTime.dart';
import 'package:menu_planner/widget/dateButtons.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:menu_planner/providers/menu_provider.dart';
import 'dart:io';

class AddMeal extends StatefulWidget {
  const AddMeal({super.key});

  @override
  State<AddMeal> createState() => _AddmealState();
}

class _AddmealState extends State<AddMeal> {
  final MealService _mealService = MealService();
  final _formKey = GlobalKey<FormState>();

  // Form controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  // Form state
  String _selectedCategory = 'main';
  String _selectedTime = 'lunch';
  List<DateTime> _selectedDays = [];
  File? _selectedImage;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _submitMeal() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields')),
      );
      return;
    }

    if (_selectedDays.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one day')),
      );
      return;
    }

    final currentDate = DateTime.now();
    // using yesterday at midnight as the base date
    final baseDate =
        DateTime(currentDate.year, currentDate.month, currentDate.day);

    final upcomingDays = _selectedDays.map((selectedDay) {
      final selectedWeekday = selectedDay.weekday;
      final todayWeekday = baseDate.weekday;

      // Calculate the number of days to add
      int daysToAdd = selectedWeekday - todayWeekday;

      // If the selected day is in the past this week, move it to next week
      if (daysToAdd < 0) {
        daysToAdd += 7; // Move it to the next week
      }

      // If the selected day is today, don't move it to the next day
      if (daysToAdd == 0) {
        daysToAdd = 0;
      }

      // Return the calculated date
      return baseDate.add(Duration(days: daysToAdd));
    }).toList();

    debugPrint("Upcoming days after adjustment: $upcomingDays");

    if (upcomingDays.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please select at least one upcoming day')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('User not authenticated');

      // Create a new meal with a temporary ID
      final newMeal = Meal(
        id: '', // This will be replaced with the actual ID from Firestore
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        category: _selectedCategory,
        creatorId: user.uid,
        imageUrl: null, // We'll set this after uploading the image
        createdAt: baseDate,
      );

      // Add the meal to Firestore and get the ID
      final mealId =
          await _mealService.addMeal(newMeal, imageFile: _selectedImage);
      debugPrint("Meal added with ID: $mealId");

      // Get the updated meal with the image path
      final updatedMeal = await _mealService.getMealById(mealId);
      debugPrint("Updated meal image path: ${updatedMeal.imageUrl}");

      // Use MenuProvider to add the meal to each selected day
      final menuProvider = Provider.of<MenuProvider>(context, listen: false);
      for (final date in upcomingDays) {
        await menuProvider.addMealToDay(date, updatedMeal, _selectedTime);
      }

      debugPrint("Meal added successfully with ID: $mealId");
      debugPrint("Selected dates: $upcomingDays");
      debugPrint("Selected time: $_selectedTime");

      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving meal: ${e.toString()}')),
        );
      }
      debugPrint('Error in _submitMeal: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      appBar: AppBar(
        backgroundColor: const Color(0xFFECECEC),
        toolbarHeight: MediaQuery.of(context).size.height * 0.15,
        automaticallyImplyLeading: false,
        title: const Row(
          children: [
            Expanded(
              child: Text(
                "What do you want to cook today?",
                style: TextStyle(
                  color: Color(0xFF02197D),
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        centerTitle: false,
        actions: [
          appBarButton(
            imagePath: "assets/Icons/add.png",
            onTap: _isLoading ? null : _submitMeal,
          ),
          const SizedBox(width: 10),
          appBarButton(
            imagePath: "assets/Icons/cancel.png",
            onTap: _isLoading ? null : () => Navigator.pop(context),
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Container(
                  width: double.infinity,
                  color: const Color(0xFFECECEC),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Select the category and time:",
                        style:
                            TextStyle(color: Color(0xFF9D9B9B), fontSize: 12),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Choosecategory(
                              onChanged: (value) => setState(() {
                                _selectedCategory = value ?? 'main';
                              }),
                            ),
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: Choosetime(
                              onChanged: (value) => setState(() {
                                _selectedTime = value ?? 'lunch';
                              }),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Image and Days Selection
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          GestureDetector(
                            onTap: _pickImage,
                            child: Container(
                              width: MediaQuery.of(context).size.width * 0.3,
                              height: MediaQuery.of(context).size.height * 0.22,
                              decoration: BoxDecoration(
                                color: const Color(0xFFD9D9D9),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: const Color(0xFFFFAC06),
                                  width: 1.0,
                                ),
                              ),
                              child: _selectedImage != null
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(20),
                                      child: Image.file(
                                        _selectedImage!,
                                        fit: BoxFit.cover,
                                      ),
                                    )
                                  : const Icon(Icons.add_a_photo,
                                      color: Colors.black, size: 40),
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Select the days (you can\nchoose multiple):",
                                style: TextStyle(
                                  color: Color(0xFF9D9B9B),
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Datebuttons(
                                onDaysSelected: (days) {
                                  _selectedDays = days;
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

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
                      const SizedBox(height: 20),

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
                      const SizedBox(height: 100),

                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
