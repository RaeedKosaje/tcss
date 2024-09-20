import 'package:flutter/material.dart';
import 'package:untitled1/drawer.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'main.dart';

class CreateUser extends StatelessWidget {
  const CreateUser({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController userNameController = TextEditingController();
    final TextEditingController userPasswordController =
        TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create User'),
      ),
      drawer: NavDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextField(
              controller: userNameController,
              decoration: const InputDecoration(labelText: 'Username'),
            ),
            TextField(
              controller: userPasswordController,
              decoration: const InputDecoration(labelText: 'Password'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                bool success = await createUser(
                  context: context,
                  name: userNameController.text,
                  password: userPasswordController.text,
                );
                if (success) {
                  Navigator.pop(context, true);
                }
              },
              child: const Text('Create User'),
            ),
          ],
        ),
      ),
    );
  }

  Future<bool> createUser({
    required BuildContext context,
    required String name,
    required String password,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    String token = prefs.getString('token') ?? '';

    final Uri url = Uri.parse('$urlbase/createUser');

    final response = await http.post(
      url,
      body: {
        'name': name,
        'password': password,
      },
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User created successfully')),
      );
      return true;
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to create user')),
      );
      return false;
    }
  }
}
