import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:untitled1/drawer.dart';
import 'package:untitled1/models/show_material_model.dart';
import 'main.dart';

class CreateInstallationService extends StatefulWidget {
  final int deviceId;

  const CreateInstallationService({super.key, required this.deviceId});

  @override
  _CreateInstallationServiceState createState() => _CreateInstallationServiceState();
}

class _CreateInstallationServiceState extends State<CreateInstallationService> {
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController quantityController = TextEditingController();

  List<Showmaterial> materials = []; // قائمة المواد
  int? selectedMaterialId; // المادة المختارة
  List<Map<String, dynamic>> selectedMaterials = []; // قائمة المواد المختارة مع الكمية

  @override
  void initState() {
    super.initState();
    _fetchMaterials(); // جلب المواد عند تحميل الصفحة
  }

  Future<void> _fetchMaterials() async {
    final prefs = await SharedPreferences.getInstance();
    String token = prefs.getString('token') ?? '';

    final Uri url = Uri.parse('$urlbase/showMaterial'); // رابط API للحصول على المواد
    final response = await http.get(url, headers: {
      'Authorization': 'Bearer $token',
    });

    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      setState(() {
        materials = jsonResponse.map((data) => Showmaterial.fromJson(data)).toList();
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to load materials')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Installation Service'),
      ),
      drawer: NavDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextFormField(
              controller: descriptionController,
              decoration: const InputDecoration(labelText: 'Description'),
            ),
            const SizedBox(height: 20),
            materials.isEmpty
                ? const CircularProgressIndicator() // إظهار مؤشر تحميل أثناء جلب المواد
                : DropdownButtonFormField<int>(
              value: selectedMaterialId,
              onChanged: (int? newValue) {
                setState(() {
                  selectedMaterialId = newValue;
                });
              },
              items: materials.map<DropdownMenuItem<int>>((Showmaterial material) {
                return DropdownMenuItem<int>(
                  value: material.id!, // تأكد من أن material.id ليس null
                  child: Text(material.name ?? 'No Name'),
                );
              }).toList(),
              decoration: const InputDecoration(labelText: 'Select Material'),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: quantityController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Quantity'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (selectedMaterialId != null && quantityController.text.isNotEmpty) {
                  setState(() {
                    selectedMaterials.add({
                      'material_id': selectedMaterialId!,
                      'quantity': int.parse(quantityController.text),
                    });
                    selectedMaterialId = null; // إعادة تعيين المادة المختارة
                    quantityController.clear(); // إعادة تعيين الحقل
                  });
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please select material and enter quantity')),
                  );
                }
              },
              child: const Text('Add Material'),
            ),
            const SizedBox(height: 20),
            // عرض المواد المضافة
            Expanded(
              child: ListView.builder(
                itemCount: selectedMaterials.length,
                itemBuilder: (context, index) {
                  // البحث عن المادة في القائمة بناءً على `material_id` من `selectedMaterials`
                  Showmaterial? material = materials.firstWhere(
                        (element) => element.id == selectedMaterials[index]['material_id'],
                    orElse: () => Showmaterial(id: null, name: 'Unknown'),
                  );

                  return ListTile(
                    title: Text('Material: ${material.name ?? 'Unknown'}'),
                    subtitle: Text('Quantity: ${selectedMaterials[index]['quantity']}'),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        setState(() {
                          selectedMaterials.removeAt(index); // إزالة المادة من القائمة
                        });
                      },
                    ),
                  );
                },
              ),
            ),

            ElevatedButton(
              onPressed: () async {
                if (selectedMaterials.isNotEmpty) {
                  bool success = await createInstallationService(
                    description: descriptionController.text,
                    materials: selectedMaterials,
                    deviceId: widget.deviceId,
                    context: context,
                  );
                  if (success) {
                    Navigator.pop(context, true);
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please add at least one material')),
                  );
                }
              },
              child: const Text('Create Installation Service'),
            ),
          ],
        ),
      ),
    );
  }

  Future<bool> createInstallationService({
    required int deviceId,
    required BuildContext context,
    required String description,
    required List<Map<String, dynamic>> materials,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    String token = prefs.getString('token') ?? '';

    final Uri url = Uri.parse('$urlbase/createInstallationService/$deviceId');

    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'description': description,
        'materials': materials, // إرسال قائمة المواد
      }),
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Create installation service successfully')),
      );
      return true;
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to create installation service')),
      );
      return false;
    }
  }
}
