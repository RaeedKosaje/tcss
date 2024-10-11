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
      ),
      drawer: NavDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'name'),
            ),
            TextField(
              controller: quantityController,
              decoration: const InputDecoration(labelText: 'quantity'),
            ),
            TextField(
              controller: codeController,
              decoration: const InputDecoration(labelText: 'code'),
            ),
            TextField(
              controller: priceController,
              decoration: const InputDecoration(labelText: 'price'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                bool success = await creatematerial(
                  context: context,
                  code: codeController.text,
                  name: nameController.text,
                  quantity:quantityController.text,
                  price:priceController.text
                );
                if (success) {
                  Navigator.pop(context, true);
                }
              },
              child: const Text('Create Material'),
            ),
          ],
        ),
      ),
    );
  }

  Future<bool> creatematerial({
    required BuildContext context,
    required String name,
    required String quantity,
    required String price,
    required String code
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
        'code':code
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
