
import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../models/user_model.dart';
import 'profile_screen.dart';

class OnboardingScreen extends StatefulWidget {
  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  int currentStep = 0;
  bool isSaving = false;

  // Step 1: Personal Details
  final nameController = TextEditingController();

  // Step 2: Skills
  List<String> skills = [];
  final skillController = TextEditingController();

  // Step 3: Experience
  List<Map<String, String>> experiences = [];
  final roleController = TextEditingController();
  final companyController = TextEditingController();
  final durationController = TextEditingController();

  // Step 4: Education
  List<Map<String, String>> education = [];
  final schoolController = TextEditingController();
  final degreeController = TextEditingController();
  final fieldController = TextEditingController();

  // Step 5: Interests
  List<String> interests = [];
  final interestController = TextEditingController();

  final auth = AuthService();
  final firestore = FirestoreService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Resume Builder"),
        elevation: 0,
      ),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            // Progress bar
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: (currentStep + 1) / 5,
                minHeight: 8,
              ),
            ),
            SizedBox(height: 10),
            Text(
              "Step ${currentStep + 1} of 5",
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            SizedBox(height: 30),

            // Step content
            Expanded(
              child: SingleChildScrollView(
                child: _buildStepContent(),
              ),
            ),

            // Navigation buttons
            SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (currentStep > 0)
                  ElevatedButton.icon(
                    onPressed: () => setState(() => currentStep--),
                    icon: Icon(Icons.arrow_back),
                    label: Text("Back"),
                  )
                else
                  SizedBox(),
                ElevatedButton.icon(
                  onPressed: isSaving ? null : _handleNext,
                  icon: Icon(currentStep == 4 ? Icons.check : Icons.arrow_forward),
                  label: Text(currentStep == 4 ? "Finish" : "Next"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepContent() {
    switch (currentStep) {
      case 0:
        return _buildPersonalDetailsStep();
      case 1:
        return _buildSkillsStep();
      case 2:
        return _buildExperienceStep();
      case 3:
        return _buildEducationStep();
      case 4:
        return _buildInterestsStep();
      default:
        return SizedBox();
    }
  }

  // Step 1: Personal Details
  Widget _buildPersonalDetailsStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Personal Details",
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        SizedBox(height: 20),
        TextField(
          controller: nameController,
          decoration: InputDecoration(
            labelText: "Full Name",
            hintText: "Enter your full name",
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.person),
          ),
        ),
        SizedBox(height: 16),
        TextField(
          enabled: false,
          controller: TextEditingController(text: auth.currentUser?.email ?? ""),
          decoration: InputDecoration(
            labelText: "Email",
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.email),
          ),
        ),
      ],
    );
  }

  // Step 2: Skills
  Widget _buildSkillsStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Your Skills",
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: skillController,
                decoration: InputDecoration(
                  labelText: "Add a skill",
                  hintText: "e.g., Flutter, Dart",
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            SizedBox(width: 10),
            ElevatedButton(
              onPressed: () {
                if (skillController.text.isNotEmpty) {
                  setState(() {
                    skills.add(skillController.text);
                    skillController.clear();
                  });
                }
              },
              child: Text("Add"),
            ),
          ],
        ),
        SizedBox(height: 20),
        Wrap(
          spacing: 8,
          children: skills
              .map(
                (skill) => Chip(
                  label: Text(skill),
                  onDeleted: () {
                    setState(() => skills.remove(skill));
                  },
                ),
              )
              .toList(),
        ),
      ],
    );
  }

  // Step 3: Experience
  Widget _buildExperienceStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Work Experience",
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        SizedBox(height: 20),
        TextField(
          controller: roleController,
          decoration: InputDecoration(
            labelText: "Job Title / Role",
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.work),
          ),
        ),
        SizedBox(height: 12),
        TextField(
          controller: companyController,
          decoration: InputDecoration(
            labelText: "Company",
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.business),
          ),
        ),
        SizedBox(height: 12),
        TextField(
          controller: durationController,
          decoration: InputDecoration(
            labelText: "Duration (e.g., 2 years)",
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.date_range),
          ),
        ),
        SizedBox(height: 16),
        ElevatedButton.icon(
          onPressed: _addExperience,
          icon: Icon(Icons.add),
          label: Text("Add Experience"),
        ),
        SizedBox(height: 20),
        ...experiences.map((exp) {
          int index = experiences.indexOf(exp);
          return Card(
            margin: EdgeInsets.only(bottom: 12),
            child: ListTile(
              title: Text(exp['role'] ?? ""),
              subtitle: Text("${exp['company']} • ${exp['duration']}"),
              trailing: IconButton(
                icon: Icon(Icons.delete),
                onPressed: () {
                  setState(() => experiences.removeAt(index));
                },
              ),
            ),
          );
        }).toList(),
      ],
    );
  }

  // Step 4: Education
  Widget _buildEducationStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Education",
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        SizedBox(height: 20),
        TextField(
          controller: schoolController,
          decoration: InputDecoration(
            labelText: "School / University",
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.school),
          ),
        ),
        SizedBox(height: 12),
        TextField(
          controller: degreeController,
          decoration: InputDecoration(
            labelText: "Degree",
            hintText: "e.g., Bachelor of Science",
            border: OutlineInputBorder(),
          ),
        ),
        SizedBox(height: 12),
        TextField(
          controller: fieldController,
          decoration: InputDecoration(
            labelText: "Field of Study",
            hintText: "e.g., Computer Science",
            border: OutlineInputBorder(),
          ),
        ),
        SizedBox(height: 16),
        ElevatedButton.icon(
          onPressed: _addEducation,
          icon: Icon(Icons.add),
          label: Text("Add Education"),
        ),
        SizedBox(height: 20),
        ...education.map((edu) {
          int index = education.indexOf(edu);
          return Card(
            margin: EdgeInsets.only(bottom: 12),
            child: ListTile(
              title: Text(edu['degree'] ?? ""),
              subtitle: Text("${edu['school']} • ${edu['field']}"),
              trailing: IconButton(
                icon: Icon(Icons.delete),
                onPressed: () {
                  setState(() => education.removeAt(index));
                },
              ),
            ),
          );
        }).toList(),
      ],
    );
  }

  // Step 5: Interests
  Widget _buildInterestsStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Interests & Goals",
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: interestController,
                decoration: InputDecoration(
                  labelText: "Add an interest",
                  hintText: "e.g., Mobile Development",
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            SizedBox(width: 10),
            ElevatedButton(
              onPressed: () {
                if (interestController.text.isNotEmpty) {
                  setState(() {
                    interests.add(interestController.text);
                    interestController.clear();
                  });
                }
              },
              child: Text("Add"),
            ),
          ],
        ),
        SizedBox(height: 20),
        Wrap(
          spacing: 8,
          children: interests
              .map(
                (interest) => Chip(
                  label: Text(interest),
                  onDeleted: () {
                    setState(() => interests.remove(interest));
                  },
                ),
              )
              .toList(),
        ),
      ],
    );
  }

  void _addExperience() {
    if (roleController.text.isEmpty ||
        companyController.text.isEmpty ||
        durationController.text.isEmpty) {
      _showError("Please fill all fields");
      return;
    }
    setState(() {
      experiences.add({
        'role': roleController.text,
        'company': companyController.text,
        'duration': durationController.text,
      });
      roleController.clear();
      companyController.clear();
      durationController.clear();
    });
  }

  void _addEducation() {
    if (schoolController.text.isEmpty ||
        degreeController.text.isEmpty ||
        fieldController.text.isEmpty) {
      _showError("Please fill all fields");
      return;
    }
    setState(() {
      education.add({
        'school': schoolController.text,
        'degree': degreeController.text,
        'field': fieldController.text,
      });
      schoolController.clear();
      degreeController.clear();
      fieldController.clear();
    });
  }

  void _handleNext() async {
    // Validation
    if (currentStep == 0 && nameController.text.isEmpty) {
      _showError("Please enter your name");
      return;
    }
    if (currentStep == 1 && skills.isEmpty) {
      _showError("Please add at least one skill");
      return;
    }

    if (currentStep < 4) {
      setState(() => currentStep++);
    } else {
      await _saveData();
    }
  }

  Future<void> _saveData() async {
    setState(() => isSaving = true);
    try {
      var user = auth.currentUser!;
      var model = UserModel(
        uid: user.uid,
        name: nameController.text,
        email: user.email!,
        skills: skills,
        experience: experiences,
        education: education,
        interests: interests,
      );
      await firestore.saveUser(model);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => ProfileScreen()),
      );
    } catch (e) {
      _showError("Error saving data: $e");
      setState(() => isSaving = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    skillController.dispose();
    roleController.dispose();
    companyController.dispose();
    durationController.dispose();
    schoolController.dispose();
    degreeController.dispose();
    fieldController.dispose();
    interestController.dispose();
    super.dispose();
  }
}
