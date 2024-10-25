import 'dart:convert';
import 'package:fan_floating_menu/fan_floating_menu.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:untitled1/devicesPage.dart';
import 'package:untitled1/drawer.dart';
import 'package:http/http.dart' as http;
import 'package:untitled1/editdepartment.dart';
import 'package:untitled1/models/show_departments_model.dart';
import 'createDepartment.dart';
import 'main.dart';

class DepartmentsPage extends StatefulWidget {
  final int floorId;

  const DepartmentsPage({super.key, required this.floorId});

  @override
  State<DepartmentsPage> createState() => _ShowDepartmentsState();
}

class _ShowDepartmentsState extends State<DepartmentsPage> {
  late Future<List<ShowDepartments>> futureDepartments;
  String? role;

  @override
  void initState() {
    super.initState();
    futureDepartments = fetchDepartments();
  }

  Future<List<ShowDepartments>> fetchDepartments() async {
    final prefs = await SharedPreferences.getInstance();
    String token = prefs.getString('token') ?? '';
    role = prefs.getString('role') ?? '';
    final response = await http.get(
      Uri.parse('$urlbase/departmentsInFloor/${widget.floorId}'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      return jsonResponse
          .map((data) => ShowDepartments.fromJson(data))
          .toList();
    } else {
      throw Exception('Failed to load departments');
    }
  }

  // دالة لعرض حوار تأكيد الحذف
  void showDeleteDialog(BuildContext context, int departmentId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
            title: const Text('Delete Department'),
            content: const Text(
              'Are you sure you want to delete this department?',
              style: TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () async {
                  bool success = await deleteDepartment(departmentId, context);
                  if (success) {
                    setState(() {
                      futureDepartments =
                          fetchDepartments(); // تحديث قائمة الأقسام بعد الحذف
                    });
                    Navigator.of(context).pop(); // إغلاق الحوار بعد الحذف
                  }
                },
                child: const Text('Delete'),
              ),
            ]);
      },
    );
  }

  // دالة لحذف القسم من خلال API
  Future<bool> deleteDepartment(int departmentId, BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    String token = prefs.getString('token') ?? '';

    final Uri url = Uri.parse('$urlbase/deleteDepartment/$departmentId');

    final response = await http.delete(
      url,
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Department deleted successfully')),
      );
      return true;
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to delete department')),
      );
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Departments Page'),
        backgroundColor: Colors.blueAccent,
      ),
      drawer: NavDrawer(),
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() {
            futureDepartments = fetchDepartments();
          });
          await futureDepartments;
        },
        child: FutureBuilder<List<ShowDepartments>>(
          future: futureDepartments,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error, size: 60, color: Colors.red),
                    const SizedBox(height: 10),
                    Text(
                      "Failed to load sections, please try again later.",
                      style: TextStyle(fontSize: 18, color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.info_outline, size: 60, color: Colors.blue),
                    SizedBox(height: 10),
                    Text("There are no sections available.", style: TextStyle(fontSize: 18)),
                  ],
                ),
              );
            } else {
              List<ShowDepartments> departments = snapshot.data!;
              return Column(
                children: [
                  Expanded(
                    child: GridView.builder(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 10.0,
                        mainAxisSpacing: 10.0,
                      ),
                      itemCount: departments.length,
                      itemBuilder: (context, index) {
                        return InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              PageRouteBuilder(
                                pageBuilder: (context, animation,
                                    secondaryAnimation) =>
                                    DevicesPage(departmentId: departments[index].id!),
                                transitionsBuilder:
                                    (context, animation, secondaryAnimation, child) {
                                  const begin = Offset(0.0, 1.0);
                                  const end = Offset.zero; // ينتهي في المكان الحالي
                                  const curve = Curves.easeInOut;

                                  var tween = Tween(begin: begin, end: end)
                                      .chain(CurveTween(curve: curve));
                                  var offsetAnimation = animation.drive(tween);

                                  return SlideTransition(
                                    position: offsetAnimation,
                                    child: child,
                                  );
                                },
                              ),
                            );
                          },
                          child: Card(
                            color: Color(0xffd1d8e0),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(40.0),
                            ),
                            elevation: 5,
                            shadowColor: Colors.blue.withOpacity(0.8),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    departments[index].name ?? 'No Name',
                                    style: const TextStyle(fontSize: 18),
                                  ),
                                  const SizedBox(height: 10),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                                    children: [
                                      ElevatedButton(
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => EditDepartment(
                                                  departmentid:
                                                  departments[index].id!),
                                            ),
                                          ).then((value) {
                                            if (value == true) {
                                              setState(() {
                                                futureDepartments =
                                                    fetchDepartments();
                                              });
                                            }
                                          });
                                        },
                                        child: const Text('Edit'),
                                      ),
                                      if (role == '1') ...[
                                        ElevatedButton(
                                          onPressed: () {
                                            showDeleteDialog(
                                                context, departments[index].id!);
                                          },
                                          child: const Text('Delete'),
                                        ),
                                      ],
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                ],
              );
            }
          },
        ),
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CreateDepartment(floorId: widget.floorId),
            ),
          ).then((value) {
            if (value == true) {
              setState(() {
                futureDepartments = fetchDepartments();
              });
            }
          });
        },
        child: const Icon(Icons.add),
        backgroundColor: Colors.blueAccent,
      ),
    );
  }
}
