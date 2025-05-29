import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wtms/models/worker.dart';
import 'package:wtms/screens/login_screen.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'task_list_screen.dart';


class ProfileScreen extends StatefulWidget {
  final Worker worker;

  const ProfileScreen({super.key, required this.worker});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  File? _image;

  Future<void> _logout(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (route) => false,
    );
  }

  Future<void> _changeProfilePicture() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Change Profile Picture"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
                child: const Text("Take a photo"),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
                child: const Text("Choose from gallery"),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });

      await _uploadProfileImage(_image!);
    }
  }

  // set default profile picture and update when user choose
  Future<void> _uploadProfileImage(File imageFile) async {
  var url = Uri.parse("http://10.0.2.2/wtms_api/update_profile_image.php");
  var request = http.MultipartRequest("POST", url);
  request.fields['id'] = widget.worker.id;

  request.files.add(await http.MultipartFile.fromPath('image', imageFile.path));

  var response = await request.send();
  if (response.statusCode == 200) {
    final res = await http.Response.fromStream(response);
    final jsonData = json.decode(res.body);

    if (jsonData['status'] == 'success') {
      String newImagePath = jsonData['image'];
      setState(() {
        widget.worker.image = newImagePath;
      });

      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('worker_image', newImagePath);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Profile picture updated!"), backgroundColor: Colors.green),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(jsonData['message']), backgroundColor: Colors.red),
      );
    }
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Upload failed"), backgroundColor: Colors.red),
    );
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile Screen"),
        backgroundColor: const Color.fromARGB(255, 255, 186, 133),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _logout(context),
          )
        ],
      ),

      body: Padding( 
        padding: const EdgeInsets.all(30.0),
        child: Column(
          children: [
            GestureDetector(
              onTap: _changeProfilePicture,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CircleAvatar(
                    radius: 70,
                    backgroundImage: _image != null
                      ? FileImage(_image!)
                      : (widget.worker.image.isNotEmpty
                          ? NetworkImage('http://10.0.2.2/wtms_api/${widget.worker.image}')
                          : const AssetImage('assets/images/profile.png')) as ImageProvider,
                  ),

                  const Icon(
                    Icons.camera_alt,
                    size: 40,
                    color: Colors.white70,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),
            Expanded(
              child: Card(
                child: ListView(
                  padding: const EdgeInsets.all(16.0),
                  children: [
                    _buildRow("Worker ID", widget.worker.id),
                    _buildRow("Full Name", widget.worker.fullName),
                    _buildRow("Email", widget.worker.email),
                    _buildRow("Phone Number", widget.worker.phone),
                    _buildRow("Address", widget.worker.address),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20), // a section for task management
            Card(
              color: const Color.fromARGB(255, 255, 237, 149),
              child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                          const Text("Task Management", style: TextStyle(fontSize: 16)),
                          const SizedBox(height: 20),
                           SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                      icon: const Icon(Icons.task),
                                      label: const Text("View My Assigned Tasks"),
                                      
                                      onPressed: () {
                                        Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                          TaskListScreen(workerId: widget.worker.id.toString()), 
                                        ),
                                        );
                                      }

                              ),
                            ),
                        ],
                    ),
              ),
            ),

          ],
        ),
      ),
    );
  }

  Widget _buildRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "$label: ",
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
