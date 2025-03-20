import 'package:flutter/material.dart';
import 'package:lipht/features/settings/widgets/index.dart';
import 'package:provider/provider.dart';
import 'package:lipht/providers/auth_provider.dart';
import 'package:lipht/routes/routes.dart';

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
  
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;

    return Scaffold(
      backgroundColor: const Color(0xFFF9EDFF),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF9EDFF),
        elevation: 0,
        centerTitle: false,
        titleSpacing: 30,
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
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: IconButton(
              icon: const Icon(
                Icons.settings_outlined,
                color: Color(0xFF9370DB),
                size: 28,
              ),
              onPressed: () {},
            ),
          ),
        ],
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: const Color(0xFFDDA7F6), 
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 24.0),
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
              SettingsCard(
                title: 'Account',
                children: [
                  Text (
                    user!.username,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFAA77EE),
                    ),
                  ) ,
                  SizedBox(height: 16),
                  SettingsActionRow(
                    label: "Change username", 
                    onTap: () { 
                      debugPrint('Settings button pressed'); 
                    }
                  ),
                  const SizedBox(height: 16),
                  SettingsActionRow(
                    label: "Change password", 
                    onTap: () { 
                      debugPrint('Change password button pressed'); 
                    }
                  ),
                ]
              ),
              
              const SizedBox(height: 24),
              
              SettingsCard(
                title: 'Privacy',
                children: [
                  // AI Meal Analysis toggle
                  SettingsSwitchRow(
                    label: 'Enable AI Meal Analysis',
                    value: _aiMealAnalysisEnabled,
                    onChanged: (value) {
                      setState(() {
                        _aiMealAnalysisEnabled = value;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  // Private Mode toggle
                  SettingsSwitchRow(
                    label: 'Private Mode',
                    value: _privateModeEnabled,
                    onChanged: (value) {
                      setState(() {
                        _privateModeEnabled = value;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  // Block List
                  SettingsActionRow(
                    label: 'View Block List',
                    onTap: () {
                      // Handle view block list action
                    },
                  ),
                ]
              ),
              
              const SizedBox(height: 24),
              
              SettingsCard(
                title: 'Data Management',
                children: [
                  SettingsActionRow(
                    label: 'Delete Fitness/Diet/Sleep Data',
                    labelColor: Colors.red,
                    onTap: () {
                      // Handle delete data action
                    },
                  ),
                ]
              ),
              
              const SizedBox(height: 32),
              
              Center(
                child: SignOutButton(
                  onPressed: () async {
                    final authProvider = Provider.of<AuthProvider>(context, listen: false);
                    await authProvider.signOut();
                    Navigator.of(context).pushReplacementNamed(Routes.login);
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
