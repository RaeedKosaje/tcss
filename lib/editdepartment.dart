import 'package:flutter/material.dart';
import 'package:untitled1/drawer.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'main.dart';

class EditDepartment extends StatelessWidget {
  final int departmentid;
  const EditDepartment({super.key, required this.departmentid});

  @override
  Widget build(BuildContext context) {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController noteController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit User'),
      ),
      drawer: NavDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'New department Name'),
            ),
            TextField(
              controller: noteController,
              decoration: const InputDecoration(labelText: 'New department note'),
            ),
            ElevatedButton(
              onPressed: () async {
                // استدعاء دالة تعديل المستخدم وانتظار النتيجة
                bool success = await editdepartment(
                  departmentid:departmentid,
                  name: nameController.text,
                  note: noteController.text,
                  context: context,
                );

                // إذا نجحت العملية، الرجوع إلى الصفحة السابقة
                if (success) {
                  Navigator.pop(context, true); // الرجوع مع القيمة true
                }
              },
              child: const Text('Edit User'),
            ),
          ],
        ),
      ),
    );
  }

  Future<bool> editdepartment({
    required int departmentid,
    required String name,
    required String note,
    required BuildContext context,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    String token = prefs.getString('token') ?? '';

    final Uri url = Uri.parse('$urlbase/editDepartment/$departmentid');

    final response = await http.put(
      url, headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: '{ "Note": "$note","name": "$name"}',
    );

    if (response.statusCode == 200) {
      // نجاح العملية
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('editDepartment updated successfully')),
      );
      return true;
    } else {
      // فشل العملية
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update editDepartment')),
      );
      return false;
    }
  }
}
