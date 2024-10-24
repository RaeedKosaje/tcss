import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:untitled1/drawer.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'main.dart';

class AddPeripherals extends StatelessWidget {
  final int Deviceid;

  const AddPeripherals({super.key, required this.Deviceid});

  @override
  Widget build(BuildContext context) {
    final TextEditingController MonitorController =
        TextEditingController(text: "Monitor");
    final TextEditingController KeyboardController =
        TextEditingController(text: "Keyboard");
    final TextEditingController MouseController =
        TextEditingController(text: "Mouse");
    final TextEditingController PrinterController =
        TextEditingController(text: "Printer");
    final TextEditingController UPSController =
        TextEditingController(text: "UPS");
    final TextEditingController cashBoxController =
        TextEditingController(text: "cashBox");
    final TextEditingController BarcodeController =
        TextEditingController(text: "Barcode");

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
            child: Column(
              mainAxisSize: MainAxisSize.min,

              mainAxisAlignment: MainAxisAlignment.start,

              children: <Widget>[
                Image.asset(
                  'lib/images/editperipherals.png',
                  // تأكد من وضع مسار الصورة الصحيح
                  height: 300, // ارتفاع الشعار
                ),
                _buildTextField(MonitorController, 'Monitor'),
                _buildTextField(KeyboardController, 'Keyboard'),
                _buildTextField(MouseController, 'Mouse'),
                _buildTextField(PrinterController, 'Printer'),
                _buildTextField(UPSController, 'UPS'),
                _buildTextField(cashBoxController, 'cashBox'),
                _buildTextField(BarcodeController, 'Barcode'),

                const SizedBox(height: 20),
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
                      Deviceid: Deviceid,
                      context: context,
                    );
                    if (success) {
                      Navigator.pop(context, true); // الرجوع مع القيمة true
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

    final Uri url = Uri.parse(
        '$urlbase/createPeripheral/$Deviceid'); // استخدام Deviceid كـ int

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
        'Barcode': Barcode,
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
