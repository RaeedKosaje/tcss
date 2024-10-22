import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:untitled1/drawer.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'main.dart';

class AddPeripherals extends StatelessWidget {
  final int Deviceid;

  const AddPeripherals({
    super.key,
    required this.Deviceid
  });

  @override
  Widget build(BuildContext context) {
    final TextEditingController MonitorController = TextEditingController(text: "Monitor");
    final TextEditingController KeyboardController = TextEditingController(text: "Keyboard");
    final TextEditingController MouseController = TextEditingController(text: "Mouse");
    final TextEditingController PrinterController = TextEditingController(text: "Printer");
    final TextEditingController UPSController = TextEditingController(text: "UPS");
    final TextEditingController cashBoxController = TextEditingController(text: "cashBox");
    final TextEditingController BarcodeController = TextEditingController(text: "Barcode");

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
              controller: MonitorController,
              decoration: const InputDecoration(labelText: 'Monitor'),
            ),
            TextField(
              controller: KeyboardController,
              decoration: const InputDecoration(labelText: 'Keyboard'),
            ),
            TextField(
              controller: MouseController,
              decoration: const InputDecoration(labelText: 'Mouse'),
            ),
            TextField(
              controller: PrinterController,
              decoration: const InputDecoration(labelText: 'Printer'),
            ),
            TextField(
              controller: UPSController,
              decoration: const InputDecoration(labelText: 'UPS'),
            ),
            TextField(
              controller: cashBoxController,
              decoration: const InputDecoration(labelText: 'cashBox'),
            ),
            TextField(
              controller: BarcodeController,
              decoration: const InputDecoration(labelText: 'Barcode'),
            ),
            const SizedBox(height: 20), // إضافة مسافة إضافية
            ElevatedButton(
              onPressed: () async {
                bool success = await addperipheral(
                  Monitor: MonitorController.text,
                  Keyboard: KeyboardController.text,
                  Mouse: MouseController.text,
                  Printer: PrinterController.text,
                  UPS: UPSController.text,
                  cashBox: cashBoxController.text,
                  Barcode: BarcodeController.text,
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

  Future<bool> addperipheral({
    required String Monitor,
    required String Keyboard,
    required String Mouse,
    required String Printer,
    required String UPS,
    required String cashBox,
    required String Barcode,

    required int Deviceid, // تغيير النوع إلى int
    required BuildContext context,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    String token = prefs.getString('token') ?? '';

    final Uri url = Uri.parse('$urlbase/createPeripheral/$Deviceid'); // استخدام Deviceid كـ int

    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'Monitor': Monitor,
        'Keyboard': Keyboard,
        'Mouse': Mouse,
        'Printer': Printer,
        'UPS': UPS,
        'cashBox': cashBox,
        'Barcode':Barcode,
      }),
    );

    if (response.statusCode == 200) {
      // نجاح العملية
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('add perpherals successfully')),
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
