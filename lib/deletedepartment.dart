import 'package:flutter/material.dart';
import 'package:untitled1/drawer.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'main.dart';
class Deletedepartment extends StatelessWidget {
  final int departmentid;
  const Deletedepartment({super.key, required this.departmentid});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Delete Department'),
      ),
      drawer: NavDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Are you sure you want to delete the department ?',
              style: const TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                bool success = await deletedepartment(departmentid, context);
                if (success) {
                  Navigator.pop(context, true); // Navigate back with success
                }
              },
              child: Text('Delete Department'),
            ),
          ],
        ),
      ),
    );
  }

  Future<bool> deletedepartment(int departmentid, BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    String token = prefs.getString('token') ?? '';

    final Uri url = Uri.parse('$urlbase/deleteDepartment/$departmentid');

    final response = await http.delete(url, headers: {
      'Authorization': 'Bearer $token',
    });

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Department deleted successfully')),
      );
      return true;
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to delete department')),
      );
      return false;
    }
  }
}
