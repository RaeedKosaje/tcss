import 'dart:convert';
import 'package:fan_floating_menu/fan_floating_menu.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:untitled1/deleteuser.dart';
import 'package:untitled1/drawer.dart';
import 'package:http/http.dart' as http;
import 'package:untitled1/edituser.dart';
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
      Uri.parse('$urlbase/showUsers?'),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Show Users'),
      ),
      drawer: NavDrawer(),
      body: FutureBuilder<List<ShowUsers>>(
        future: futureUser,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            List<ShowUsers>? devices = snapshot.data;
            return ListView.builder(
              itemCount: devices?.length ?? 0,
              itemBuilder: (context, index) {
                return Card(
                  elevation: 5,
                  margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          devices![index].name ?? 'No Name',
                          style: TextStyle(fontSize: 18),
                        ),
                        SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            ElevatedButton.icon(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          EditUser(userId: devices[index].id!)),
                                ).then((value) {
                                  if (value == true) {
                                    setState(() {
                                      futureUser = fetchUser();
                                    });
                                  }
                                });
                              },
                              icon: Icon(Icons.edit),
                              label: Text('Edit'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                              ),
                            ),
                            SizedBox(width: 10),
                            ElevatedButton.icon(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => DeleteUser(
                                      userId: devices[index].id!,
                                    ),
                                  ),
                                ).then((value) {
                                  if (value == true) {
                                    setState(() {
                                      futureUser = fetchUser();
                                    });
                                  }
                                });
                              },
                              icon: Icon(Icons.delete),
                              label: Text('Delete'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          } else if (snapshot.hasError) {
            return Text("${snapshot.error}");
          }
          return Center(child: CircularProgressIndicator());
        },
      ),
      floatingActionButton: FanFloatingMenu(
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
