import 'dart:async';
import 'dart:io';
import 'package:aim_tracker/services/local_db.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();
  final TextEditingController _nameController = TextEditingController();

  Future<void> _loadUserData() async {
    final data  = await ActtivityDatabase.instance.getUserData();

    if (data != null){
      setState(() {
        _nameController.text = data['name'] ?? "Demo";
        final path = data['imagePath'];
        if (path != null && path.isNotEmpty){
          _selectedImage = File(path);
        }
      });
      print("Load User Data: ${_nameController.text}, ${_selectedImage?.path}");
  } else {
      _nameController.text = "Demo";
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null){
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
      await ActtivityDatabase.instance.saveUserData(
        _nameController.text,
        pickedFile.path,
      );
    }
  }
  Future <void> _saveUserName() async {
    await ActtivityDatabase.instance.saveUserData(
      _nameController.text,
      _selectedImage?.path
    );
  }
@override
  void initState() {
    // TODO: implement initState
    super.initState();
    _loadUserData();
  }

//   void initState(){
//     super.initState();
//   Timer(
//   const Duration(seconds:2),(){
//   if (!mounted) return;
  // Navigator.of(context).pushReplacement(
  // MaterialPageRoute(builder:(context) => HomeScreen()),
  // );
//   });
// }
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
          child: SingleChildScrollView(
            child: Center(
              child: Column(
                children: [
                  Stack(
                    clipBehavior: Clip.none,
                      children: [
                        ClipOval(
                            child:
                              _selectedImage != null ?
                            Image.file(_selectedImage!, width: 300, height: 300, fit: BoxFit.cover,)
                            : Image.asset("assets/images/demo_user.jpg", width: 300, height: 300, fit: BoxFit.cover,)
                              ),
                        // SizedBox(width: 20,),
                        Positioned(
                            top: 40,
                            right: 0,
                            child: GestureDetector(
                              onTap: _pickImage,
                              child: CircleAvatar(
                                backgroundColor: Colors.blue,
                                child: Icon(Icons.edit, size: 25,color: Colors.white,)
                              ),
                            ))
                      ],
                    ),
                  // SizedBox(height: 10,),
                  Text("Welcome", style: TextStyle(fontSize: 24),),
                  SizedBox(height: 20,),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(25),
                      color: Color(0xFFD9D9D9)
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 150,
                          child: TextField(
                            controller: _nameController,
                            textAlign: TextAlign.center,
                            decoration: InputDecoration(
                              border: InputBorder.none,
                                // contentPadding: EdgeInsets.zero,
                              hintText: "Enter Name"
                            ),
                            style: TextStyle(
                              fontSize: 20
                            ),
                            onChanged: (value) => _saveUserName(),
                          ),
                        ),
                        // SizedBox(width: 8,),
                      ],
                    ),
                  ),
                  SizedBox(height: 150,),
                  InkWell(
                    onTap: () async {
                      String userName = _nameController.text.trim();
                      if (userName.isNotEmpty){
                        await _saveUserName();
                      }
                      print(userName);
                      Navigator.push(context, MaterialPageRoute(builder: (context) => HomeScreen()));
                    },
                    child: Container(
                      width: 150,
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Color(0xFFFFBABA),
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: Text("Continue", style: TextStyle(fontSize: 20),textAlign: TextAlign.center,),
                    ),
                  ),
                  SizedBox(height: 15,),
                ],
              ),
            ),
          )
      ),
    );
  }

}