import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:untitled1/drawer.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'main.dart';

class EditProperties extends StatelessWidget {
  final int Deviceid;

  const EditProperties({
    super.key,
    required this.Deviceid,
  });

  @override
  Widget build(BuildContext context) {
    final TextEditingController CPUController =
        TextEditingController(text: "cpu");
    final TextEditingController MotherboardController =
        TextEditingController(text: "Motherboard");
    final TextEditingController RAMController =
        TextEditingController(text: "RAM");
    final TextEditingController HardController =
        TextEditingController(text: "Hard");
    final TextEditingController GraphicsController =
        TextEditingController(text: "Graphics");
    final TextEditingController powerSupplyController =
        TextEditingController(text: "powerSupply");
    final TextEditingController OSController =
        TextEditingController(text: "OS");
    final TextEditingController NICController =
        TextEditingController(text: "NIC");

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Properties'),
        backgroundColor: Colors.teal, // تخصيص لون شريط العنوان
      ),
      drawer: NavDrawer(),
      body: Stack(
        children: [
          // الخلفية
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('lib/images/editproperties.png'), // مسار صورة الخلفية
                fit: BoxFit.cover, // جعل الصورة تغطي كامل الخلفية
              ),
            ),
          ),
          // محتوى الصفحة
          SingleChildScrollView(
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
                      Text(
                        'Edit Device Properties',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.teal,
                        ),
                      ),
                      const SizedBox(height: 20),
                      // حقول الإدخال
                      _buildTextField(CPUController, 'New CPU'),
                      const SizedBox(height: 20),
                      _buildTextField(MotherboardController, 'New Motherboard'),
                      const SizedBox(height: 20),
                      _buildTextField(RAMController, 'New RAM'),
                      const SizedBox(height: 20),
                      _buildTextField(HardController, 'New Hard'),
                      const SizedBox(height: 20),
                      _buildTextField(GraphicsController, 'New Graphics'),
                      const SizedBox(height: 20),
                      _buildTextField(
                          powerSupplyController, 'New Power Supply'),
                      const SizedBox(height: 20),
                      _buildTextField(OSController, 'New OS'),
                      const SizedBox(height: 20),
                      _buildTextField(NICController, 'New NIC'),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () async {
                          bool success = await editproperties(
                            CPU: CPUController.text,
                            Motherboard: MotherboardController.text,
                            RAM: RAMController.text,
                            Hard: HardController.text,
                            Graphics: GraphicsController.text,
                            powerSupply: powerSupplyController.text,
                            OS: OSController.text,
                            NIC: NICController.text,
                            Deviceid: Deviceid,
                            context: context,
                          );
                          if (success) {
                            Navigator.pop(context, true);
                            Navigator.pop(context); // الرجوع مع القيمة true
                            Navigator.pop(context); // الرجوع مع القيمة true
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 30, vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          elevation: 5,
                        ),
                        child: const Text(
                          'Edit Properties',
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

  Future<bool> editproperties({
    required String CPU,
    required String Motherboard,
    required String RAM,
    required String Hard,
    required String Graphics,
    required String powerSupply,
    required String OS,
    required String NIC,
    required int Deviceid,
    required BuildContext context,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    String token = prefs.getString('token') ?? '';

    final Uri url = Uri.parse('$urlbase/editProperties/$Deviceid');

    final response = await http.put(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'CPU': CPU,
        'Motherboard': Motherboard,
        'RAM': RAM,
        'Hard': Hard,
        'Graphics': Graphics,
        'powerSupply': powerSupply,
        'OS': OS,
        'NIC': NIC,
      }),
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Device properties updated successfully')),
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
