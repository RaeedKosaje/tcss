import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fan_floating_menu/fan_floating_menu.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:untitled1/drawer.dart';
import 'package:untitled1/edituser.dart';
import 'package:untitled1/floorspage.dart';
import 'creat.dart';
import 'main.dart';
import 'models/show_users.dart';

class Showusers extends StatefulWidget {
  const Showusers({super.key});

  @override
  State<Showusers> createState() => _ShowUserState();
}

class _ShowUserState extends State<Showusers> {
  late Future<List<ShowUsers>> futureUser;

  @override
  void initState() {
    super.initState();
    futureUser = fetchUser();
  }

  Future<List<ShowUsers>> fetchUser() async {
    final prefs = await SharedPreferences.getInstance();
    String token = prefs.getString('token') ?? '';

    final response = await http.get(
      Uri.parse('$urlbase/showUsers'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      return jsonResponse.map((data) => ShowUsers.fromJson(data)).toList();
    } else {
      throw Exception('Failed to load users');
    }
  }

  // دالة لعرض حوار الحذف
  void _showDeleteDialog(BuildContext context, ShowUsers user) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete User'),
          content: Text(
            'Are you sure you want to delete user "${user.name}"?',
            style: TextStyle(fontSize: 18),
            textAlign: TextAlign.center,
          ),
          actions: <Widget>[
            ElevatedButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop(); // إغلاق الحوار
              },
            ),
            ElevatedButton(
              child: Text('Delete'),
              onPressed: () async {
                bool success = await _deleteUser(user.id!, context);
                if (success) {
                  setState(() {
                    futureUser = fetchUser(); // تحديث المستخدمين بعد الحذف
                  });
                  Navigator.of(context).pop(); // إغلاق الحوار
                }
              },
            ),
          ],
        );
      },
    );
  }

  // دالة لحذف المستخدم من خلال API
  Future<bool> _deleteUser(int userId, BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    String token = prefs.getString('token') ?? '';

    final Uri url = Uri.parse('$urlbase/deleteUser/$userId');

    final response = await http.delete(
      url,
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User deleted successfully')),
      );
      return true;
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to delete user')),
      );
      return false;
    }
  }

  // دالة لعرض قائمة الخيارات (تعديل / حذف)
  void _showPopupMenu(BuildContext context, ShowUsers user, Offset offset) {
    showMenu(
      context: context,
      position: RelativeRect.fromLTRB(
        offset.dx,
        offset.dy,
        0.0,
        0.0,
      ),
      items: [
        PopupMenuItem<int>(
          value: 0,
          child: Row(
            children: [
              Icon(Icons.edit, color: Colors.teal),
              SizedBox(width: 8),
              Text('Edit'),
            ],
          ),
        ),
        PopupMenuItem<int>(
          value: 1,
          child: Row(
            children: [
              Icon(Icons.delete, color: Colors.red),
              SizedBox(width: 8),
              Text('Delete'),
            ],
          ),
        ),
      ],
      elevation: 8.0,
    ).then((value) {
      if (value != null) {
        if (value == 0) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => EditUser(userId: user.id!),
            ),
          ).then((value) {
            if (value == true) {
              setState(() {
                futureUser = fetchUser();
              });
            }
          });
        } else if (value == 1) {
          _showDeleteDialog(context, user); // عرض حوار الحذف بدلاً من صفحة الحذف
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Show Users'),
        backgroundColor: Colors.teal,
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


        ],
      ),

      drawer: NavDrawer(),
      body: FutureBuilder<List<ShowUsers>>(
        future: futureUser,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            List<ShowUsers>? users = snapshot.data;
            return ListView.builder(
              itemCount: users?.length ?? 0,
              itemBuilder: (context, index) {
                // إنشاء مفتاح لكل بطاقة مستخدم
                final GlobalKey buttonKey = GlobalKey();

                return Card(
                  elevation: 8,
                  margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            users![index].name ?? 'No Name',
                            style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.teal),
                          ),
                        ),
                        IconButton(
                          key: buttonKey, // تعيين المفتاح إلى الزر
                          icon: Icon(Icons.more_vert, color: Colors.teal),
                          onPressed: () {
                            RenderBox renderBox = buttonKey.currentContext!.findRenderObject() as RenderBox;
                            Offset offset = renderBox.localToGlobal(Offset.zero);
                            _showPopupMenu(context, users[index], Offset(offset.dx, offset.dy + 30)); // تعديل إزاحة Y
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          } else if (snapshot.hasError) {
            return Center(child: Text("${snapshot.error}"));
          }
          return Center(child: CircularProgressIndicator());
        },
      ),
      floatingActionButton: FanFloatingMenu(
        toggleButtonIconColor: Colors.green.shade300,

        menuItems: [
          FanMenuItem(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CreateUser()),
              ).then((value) {
                if (value) {
                  setState(() {
                    futureUser = fetchUser();
                  });
                } else {
                  print('error');
                }
              });
            },
            icon: Icons.add,
            title: 'Add user',
          ),
        ],
      ),
    );
  }
}
