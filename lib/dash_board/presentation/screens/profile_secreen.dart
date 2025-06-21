import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  HRUser user = HRUser(
    name: "Sarah Ahmad",
    position: "HR Manager",
    email: "sara.ahmad@company.com",
    phone: "+966 500 123 456",
    department: "Human Resources",
    address: "123 Main St, Riyadh, KSA",
    dob: DateTime(1990, 5, 20),
    gender: "Female",
    website: "https://sarahahmad.com",
    bio: "Passionate HR professional with over 10 years of experience.",
    profileImagePath: null,
    profileImageUrl: "https://i.pravatar.cc/150?img=47",
  );

  bool isEditing = false;

  late TextEditingController nameController;
  late TextEditingController positionController;
  late TextEditingController emailController;
  late TextEditingController phoneController;
  late TextEditingController departmentController;
  late TextEditingController addressController;
  late TextEditingController websiteController;
  late TextEditingController bioController;

  String? selectedGender;
  DateTime? selectedDOB;

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: user.name);
    positionController = TextEditingController(text: user.position);
    emailController = TextEditingController(text: user.email);
    phoneController = TextEditingController(text: user.phone);
    departmentController = TextEditingController(text: user.department);
    addressController = TextEditingController(text: user.address);
    websiteController = TextEditingController(text: user.website);
    bioController = TextEditingController(text: user.bio);
    selectedGender = user.gender;
    selectedDOB = user.dob;
  }

  @override
  void dispose() {
    nameController.dispose();
    positionController.dispose();
    emailController.dispose();
    phoneController.dispose();
    departmentController.dispose();
    addressController.dispose();
    websiteController.dispose();
    bioController.dispose();
    super.dispose();
  }

  Future<void> _pickDOB(BuildContext context) async {
    final initialDate = selectedDOB ?? DateTime(1990, 1, 1);
    final newDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (newDate != null) {
      setState(() {
        selectedDOB = newDate;
      });
    }
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        user = user.copyWith(profileImagePath: image.path);
      });
    }
  }

  void _saveProfile() {
    setState(() {
      user = user.copyWith(
        name: nameController.text.trim(),
        position: positionController.text.trim(),
        email: emailController.text.trim(),
        phone: phoneController.text.trim(),
        department: departmentController.text.trim(),
        address: addressController.text.trim(),
        website: websiteController.text.trim(),
        bio: bioController.text.trim(),
        gender: selectedGender ?? user.gender,
        dob: selectedDOB ?? user.dob,
      );
      isEditing = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profile updated successfully!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 30),
        child: Column(
          children: [
            _buildProfileHeader(),
            const SizedBox(height: 28),
            _buildProfileForm(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          if (isEditing) {
            _saveProfile();
          } else {
            setState(() {
              isEditing = true;
            });
          }
        },
        label: Text(isEditing ? 'Save' : 'Edit'),
        icon: Icon(isEditing ? Icons.save : Icons.edit),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Column(
      children: [
        Stack(
          alignment: Alignment.bottomRight,
          children: [
            CircleAvatar(
              radius: 72,
              backgroundColor: Colors.cyan.shade50,
              backgroundImage: user.profileImagePath != null
                  ? FileImage(File(user.profileImagePath!))
                  : NetworkImage(user.profileImageUrl) as ImageProvider,
            ),
            if (isEditing)
              Positioned(
                bottom: 4,
                right: 4,
                child: InkWell(
                  onTap: _pickImage,
                  child: const CircleAvatar(
                    backgroundColor: Colors.cyan,
                    radius: 20,
                    child:
                        Icon(Icons.camera_alt, size: 20, color: Colors.white),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          user.name,
          style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 6),
        Text(
          user.position,
          style: TextStyle(
              fontSize: 16,
              color: Colors.cyan.shade400,
              fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  Widget _buildProfileForm() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildTextField("Full Name", nameController),
            _buildTextField("Position", positionController),
            _buildTextField("Email", emailController,
                keyboard: TextInputType.emailAddress),
            _buildTextField("Phone", phoneController,
                keyboard: TextInputType.phone),
            _buildTextField("Department", departmentController),
            _buildTextField("Address", addressController),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: isEditing ? () => _pickDOB(context) : null,
              child: AbsorbPointer(
                child: TextField(
                  controller: TextEditingController(
                      text: selectedDOB == null
                          ? ''
                          : "${selectedDOB!.year}-${selectedDOB!.month.toString().padLeft(2, '0')}-${selectedDOB!.day.toString().padLeft(2, '0')}"),
                  decoration: const InputDecoration(labelText: "Date of Birth"),
                ),
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: selectedGender,
              onChanged: isEditing
                  ? (val) => setState(() => selectedGender = val)
                  : null,
              items: const [
                DropdownMenuItem(value: "Male", child: Text("Male")),
                DropdownMenuItem(value: "Female", child: Text("Female")),
                DropdownMenuItem(value: "Other", child: Text("Other")),
              ],
              decoration: const InputDecoration(labelText: "Gender"),
            ),
            _buildTextField("Website", websiteController,
                keyboard: TextInputType.url),
            _buildTextField("Bio", bioController, maxLines: 3),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller,
      {TextInputType keyboard = TextInputType.text, int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: controller,
        keyboardType: keyboard,
        enabled: isEditing,
        maxLines: maxLines,
        decoration: InputDecoration(labelText: label),
      ),
    );
  }
}

class HRUser {
  final String name;
  final String position;
  final String email;
  final String phone;
  final String department;
  final String address;
  final DateTime dob;
  final String gender;
  final String website;
  final String bio;
  final String? profileImagePath;
  final String profileImageUrl;

  HRUser({
    required this.name,
    required this.position,
    required this.email,
    required this.phone,
    required this.department,
    required this.address,
    required this.dob,
    required this.gender,
    required this.website,
    required this.bio,
    this.profileImagePath,
    required this.profileImageUrl,
  });

  HRUser copyWith({
    String? name,
    String? position,
    String? email,
    String? phone,
    String? department,
    String? address,
    DateTime? dob,
    String? gender,
    String? website,
    String? bio,
    String? profileImagePath,
    String? profileImageUrl,
  }) {
    return HRUser(
      name: name ?? this.name,
      position: position ?? this.position,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      department: department ?? this.department,
      address: address ?? this.address,
      dob: dob ?? this.dob,
      gender: gender ?? this.gender,
      website: website ?? this.website,
      bio: bio ?? this.bio,
      profileImagePath: profileImagePath ?? this.profileImagePath,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
    );
  }
}
