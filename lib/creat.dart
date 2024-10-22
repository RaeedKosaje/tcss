import 'package:flutter/material.dart';
import 'package:untitled1/drawer.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'main.dart';

class CreateUser extends StatelessWidget {
  const CreateUser({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController userNameController = TextEditingController();
    final TextEditingController userPasswordController =
    TextEditingController();

    return Scaffold(
        appBar: AppBar(
          title: const Text('Create User'),
          backgroundColor: Colors.blueAccent,
        ),
        drawer: NavDrawer(),
        body: Stack(children: [
          Container(
            decoration: const BoxDecoration(
              color: Colors.lightBlueAccent, // لون الخلفية
              border: Border(
                top: BorderSide(width: 5.0, color: Colors.blue), // إطار علوي
                bottom: BorderSide(width: 5.0, color: Colors.blue), // إطار سفلي
                left: BorderSide(width: 5.0, color: Colors.blue), // إطار يساري
                right: BorderSide(width: 5.0, color: Colors.blue), // إطار يميني
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              elevation: 8,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    // إضافة الشعار هنا
                    Image.asset(
                      'lib/images/CreateUser.png', // تأكد من وضع مسار الصورة الصحيح
                      height: 300, // ارتفاع الشعار
                    ),
                    const SizedBox(height: 20), // مسافة بين الشعار وحقل الإدخال

                    TextField(
                      controller: userNameController,
                      decoration: const InputDecoration(
                        labelText: 'Username',
                        border: OutlineInputBorder(),
                        filled: true,
                        fillColor: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: userPasswordController,
                      obscureText: true, // لإخفاء كلمة المرور
                      decoration: const InputDecoration(
                        labelText: 'Password',
                        border: OutlineInputBorder(),
                        filled: true,
                        fillColor: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 30),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.person_add),
                      label: const Text('Create User'),
                      onPressed: () async {
                        bool success = await createUser(
                          context: context,
                          name: userNameController.text,
                          password: userPasswordController.text,
                        );
                        if (success) {
                          Navigator.pop(context, true);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 40, vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ]));
  }

  Future<bool> createUser({
    required BuildContext context,
    required String name,
    required String password,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    String token = prefs.getString('token') ?? '';

    final Uri url = Uri.parse('$urlbase/createUser');

    final response = await http.post(
      url,
      body: {
        'name': name,
        'password': password,
      },
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User created successfully')),
      );
      return true;
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to create user')),
      );
      return false;
    }
  }
}
