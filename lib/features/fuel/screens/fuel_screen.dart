import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../data/food_data.dart';
import '../screens/ai_analysis_screen.dart'; // Import the AI Analysis Screen

class FuelScreen extends StatefulWidget {
  const FuelScreen({Key? key}) : super(key: key);

  @override
  State<FuelScreen> createState() => _FuelScreenState();
}

class _FuelScreenState extends State<FuelScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _searchResults = [];
  bool _isLoading = false;
  bool _isSearching = false;
  DateTime _selectedDate = DateTime.now();
  
  // To track which meal type we're adding to
  String _currentMealType = 'breakfast';
  
  // To store the meals fetched from Firebase
  Map<String, List<Map<String, dynamic>>> _meals = {
    'breakfast': [],
    'lunch': [],
    'dinner': [],
    'snacks': []
  };
  
  // Reference to Firestore
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  // Serving size controller
  final TextEditingController _gramController = TextEditingController();
  int _servingGrams = 100; // Default serving size in grams
  
  @override
  void initState() {
    super.initState();
    _gramController.text = _servingGrams.toString();
    _fetchMealsForDate(_selectedDate);
  }
  
  @override
  void dispose() {
    _searchController.dispose();
    _gramController.dispose();
    super.dispose();
  }

  // Fetch meals for selected date
  Future<void> _fetchMealsForDate(DateTime date) async {
    setState(() {
      _isLoading = true;
      // Important: Clear existing meals immediately to avoid showing old data
      _meals = {
        'breakfast': [],
        'lunch': [],
        'dinner': [],
        'snacks': []
      };
    });
    
    try {
      final user = _auth.currentUser;
      if (user == null) {
        setState(() {
          _isLoading = false;
        });
        return;
      }
      
      String dateString = DateFormat('yyyy-MM-dd').format(date);
      print('Fetching meals for date: $dateString'); // Debug log
      
      // Get meal logs for the date
      final mealSnapshot = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('mealLogs')
          .where('date', isEqualTo: dateString)
          // .orderBy('timestamp', descending: false)
          .get();
      
      print('Found ${mealSnapshot.docs.length} meal items for $dateString'); // Debug log
      
      // Create a fresh meals map for this date
      Map<String, List<Map<String, dynamic>>> newMeals = {
        'breakfast': [],
        'lunch': [],
        'dinner': [],
        'snacks': []
      };
      
      // Sort meals by type
      for (var doc in mealSnapshot.docs) {
        final data = doc.data();
        data['id'] = doc.id;
        
        String mealType = data['mealType'] ?? 'breakfast';
        if (newMeals.containsKey(mealType)) {
          newMeals[mealType]!.add(data);
        } else {
          newMeals['snacks']!.add(data);
        }
      }
      
      // Only update state if the component is still mounted and the selected date hasn't changed
      if (mounted && _selectedDate == date) {
        setState(() {
          _meals = newMeals;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching meals: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
  
  // Function to search among the hard-coded foods
  void _searchFoodItems(String query) {
    setState(() {
      _isSearching = true;
      if (query.isEmpty) {
        _searchResults = [];
      } else {
        _searchResults = FoodData.allFoods
            .where((food) => food['name'].toString().toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }
  
  // Function to add food to user's meal log with specific meal type
  Future<void> _addFoodToMealLog(Map<String, dynamic> food, String mealType, int grams) async {
    try {
      // Get current user
      final user = _auth.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please log in to add food to your meal log')),
        );
        return;
      }
      
      // Calculate nutrition based on grams
      double multiplier = grams / 100.0; // Convert from base 100g
      int calories = (food['calories'] * multiplier).round();
      double protein = (food['protein'] * multiplier);
      double carbs = (food['carbs'] * multiplier);
      double fat = (food['fat'] * multiplier);
      
      // Add to user's meal log
      final docRef = await _firestore.collection('users').doc(user.uid).collection('mealLogs').add({
        'foodId': food['id'],
        'foodName': food['name'],
        'originalCalories': food['calories'],
        'originalProtein': food['protein'],
        'originalCarbs': food['carbs'],
        'originalFat': food['fat'],
        'servingGrams': grams,
        'calories': calories,
        'protein': protein,
        'carbs': carbs,
        'fat': fat,
        'mealType': mealType,
        'timestamp': FieldValue.serverTimestamp(),
        'date': DateFormat('yyyy-MM-dd').format(_selectedDate),
      });
      
      // Add to local state
      setState(() {
        _meals[mealType]!.add({
          'id': docRef.id,
          'foodName': food['name'],
          'calories': calories,
          'protein': protein,
          'carbs': carbs,
          'fat': fat,
          'servingGrams': grams,
          'mealType': mealType,
        });
        _isSearching = false;
        _searchResults = [];
        _searchController.clear();
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${food['name']} added to $mealType')),
      );
    } catch (e) {
      print('Error adding food to meal log: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add food to meal log: $e')),
      );
    }
  }
  
  // Delete food item from meal log
  Future<void> _deleteFoodFromMealLog(String documentId, String mealType, int index) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;
      
      // Delete from Firestore
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('mealLogs')
          .doc(documentId)
          .delete();
      
      // Delete from local state
      setState(() {
        _meals[mealType]!.removeAt(index);
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Food removed from $mealType')),
      );
    } catch (e) {
      print('Error deleting food: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete food: $e')),
      );
    }
  }
  
  // Calculate total nutrition for a meal type
  Map<String, dynamic> _calculateMealTotals(String mealType) {
    if (_meals[mealType] == null || _meals[mealType]!.isEmpty) {
      return {'calories': 0, 'protein': 0, 'carbs': 0, 'fat': 0};
    }
    
    int totalCalories = 0;
    double totalProtein = 0;
    double totalCarbs = 0;
    double totalFat = 0;
    
    for (var food in _meals[mealType]!) {
      totalCalories += food['calories'] as int;
      totalProtein += food['protein'] as double;
      totalCarbs += food['carbs'] as double;
      totalFat += food['fat'] as double;
    }
    
    return {
      'calories': totalCalories,
      'protein': totalProtein,
      'carbs': totalCarbs,
      'fat': totalFat,
    };
  }
  
  // Calculate daily totals across all meals
  Map<String, dynamic> _calculateDailyTotals() {
    int totalCalories = 0;
    double totalProtein = 0;
    double totalCarbs = 0;
    double totalFat = 0;
    
    for (var mealType in _meals.keys) {
      for (var food in _meals[mealType]!) {
        totalCalories += food['calories'] as int;
        totalProtein += food['protein'] as double;
        totalCarbs += food['carbs'] as double;
        totalFat += food['fat'] as double;
      }
    }
    
    return {
      'calories': totalCalories,
      'protein': totalProtein,
      'carbs': totalCarbs,
      'fat': totalFat,
    };
  }
  
  void _showAddFoodDialog(Map<String, dynamic> food) {
    _gramController.text = '100';
    _servingGrams = 100;
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          // Calculate nutrition based on current gram input
          double multiplier = _servingGrams / 100.0;
          int calculatedCalories = (food['calories'] * multiplier).round();
          double calculatedProtein = (food['protein'] * multiplier);
          double calculatedCarbs = (food['carbs'] * multiplier);
          double calculatedFat = (food['fat'] * multiplier);
          
          return AlertDialog(
            title: Text('Add ${food['name']}'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Serving size control
                Row(
                  children: [
                    Text('Serving size (g): '),
                    Expanded(
                      child: TextField(
                        controller: _gramController,
                        keyboardType: TextInputType.number,
                        onChanged: (value) {
                          setDialogState(() {
                            _servingGrams = int.tryParse(value) ?? 100;
                          });
                        },
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                
                // Show calculated nutrition
                Text('Calories: $calculatedCalories'),
                Text('Protein: ${calculatedProtein.toStringAsFixed(1)}g'),
                Text('Carbs: ${calculatedCarbs.toStringAsFixed(1)}g'),
                Text('Fat: ${calculatedFat.toStringAsFixed(1)}g'),
                
                SizedBox(height: 20),
                
                // Meal type selection
                Text('Add to:'),
                DropdownButton<String>(
                  value: _currentMealType,
                  isExpanded: true,
                  items: [
                    DropdownMenuItem(value: 'breakfast', child: Text('Breakfast')),
                    DropdownMenuItem(value: 'lunch', child: Text('Lunch')),
                    DropdownMenuItem(value: 'dinner', child: Text('Dinner')),
                    DropdownMenuItem(value: 'snacks', child: Text('Snacks')),
                  ],
                  onChanged: (value) {
                    setDialogState(() {
                      _currentMealType = value!;
                    });
                  },
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _addFoodToMealLog(food, _currentMealType, _servingGrams);
                },
                child: Text('Add'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFA764FF),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
  
  // Navigate to AI Analysis Screen
  void _navigateToAIAnalysis() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AIAnalysisScreen(
          mealData: _meals,
          selectedDate: _selectedDate,
          dailyTotals: _calculateDailyTotals(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dailyTotals = _calculateDailyTotals();
    
    return Scaffold(
      backgroundColor: const Color(0xFFF9EDFF),
      body: _isLoading 
          ? Center(child: CircularProgressIndicator(color: Color(0xFFA764FF)))
          : Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 20),
                  
                  // Date selector
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: Icon(Icons.arrow_back, color: Color(0xFF9D76C1)),
                        onPressed: () {
                          setState(() {
                            _selectedDate = _selectedDate.subtract(Duration(days: 1));
                          });
                          _fetchMealsForDate(_selectedDate);
                        },
                      ),
                      GestureDetector(
                        onTap: () async {
                          final DateTime? picked = await showDatePicker(
                            context: context,
                            initialDate: _selectedDate,
                            firstDate: DateTime(2020),
                            lastDate: DateTime(2101),
                          );
                          if (picked != null && picked != _selectedDate) {
                            setState(() {
                              _selectedDate = picked;
                            });
                            _fetchMealsForDate(_selectedDate);
                          }
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: Color(0xFFA764FF),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            DateFormat('MMM dd, yyyy').format(_selectedDate),
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.arrow_forward, color: Color(0xFF9D76C1)),
                        onPressed: () {
                          setState(() {
                            _selectedDate = _selectedDate.add(Duration(days: 1));
                          });
                          _fetchMealsForDate(_selectedDate);
                        },
                      ),
                    ],
                  ),
                  SizedBox(height: 15),
                  
                  // Daily Total and AI Analysis button
                  Row(
                    children: [
                      // Daily Total Container (modified to take less width)
                      Expanded(
                        flex: 3,
                        child: Container(
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Color(0xFFA764FF),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                'Daily Total',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  _buildNutrientInfo('Calories', '${dailyTotals['calories']}', Colors.white),
                                  _buildNutrientInfo('Protein', '${dailyTotals['protein'].toStringAsFixed(1)}g', Colors.white),
                                  _buildNutrientInfo('Carbs', '${dailyTotals['carbs'].toStringAsFixed(1)}g', Colors.white),
                                  _buildNutrientInfo('Fat', '${dailyTotals['fat'].toStringAsFixed(1)}g', Colors.white),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      
                      SizedBox(width: 10),
                      
                      // AI Analysis Button
                      Expanded(
                        flex: 1,
                        child: GestureDetector(
                          onTap: _navigateToAIAnalysis,
                          child: Container(
                            height: 84, // Match the height of Daily Total container
                            padding: EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Color(0xFF879FFF),
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.analytics_outlined,
                                  color: Colors.white,
                                  size: 30,
                                ),
                                SizedBox(height: 5),
                                Text(
                                  'AI Analysis',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  SizedBox(height: 20),
                  
                  // Search Bar
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Color(0xFF9D76C1)),
                    ),
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: "Search foods to add...",
                        hintStyle: TextStyle(color: Color(0xFF9D76C1)),
                        border: InputBorder.none,
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                        suffixIcon: IconButton(
                          icon: Icon(Icons.search, color: Color(0xFF9D76C1)),
                          onPressed: () => _searchFoodItems(_searchController.text),
                        ),
                      ),
                      onSubmitted: _searchFoodItems,
                    ),
                  ),
                  SizedBox(height: 10),
                  
                  // Search results or meal log display
                  Expanded(
                    child: _isSearching && _searchResults.isNotEmpty
                        ? _buildSearchResultsList()
                        : _buildMealLogsList(),
                  ),
                ],
              ),
            ),
    );
  }
  
  // Widget to build search results list
  Widget _buildSearchResultsList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Search Results:",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF9D76C1),
          ),
        ),
        SizedBox(height: 8),
        
        Expanded(
          child: ListView.builder(
            itemCount: _searchResults.length,
            itemBuilder: (context, index) {
              final food = _searchResults[index];
              return GestureDetector(
                onTap: () => _showAddFoodDialog(food),
                child: _buildFoodItemCard(food),
              );
            },
          ),
        ),
      ],
    );
  }
  
  // Widget to build meal logs list
  Widget _buildMealLogsList() {
    return ListView(
      children: [
        // Breakfast Section
        _buildMealSection('breakfast', 'Breakfast'),
        SizedBox(height: 16),
        
        // Lunch Section
        _buildMealSection('lunch', 'Lunch'),
        SizedBox(height: 16),
        
        // Dinner Section
        _buildMealSection('dinner', 'Dinner'),
        SizedBox(height: 16),
        
        // Snacks Section
        _buildMealSection('snacks', 'Snacks'),
        SizedBox(height: 16),
      ],
    );
  }
  
  // Widget to build a meal section (breakfast, lunch, etc.)
  Widget _buildMealSection(String mealType, String title) {
    final mealTotals = _calculateMealTotals(mealType);
    
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Color(0xFF9D76C1)),
      ),
      child: Column(
        children: [
          // Meal header
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Color(0xFF9D76C1),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(15),
                topRight: Radius.circular(15),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  '${mealTotals['calories']} cals',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          
          // Meal items
          _meals[mealType]!.isEmpty
              ? Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    'No $title items added yet',
                    style: TextStyle(
                      color: Color(0xFF9D76C1),
                    ),
                  ),
                )
              : ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: _meals[mealType]!.length,
                  itemBuilder: (context, index) {
                    final meal = _meals[mealType]![index];
                    return Dismissible(
                      key: Key(meal['id']),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        color: Colors.red,
                        alignment: Alignment.centerRight,
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Icon(Icons.delete, color: Colors.white),
                      ),
                      onDismissed: (direction) {
                        _deleteFoodFromMealLog(meal['id'], mealType, index);
                      },
                      child: ListTile(
                        title: Text(meal['foodName']),
                        subtitle: Text('${meal['servingGrams']}g • ${(meal['protein'] as double).toStringAsFixed(1)}g protein • ${(meal['carbs'] as double).toStringAsFixed(1)}g carbs • ${(meal['fat'] as double).toStringAsFixed(1)}g fat'),
                        trailing: Text(
                          '${meal['calories']} cals',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ],
      ),
    );
  }

  // Widget to build a food item card in search results
  Widget _buildFoodItemCard(Map<String, dynamic> food) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 6),
      color: Color(0xFF879FFF),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  food['name'],
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
                Text(
                  "${food['calories']} cals (100g)",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Protein: ${food['protein']}g",
                  style: TextStyle(color: Colors.white),
                ),
                Text(
                  "Carbs: ${food['carbs']}g",
                  style: TextStyle(color: Colors.white),
                ),
                Text(
                  "Fat: ${food['fat']}g",
                  style: TextStyle(color: Colors.white),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  // Helper widget for nutrient information display
  Widget _buildNutrientInfo(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: color.withOpacity(0.8),
          ),
        ),
        SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}