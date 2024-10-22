import 'dart:convert'; // إضافة مكتبة لتحويل البيانات إلى JSON
import 'package:flutter/material.dart';
import 'package:untitled1/drawer.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'main.dart';

class EditDevice extends StatelessWidget {
  final int Deviceid;
  const EditDevice({super.key, required this.Deviceid});

  @override
  Widget build(BuildContext context) {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController typeController = TextEditingController();
    final TextEditingController descriptionController = TextEditingController();
    final TextEditingController noteController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Device '),
      ),
      drawer: NavDrawer(),
      body:Stack(
          children: [
      // الخلفية
      Container(
      decoration: const BoxDecoration(
      image: DecorationImage(
          image: AssetImage('lib/images/editdevice.png'), // مسار صورة الخلفية
      fit: BoxFit.cover, // جعل الصورة تغطي كامل الخلفية
    ),
    ),
    ),
      Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'New Device Name'),
            ),
            TextField(
              controller: typeController,
              decoration: const InputDecoration(labelText: 'New Device type '),
            ),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(labelText: 'New Device description note'),
            ),
            TextField(
              controller: noteController,
              decoration: const InputDecoration(labelText: 'New Device note'),
            ),
            ElevatedButton(
              onPressed: () async {
                bool success = await editdevice(
                  Deviceid: Deviceid,
                  name: nameController.text,
                  type: typeController.text,
                  description: descriptionController.text,
                  note: noteController.text,
                  context: context,
                );
                if (success) {
                  Navigator.pop(context, true); // الرجوع مع القيمة true
                }
              },
              child: const Text('Edit Device'),
            ),
          ],
        ),
      ),
    ]));
  }

  Future<bool> editdevice({
    required int Deviceid,
    required String name,
    required String note,
    required String type,
    required String description,
    required BuildContext context,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    String token = prefs.getString('token') ?? '';

    final Uri url = Uri.parse('$urlbase/editDevice/$Deviceid');

    // استخدام jsonEncode لتحويل البيانات إلى JSON صحيح
    final response = await http.put(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'Note': note,
        'name': name,
        'type': type,
        'description': description,
      }),
    );

    if (response.statusCode == 200) {
      // نجاح العملية
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('editDevice updated successfully')),
      );
      return true;
    } else {
      // فشل العملية
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update editDevice')),
      );
      return false;
    }
  }
}
