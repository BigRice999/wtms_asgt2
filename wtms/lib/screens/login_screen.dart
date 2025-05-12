import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wtms/screens/registration_screen.dart';
import 'package:wtms/screens/profile_screen.dart';
import 'package:wtms/models/worker.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  bool isChecked = false;

  @override
  void initState() {
    super.initState();
    loadCredentials();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Login Screen"),
        backgroundColor: const Color.fromARGB(255, 255, 186, 133),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Card(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      TextField(
                        controller: emailController,
                        decoration: const InputDecoration(labelText: "Email"),
                        keyboardType: TextInputType.emailAddress,
                      ),
                      TextField(
                        controller: passwordController,
                        decoration: const InputDecoration(labelText: "Password"),
                        obscureText: true,
                      ),
                      Row(
                        children: [
                          const Text("Remember Me"),
                          Checkbox(
                            value: isChecked,
                            onChanged: (value) {
                              setState(() {
                                isChecked = value!;
                              });
                              storeCredentials(
                                emailController.text,
                                passwordController.text,
                                isChecked,
                              );
                            },
                          ),
                        ],
                      ),
                      
                      ElevatedButton(
                        onPressed: loginUser,
                        child: const Text("Login"),
                      )
                    ],
                  ),
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const RegisterScreen()),
                );
              },
              child: const Text("Register an account"),
            ),
            const SizedBox(height: 10),
            GestureDetector(onTap: () {}, child: const Text("Forgot Password?")),
          ],
        ),
      ),
    );
  }

  // error message when user didn't input credentials
  void loginUser() async {
  String email = emailController.text;
  String password = passwordController.text;

  if (email.isEmpty || password.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text("Please fill all fields"),
      backgroundColor: Colors.red,
    ));
    return;
  }

  var url = Uri.parse("http://10.0.2.2/wtms_api/login_worker.php");
  var response = await http.post(url, body: {
    "email": email,
    "password": password,
  });

  if (response.statusCode == 200) {
    var jsondata = json.decode(response.body);
    if (jsondata['status'] == 'success') {
      var workerData = jsondata['data'];
      Worker worker = Worker.fromJson(workerData);

      // save credentials only after successful login
      if (isChecked) {
        await storeCredentials(email, password, true);
      } else {
        await storeCredentials("", "", false);
      }

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Welcome ${worker.fullName}"),
        backgroundColor: Colors.green,
      ));

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => ProfileScreen(worker: worker)),
      );
    } else {
      String message = jsondata['message'] ?? "Login failed. Email not registered.";
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ));
    }
  }
}

  // store user data to database
  Future<void> storeCredentials(String email, String password, bool isChecked) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (isChecked) {
      await prefs.setString('email', email);
      await prefs.setString('password', password);
      await prefs.setBool('remember', isChecked);
    } else {
      await prefs.remove('email');
      await prefs.remove('password');
      await prefs.remove('remember');
      emailController.clear();
      passwordController.clear();
      setState(() {});
    }
  }

  // keep last input credentials when user tick Remember me
  Future<void> loadCredentials() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? email = prefs.getString('email');
    String? password = prefs.getString('password');
    bool? isChecked = prefs.getBool('remember');

    if (email != null && password != null && isChecked != null && isChecked) {
      emailController.text = email;
      passwordController.text = password;
      setState(() {
        this.isChecked = isChecked;
      });
    }
  }
}
