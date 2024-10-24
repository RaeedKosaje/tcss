import 'package:flutter/material.dart';
import 'package:untitled1/drawer.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'main.dart';

class EditMaterial extends StatelessWidget {
  final int materialId;
  const EditMaterial({super.key, required this.materialId});

  @override
  Widget build(BuildContext context) {
    final TextEditingController codeController = TextEditingController();
    final TextEditingController nameController = TextEditingController();
    final TextEditingController quantityController = TextEditingController();
    final TextEditingController priceController = TextEditingController();
    GlobalKey<FormState> editMaterialForm = GlobalKey();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Material'),
        backgroundColor: Colors.blueAccent,
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
                  child: Form(
                    key: editMaterialForm,
                    child: Column(
                      mainAxisSize: MainAxisSize.min, // تعديل حجم العمود
                      children: <Widget>[
                        Image.asset(
                          'lib/images/editmaterial.png', // مسار الشعار
                          height: 100, // ارتفاع الشعار
                        ),
                        Text(
                          'Edit Material',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.teal,
                          ),
                        ),


                        const SizedBox(height: 20),
                        _buildTextField(nameController, 'New Material Name', (value) {
                          if (value!.length < 2) {
                            return 'The name must be at least 2 characters.';
                          }
                          return null;
                        }),
                        const SizedBox(height: 20),
                        _buildTextField(codeController, 'New Material Code', (value) {
                          if (value!.isEmpty) {
                            return 'The code must not be empty.';
                          }
                          return null;
                        }, obscureText: true),

                        const SizedBox(height: 20),
                        _buildTextField(quantityController, 'New Material Quantity', null),
                        const SizedBox(height: 20),
                        _buildTextField(priceController, 'New Material Price', (value) {
                          if (value!.length < 2) {
                            return 'The price must be at least 2 characters.';
                          }
                          return null;
                        }),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () async {
                            // استدعاء دالة تعديل المستخدم وانتظار النتيجة
                            if (editMaterialForm.currentState!.validate()) {
                              bool success = false;
                              success = await editMaterial(
                                materialId: materialId,
                                name: nameController.text,
                                code: codeController.text,
                                quantity: quantityController.text,
                                price: priceController.text,
                                context: context,
                              );

                              // إذا نجحت العملية، الرجوع إلى الصفحة السابقة
                              if (success) {
                                Navigator.pop(context, true); // الرجوع مع القيمة true
                              }
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
                            'Edit Material',
                            style: TextStyle(fontSize: 18),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, String? Function(String?)? validator, {bool obscureText = false}) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(),
        filled: true,
        fillColor: Colors.white70, // لون خلفية الحقل
      ),
      obscureText: obscureText,
      validator: validator,
    );
  }

  Future<bool> editMaterial({
    required int materialId,
    required String name,
    required String code,
    required String quantity,
    required String price,
    required BuildContext context,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    String token = prefs.getString('token') ?? '';

    final Uri url = Uri.parse('$urlbase/editMaterial/$materialId');

    final response = await http.put(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: '{"name": "$name","quantity":$quantity,"price":"$price"}',
    );

    if (response.statusCode == 200) {
      // نجاح العملية
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Material updated successfully')),
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
