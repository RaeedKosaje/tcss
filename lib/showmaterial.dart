import 'dart:convert';
import 'package:fan_floating_menu/fan_floating_menu.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:untitled1/drawer.dart';
import 'package:untitled1/editmaterial.dart';
import 'createMaterial.dart';
import 'main.dart';
import 'models/show_material_model.dart';

class ShowMaterials extends StatefulWidget {
  const ShowMaterials({super.key});

  @override
  State<ShowMaterials> createState() => _ShowMaterialState();
}

class _ShowMaterialState extends State<ShowMaterials> {
  late Future<List<Showmaterial>> futureMaterial;

  @override
  void initState() {
    super.initState();
    futureMaterial = fetchMaterial();
  }

  Future<List<Showmaterial>> fetchMaterial() async {
    final prefs = await SharedPreferences.getInstance();
    String token = prefs.getString('token') ?? '';

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
        backgroundColor: Colors.teal,
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
                // إنشاء مفتاح لكل بطاقة مستخدم
                final GlobalKey buttonKey = GlobalKey();

                return Card(
                  elevation: 12,
                  margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: ExpansionTile(
                      title: Row(
                        children: [
                          Icon(Icons.notes, color: Colors.teal),
                          SizedBox(width: 8),
                          Text(
                            material![index].name ?? 'No Name',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.teal,
                            ),
                          ),
                        ],
                      ),
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Text(
                                  'Quantity: ${material![index].quantity?.toString() ?? 'No Quantity'}',
                                  style: const TextStyle(fontSize: 18, color: Colors.brown),
                                  overflow: TextOverflow.clip, // يقطع النص إذا كان طويلاً
                                ),
                              ),
                              SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  'Price: ${material![index].price?.toString() ?? 'No Price'}',
                                  style: TextStyle(fontSize: 18, color: Colors.blue),
                                  overflow: TextOverflow.clip, // يقطع النص إذا كان طويلاً
                                ),
                              ),SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  'code: ${material![index].code?.toString() ?? 'No code'}',
                                  style: TextStyle(fontSize: 18, color: Colors.green),
                                  overflow: TextOverflow.clip, // يقطع النص إذا كان طويلاً
                                ),
                              ),
                              SizedBox(width: 4),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  IconButton(
                                    icon: Icon(Icons.edit, color: Colors.teal),
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
                                  IconButton(
                                    icon: Icon(Icons.delete, color: Colors.red),
                                    onPressed: () {
                                      _showDeleteDialog(context, material[index]);
                                    },
                                  ),
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
      floatingActionButton: FanFloatingMenu(
        menuItems: [
          FanMenuItem(
            onTap: () {
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
            icon: Icons.add,
            title: 'Add Material',
          ),
        ],
      ),
    );
  }
}
