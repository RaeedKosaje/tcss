import 'dart:convert';
import 'package:fan_floating_menu/fan_floating_menu.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:untitled1/drawer.dart';
import 'package:http/http.dart' as http;
import 'createDevice.dart';
import 'main.dart';
import 'models/show_devices_model.dart';

class DevicesPage extends StatefulWidget {
  final int departmentId;
  const DevicesPage({super.key, required this.departmentId});

  @override
  State<DevicesPage> createState() => _ShowDevicesState();
}

class _ShowDevicesState extends State<DevicesPage> {
  late Future<List<ShowDevices>> futureDevices;

  @override
  void initState() {
    super.initState();
    futureDevices = fetchDevices();
  }

  Future<List<ShowDevices>> fetchDevices() async {
    final prefs = await SharedPreferences.getInstance();
    String token = prefs.getString('token') ?? '';

    final response = await http.get(
      Uri.parse('$urlbase/devicesInDepartment/${widget.departmentId}'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      return jsonResponse.map((data) => ShowDevices.fromJson(data)).toList();
    } else {
      throw Exception('Failed to load devices');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Devices Page'),
      ),
      drawer: NavDrawer(),
      body: FutureBuilder<List<ShowDevices>>(
        future: futureDevices,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            List<ShowDevices>? devices = snapshot.data;
            return GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10.0,
                mainAxisSpacing: 10.0,
              ),
              itemCount: devices?.length ?? 0,
              itemBuilder: (context, index) {
                return InkWell(
                  onTap: () {
                    // عرض معلومات الجهاز عند الضغط على الكارد
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text(devices![index].name ?? 'No Name'),
                          content: Text('Details about device ${devices[index].name}'),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: const Text('Close'),
                            ),
                          ],
                        );
                      },
                    );
                  },
                  child: Card(
                    elevation: 5,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            devices![index].name ?? 'No Name',
                            style: const TextStyle(fontSize: 18),
                          ),
                          const SizedBox(height: 30),
                          SingleChildScrollView(scrollDirection: Axis.horizontal,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                ElevatedButton(
                                  onPressed: () {
                                    // وظيفة تعديل الجهاز
                                    print('Edit device ${devices[index].name}');
                                  },
                                  child: const Text('Edit'),
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    // وظيفة حذف الجهاز
                                    print('Delete device ${devices[index].name}');
                                  },
                                  child: const Text('Delete'),
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    // وظيفة تعديل الجهاز
                                    print('ok');
                                  },
                                  child: const Text('ok'),
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    // وظيفة حذف الجهاز
                                    print('yes');
                                  },
                                  child: const Text('yes'),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          } else if (snapshot.hasError) {
            return Text("${snapshot.error}");
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
      floatingActionButton: FanFloatingMenu(
        menuItems: [
          FanMenuItem(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      Createdevice(departmentId: widget.departmentId),
                ),
              ).then((value) {
                if (value == true) {
                  setState(() {
                    futureDevices = fetchDevices();
                  });
                }
              });
            },
            icon: Icons.add,
            title: 'add device',
          ),
        ],
      ),
    );
  }
}
