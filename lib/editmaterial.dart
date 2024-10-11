import 'package:flutter/material.dart';
import 'package:untitled1/drawer.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'main.dart';

class EditMaterial extends StatelessWidget {
  final int materialId;
  const EditMaterial({super.key, required this.materialId});

  @override
  Widget build(BuildContext context) {
    final TextEditingController codeController = TextEditingController();
    final TextEditingController nameController = TextEditingController();
    final TextEditingController quantityController = TextEditingController();
    final TextEditingController priceController = TextEditingController();
    GlobalKey<FormState> editmaterialForm = GlobalKey();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edi Material'),
      ),
      drawer: NavDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: editmaterialForm,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'New material Name'),
                validator: (value){
                  if(value!.length<2){
                    return ' the name must be ';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: codeController,
                decoration: const InputDecoration(labelText: 'New material code'),
                obscureText: true,
                validator: (value){
                  if(value!.length<1){
                    return ' the code must be ';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: quantityController,
                decoration: const InputDecoration(labelText: 'New material quantity'),


              ),
              TextFormField(
                controller: priceController,
                decoration: const InputDecoration(labelText: 'New material price'),

                validator: (value){
                  if(value!.length<2){
                    return ' the price must be ';
                  }
                  return null;
                },
              ),

              ElevatedButton(
                onPressed: () async {
                  // استدعاء دالة تعديل المستخدم وانتظار النتيجة
                  if(editmaterialForm.currentState!.validate()){
                    bool success =false;
                    await editmaterial(
                      materialId: materialId,
                      name: nameController.text,
                      code: codeController.text,
                      quantity:quantityController.text,
                      price:priceController.text,
                      context: context,
                    );

                    // إذا نجحت العملية، الرجوع إلى الصفحة السابقة
                    // if (success) {
                    //    Navigator.pop(context, true); // الرجوع مع القيمة true
                    //  }else{}
                  }

                },
                child: const Text('Edit material'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<bool> editmaterial({
    required int materialId,
    required String name,
    required String code,
    required String quantity,
    required String price,
    required BuildContext context,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    String token = prefs.getString('token') ?? '';

    final Uri url = Uri.parse('$urlbase/editMaterial/$materialId');

    final response = await http.put(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: '{"name": "$name","quantity":$quantity,"price":"$price"}',
    );

    if (response.statusCode == 200) {
      // نجاح العملية
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('edit Material updated successfully')),
      );
      return true;
    }
    else {
      // فشل العملية
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(response.body)),
      );
      return false;
    }
  }
}
