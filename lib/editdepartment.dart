import 'dart:convert';
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
        title: const Text('Edit Department'),
        backgroundColor: Colors.blueAccent, // تخصيص لون شريط العنوان
      ),
      drawer: NavDrawer(),
      body: Stack(
        children: [
          // الخلفية
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
          // محتوى الصفحة
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20), // زوايا مستديرة
                ),
                elevation: 10, // ظل الكارد
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min, // تعديل حجم العمود
                    children: <Widget>[
                      Image.asset(
                        'lib/images/editdepartment.png', // تأكد من وضع مسار الصورة الصحيح
                        height: 300, // ارتفاع الشعار
                      ),

                      Text(
                        'Edit Department',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.teal,
                        ),
                      ),
                      const SizedBox(height: 20),
                      _buildTextField(nameController, 'New Department Name'),
                      const SizedBox(height: 20),
                      _buildTextField(noteController, 'New Department Note'),
                      const SizedBox(height: 20),
                      ElevatedButton(

                        onPressed: () async {
                          bool success = await editdepartment(
                            departmentid: departmentid,
                            name: nameController.text,
                            note: noteController.text,
                            context: context,
                          );

                          // إذا نجحت العملية، الرجوع إلى الصفحة السابقة
                          if (success) {
                            Navigator.pop(context, true); // الرجوع مع القيمة true
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
                        child: const Text(
                          'Edit Department',
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
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
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({"Note": note, "name": name}),
    );

    if (response.statusCode == 200) {
      // نجاح العملية
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Edit Department updated successfully')),
      );
      return true;
    } else {
      // فشل العملية
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update Edit Department')),
      );
      return false;
    }
  }
}
