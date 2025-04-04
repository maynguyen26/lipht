import 'package:flutter/material.dart';
import 'package:lipht/features/settings/widgets/index.dart';
import 'package:provider/provider.dart';
import 'package:lipht/providers/auth_provider.dart';
import 'package:lipht/routes/routes.dart';
import 'package:lipht/data/repositories/user_repository.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({
    Key? key,
  }) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _aiMealAnalysisEnabled = false;
  bool _privateModeEnabled = false;
  bool _isInitialized = false;

  final UserRepository _userRepository = UserRepository();
  bool _isUpdatingSetting = false;
  String? _updateError;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeSettings();
    });
  }

  void _initializeSettings() {
    if (_isInitialized || !mounted) return;
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final currentUser = authProvider.user;
    print("SETTINGS_SCREEN: Initializing with User: ${currentUser?.id}");

    setState(() {
      _aiMealAnalysisEnabled = currentUser?.enableAiMealAnalysis ?? false;
      _privateModeEnabled = currentUser?.privateMode ?? false;
      _isInitialized = true;
    });
  }

  Future<void> _handleSettingChange(String key, bool newValue) async {
    // Get current user ID from AuthProvider (read-only)
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userId = authProvider.user?.id;

    if (userId == null) {
      print("SETTINGS_SCREEN: Error - User ID is null, cannot update.");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text("Error: Not logged in."),
            backgroundColor: Colors.red),
      );
      if (mounted) {
        setState(() {
          if (key == 'enableAiMealAnalysis') _aiMealAnalysisEnabled = !newValue;
          if (key == 'privateMode') _privateModeEnabled = !newValue;
        });
      }
      return;
    }

    // Prevent concurrent updates
    if (_isUpdatingSetting) return;

    // Set local loading state
    if (mounted) {
      setState(() {
        _isUpdatingSetting = true;
        _updateError = null;
      });
    }

    try {
      // Call repository directly
      await _userRepository.updateUserData(userId, {key: newValue});
      print("SETTINGS_SCREEN: Firestore updated successfully for '$key'.");

      if (mounted) {
        setState(() {
          _updateError = null; // Clear error on success
        });
      }
    } catch (e) {
      print("SETTINGS_SCREEN: Error updating setting '$key': $e");
      if (mounted) {
        setState(() {
          _updateError = "Failed to update: $e";
          // Revert optimistic UI update on failure
          if (key == 'enableAiMealAnalysis') _aiMealAnalysisEnabled = !newValue;
          if (key == 'privateMode') _privateModeEnabled = !newValue;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_updateError!), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUpdatingSetting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.user;

    final bool isUpdating = _isUpdatingSetting;

    return Scaffold(
      backgroundColor: const Color(0xFFF9EDFF),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF9EDFF),
        elevation: 0,
        centerTitle: false,
        titleSpacing: 0,
        toolbarHeight: 80,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'LIPHT',
              style: TextStyle(
                fontFamily: 'Montserrat',
                color: Color(0xFFDDA7F6),
                fontWeight: FontWeight.w800,
              ),
            ),
            Transform(
              alignment: Alignment.center,
              transform: Matrix4.rotationY(3.14159),
              child: const Icon(
                Icons.fitness_center,
                color: Color(0xFFDDA7F6),
                grade: 900,
              ),
            ),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: const Color(0xFFDDA7F6),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        automaticallyImplyLeading: false,
      ),
      body: !_isInitialized
          ? Center(child: CircularProgressIndicator(color: Color(0xFFA764FF)))
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 32.0, vertical: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Profile section
                    const Center(
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 36,
                            backgroundColor: Color(0xFFAA77EE),
                            child: Icon(
                              Icons.person_outline,
                              color: Colors.white,
                              size: 40,
                            ),
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Settings',
                            style: TextStyle(
                              fontSize: 24,
                              color: Color(0xFF9370DB),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Settings sections with cards
                    SettingsCard(title: 'Account', children: [
                      Text(
                        user!.username,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFAA77EE),
                        ),
                      ),
                      SizedBox(height: 16),
                      SettingsActionRow(
                          label: "Change username",
                          onTap: () {
                            debugPrint('Settings button pressed');
                          }),
                      const SizedBox(height: 16),
                      SettingsActionRow(
                          label: "Change password",
                          onTap: () {
                            debugPrint('Change password button pressed');
                          }),
                    ]),

                    const SizedBox(height: 24),

                    SettingsCard(title: 'Privacy', children: [
                      // AI Meal Analysis toggle
                      IgnorePointer(
                        ignoring: isUpdating,
                        child: SettingsSwitchRow(
                          label: 'Enable AI Meal Analysis',
                          value: _aiMealAnalysisEnabled,
                          onChanged: (value) {
                            setState(() {
                              _aiMealAnalysisEnabled = value;
                            });
                            _handleSettingChange('enableAiMealAnalysis', value);
                          },
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Private Mode toggle
                      IgnorePointer(
                        ignoring: isUpdating,
                        child: SettingsSwitchRow(
                          label: 'Private Mode',
                          value: _privateModeEnabled,
                          onChanged: (value) {
                            setState(() {
                              _privateModeEnabled = value;
                            });
                            _handleSettingChange('privateMode', value);
                          },
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Block List
                      SettingsActionRow(
                        label: 'View Block List',
                        onTap: () {
                          // Handle view block list action
                        },
                      ),
                    ]),

                    const SizedBox(height: 24),

                    SettingsCard(title: 'Data Management', children: [
                      SettingsActionRow(
                        label: 'Delete Fitness/Diet/Sleep Data',
                        labelColor: Colors.red,
                        onTap: () {
                          // Handle delete data action
                        },
                      ),
                    ]),

                    const SizedBox(height: 32),

                    Center(
                      child: SignOutButton(
                        onPressed: () async {
                          final authProvider =
                              Provider.of<AuthProvider>(context, listen: false);
                          await authProvider.signOut();
                          Navigator.of(context)
                              .pushReplacementNamed(Routes.login);
                        },
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
    );
  }
}
