import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:untitled1/drawer.dart';
import 'package:http/http.dart' as http;
import 'main.dart';
import 'package:intl/intl.dart'; // مكتبة لتنسيق التاريخ

class Edithardwarekey extends StatefulWidget {
  final int deviceid;
  const Edithardwarekey({super.key, required this.deviceid});

  @override
  _EdithardwarekeyState createState() => _EdithardwarekeyState();
}

class _EdithardwarekeyState extends State<Edithardwarekey> {
  final TextEditingController typeController = TextEditingController();
  final TextEditingController serealController = TextEditingController();
  final TextEditingController exDateController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Hardware Key'),
        backgroundColor: Colors.teal, // نفس اللون المستخدم في شريط العنوان
      ),
      drawer: NavDrawer(),
      body: Stack(
        children: [
          // الخلفية
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('lib/images/edithardwarekey.png'), // مسار صورة الخلفية
                fit: BoxFit.cover, // جعل الصورة تغطي كامل الخلفية
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
                      // إضافة الشعار هنا
                      Image.asset(
                        'lib/images/edithardwarekey.png', // مسار الشعار
                        height: 100, // ارتفاع الشعار
                      ),
                      const SizedBox(height: 20), // مسافة بين الشعار والحقول

                      Text(
                        'Edit Hardware Key',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.teal,
                        ),
                      ),
                      const SizedBox(height: 20),
                      _buildTextField(typeController, 'Type'),
                      const SizedBox(height: 20),
                      _buildTextField(serealController, 'Serial Number'),
                      const SizedBox(height: 20),

                      // حقل تاريخ انتهاء الصلاحية
                      TextField(
                        controller: exDateController,
                        decoration: const InputDecoration(
                          labelText: 'Expiration Date',
                          border: OutlineInputBorder(),
                          filled: true,
                          fillColor: Colors.white70, // لون خلفية الحقل
                        ),
                        readOnly: true, // لجعل الحقل غير قابل للتحرير يدويًا
                        onTap: () async {
                          // إظهار مربع حوار اختيار التاريخ
                          DateTime? pickedDate = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime(2000), // أقل تاريخ يمكن اختياره
                            lastDate: DateTime(2101), // أقصى تاريخ يمكن اختياره
                          );

                          if (pickedDate != null) {
                            // إذا تم اختيار تاريخ
                            String formattedDate =
                            DateFormat('yyyy-MM-dd').format(pickedDate);
                            setState(() {
                              exDateController.text = formattedDate; // تحديث الحقل بالتاريخ
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 20),
                      _buildTextField(descriptionController, 'Description'),
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
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal,
                          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          elevation: 5,
                        ),
                        child: const Text(
                          'Edit Hardware Key',
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
        border: const OutlineInputBorder(),
        filled: true,
        fillColor: Colors.white70, // لون خلفية الحقل
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
    final Uri url = Uri.parse('$urlbase/editHardwarekey/${widget.deviceid}');
    final prefs = await SharedPreferences.getInstance();
    String token = prefs.getString('token') ?? '';

    final response = await http.put(
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
        const SnackBar(content: Text('Edit Hardware Key successfully')),
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
