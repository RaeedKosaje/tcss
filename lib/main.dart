import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:untitled1/floorspage.dart';
import 'package:untitled1/models/user_model.dart';
void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  // print(prefs.getString('token'));
  token = prefs.getString('token')??'';
  runApp(MyApp());
}
String urlbase = "http://10.0.2.2:8000/api";
String token='';
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: token.isEmpty? LoginPage():FloorsPage(),
    );
  }
}

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();


  UserModel? userModel;
  Future<void> _login() async {
    final String name = _nameController.text;
    final String password = _passwordController.text;
    final Uri url = Uri.parse('$urlbase/login');
    final response = await http.post(
      url,
      body: {
        'name': name,
        'password': password,
      },

    );

    userModel = UserModel.fromJson(jsonDecode(response.body));
    // print(userModel!.data!.accessToken);

    if (response.statusCode == 200) {
      // print('Login successful!');

      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('name', name);
      await prefs.setString('token', userModel!.data!.accessToken!);

      // الانتقال إلى شاشة أخرى

      Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => FloorsPage()),
      );
    } else {

      print('Login failed!');
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Username'),
            ),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _login,
              child: const Text('Login'),
            ),
          ],
        ),
      ),
    );
  }
}
