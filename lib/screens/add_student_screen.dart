import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

class AddStudentScreen extends StatefulWidget {
  const AddStudentScreen({super.key});

  @override
  State<AddStudentScreen> createState() => _AddStudentScreenState();
}

class _AddStudentScreenState extends State<AddStudentScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController registerController = TextEditingController();
  final TextEditingController admissionController = TextEditingController();
  final TextEditingController loginIdController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController departmentController = TextEditingController();
  final TextEditingController semesterController = TextEditingController();
  final TextEditingController classController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool isLoading = false;

  Future<void> addStudent() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        isLoading = true;
      });

      var url = Uri.parse('http://10.3.2.145/add_student.php');
      var response = await http.post(url, body: {
        'register_number': registerController.text,
        'admission_number': admissionController.text,
        'login_id': loginIdController.text,
        'username': usernameController.text,
        'name': nameController.text,
        'department': departmentController.text,
        'semester': semesterController.text,
        'class': classController.text,
        'email': emailController.text,
        'password': passwordController.text,
      });

      setState(() {
        isLoading = false;
      });

      if (response.statusCode == 200) {
        var res = response.body;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(res)),
        );
        _formKey.currentState!.reset();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Error adding student.")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Add Student",
          style: GoogleFonts.poppins(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: registerController,
                decoration: const InputDecoration(labelText: 'Register Number'),
                validator: (value) => value!.isEmpty ? 'Required' : null,
              ),
              TextFormField(
                controller: admissionController,
                decoration: const InputDecoration(labelText: 'Admission Number'),
                validator: (value) => value!.isEmpty ? 'Required' : null,
              ),
              TextFormField(
                controller: loginIdController,
                decoration: const InputDecoration(labelText: 'Login ID'),
              ),
              TextFormField(
                controller: usernameController,
                decoration: const InputDecoration(labelText: 'Username'),
              ),
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Full Name'),
                validator: (value) => value!.isEmpty ? 'Required' : null,
              ),
              TextFormField(
                controller: departmentController,
                decoration: const InputDecoration(labelText: 'Department'),
              ),
              TextFormField(
                controller: semesterController,
                decoration: const InputDecoration(labelText: 'Semester'),
                keyboardType: TextInputType.number,
              ),
              TextFormField(
                controller: classController,
                decoration: const InputDecoration(labelText: 'Class'),
              ),
              TextFormField(
                controller: emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
              ),
              TextFormField(
                controller: passwordController,
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
              ),
              const SizedBox(height: 20),
              isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                onPressed: addStudent,
                child: const Text("Add Student"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
