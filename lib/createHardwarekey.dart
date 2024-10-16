import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:untitled1/drawer.dart';
import 'package:http/http.dart' as http;
import 'main.dart';
import 'package:intl/intl.dart'; // لتنسيق التاريخ

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
            // حقل لاختيار التاريخ
            TextField(
              controller: exDateController,
              readOnly: true, // اجعل الحقل غير قابل للتحرير اليدوي
              decoration: const InputDecoration(labelText: 'Expiration Date'),
              onTap: () async {
                // عند الضغط على الحقل، افتح منتقي التاريخ
                DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(), // التاريخ الافتراضي الحالي
                  firstDate: DateTime(2000), // أقل تاريخ مسموح
                  lastDate: DateTime(2100), // أعلى تاريخ مسموح
                );

                if (pickedDate != null) {
                  String formattedDate = DateFormat('yyyy-MM-dd').format(pickedDate);
                  exDateController.text = formattedDate; // املأ الحقل بالتاريخ المختار
                }
              },
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
              child: const Text('Create Hardware Key'),
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
        const SnackBar(content: Text('Hardware key created successfully')),
      );
      return true;
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(response.body)),
      );
      return false;
    }
  }
}
