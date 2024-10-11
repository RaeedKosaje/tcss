import 'dart:convert';
import 'package:fan_floating_menu/fan_floating_menu.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:untitled1/addperipherals.dart';
import 'package:untitled1/addproperties.dart';
import 'package:untitled1/drawer.dart';
import 'package:untitled1/editProperties.dart';
import 'package:untitled1/editdevice.dart';
import 'package:untitled1/createDevice.dart';
import 'package:untitled1/editperipherals.dart';
import 'package:untitled1/models/show-properties-model.dart';
import 'package:untitled1/models/show_devices_model.dart';
import 'createHardwarekey.dart';
import 'createinstallationservice.dart';
import 'createmaintenanceservice.dart';
import 'edithardwarekey.dart';
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

  @override
  void initState() {
    super.initState();
    fetchDevices();
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
        showProperties = ShowProperties.fromJson(jsonResponse);
      });
    } else {
      setState(() {
        showProperties = null; // تحديد أن البيانات غير متوفرة
      });
    }

    final response1 = await http.get(
      Uri.parse('$urlbase/showPeripherals/$deviceId'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response1.statusCode == 200) {
      dynamic jsonResponse = json.decode(response1.body);
      setState(() {
        showPeripherals = ShowPeripherals.fromJson(jsonResponse);
      });
    } else {
      setState(() {
        showPeripherals = null; // تحديد أن البيانات غير متوفرة
      });
    }
    final response3 = await http.get(
      Uri.parse('$urlbase/showHardwarekey/$deviceId'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response1.statusCode == 200) {
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
              child: const Text('Delete'),
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

  void showDeviceSpecifications(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('مواصفات الجهاز'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('CPU: ${showProperties?.cPU ?? "غير موجود"}'),
              Text(
                  'Motherboard: ${showProperties?.motherboard ?? "غير موجود"}'),
              Text('RAM: ${showProperties?.rAM ?? "غير موجود"}'),
              Text('Hard: ${showProperties?.hard ?? "غير موجود"}'),
              Text('Graphics: ${showProperties?.graphics ?? "غير موجود"}'),
              Text(
                  'Power Supply: ${showProperties?.powerSupply ?? "غير موجود"}'),
              Text('OS: ${showProperties?.oS ?? "غير موجود"}'),
              Text('NIC: ${showProperties?.nIC ?? "غير موجود"}'),

              const SizedBox(height: 10), // مسافة بين المواصفات والأزرار
              // زر تعديل معلومات الجهاز
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          EditProperties(Deviceid: showProperties!.id!),
                    ),
                  ).then((value) {
                    if (value == true) {
                      setState(() {
                        fetchDevices();
                      });
                    }
                  });
                },
                child: const Text('تعديل معلومات الجهاز'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('إغلاق'),
            ),
          ],
        );
      },
    );
  }

  void showDeviceper(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('الملحقات'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('monitor: ${showPeripherals?.monitor ?? "غير موجود"}'),
              Text('keyboard: ${showPeripherals?.keyboard ?? "غير موجود"}'),
              Text('mouse: ${showPeripherals?.mouse ?? "غير موجود"}'),
              Text('printer: ${showPeripherals?.printer ?? "غير موجود"}'),
              Text('uPS: ${showPeripherals?.uPS ?? "غير موجود"}'),
              Text('cashBox: ${showPeripherals?.cashBox ?? "غير موجود"}'),
              Text('barcode: ${showPeripherals?.barcode ?? "غير موجود"}'),

              const SizedBox(height: 10), // مسافة بين المواصفات والأزرار
              // زر تعديل معلومات الجهاز
              ElevatedButton(
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
                child: const Text('تعديل الملحقات'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('إغلاق'),
            ),
          ],
        );
      },
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
              Text('type: ${hardwarekey?.type ?? "غير موجود"}'),
              Text('serial: ${hardwarekey?.sereal ?? "غير موجود"}'),
              Text('exDate: ${hardwarekey?.exDate ?? "غير موجود"}'),
              Text('description: ${hardwarekey?.description ?? "غير موجود"}'),

              const SizedBox(height: 10), // مسافة بين المواصفات والأزرار

              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          Edithardwarekey(
                              deviceid: hardwarekey!.id!),
                    ),
                  ).then((value) {
                    if (value == true) {
                      setState(() {
                        fetchDevices();
                      });
                    }
                  });
                },
                child: const Text('تعديل دارة الحماية'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('إغلاق'),
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
        title: const Text('Devices Page'),
      ),
      drawer: NavDrawer(),
      body: FutureBuilder(
        future: fetchDevices(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10.0,
                mainAxisSpacing: 10.0,
              ),
              itemCount: futureDevices.length,
              itemBuilder: (context, index) {
                return InkWell(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return const Center(child: CircularProgressIndicator());
                      },
                    );

                    device(futureDevices[index].id!).then((value) {
                      Navigator.pop(
                          context); // إغلاق Dialog التحميل بعد جلب البيانات

                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text(futureDevices[index].name ?? 'No Name'),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                    'تفاصيل الجهاز ${futureDevices[index].name ?? "غير موجودة"}'),
                                const SizedBox(height: 10),
                                // أزرار جديدة في الـ Dialog
                                ElevatedButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => EditDevice(
                                            Deviceid: futureDevices[index].id!),
                                      ),
                                    ).then((value) {
                                      if (value == true) {
                                        setState(() {
                                          fetchDevices();
                                        });
                                      }
                                    });
                                  },
                                  child: const Text('تعديل الجهاز'),
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    showDeleteDialog(
                                        context, futureDevices[index].id!);
                                  },
                                  child: const Text('حذف الجهاز'),
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => CreateMaintenanceService(

                                            deviceId: futureDevices[index].id!),
                                      ),
                                    ).then((value) {
                                      if (value == true) {
                                        setState(() {
                                          fetchDevices();
                                        });
                                      }
                                    });
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue, // لون الخلفية
                                    foregroundColor: Colors.white, // لون النص
                                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12), // حشوة الزر
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12), // الزوايا المستديرة
                                    ),
                                    elevation: 5, // ارتفاع الظل
                                  ),
                                  child: const Text(
                                    'خدمة صيانة',
                                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold), // تخصيص النص
                                  ),
                                ),

                                ElevatedButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => CreateInstallationService(

                                            deviceId: futureDevices[index].id!),
                                      ),
                                    ).then((value) {
                                      if (value == true) {
                                        setState(() {
                                          fetchDevices();
                                        });
                                      }
                                    });
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue, // لون الخلفية
                                    foregroundColor: Colors.white, // لون النص
                                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12), // حشوة الزر
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12), // الزوايا المستديرة
                                    ),
                                    elevation: 5, // ارتفاع الظل
                                  ),
                                  child: const  Text(
                                    'خدمة تركيب',
                                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold), // تخصيص النص
                                  ),
                                  ),

                                // زر مواصفات الجهاز
                                ElevatedButton(
                                  onPressed: () {
                                    if (showProperties == null) {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => AddProperties(
                                              Deviceid:
                                                  futureDevices[index].id!),
                                        ),
                                      ).then((value) {
                                        if (value == true) {
                                          setState(() {
                                            fetchDevices();
                                          });
                                        }
                                      });
                                    } else {
                                      showDeviceSpecifications(context);
                                    }
                                  },
                                  child: const Text('مواصفات الجهاز'),
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    if (hardwarekey == null) {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              Creathardwarekey(
                                                  deviceid:
                                                      futureDevices[index].id!),
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
                                  child: const Text('hard ware key'),
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    if (showPeripherals == null) {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => AddPeripherals(
                                              Deviceid:
                                                  futureDevices[index].id!),
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
                                  child: const Text(' الملحقات'),
                                ),
                              ],
                            ),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: const Text('إغلاق النافذة'),
                              ),
                            ],
                          );
                        },
                      );
                    }).catchError((error) {
                      Navigator.pop(context);
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text('Error'),
                            content:
                                Text('حدث خطأ أثناء جلب بيانات الجهاز: $error'),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: const Text('إغلاق'),
                              ),
                            ],
                          );
                        },
                      );
                    });
                  },
                  child: Card(
                    elevation: 5,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.devices),
                          Text(
                            futureDevices[index].name ?? 'No Name',
                            style: const TextStyle(fontSize: 18),
                          ),
                          const SizedBox(height: 30),
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
                    fetchDevices();
                  });
                }
              });
            },
            icon: Icons.add,
            title: 'Add Device',
          ),
        ],
      ),
    );
  }
}
