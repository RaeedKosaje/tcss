import 'package:flutter/material.dart';
import 'package:untitled1/drawer.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'main.dart';

class CreateMaintenanceService extends StatelessWidget {
  final int deviceId;

  const CreateMaintenanceService({super.key, required this.deviceId});

  @override
  Widget build(BuildContext context) {
    final TextEditingController descriptionController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Maintenance Service'),
        backgroundColor: Colors.blueAccent, // تخصيص لون شريط العنوان
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
          SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.only(top: 100.0),
                  child: Center(
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(20), // زوايا مستديرة
                      ),
                      elevation: 10, // ظل الكارد
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Image.asset(
                              'lib/images/createMaintenanceService.png',
                              // تأكد من وضع مسار الصورة الصحيح
                              height: 300, // ارتفاع الشعار
                            ),
                            Text(
                              'Create Maintenance Service',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.blueAccent,
                              ),
                            ),
                            const SizedBox(height: 20),
                            _buildTextField(
                                descriptionController, 'Description'),
                            const SizedBox(height: 20),
                            ElevatedButton(
                              onPressed: () async {
                                bool success = await createMaintenanceService(
                                  description: descriptionController.text,
                                  deviceId: deviceId,
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
                                'Create Service',
                                style: TextStyle(fontSize: 18),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ))
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

  Future<bool> createMaintenanceService({
    required int deviceId,
    required BuildContext context,
    required String description,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    String token = prefs.getString('token') ?? '';

    final Uri url = Uri.parse('$urlbase/createMaintenanceService/$deviceId');

    final response = await http.post(
      url,
      body: {
        'description': description,
      },
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Maintenance Service created successfully')),
      );
      return true;
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to create Maintenance Service')),
      );
      return false;
    }
  }
}
