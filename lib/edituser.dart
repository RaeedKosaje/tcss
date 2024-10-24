import 'package:flutter/material.dart';
import 'package:untitled1/drawer.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'floorspage.dart';
import 'main.dart';

class EditUser extends StatelessWidget {
  final int userId;
  const EditUser({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();
    GlobalKey<FormState> editUserForm = GlobalKey();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit User'),
        backgroundColor: Colors.blueAccent, // شفافية خلفية الـ AppBar
          actions: [
            IconButton(
              icon: Icon(Icons.home),
              tooltip: 'Go to Home',
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Navigating to Home...'),
                    duration: Duration(seconds: 1),
                  ),
                );

                Navigator.pushAndRemoveUntil(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) => FloorsPage(),
                    transitionsBuilder: (context, animation, secondaryAnimation, child) {
                      const begin = Offset(1.0, 0.0); // يبدأ من اليمين
                      const end = Offset.zero; // ينتهي في المكان الحالي
                      const curve = Curves.easeInOut;

                      var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                      var offsetAnimation = animation.drive(tween);

                      return SlideTransition(
                        position: offsetAnimation,
                        child: child,
                      );
                    },
                  ),
                      (route) => false,
                );
              },
            ),


          ]),
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
          Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Card(
                color: Colors.white.withOpacity(0.7), // شفافية الكارد
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20), // زوايا مستديرة
                ),
                elevation: 10, // ظل الكارد
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Form(
                    key: editUserForm,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Image.asset(
                          'lib/images/edituser.png', // مسار الشعار
                          height: 100, // ارتفاع الشعار
                        ),
                        Text(
                          'Edit User Information',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.teal.withOpacity(0.8), // شفافية النص
                          ),
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          controller: nameController,
                          decoration: InputDecoration(
                            labelText: 'New User Name',
                            border: OutlineInputBorder(),
                            filled: true,
                            fillColor: Colors.white.withOpacity(0.5), // شفافية حقل النص
                          ),
                          validator: (value) {
                            if (value!.length < 2) {
                              return 'The name must be at least 2 characters';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          controller: passwordController,
                          decoration: InputDecoration(
                            labelText: 'New User Password',
                            border: OutlineInputBorder(),
                            filled: true,
                            fillColor: Colors.white.withOpacity(0.5), // شفافية حقل كلمة المرور
                          ),
                          obscureText: true,
                          validator: (value) {
                            if (value!.length < 4) {
                              return 'The password must be at least 4 characters';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () async {
                            if (editUserForm.currentState!.validate()) {
                              bool success = false;
                              await editUser(
                                userId: userId,
                                name: nameController.text,
                                password: passwordController.text,
                                context: context,
                              );

                              if (success) {
                                Navigator.pop(context, true);
                              }
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
                            'Edit User',
                            style: TextStyle(fontSize: 18),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<bool> editUser({
    required int userId,
    required String name,
    required String password,
    required BuildContext context,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    String token = prefs.getString('token') ?? '';

    final Uri url = Uri.parse('$urlbase/editUser/$userId');

    final response = await http.put(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: '{"name": "$name", "password": "$password"}',
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User updated successfully')),
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
