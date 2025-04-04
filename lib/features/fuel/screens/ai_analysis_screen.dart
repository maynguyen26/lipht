import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AIAnalysisScreen extends StatefulWidget {
  final Map<String, List<Map<String, dynamic>>> mealData;
  final DateTime selectedDate;
  final Map<String, dynamic> dailyTotals;

  const AIAnalysisScreen({
    Key? key,
    required this.mealData,
    required this.selectedDate,
    required this.dailyTotals,
  }) : super(key: key);

  @override
  State<AIAnalysisScreen> createState() => _AIAnalysisScreenState();
}

class _AIAnalysisScreenState extends State<AIAnalysisScreen> {
  bool _isLoading = true;
  String _mealScore = '';
  String _analysisComments = '';
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _getAIMealAnalysis();
  }

  // Function to get AI analysis
  Future<void> _getAIMealAnalysis() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      // Prepare the meal data for the API
      final mealSummary = _prepareMealDataSummary();
      
      // API endpoint - this would typically be your own server endpoint that handles the API key securely
      final response = await http.post(
        Uri.parse('https://api.openai.com/v1/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer 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',
        },
        body: jsonEncode({
          'model': 'gpt-4o-mini',
          'messages': [
            {
              'role': 'system',
              'content': 'You are a nutritionist AI that analyzes daily meal data. Provide a score rating (S+, S, S-, A+, A, A-, B+, B, B-, C+, C, C-, D+, D, D-, F) based on nutritional balance, and brief comments (max 3-4 sentences) on what was good and what could be improved.'
            },
            {
              'role': 'user',
              'content': 'Please analyze this daily meal data and give a score rating from S+ to F tier with brief comments: $mealSummary'
            }
          ],
          'temperature': 0.7,
          'max_tokens': 300
        }),
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        final analysisText = jsonResponse['choices'][0]['message']['content'];
        
        // Extract the score and comments from the response
        _parseAnalysisResponse(analysisText);
      } else {
        print('Error response: ${response.body}');
        setState(() {
          _errorMessage = 'Failed to connect to AI service. Status code: ${response.statusCode}';
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Exception during API call: $e');
      setState(() {
        _errorMessage = 'Error connecting to AI service: $e';
        _isLoading = false;
      });
    }
  }

  // Parse the AI response to extract score and comments
  void _parseAnalysisResponse(String response) {
    try {
      // Try to find a pattern like "Score: A+" or "Rating: B-" in the first few lines
      final scorePattern = RegExp(r'(Score:|Rating:|Grade:)\s*([SABCDF][+\-]?)');
      final scoreMatch = scorePattern.firstMatch(response);
      
      setState(() {
        if (scoreMatch != null) {
          _mealScore = scoreMatch.group(2) ?? 'N/A';
          // Remove the score line from the comments
          _analysisComments = response.replaceFirst(scoreMatch.group(0)!, '').trim();
        } else {
          // If no clear score pattern, try to find just the grade
          final simpleScorePattern = RegExp(r'\b([SABCDF][+\-]?)\b');
          final simpleMatch = simpleScorePattern.firstMatch(response);
          
          if (simpleMatch != null) {
            _mealScore = simpleMatch.group(1) ?? 'N/A';
            // Make our best effort to separate the score from comments
            _analysisComments = response.replaceFirst(simpleScorePattern, '').trim();
          } else {
            // If we can't find a score pattern at all
            _mealScore = 'N/A';
            _analysisComments = response.trim();
          }
        }
        _isLoading = false;
      });
    } catch (e) {
      print('Error parsing AI response: $e');
      setState(() {
        _mealScore = 'N/A';
        _analysisComments = response.trim();
        _isLoading = false;
      });
    }
  }

  // Prepare meal data in a format suitable for the AI
  String _prepareMealDataSummary() {
    final dateStr = DateFormat('MMMM d, yyyy').format(widget.selectedDate);
    String summary = "Date: $dateStr\n\n";
    
    // Add daily totals
    summary += "Daily Totals:\n";
    summary += "- Calories: ${widget.dailyTotals['calories']}\n";
    summary += "- Protein: ${widget.dailyTotals['protein'].toStringAsFixed(1)}g\n";
    summary += "- Carbs: ${widget.dailyTotals['carbs'].toStringAsFixed(1)}g\n";
    summary += "- Fat: ${widget.dailyTotals['fat'].toStringAsFixed(1)}g\n\n";
    
    // Add each meal
    for (final mealType in widget.mealData.keys) {
      if (widget.mealData[mealType]!.isNotEmpty) {
        summary += "${mealType.substring(0, 1).toUpperCase()}${mealType.substring(1)}:\n";
        
        for (final food in widget.mealData[mealType]!) {
          summary += "- ${food['foodName']} (${food['servingGrams']}g): ${food['calories']} calories, ";
          summary += "${food['protein'].toStringAsFixed(1)}g protein, ";
          summary += "${food['carbs'].toStringAsFixed(1)}g carbs, ";
          summary += "${food['fat'].toStringAsFixed(1)}g fat\n";
        }
        summary += "\n";
      }
    }
    
    return summary;
  }

  // Get the color based on the score
  Color _getScoreColor(String score) {
    if (score.startsWith('S')) return Color(0xFFFFD700); // Gold
    if (score.startsWith('A')) return Color(0xFF00C853); // Green
    if (score.startsWith('B')) return Color(0xFF2196F3); // Blue
    if (score.startsWith('C')) return Color(0xFFFFA000); // Orange
    if (score.startsWith('D')) return Color(0xFFFF5722); // Deep Orange
    if (score.startsWith('F')) return Color(0xFFF44336); // Red
    return Color(0xFF9E9E9E); // Grey for N/A
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9EDFF),
      appBar: AppBar(
        title: Text('AI Meal Analysis'),
        backgroundColor: Color(0xFFA764FF),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading
          ? Center(child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(color: Color(0xFFA764FF)),
                SizedBox(height: 20),
                Text('Analyzing your meals...',
                  style: TextStyle(
                    color: Color(0xFF9D76C1),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ))
          : _errorMessage.isNotEmpty
              ? Center(child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, color: Colors.red, size: 50),
                      SizedBox(height: 20),
                      Text(_errorMessage,
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.red),
                      ),
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _getAIMealAnalysis,
                        child: Text('Try Again'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFFA764FF),
                        ),
                      ),
                    ],
                  ),
                ))
              : SingleChildScrollView(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        DateFormat('MMMM d, yyyy').format(widget.selectedDate),
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF9D76C1),
                        ),
                      ),
                      SizedBox(height: 30),
                      
                      // Score Display
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: _getScoreColor(_mealScore),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 10,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            _mealScore,
                            style: TextStyle(
                              fontSize: 42,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 40),
                      
                      // Analysis Comments
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Analysis',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF9D76C1),
                              ),
                            ),
                            SizedBox(height: 15),
                            Text(
                              _analysisComments,
                              style: TextStyle(
                                fontSize: 16,
                                height: 1.5,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 30),
                      
                      // Nutrition Summary
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(color: Color(0xFF9D76C1).withOpacity(0.5)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Daily Nutrition Summary',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF9D76C1),
                              ),
                            ),
                            SizedBox(height: 15),
                            _buildNutrientBar('Calories', widget.dailyTotals['calories'], 2000, Color(0xFFA764FF)),
                            SizedBox(height: 10),
                            _buildNutrientBar('Protein', widget.dailyTotals['protein'], 150, Color(0xFF879FFF)),
                            SizedBox(height: 10),
                            _buildNutrientBar('Carbs', widget.dailyTotals['carbs'], 250, Color(0xFF9D76C1)),
                            SizedBox(height: 10),
                            _buildNutrientBar('Fat', widget.dailyTotals['fat'], 70, Color(0xFFE57373)),
                          ],
                        ),
                      ),
                      SizedBox(height: 20),
                      
                      // Refresh Button
                      ElevatedButton.icon(
                        onPressed: _getAIMealAnalysis,
                        icon: Icon(Icons.refresh),
                        label: Text('Refresh Analysis'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFFA764FF),
                          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }
  
  // Helper widget to build nutrient progress bars
  Widget _buildNutrientBar(String label, dynamic value, double target, Color color) {
    // Convert to double if not already
    double valueDouble = value is int ? value.toDouble() : value;
    double percentage = (valueDouble / target).clamp(0.0, 1.0);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Color(0xFF9D76C1),
              ),
            ),
            Text(
              '$valueDouble / $target${label == 'Calories' ? '' : 'g'}',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Color(0xFF9D76C1),
              ),
            ),
          ],
        ),
        SizedBox(height: 5),
        Container(
          height: 10,
          decoration: BoxDecoration(
            color: Colors.grey.withOpacity(0.2),
            borderRadius: BorderRadius.circular(5),
          ),
          child: FractionallySizedBox(
            widthFactor: percentage,
            alignment: Alignment.centerLeft,
            child: Container(
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(5),
              ),
            ),
          ),
        ),
      ],
    );
  }
}