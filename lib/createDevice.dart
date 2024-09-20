import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:untitled1/drawer.dart';
import 'package:http/http.dart' as http;
import 'main.dart';

class Createdevice extends StatelessWidget {
  final int departmentId;
  const Createdevice({super.key, required this.departmentId});

  @override
  Widget build(BuildContext context) {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController typeController = TextEditingController();
    final TextEditingController descriptionController = TextEditingController();
    final TextEditingController noteController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Device'),
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
              controller: descriptionController,
              decoration: const InputDecoration(labelText: 'Description'),
            ),
            TextField(
              controller: noteController,
              decoration: const InputDecoration(labelText: 'Note'),
            ),
            TextField(
              controller: typeController,
              decoration: const InputDecoration(labelText: 'Type'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                bool success = await createDevice(
                  context: context,
                  name: nameController.text,
                  type: typeController.text,
                  description: descriptionController.text,
                  note: noteController.text,
                );
                if (success) {
                  Navigator.pop(context, true);
                }
              },
              child: const Text('Create Device'),
            ),
          ],
        ),
      ),
    );
  }

  Future<bool> createDevice({
    required BuildContext context,
    required String name,
    required String note,
    required String type,
    required String description,
  }) async {
    final Uri url = Uri.parse('$urlbase/createDevice/$departmentId');
    final prefs = await SharedPreferences.getInstance();
    String token = prefs.getString('token') ?? '';

    final response = await http.post(
      url,
      body: {
        "name": name,
        "type": type,
        "description": description,
        "Note": note,
      },
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Device created successfully')),
      );
      return true;
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to create device')),
      );
      return false;
    }
  }
}
