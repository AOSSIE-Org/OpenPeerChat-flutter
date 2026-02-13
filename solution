import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'package:nanoid/nanoid.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../classes/global.dart';

class Profile extends StatefulWidget {
  final bool onLogin;
  const Profile({Key? key, required this.onLogin}) : super(key: key);

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  final TextEditingController myName = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool loading = true;
  String customLengthId = nanoid(6);

  @override
  void initState() {
    super.initState();
    getDetails();
  }

  @override
  void dispose() {
    myName.dispose();
    super.dispose();
  }

  Future<void> getDetails() async {
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString('p_name') ?? '';
    final id = prefs.getString('p_id') ?? '';

    setState(() {
      myName.text = name;
      if (id.isNotEmpty) customLengthId = id;
      loading = false;
    });

    // If profile already exists and we arrived here from login flow, go home
    if (name.isNotEmpty && id.isNotEmpty && widget.onLogin) {
      navigateToHomeScreen();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // show what the final username will look like
                  Text('Your username will be: ${myName.text}$customLengthId'),
                  const SizedBox(height: 16),
                  Form(
                    key: _formKey,
                    child: TextFormField(
                      controller: myName,
                      decoration: const InputDecoration(
                        icon: Icon(Icons.person),
                        hintText: 'What do people call you?',
                        labelText: 'Name *',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        final v = value?.trim() ?? '';
                        if (v.isEmpty) return 'Please enter a name';
                        if (v.contains('@')) return 'Do not use the @ character';
                        if (v.length <= 3) return 'Name should be greater than 3 characters';
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () async {
                      if (!(_formKey.currentState?.validate() ?? false)) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Please fix the errors')),
                        );
                        return;
                      }

                      final prefs = await SharedPreferences.getInstance();
                      await prefs.setString('p_name', myName.text.trim());
                      await prefs.setString('p_id', customLengthId);

                      navigateToHomeScreen();
                    },
                    child: const Text('Save'),
                  ),
                ],
              ),
            ),
    );
  }
}
