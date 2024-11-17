import 'dart:convert';
import 'package:fan_floating_menu/fan_floating_menu.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:untitled1/drawer.dart';
import 'package:untitled1/editmaterial.dart';
import 'createMaterial.dart';
import 'floorspage.dart';
import 'main.dart';
import 'models/show_material_model.dart';

class ShowMaterials extends StatefulWidget {
  const ShowMaterials({super.key});

  @override
  State<ShowMaterials> createState() => _ShowMaterialState();
}

class _ShowMaterialState extends State<ShowMaterials> {
  late Future<List<Showmaterial>> futureMaterial;
  String role = '';
  @override
  void initState() {
    super.initState();
    futureMaterial = fetchMaterial();
  }

  Future<List<Showmaterial>> fetchMaterial() async {
    final prefs = await SharedPreferences.getInstance();
    String token = prefs.getString('token') ?? '';
    role = prefs.getString('role') ?? '';
    final response = await http.get(
      Uri.parse('$urlbase/showMaterial'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      return jsonResponse.map((data) => Showmaterial.fromJson(data)).toList();
    } else {
      throw Exception('Failed to load Show material');
    }
  }

  // دالة لعرض حوار الحذف
  void _showDeleteDialog(BuildContext context, Showmaterial material) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete User'),
          content: Text(
            'Are you sure you want to delete "${material.name}"?',
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
                bool success = await _deletematerial(material.id!, context);
                if (success) {
                  setState(() {
                    futureMaterial =
                        fetchMaterial(); // تحديث المستخدمين بعد الحذف
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
  Future<bool> _deletematerial(int materialId, BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    String token = prefs.getString('token') ?? '';

    final Uri url = Uri.parse('$urlbase/deleteMaterial/$materialId');

    final response = await http.delete(
      url,
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Material deleted successfully')),
      );
      return true;
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to delete material')),
      );
      return false;
    }
  }

  // دالة لعرض قائمة الخيارات (تعديل / حذف)
  void _showPopupMenu(
      BuildContext context, Showmaterial material, Offset offset) {
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
              builder: (context) => EditMaterial(materialId: material.id!),
            ),
          ).then((value) {
            if (value == true) {
              setState(() {
                futureMaterial = fetchMaterial();
              });
            }
          });
        } else if (value == 1) {
          _showDeleteDialog(
              context, material); // عرض حوار الحذف بدلاً من صفحة الحذف
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Show Material'),
        backgroundColor: Colors.blueAccent,
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
                  pageBuilder: (context, animation, secondaryAnimation) =>
                      FloorsPage(),
                  transitionsBuilder:
                      (context, animation, secondaryAnimation, child) {
                    const begin = Offset(1.0, 0.0); // يبدأ من اليمين
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
                (route) => false,
              );
            },
          ),
        ],
      ),
      drawer: NavDrawer(),
      body: FutureBuilder<List<Showmaterial>>(
        future: futureMaterial,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            List<Showmaterial>? material = snapshot.data;
            return ListView.builder(
              itemCount: material?.length ?? 0,
              itemBuilder: (context, index) {
                final GlobalKey buttonKey = GlobalKey();

                return Card(
                  elevation: 8,
                  margin: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: ExpansionTile(
                      title: Row(
                        children: [
                          Icon(Icons.notes, color: Color(0xff6a89cc)),
                          SizedBox(width: 10),
                          Text(
                            material![index].name ?? 'No Name',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Color(0xff1e3799),
                            ),
                          ),
                        ],
                      ),
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Quantity: ${material![index].quantity?.toString() ?? 'No Quantity'}',
                                style: TextStyle(fontSize: 18, color: Color(0xff34495e)),
                              ),
                              Text(
                                'Price: \$${material![index].price?.toString() ?? 'No Price'}',
                                style: TextStyle(fontSize: 18, color: Color(0xff34495e)),
                              ),
                              Text(
                                'Code: ${material![index].code?.toString() ?? 'No Code'}',
                                style: TextStyle(fontSize: 18, color: Color(0xff34495e)),
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  IconButton(
                                    icon: Icon(Icons.edit, color: Color(0xff6a89cc)),
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => EditMaterial(materialId: material[index].id!),
                                        ),
                                      ).then((value) {
                                        if (value == true) {
                                          setState(() {
                                            futureMaterial = fetchMaterial();
                                          });
                                        }
                                      });
                                    },
                                  ),
                                  if(role=='1')...[
                                  IconButton(
                                    icon: Icon(Icons.delete, color: Color(0xfff8c291)),
                                    onPressed: () {
                                      _showDeleteDialog(context, material[index]);
                                    },
                                  )],
                                ],
                              ),
                            ],
                          ),
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

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => CreateMaterial()),
          ).then((value) {
            if (value) {
              setState(() {
                futureMaterial = fetchMaterial();
              });
            } else {
              print('error');
            }
          });
        },
        child: const Icon(Icons.add),
        backgroundColor: Colors.blueAccent,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
    );
  }
}
