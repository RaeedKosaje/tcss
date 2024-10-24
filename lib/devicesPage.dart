import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:untitled1/addperipherals.dart';
import 'package:untitled1/addproperties.dart';
import 'package:untitled1/drawer.dart';
import 'package:untitled1/editProperties.dart';
import 'package:untitled1/editdevice.dart';
import 'package:untitled1/editperipherals.dart';
import 'package:untitled1/models/show-properties-model.dart';
import 'package:untitled1/models/show_devices_model.dart';
import 'createDevice.dart';
import 'createHardwarekey.dart';
import 'createinstallationservice.dart';
import 'createmaintenanceservice.dart';
import 'edithardwarekey.dart';
import 'floorspage.dart';
import 'main.dart';
import 'models/create_hardware_key_model.dart';
import 'models/show_peripherals_model.dart';

class DevicesPage extends StatefulWidget {
  final int departmentId;

  const DevicesPage({super.key, required this.departmentId});

  @override
  State<DevicesPage> createState() => _ShowDevicesState();
}

class _ShowDevicesState extends State<DevicesPage> {
  late List<ShowDevices> futureDevices;
  ShowProperties? showProperties;
  Hardwarekey? hardwarekey;
  ShowPeripherals? showPeripherals;
  String? role;

  @override
  void initState() {
    super.initState();
    fetchDevices();
  }

  Future<List<ShowDevices>> fetchDevices() async {
    final prefs = await SharedPreferences.getInstance();
    String token = prefs.getString('token') ?? '';
    role = prefs.getString('role') ?? '';

    final response = await http.get(
      Uri.parse('$urlbase/devicesInDepartment/${widget.departmentId}'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      futureDevices =
          jsonResponse.map((data) => ShowDevices.fromJson(data)).toList();
      return futureDevices;
    } else {
      throw Exception('Failed to load devices');
    }
  }

  Future<void> device(int deviceId) async {
    final prefs = await SharedPreferences.getInstance();
    String token = prefs.getString('token') ?? '';

    final response = await http.get(
      Uri.parse('$urlbase/showProperties/$deviceId'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode == 200) {
      dynamic jsonResponse = json.decode(response.body);
      setState(() {
        //print(showProperties);
        showProperties = ShowProperties.fromJson(jsonResponse);
      });
    } else {
      setState(() {
        showProperties = null;
      });
    }

    final response2 = await http.get(
      Uri.parse('$urlbase/showPeripherals/$deviceId'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response2.statusCode == 200) {
      dynamic jsonResponse = json.decode(response2.body);
      setState(() {
        showPeripherals = ShowPeripherals.fromJson(jsonResponse);
      });
    } else {
      setState(() {
        showPeripherals = null;
      });
    }

    final response3 = await http.get(
      Uri.parse('$urlbase/showHardwarekey/$deviceId'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response3.statusCode == 200) {
      dynamic jsonResponse = json.decode(response3.body);
      setState(() {

        hardwarekey = Hardwarekey.fromJson(jsonResponse);
      });
    } else {
      setState(() {
        hardwarekey = null; // تحديد أن البيانات غير متوفرة
      });
    }
  }

  void showDeleteDialog(BuildContext context, int deviceId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Device'),
          content: const Text(
            'Are you sure you want to delete this device?',
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
                bool success = await deletedeDevice(deviceId, context);
                if (success) {
                  setState(() {
                    fetchDevices();
                  });
                  Navigator.of(context).pop();
                }
              },
              child: const Text(
                'Delete',
                style: TextStyle(color: Colors.redAccent),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<bool> deletedeDevice(int deviceId, BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    String token = prefs.getString('token') ?? '';

    final Uri url = Uri.parse('$urlbase/deleteDevice/$deviceId');

    final response = await http.delete(
      url,
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Device deleted successfully')),
      );
      return true;
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to delete device')),
      );
      return false;
    }
  }

  void showDeviceSpecifications(ShowProperties properties) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          title: const Text(
            'Show Properties',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: Colors.blue,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildSpecificationRow(Icons.memory, 'CPU', properties.cPU),
              _buildSpecificationRow(
                  Icons.devices, 'Motherboard', properties.motherboard),
              _buildSpecificationRow(Icons.storage, 'RAM', properties.rAM),
              _buildSpecificationRow(
                  Icons.hardware_outlined, 'Hard', properties.hard),
              _buildSpecificationRow(
                  Icons.image, 'Graphics', properties.graphics),
              _buildSpecificationRow(
                  Icons.bolt, 'Power Supply', properties.powerSupply),
              _buildSpecificationRow(Icons.computer, 'OS', properties.oS),
              _buildSpecificationRow(
                  Icons.network_check, 'NIC', properties.nIC),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                icon: const Icon(Icons.edit),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          EditProperties(Deviceid: properties.id!),
                    ),
                  ).then((value) {
                    if (value == true) {
                      setState(() {
                        fetchDevices();
                      });
                    }
                  });
                },
                label: const Text('Edit Properties Devices'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text(
                'Clos',
                style: TextStyle(color: Colors.redAccent),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSpecificationRow(IconData icon, String label, String? value) {
    return Row(
      children: [
        Icon(icon, color: Colors.blue),
        const SizedBox(width: 10),
        Text('$label: ${value ?? "غير موجود"}',
            style: const TextStyle(fontSize: 16)),
      ],
    );
  }

  void showDeviceper(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          title: const Text(
            'Show Peripherals',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: Colors.blue,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildPeripheralRow(
                  Icons.monitor, 'monitor', showPeripherals?.monitor),
              _buildPeripheralRow(
                  Icons.keyboard, 'keyboard', showPeripherals?.keyboard),
              _buildPeripheralRow(Icons.mouse, 'mouse', showPeripherals?.mouse),
              _buildPeripheralRow(
                  Icons.print, 'printer', showPeripherals?.printer),
              _buildPeripheralRow(
                  Icons.battery_charging_full, 'uPS', showPeripherals?.uPS),
              _buildPeripheralRow(
                  Icons.shopping_bag, 'cashBox', showPeripherals?.cashBox),
              _buildPeripheralRow(
                  Icons.qr_code, 'barcode', showPeripherals?.barcode),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                icon: const Icon(Icons.edit),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          EditPeripherals(Deviceid: showPeripherals!.id!),
                    ),
                  ).then((value) {
                    if (value == true) {
                      setState(() {
                        fetchDevices();
                      });
                    }
                  });
                },
                label: const Text('Edit Peripherals Devices'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text(
                'Clos',
                style: TextStyle(color: Colors.redAccent),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildPeripheralRow(IconData icon, String label, String? value) {
    return Row(
      children: [
        Icon(icon, color: Colors.blue),
        const SizedBox(width: 10),
        Text('$label: ${value ?? "غير موجود"}',
            style: const TextStyle(fontSize: 16)),
      ],
    );
  }

  void showhardwarekey(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('hard ware key'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildPeripheralRow(Icons.type_specimen_outlined, 'type',
                  hardwarekey?.type ?? "غير موجود"),
              _buildPeripheralRow(
                  Icons.code, 'serial', hardwarekey?.sereal ?? "غير موجود"),
              _buildPeripheralRow(Icons.more_time, 'exDate',
                  hardwarekey?.exDate ?? "غير موجود"),
              _buildPeripheralRow(Icons.description, 'description',
                  hardwarekey?.description ?? "رينغير موجود"),

              const SizedBox(height: 10), // مسافة بين المواصفات والأزرار

              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          Edithardwarekey(deviceid: hardwarekey!.id!),
                    ),
                  ).then((value) {
                    if (value == true) {
                      setState(() {
                        fetchDevices();
                      });
                    }
                  });
                },
                child: const Text('Edit Hardware Key'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child:
                  const Text('Clos', style: TextStyle(color: Colors.redAccent)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
        title: const Text('Devices Page'),
        actions: [
          IconButton(
            icon: Icon(Icons.home),
            tooltip: 'Go to Home',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Welcom to Home...'),
                  duration: Duration(seconds: 2),
                ),
              );

              Navigator.pushAndRemoveUntil(
                context,
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) =>
                      FloorsPage(),
                  transitionsBuilder:
                      (context, animation, secondaryAnimation, child) {
                    const begin = Offset(0.1, 0.1);
                    const end = Offset.zero;
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
      body: FutureBuilder(
        future: fetchDevices(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return ListView.builder(
              itemCount: futureDevices.length,
              itemBuilder: (context, index) {
                return Card(
                  color: Color(0xffd1d8e0),
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(40.0),
                  ),
                  shadowColor: Colors.blue.withOpacity(0.8),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Stack(
                      children: [
                        // زر في أعلى يمين الكارد
                        Positioned(
                          top: 20,
                          right: 20,
                          child: IconButton(
                            icon: const Icon(Icons.more_vert),
                            onPressed: () {
                              device(futureDevices[index].id!);
                              showModalBottomSheet(
                                context: context,
                                builder: (BuildContext context) {
                                  return Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: <Widget>[
                                      ListTile(
                                        leading: const Icon(Icons.extension,
                                            color: Colors.blue),
                                        title: const Text('Show Peripherals'),
                                        onTap: () {
                                          Navigator.pop(context);
                                          if (showPeripherals == null) {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    AddPeripherals(
                                                  Deviceid:
                                                      futureDevices[index].id!,
                                                ),
                                              ),
                                            ).then((value) {
                                              if (value == true) {
                                                setState(() {
                                                  fetchDevices();
                                                });
                                              }
                                            });
                                          } else {
                                            showDeviceper(context);
                                          }
                                        },
                                      ),
                                      ListTile(
                                        leading: const Icon(Icons.info,
                                            color: Colors.blueAccent),
                                        title: const Text('Show Properties '),
                                        onTap: () {
                                          Navigator.pop(context);
                                          if (showProperties == null) {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    AddProperties(
                                                  DeviceId:
                                                      futureDevices[index].id!,
                                                ),
                                              ),
                                            ).then((value) {
                                              if (value == true) {
                                                setState(() {
                                                  fetchDevices();
                                                });
                                              }
                                            });
                                          } else {
                                            showDeviceSpecifications(
                                                showProperties!);
                                          }
                                        },
                                      ),
                                      ListTile(
                                        leading: Icon(Icons.h_mobiledata, color: Colors.blueAccent),
                                        title: Text('hardware key'),
                                        onTap: () {
                                          Navigator.pop(context); // لإغلاق النافذة المنبثقة
                                          if (hardwarekey == null) {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => Creathardwarekey(
                                                  deviceid: futureDevices[index].id!,
                                                ),
                                              ),
                                            ).then((value) {
                                              if (value == true) {
                                                setState(() {
                                                  fetchDevices();
                                                });
                                              }
                                            });
                                          } else {
                                            showhardwarekey(context);
                                          }
                                        },
                                      ),


                                      // تعديل الجهاز
                                      ListTile(
                                        leading: const Icon(Icons.edit,
                                            color: Colors.blueAccent),
                                        title: const Text('Edit Device'),
                                        onTap: () {
                                          Navigator.pop(context);
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => EditDevice(
                                                Deviceid:
                                                    futureDevices[index].id!,
                                              ),
                                            ),
                                          ).then((value) {
                                            if (value == true) {
                                              setState(() {
                                                fetchDevices();
                                              });
                                            }
                                          });
                                        },
                                      ),
                                      if (role == '1') ...[
                                        ListTile(
                                          leading: const Icon(Icons.delete,
                                              color: Colors.redAccent),
                                          title: const Text('Delete Device'),
                                          onTap: () {
                                            Navigator.pop(context);
                                            showDeleteDialog(context,
                                                futureDevices[index].id!);
                                          },
                                        )
                                      ],
                                      if (role == '2') ...[
                                        ListTile(
                                          leading: const Icon(
                                              Icons.install_desktop,
                                              color: Colors.blueAccent),
                                          title: const Text(
                                              'Installation Service'),
                                          onTap: () {
                                            Navigator.pop(context);
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    CreateInstallationService(
                                                  deviceId:
                                                      futureDevices[index].id!,
                                                ),
                                              ),
                                            ).then((value) {
                                              if (value == true) {
                                                setState(() {
                                                  fetchDevices();
                                                });
                                              }
                                            });
                                          },
                                        ),
                                        ListTile(
                                          leading: const Icon(
                                              Icons.settings_suggest_outlined,
                                              color: Colors.blueAccent),
                                          title:
                                              const Text('Maintenance Service'),
                                          onTap: () {
                                            Navigator.pop(context);
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    CreateMaintenanceService(
                                                  deviceId:
                                                      futureDevices[index].id!,
                                                ),
                                              ),
                                            ).then((value) {
                                              if (value == true) {
                                                setState(() {
                                                  fetchDevices();
                                                });
                                              }
                                            });
                                          },
                                        )
                                      ],
                                    ],
                                  );
                                },
                              );
                            },
                          ),
                        ),
                        // محتوى الكارد في الوسط
                        Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const Icon(Icons.devices,
                                  size: 50, color: Colors.blueAccent),
                              const SizedBox(height: 10),
                              Text(
                                futureDevices[index].name ?? 'No Name',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
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
          return const Center(child: CircularProgressIndicator());
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  Createdevice(departmentId: widget.departmentId),
            ),
          ).then((value) {
            if (value == true) {
              setState(() {
                fetchDevices();
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
