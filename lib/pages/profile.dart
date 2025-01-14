import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nanoid/nanoid.dart';
import '../classes/global.dart';
import '../providers/theme_provider.dart';
import 'home_screen.dart';

class Profile extends StatefulWidget {
  final bool onLogin;

  const Profile({Key? key, required this.onLogin}) : super(key: key);
  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  TextEditingController myName = TextEditingController();
  bool loading = true;
  var customLengthId = nanoid(6);

  @override
  void initState() {
    super.initState();
    getDetails();
  }

  Future<void> getDetails() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final name = prefs.getString('p_name') ?? '';
      final id = prefs.getString('p_id') ?? '';

      if (mounted) {
        setState(() {
          myName.text = name;
          customLengthId = id.isNotEmpty ? id : customLengthId;
        });

        if (name.isNotEmpty && id.isNotEmpty && widget.onLogin) {
          navigateToHomeScreen();
        } else {
          setState(() {
            loading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          loading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading profile: $e')),
        );
      }
    }
  }

  void navigateToHomeScreen() {
    Global.myName = myName.text;
    if (!widget.onLogin) {
      Navigator.pop(context);
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    }
  }

  Future<void> saveProfile() async {
    if (myName.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid name')),
      );
      return;
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('p_name', myName.text.trim());
      await prefs.setString('p_id', customLengthId);
      navigateToHomeScreen();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving profile: $e')),
      );
    }
  }

  Widget buildThemeSelector() {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                'Theme Selection',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Container(
              height: 120,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: ThemeProvider.availableThemes.length,
                itemBuilder: (context, index) {
                  String themeName = ThemeProvider.availableThemes.keys.elementAt(index);
                  bool isSelected = themeName == themeProvider.currentTheme;

                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Material(
                      elevation: isSelected ? 8 : 2,
                      borderRadius: BorderRadius.circular(12),
                      child: InkWell(
                        onTap: () => themeProvider.setTheme(themeName),
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          width: 100,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: isSelected
                                ? Border.all(
                              color: Theme.of(context).colorScheme.primary,
                              width: 2,
                            )
                                : null,
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                isSelected
                                    ? Icons.check_circle
                                    : Icons.brightness_auto,
                                color: ThemeProvider.availableThemes[themeName]!.primaryColor,
                                size: 32,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                themeName,
                                style: TextStyle(
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        elevation: 0,
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Your Profile',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: myName,
                          decoration: InputDecoration(
                            labelText: 'Name',
                            hintText: 'What do people call you?',
                            prefixIcon: const Icon(Icons.person),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            filled: true,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Your ID: $customLengthId',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                buildThemeSelector(),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: saveProfile,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Save Profile',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
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

  @override
  void dispose() {
    myName.dispose();
    super.dispose();
  }
}