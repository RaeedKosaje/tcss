import 'package:flutter/material.dart';
import 'package:untitled1/drawer.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'main.dart';

class CreateMaterial extends StatelessWidget {
  const CreateMaterial({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController quantityController = TextEditingController();
    final TextEditingController priceController = TextEditingController();
    final TextEditingController codeController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Material'),
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
          SingleChildScrollView(
              child:
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(top: 100.0),
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
                        'lib/images/creatematerial.png', // تأكد من وضع مسار الصورة الصحيح
                        height: 300, // ارتفاع الشعار
                      ),
                      Text(
                        'Create Material',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.teal,
                        ),
                      ),
                      const SizedBox(height: 20),
                      _buildTextField(nameController, 'Material Name'),
                      const SizedBox(height: 20),
                      _buildTextField(quantityController, 'Quantity'),
                      const SizedBox(height: 20),
                      _buildTextField(codeController, 'Code'),
                      const SizedBox(height: 20),
                      _buildTextField(priceController, 'Price'),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () async {
                          bool success = await creatematerial(
                            context: context,
                            code: codeController.text,
                            name: nameController.text,
                            quantity: quantityController.text,
                            price: priceController.text,
                          );
                          if (success) {
                            Navigator.pop(context, true);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white10,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 40, vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          elevation: 5,
                        ),
                        child: const Text(
                          'Create Material',
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
            ))],
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

  Future<bool> creatematerial({
    required BuildContext context,
    required String name,
    required String quantity,
    required String price,
    required String code,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    String token = prefs.getString('token') ?? '';

    final Uri url = Uri.parse('$urlbase/createMaterial');

    final response = await http.post(
      url,
      body: {
        'name': name,
        'quantity': quantity,
        'price': price,
        'code': code,
      },
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Material created successfully')),
      );
      return true;
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to create material')),
      );
      return false;
    }
  }
}
