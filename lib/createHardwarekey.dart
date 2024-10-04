import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:untitled1/drawer.dart';
import 'package:http/http.dart' as http;
import 'main.dart';

class Creathardwarekey extends StatelessWidget {
  final int deviceid;
  const Creathardwarekey({super.key, required this.deviceid});

  @override
  Widget build(BuildContext context) {
    final TextEditingController typeController = TextEditingController();
    final TextEditingController serealController = TextEditingController();
    final TextEditingController exDateController = TextEditingController();
    final TextEditingController descriptionController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create hardware key'),
      ),
      drawer: NavDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextField(
              controller: typeController,
              decoration: const InputDecoration(labelText: 'type'),
            ),
            TextField(
              controller: serealController,
              decoration: const InputDecoration(labelText: 'serealController'),
            ),
            TextField(
              controller: exDateController,
              decoration: const InputDecoration(labelText: 'exDateController'),
            ),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(labelText: 'descriptionController'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                bool success = await createDevice(
                  context: context,
                  type: typeController.text,
                  sereal: serealController.text,
                  exDate: exDateController.text,
                  description: descriptionController.text,
                );
                if (success) {
                  Navigator.pop(context, true);
                }
              },
              child: const Text('create Hardware key'),
            ),
          ],
        ),
      ),
    );
  }

  Future<bool> createDevice({
    required BuildContext context,
    required String type,
    required String sereal,
    required String exDate,
    required String description,
  }) async {
    final Uri url = Uri.parse('$urlbase/createHardwarekey/$deviceid');
    final prefs = await SharedPreferences.getInstance();
    String token = prefs.getString('token') ?? '';

    final response = await http.post(
      url,
      body: {

        "type": type,
        "sereal": sereal,
        "exDate": exDate,
        "description": description,
      },
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('create Hardware key successfully')),
      );
      return true;
    } else {
      // فشل العملية
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(response.body)),
      );
      return false;
    }
  }
}
