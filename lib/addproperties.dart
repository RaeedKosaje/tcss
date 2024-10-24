import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:untitled1/drawer.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'main.dart';

class AddProperties extends StatelessWidget {
  final int DeviceId;

  AddProperties({super.key, required this.DeviceId});

  @override
  Widget build(BuildContext context) {
    // إنشاء Controllers للحقول
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
        title: const Text('Add Properties'),
        backgroundColor: Colors.blueAccent,
      ),
      drawer: NavDrawer(),
      body: Stack(
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
          // المحتويات
          SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              elevation: 8,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,

                  mainAxisAlignment: MainAxisAlignment.start,                  children: <Widget>[
                    Image.asset(
                      'lib/images/editproperties.png',

                      height: 300,
                    ),
                    _buildTextField(CPUController, 'New CPU'),
                    _buildTextField(MotherboardController, 'New Motherboard'),
                    _buildTextField(RAMController, 'New RAM'),
                    _buildTextField(HardController, 'New Hard'),
                    _buildTextField(GraphicsController, 'New Graphics'),
                    _buildTextField(powerSupplyController, 'New Power Supply'),
                    _buildTextField(OSController, 'New OS'),
                    _buildTextField(NICController, 'New NIC'),
                    const SizedBox(height: 20),
                    ElevatedButton(
                        onPressed: () async {
                          bool success = await addProperties(
                            CPU: CPUController.text,
                            Motherboard: MotherboardController.text,
                            RAM: RAMController.text,
                            Hard: HardController.text,
                            Graphics: GraphicsController.text,
                            powerSupply: powerSupplyController.text,
                            OS: OSController.text,
                            NIC: NICController.text,
                            deviceId: DeviceId,
                            context: context,
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
                          'Add Properties'),
                    ),

                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
          filled: true,
          fillColor: Colors.white70,
        ),
      ),
    );
  }

  // دالة لإضافة الخصائص
  Future<bool> addProperties({
    required String CPU,
    required String Motherboard,
    required String RAM,
    required String Hard,
    required String Graphics,
    required String powerSupply,
    required String OS,
    required String NIC,
    required int deviceId,
    required BuildContext context,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    String token = prefs.getString('token') ?? '';

    final Uri url = Uri.parse('$urlbase/createProperty/$deviceId');

    final response = await http.post(
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
