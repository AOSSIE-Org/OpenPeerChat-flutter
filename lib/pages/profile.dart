import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nanoid/nanoid.dart';
import '../classes/global.dart';

import '../services/communication_service.dart';

import '../providers/theme_provider.dart';
import 'home_screen.dart';


class Profile extends StatefulWidget {
  final bool onLogin;
  const Profile({Key? key, required this.onLogin}) : super(key: key);

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  late final AnimationController _animationController;
  late final Animation<double> _fadeAnimation;

  String _userId = '';
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _loadProfileData();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _animationController.forward();
  }

  Future<void> _loadProfileData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final name = prefs.getString('p_name') ?? '';
      final savedId = prefs.getString('p_id') ?? '';

      if (mounted) {
        setState(() {
          _nameController.text = name;
          _userId = savedId.isNotEmpty ? savedId : nanoid(6);
          _isLoading = false;
        });

        if (name.isNotEmpty && savedId.isNotEmpty && widget.onLogin) {
          Global.myName = name; // Ensure name is set before navigation
          _navigateToHome();
        }
      }
    } catch (e) {
      _handleError('Failed to load profile', e);
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final name = _nameController.text.trim();

      await prefs.setString('p_name', name);
      await prefs.setString('p_id', _userId);

      Global.myName = name; // Set global name before navigation
      _navigateToHome();
    } catch (e) {
      _handleError('Failed to save profile', e);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }


  void _navigateToHome() {
    if (!widget.onLogin) {
      Navigator.pop(context);
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    }
  }

  void _handleError(String message, dynamic error) {
    if (!mounted) return;
    setState(() => _isLoading = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$message: $error'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Widget _buildProfileCard() {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      elevation: 8,
      shadowColor: colorScheme.shadow.withOpacity(0.2),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Profile Details',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.primary,
                ),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _nameController,
                validator: (value) =>
                value!.trim().isEmpty ? 'Name is required' : null,
                decoration: InputDecoration(
                  labelText: 'Display Name',
                  hintText: 'Enter your display name',
                  prefixIcon: Icon(Icons.person_outline,
                      color: colorScheme.primary),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(Icons.fingerprint, color: colorScheme.primary),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Your Unique ID',
                          style: TextStyle(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                        Text(
                          _userId,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile Setup'),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : FadeTransition(
        opacity: _fadeAnimation,
        child: CustomScrollView(
          slivers: [
            SliverFillRemaining(
              hasScrollBody: false,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildProfileCard(),
                    const SizedBox(height: 20),
                    const ThemeSelector(),
                    // Minimum spacing that ensures button visibility
                    SizedBox(height: MediaQuery.of(context).size.height * 0.08),
                    _buildSaveButton(),
                    // Safe area padding for bottom
                    SizedBox(height: MediaQuery.of(context).padding.bottom + 16),
                  ],
                ),
              ),
            ),

            ElevatedButton(
              onPressed: () async {
                final prefs = await SharedPreferences.getInstance();
                // saving the name and id to shared preferences
                prefs.setString('p_name', myName.text);
                prefs.setString('p_id', customLengthId);
                CommunicationService.broadcastProfileUpdate(customLengthId, myName.text);
                // On pressing, move to the home screen
                navigateToHomeScreen();
              },
              child: const Text("Save"),
            )

          ],
        ),
      ),
    );
  }


  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _isSaving ? null : _saveProfile,
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: _isSaving
            ? const SizedBox(
          height: 24,
          width: 24,
          child: CircularProgressIndicator(),
        )
            : const Text(
          'Save Profile',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _animationController.dispose();
    super.dispose();
  }
}
class ThemeSelector extends StatelessWidget {
  const ThemeSelector({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            'Choose Base Theme',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        BaseThemeSelector(),

        const SizedBox(height: 24),

        const Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            'Choose Color Scheme (Optional)',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        ColorSchemeSelector(),
      ],
    );
  }
}

class BaseThemeSelector extends StatelessWidget {
  const BaseThemeSelector({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: ThemeProvider.baseThemes.keys.map((themeName) {
          final isSelected = themeName == themeProvider.baseTheme;

          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: ThemeOption(
              name: themeName,
              isSelected: isSelected,
              onTap: () => themeProvider.setBaseTheme(themeName),
              color: themeName == 'Light'
                  ? Colors.blue.shade100
                  : Colors.grey.shade800,
              secondaryColor: themeName == 'Light'
                  ? Colors.blue.shade200
                  : Colors.grey.shade900,
            ),

          );
        }).toList(),
      ),
    );
  }
}

class ColorSchemeSelector extends StatelessWidget {
  const ColorSchemeSelector({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: ThemeProvider.colorSchemes.entries.map((entry) {
          final isSelected = entry.key == themeProvider.colorSchemeName;
          final scheme = isDark
              ? ThemeProvider.getDarkScheme(entry.key)
              : entry.value;

          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: ThemeOption(
              name: entry.key,
              isSelected: isSelected,
              onTap: () => themeProvider.setColorScheme(entry.key),
              color: scheme.primary,
              secondaryColor: scheme.secondary,
            ),
          );
        }).toList(),
      ),
    );
  }
}

class ThemeOption extends StatelessWidget {
  final String name;
  final bool isSelected;
  final VoidCallback onTap;
  final Color color;
  final Color secondaryColor;

  const ThemeOption({
    Key? key,
    required this.name,
    required this.isSelected,
    required this.onTap,
    required this.color,
    required this.secondaryColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme
        .of(context)
        .colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color, secondaryColor],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? colorScheme.primary : Colors.transparent,
            width: 2,
          ),
          boxShadow: isSelected ? [
            BoxShadow(
              color: colorScheme.shadow.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ] : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              name,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: color.computeLuminance() > 0.5 ? Colors.black : Colors
                    .white,
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                size: 16,
                color: color.computeLuminance() > 0.5 ? Colors.black : Colors
                    .white,
              ),
          ],
        ),
      ),
    );
  }

}