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
        backgroundColor: Colors.blueAccent,
      ),
      drawer: NavDrawer(),
      body:Stack(
          children: [

      Container(
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(width: 5.0, color: Colors.blue), // إطار علوي
          bottom: BorderSide(width: 5.0, color: Colors.blue), // إطار سفلي
          left: BorderSide(width: 5.0, color: Colors.blue), // إطار يساري
          right: BorderSide(width: 5.0, color: Colors.blue), // إطار يميني
        ),
    ),
    ),
            SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child:
                Center(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 100.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image.asset(
              'lib/images/editdevice.png',
              height: 300,
            ),

            const SizedBox(height: 20),
            // حقول الإدخال
            _buildTextField(nameController, 'name'),
            const SizedBox(height: 20),
            // حقول الإدخال
            _buildTextField(typeController, 'type'),
            const SizedBox(height: 20),
            // حقول الإدخال
            _buildTextField(descriptionController, 'description'),
            const SizedBox(height: 20),
            // حقول الإدخال
            _buildTextField(noteController, 'note'),
            const SizedBox(height: 20),
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
                  Navigator.pop(context, true);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white10,
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                elevation: 5,
              ),
              child: const Text('Edit Device'),
            ),
          ],
        ),
      ),
    )) ]));
  }

  Widget _buildTextField(TextEditingController controller, String label) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(),
        filled: true,
        fillColor: Colors.white70, // لون خلفية الحقل
      ),
    );
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
