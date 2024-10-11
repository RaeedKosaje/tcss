import 'package:flutter/material.dart';
import 'package:untitled1/drawer.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'main.dart';

class CreateMaintenanceService extends StatelessWidget {
  final int deviceId;

  const CreateMaintenanceService({super.key, required this.deviceId});

  @override
  Widget build(BuildContext context) {
    final TextEditingController descriptionController = TextEditingController();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Maintenance Service'),
      ),
      drawer: NavDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextFormField(
              controller: descriptionController,
              decoration: const InputDecoration(labelText: 'description'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                bool success = await createMaintenanceService(
                  description: descriptionController.text,
                  deviceId: deviceId,
                  context: context,
                );
                if (success) {
                  Navigator.pop(context, true);
                }
              },
              child: const Text('Create Maintenance Service'),
            ),
          ],
        ),
      ),
    );
  }

  Future<bool> createMaintenanceService({
    required int deviceId,
    required BuildContext context,
    required String description,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    String token = prefs.getString('token') ?? '';

    final Uri url = Uri.parse('$urlbase/createMaintenanceService/$deviceId');

    final response = await http.post(
      url,
      body: {
        'description': description.toString(),
      },
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Create Maintenance Service successfully')),
      );
      return true;
    } else {
      print(response.body);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to Create Maintenance Service')),
      );
      return false;
    }
  }
}
