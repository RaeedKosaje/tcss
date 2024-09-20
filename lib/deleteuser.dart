import 'package:flutter/material.dart';
import 'package:untitled1/drawer.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'main.dart';

class DeleteUser extends StatelessWidget {
  final int userId;

  const DeleteUser({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Delete User'),
      ),
      drawer: NavDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Are you sure you want to delete user with ID ?',
              style: const TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                bool success = await deleteUser(userId, context);
                if (success) {
                  Navigator.pop(context, true); // الرجوع مع إرجاع نجاح العملية
                }
              },
              child: const Text('Delete User'),
            ),
          ],
        ),
      ),
    );
  }

  Future<bool> deleteUser(int userId, BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    String token = prefs.getString('token') ?? '';

    final Uri url = Uri.parse('$urlbase/deleteUser/$userId');

    final response = await http.delete(
      url,
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User deleted successfully')),
      );
      return true;
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to delete user')),
      );
      return false;
    }
  }
}
