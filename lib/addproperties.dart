import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:untitled1/drawer.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'main.dart';

class AddProperties extends StatelessWidget {
  final int Deviceid;

   AddProperties({
    super.key,
    required this.Deviceid // تأكيد أن Deviceid نوعه int
  });

  @override
  Widget build(BuildContext context) {
    final TextEditingController CPUController = TextEditingController(text: "cpu");
    final TextEditingController MotherboardController = TextEditingController(text: "Motherboard");
    final TextEditingController RAMController = TextEditingController(text: "RAM");
    final TextEditingController HardController = TextEditingController(text: "Hard");
    final TextEditingController GraphicsController = TextEditingController(text: "Graphics");
    final TextEditingController powerSupplyController = TextEditingController(text: "powerSupply");
    final TextEditingController OSController = TextEditingController(text: "OS");
    final TextEditingController NICController = TextEditingController(text: "NIC");

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Properties'),
      ),
      drawer: NavDrawer(),
      body: SingleChildScrollView( // إضافة SingleChildScrollView هنا
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start, // تغيير المركز إلى البداية
          children: <Widget>[
            TextField(
              controller: CPUController,
              decoration: const InputDecoration(labelText: 'New CPU'),
            ),
            TextField(
              controller: MotherboardController,
              decoration: const InputDecoration(labelText: 'New Motherboard'),
            ),
            TextField(
              controller: RAMController,
              decoration: const InputDecoration(labelText: 'New RAM'),
            ),
            TextField(
              controller: HardController,
              decoration: const InputDecoration(labelText: 'New Hard'),
            ),
            TextField(
              controller: GraphicsController,
              decoration: const InputDecoration(labelText: 'New Graphics'),
            ),
            TextField(
              controller: powerSupplyController,
              decoration: const InputDecoration(labelText: 'New Power Supply'),
            ),
            TextField(
              controller: OSController,
              decoration: const InputDecoration(labelText: 'New OS'),
            ),
            TextField(
              controller: NICController,
              decoration: const InputDecoration(labelText: 'New NIC'),
            ),
            const SizedBox(height: 20), // إضافة مسافة إضافية
            ElevatedButton(
              onPressed: () async {
                bool success = await addtproperties(
                  CPU: CPUController.text,
                  Motherboard: MotherboardController.text,
                  RAM: RAMController.text,
                  Hard: HardController.text,
                  Graphics: GraphicsController.text,
                  powerSupply: powerSupplyController.text,
                  OS: OSController.text,
                  NIC: NICController.text,
                  Deviceid: Deviceid, // تمرير Deviceid كـ int
                  context: context,
                );
                if (success) {
                  Navigator.pop(context, true); // الرجوع مع القيمة true
                }
              },
              child: const Text('Add Properties'), // تصحيح النص إلى "Add Properties"
            ),
          ],
        ),
      ),
    );
  }

  Future<bool> addtproperties({
    required String CPU,
    required String Motherboard,
    required String RAM,
    required String Hard,
    required String Graphics,
    required String powerSupply,
    required String OS,
    required String NIC,
    required int Deviceid, // تغيير النوع إلى int
    required BuildContext context,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    String token = prefs.getString('token') ?? '';

    final Uri url = Uri.parse('$urlbase/createProperty/$Deviceid'); // استخدام Deviceid كـ int

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
      // نجاح العملية
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('editDevice updated successfully')),
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
