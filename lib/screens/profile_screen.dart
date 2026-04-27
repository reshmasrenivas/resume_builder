
import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../models/user_model.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final auth = AuthService();
  final firestore = FirestoreService();
  UserModel? user;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadUser();
  }

  void loadUser() async {
    setState(() => isLoading = true);
    try {
      var current = auth.currentUser!;
      var data = await firestore.getUser(current.uid);
      setState(() => user = data);
    } catch (e) {
      _showError("Error loading profile: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text("Profile")),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: Text("Profile")),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("No profile data found"),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: loadUser,
                child: Text("Retry"),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("My Resume"),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () => _showLogoutDialog(),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Personal Details Section
            _buildSectionHeader("Personal Details", Icons.person),
            Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user!.name,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.email, size: 18, color: Colors.grey),
                        SizedBox(width: 8),
                        Text(user!.email),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 24),

            // Skills Section
            _buildSectionHeader("Skills", Icons.code, onEdit: () => _editSkills()),
            Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: user!.skills
                      .map((skill) => Chip(
                            label: Text(skill),
                            backgroundColor: Colors.blue.shade50,
                          ))
                      .toList(),
                ),
              ),
            ),

            SizedBox(height: 24),

            // Experience Section
            _buildSectionHeader("Experience", Icons.work, onEdit: () => _editExperience()),
            ...user!.experience.map((exp) => Card(
                  margin: EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          exp['role'] ?? '',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        SizedBox(height: 4),
                        Text(
                          exp['company'] ?? '',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                        SizedBox(height: 4),
                        Text(
                          exp['duration'] ?? '',
                          style: TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                )),

            SizedBox(height: 24),

            // Education Section
            _buildSectionHeader("Education", Icons.school, onEdit: () => _editEducation()),
            ...user!.education.map((edu) => Card(
                  margin: EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          edu['degree'] ?? '',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        SizedBox(height: 4),
                        Text(
                          "${edu['school'] ?? ''}",
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                        SizedBox(height: 4),
                        Text(
                          "Field: ${edu['field'] ?? ''}",
                          style: TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                )),

            SizedBox(height: 24),

            // Interests Section
            _buildSectionHeader("Interests & Goals", Icons.lightbulb, onEdit: () => _editInterests()),
            Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: user!.interests
                      .map((interest) => Chip(
                            label: Text(interest),
                            backgroundColor: Colors.green.shade50,
                          ))
                      .toList(),
                ),
              ),
            ),

            SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, {VoidCallback? onEdit}) {
    return Row(
      children: [
        Icon(icon, color: Colors.blue),
        SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        Spacer(),
        if (onEdit != null)
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: onEdit,
          ),
      ],
    );
  }

  void _editSkills() {
    final skillController = TextEditingController();
    List<String> currentSkills = List.from(user!.skills);

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text("Edit Skills"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: skillController,
                      decoration: InputDecoration(labelText: "Add skill"),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.add),
                    onPressed: () {
                      if (skillController.text.isNotEmpty) {
                        setState(() {
                          currentSkills.add(skillController.text);
                          skillController.clear();
                        });
                      }
                    },
                  ),
                ],
              ),
              SizedBox(height: 16),
              Wrap(
                spacing: 8,
                children: currentSkills
                    .map((skill) => Chip(
                          label: Text(skill),
                          onDeleted: () {
                            setState(() => currentSkills.remove(skill));
                          },
                        ))
                    .toList(),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () => _saveSkills(currentSkills),
              child: Text("Save"),
            ),
          ],
        ),
      ),
    );
  }

  void _editExperience() {
    List<Map<String, String>> currentExperience = List.from(user!.experience);
    final roleController = TextEditingController();
    final companyController = TextEditingController();
    final durationController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text("Edit Experience"),
          content: Container(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: roleController,
                  decoration: InputDecoration(labelText: "Job Title"),
                ),
                TextField(
                  controller: companyController,
                  decoration: InputDecoration(labelText: "Company"),
                ),
                TextField(
                  controller: durationController,
                  decoration: InputDecoration(labelText: "Duration"),
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    if (roleController.text.isNotEmpty &&
                        companyController.text.isNotEmpty &&
                        durationController.text.isNotEmpty) {
                      setState(() {
                        currentExperience.add({
                          'role': roleController.text,
                          'company': companyController.text,
                          'duration': durationController.text,
                        });
                        roleController.clear();
                        companyController.clear();
                        durationController.clear();
                      });
                    }
                  },
                  child: Text("Add Experience"),
                ),
                SizedBox(height: 16),
                ...currentExperience.map((exp) {
                  int index = currentExperience.indexOf(exp);
                  return Card(
                    child: ListTile(
                      title: Text(exp['role'] ?? ''),
                      subtitle: Text("${exp['company']} • ${exp['duration']}"),
                      trailing: IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () {
                          setState(() => currentExperience.removeAt(index));
                        },
                      ),
                    ),
                  );
                }).toList(),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () => _saveExperience(currentExperience),
              child: Text("Save"),
            ),
          ],
        ),
      ),
    );
  }

  void _editEducation() {
    List<Map<String, String>> currentEducation = List.from(user!.education);
    final schoolController = TextEditingController();
    final degreeController = TextEditingController();
    final fieldController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text("Edit Education"),
          content: Container(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: schoolController,
                  decoration: InputDecoration(labelText: "School/University"),
                ),
                TextField(
                  controller: degreeController,
                  decoration: InputDecoration(labelText: "Degree"),
                ),
                TextField(
                  controller: fieldController,
                  decoration: InputDecoration(labelText: "Field of Study"),
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    if (schoolController.text.isNotEmpty &&
                        degreeController.text.isNotEmpty &&
                        fieldController.text.isNotEmpty) {
                      setState(() {
                        currentEducation.add({
                          'school': schoolController.text,
                          'degree': degreeController.text,
                          'field': fieldController.text,
                        });
                        schoolController.clear();
                        degreeController.clear();
                        fieldController.clear();
                      });
                    }
                  },
                  child: Text("Add Education"),
                ),
                SizedBox(height: 16),
                ...currentEducation.map((edu) {
                  int index = currentEducation.indexOf(edu);
                  return Card(
                    child: ListTile(
                      title: Text(edu['degree'] ?? ''),
                      subtitle: Text("${edu['school']} • ${edu['field']}"),
                      trailing: IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () {
                          setState(() => currentEducation.removeAt(index));
                        },
                      ),
                    ),
                  );
                }).toList(),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () => _saveEducation(currentEducation),
              child: Text("Save"),
            ),
          ],
        ),
      ),
    );
  }

  void _editInterests() {
    final interestController = TextEditingController();
    List<String> currentInterests = List.from(user!.interests);

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text("Edit Interests & Goals"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: interestController,
                      decoration: InputDecoration(labelText: "Add interest"),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.add),
                    onPressed: () {
                      if (interestController.text.isNotEmpty) {
                        setState(() {
                          currentInterests.add(interestController.text);
                          interestController.clear();
                        });
                      }
                    },
                  ),
                ],
              ),
              SizedBox(height: 16),
              Wrap(
                spacing: 8,
                children: currentInterests
                    .map((interest) => Chip(
                          label: Text(interest),
                          onDeleted: () {
                            setState(() => currentInterests.remove(interest));
                          },
                        ))
                    .toList(),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () => _saveInterests(currentInterests),
              child: Text("Save"),
            ),
          ],
        ),
      ),
    );
  }

  void _saveSkills(List<String> skills) async {
    try {
      var updatedUser = UserModel(
        uid: user!.uid,
        name: user!.name,
        email: user!.email,
        skills: skills,
        experience: user!.experience,
        education: user!.education,
        interests: user!.interests,
      );
      await firestore.saveUser(updatedUser);
      setState(() => user = updatedUser);
      Navigator.pop(context);
      _showSuccess("Skills updated!");
    } catch (e) {
      _showError("Error updating skills: $e");
    }
  }

  void _saveExperience(List<Map<String, String>> experience) async {
    try {
      var updatedUser = UserModel(
        uid: user!.uid,
        name: user!.name,
        email: user!.email,
        skills: user!.skills,
        experience: experience,
        education: user!.education,
        interests: user!.interests,
      );
      await firestore.saveUser(updatedUser);
      setState(() => user = updatedUser);
      Navigator.pop(context);
      _showSuccess("Experience updated!");
    } catch (e) {
      _showError("Error updating experience: $e");
    }
  }

  void _saveEducation(List<Map<String, String>> education) async {
    try {
      var updatedUser = UserModel(
        uid: user!.uid,
        name: user!.name,
        email: user!.email,
        skills: user!.skills,
        experience: user!.experience,
        education: education,
        interests: user!.interests,
      );
      await firestore.saveUser(updatedUser);
      setState(() => user = updatedUser);
      Navigator.pop(context);
      _showSuccess("Education updated!");
    } catch (e) {
      _showError("Error updating education: $e");
    }
  }

  void _saveInterests(List<String> interests) async {
    try {
      var updatedUser = UserModel(
        uid: user!.uid,
        name: user!.name,
        email: user!.email,
        skills: user!.skills,
        experience: user!.experience,
        education: user!.education,
        interests: interests,
      );
      await firestore.saveUser(updatedUser);
      setState(() => user = updatedUser);
      Navigator.pop(context);
      _showSuccess("Interests updated!");
    } catch (e) {
      _showError("Error updating interests: $e");
    }
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Logout"),
        content: Text("Are you sure you want to logout?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () => _logout(),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text("Logout"),
          ),
        ],
      ),
    );
  }

  void _logout() async {
    try {
      await auth.signOut();
      Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
    } catch (e) {
      _showError("Error logging out: $e");
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }
}
