import 'package:flutter/material.dart';
import 'package:untitled1/drawer.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'main.dart';

class EditUser extends StatelessWidget {
  final int userId;
  const EditUser({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    final TextEditingController nameController = TextEditingController(text: 'majd');
    final TextEditingController passwordController = TextEditingController();
    GlobalKey<FormState> editUserForm = GlobalKey();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit User'),
      ),
      drawer: NavDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: editUserForm,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'New User Name'),
                validator: (value){
                  if(value!.length<2){
                    return ' the name must be ';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: passwordController,
                decoration: const InputDecoration(labelText: 'New User Password'),
                obscureText: true,
                validator: (value){
                  if(value!.length<4){
                    return ' the password must be ';
                  }
                  return null;
                },
              ),
              ElevatedButton(
                onPressed: () async {
                  // استدعاء دالة تعديل المستخدم وانتظار النتيجة
                  if(editUserForm.currentState!.validate()){
                    bool success =false;
                    await editUser(
                      userId: userId,
                      name: nameController.text,
                      password: passwordController.text,
                      context: context,
                    );

                    // إذا نجحت العملية، الرجوع إلى الصفحة السابقة
                    if (success) {
                      Navigator.pop(context, true); // الرجوع مع القيمة true
                    }
                  }

                },
                child: const Text('Edit User'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<bool> editUser({
    required int userId,
    required String name,
    required String password,
    required BuildContext context,
  }) async {
    print('response.body');
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
  print(response.body);
  print('response.body');
    if (response.statusCode == 200) {
      // نجاح العملية
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User updated successfully')),
      );
      return true;
    }
    else {
      // فشل العملية
      ScaffoldMessenger.of(context).showSnackBar(
         SnackBar(content: Text(response.body)),
      );
      return false;
    }
  }
}
