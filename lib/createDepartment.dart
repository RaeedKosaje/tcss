import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:untitled1/drawer.dart';
import 'package:http/http.dart' as http;
import 'main.dart';

class CreateDepartment extends StatelessWidget {
  final int floorId;
  const CreateDepartment({super.key, required this.floorId});

  @override
  Widget build(BuildContext context) {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController noteController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Department'),
      ),
      drawer: NavDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            TextField(
              controller: noteController,
              decoration: const InputDecoration(labelText: 'Note'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                bool success = await createDepartment(
                  name: nameController.text,
                  id: floorId,
                  note: noteController.text,
                  context: context,
                );
                if (success) {
                  Navigator.pop(context, true);
                }
              },
              child: const Text('Create Department'),
            ),
          ],
        ),
      ),
    );
  }

  Future<bool> createDepartment({
    required String name,
    required int id,
    required String note,
    required BuildContext context,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    String token = prefs.getString('token') ?? '';
    final Uri url = Uri.parse('$urlbase/createDepartment/$id');

    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        "name": name,
        "Note": note,
      }),
    );

    if (response.statusCode == 200) {
      // نجاح العملية
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Department created successfully')),
      );
      return true;
    } else {
      // فشل العملية
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to create department')),
      );
      return false;
    }
  }
}
