import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:wtms/screens/login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  File? _image;
  Uint8List? webImageBytes;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Register Screen"),
        backgroundColor: const Color.fromARGB(255, 255, 186, 133),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            margin: const EdgeInsets.all(16.0),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: () => showSelectionDialog(),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          CircleAvatar(
                            radius: 60,
                            backgroundImage: _image != null
                                ? _buildProfileImage()
                                : const AssetImage('assets/images/profile.png') as ImageProvider,
                          ),
                          const Icon(Icons.camera_alt, size: 30, color: Colors.white70),
                        ],
                      ),
                    ),
                    // box to accept user input
                    const SizedBox(height: 16),
                    buildTextField(nameController, "Full Name"),
                    buildTextField(emailController, "Email", keyboardType: TextInputType.emailAddress),
                    buildTextField(passwordController, "Password", obscureText: true),
                    buildTextField(confirmPasswordController, "Confirm Password", obscureText: true),
                    buildTextField(phoneController, "Phone", keyboardType: TextInputType.phone),
                    buildTextField(addressController, "Address", maxLines: 5),
                    const SizedBox(height: 16),
                    
                    SizedBox(
                      width: 400,
                      child: ElevatedButton(
                        onPressed: registerUserDialog,
                        child: const Text("Register"),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => const LoginScreen()),
                        );
                      },
                      child: const Text("Already have an account? Sign In"),
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildTextField(TextEditingController controller, String label,
      {TextInputType keyboardType = TextInputType.text,
      bool obscureText = false,
      int maxLines = 1}) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(labelText: label),
      keyboardType: keyboardType,
      obscureText: obscureText,
      maxLines: maxLines,
    );
  }

  void registerUserDialog() {
    String name = nameController.text;
    String email = emailController.text;
    String password = passwordController.text;
    String confirmPassword = confirmPasswordController.text;
    String phone = phoneController.text;
    String address = addressController.text;

    // error message when user input invalid data
    final emailValid = RegExp(r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}").hasMatch(email);
    final phoneValid = RegExp(r"^\d+").hasMatch(phone);

    if (name.isEmpty || email.isEmpty || password.isEmpty ||
        confirmPassword.isEmpty || phone.isEmpty || address.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all fields"), backgroundColor: Colors.red),
      );
      return;
    }

    if (!emailValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a valid email address"), backgroundColor: Colors.red),
      );
      return;
    }

    if (!phoneValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a valid phone number"), backgroundColor: Colors.red),
      );
      return;
    }

    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Passwords do not match"), backgroundColor: Colors.red),
      );
      return;
    }

    // message to ask user confirming
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Register this account?"),
          content: const Text("Are you sure?"),
          actions: [
            TextButton(
              child: const Text("YES"),
              onPressed: () {
                Navigator.of(context).pop();
                registerUser();
              },
            ),
            TextButton(
              child: const Text("CANCEL"),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }

  // POST request to the server to validate credentials
  void registerUser() async {
    var url = Uri.parse("http://10.0.2.2/wtms_api/register_worker.php");
    var request = http.MultipartRequest('POST', url);
    request.fields['full_name'] = nameController.text;
    request.fields['email'] = emailController.text;
    request.fields['password'] = passwordController.text;
    request.fields['phone'] = phoneController.text;
    request.fields['address'] = addressController.text;

    if (_image != null) {
      request.files.add(await http.MultipartFile.fromPath('image', _image!.path));
    }

    var response = await request.send();
    var res = await http.Response.fromStream(response);
    if (res.statusCode == 200) {
      var jsondata = json.decode(res.body);
      if (jsondata['status'] == 'success') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Register Successfully!"), backgroundColor: Colors.green),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );

      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(jsondata['message'] ?? "Failed to register"), backgroundColor: Colors.red),
        );
      }
    }
  }

  // options to insert profile picture
  void showSelectionDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Select from"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _selectFromCamera();
                },
                child: const Text("From Camera"),
              ),

              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _selectfromGallery();
                },
                child: const Text("From Gallery"),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _selectFromCamera() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: kIsWeb ? ImageSource.gallery : ImageSource.camera,
      maxHeight: 800,
      maxWidth: 800,
    );

    if (pickedFile != null) {
      _image = File(pickedFile.path);
      if (kIsWeb) {
        webImageBytes = await pickedFile.readAsBytes();
      }
      setState(() {});
    }
  }

  Future<void> _selectfromGallery() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      maxHeight: 800,
      maxWidth: 800,
    );

    if (pickedFile != null) {
      _image = File(pickedFile.path);
      setState(() {});
    }
  }

  ImageProvider _buildProfileImage() {
    if (_image != null) {
      if (kIsWeb && webImageBytes != null) {
        return MemoryImage(webImageBytes!);
      } else {
        return FileImage(_image!);
      }
    }
    return const AssetImage('assets/images/profile.png');
  }
}
