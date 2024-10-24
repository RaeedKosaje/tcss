import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:untitled1/drawer.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'main.dart';

class EditPeripherals extends StatelessWidget {
  final int Deviceid;

  const EditPeripherals({
    super.key,
    required this.Deviceid,
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
        title: const Text('Edit Peripherals'),
        backgroundColor: Colors.blueAccent,      ),
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
                      Image.asset(
                        'lib/images/editperipherals.png', // تأكد من وضع مسار الصورة الصحيح
                        height: 300, // ارتفاع الشعار
                      ),
                      Text(
                        'Edit Peripheral Devices',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.teal,
                        ),
                      ),
                      const SizedBox(height: 20),
                      // حقول الإدخال
                      _buildTextField(MonitorController, 'Monitor'),
                      const SizedBox(height: 20),
                      _buildTextField(KeyboardController, 'Keyboard'),
                      const SizedBox(height: 20),
                      _buildTextField(MouseController, 'Mouse'),
                      const SizedBox(height: 20),
                      _buildTextField(PrinterController, 'Printer'),
                      const SizedBox(height: 20),
                      _buildTextField(UPSController, 'UPS'),
                      const SizedBox(height: 20),
                      _buildTextField(cashBoxController, 'Cash Box'),
                      const SizedBox(height: 20),
                      _buildTextField(BarcodeController, 'Barcode'),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () async {
                          bool success = await editperipheral(
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
                            Navigator.pop(context); // الرجوع مع القيمة true

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

  Future<bool> editperipheral({
    required String Monitor,
    required String Keyboard,
    required String Mouse,
    required String Printer,
    required String UPS,
    required String cashBox,
    required String Barcode,
    required int Deviceid,
    required BuildContext context,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    String token = prefs.getString('token') ?? '';

    final Uri url = Uri.parse('$urlbase/editPeripherals/$Deviceid'); // استخدام Deviceid كـ int

    final response = await http.put(
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
        const SnackBar(content: Text('Peripherals updated successfully')),
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
