import 'package:flutter/material.dart';

void main() {
  runApp(const GwaCalculatorApp());
}

class GwaCalculatorApp extends StatelessWidget {
  const GwaCalculatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'UnoDos GWA Calculator',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // Use colorScheme instead of primarySwatch for better Material 3 support
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF5F5F5),
      ),
      home: const CalculatorScreen(),
    );
  }
}

// Model class to represent a Subject
class Subject {
  String name;
  double units;
  double grade;

  Subject({required this.name, required this.units, required this.grade});
}

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  // List to store our subjects
  List<Subject> subjects = [];

  // Controllers for input fields
  final _nameController = TextEditingController();
  final _unitsController = TextEditingController();

  // Standard PH Grading System
  final List<double> _gradeOptions = [
    1.00,
    1.25,
    1.50,
    1.75,
    2.00,
    2.25,
    2.50,
    2.75,
    3.00,
    5.00,
  ];
  double _selectedGrade = 1.00;

  @override
  void dispose() {
    _nameController.dispose();
    _unitsController.dispose();
    super.dispose();
  }

  // LOGIC: Calculate GWA
  double get _calculateGWA {
    if (subjects.isEmpty) return 0.0;

    double totalUnits = 0;
    double totalGradePoints = 0;

    for (var subject in subjects) {
      totalUnits += subject.units;
      totalGradePoints += (subject.grade * subject.units);
    }

    if (totalUnits == 0) return 0.0;
    return totalGradePoints / totalUnits;
  }

  // LOGIC: Add a new subject
  void _addSubject() {
    final name = _nameController.text;
    final units = double.tryParse(_unitsController.text);

    if (name.isEmpty || units == null || units <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid name and units!')),
      );
      return;
    }

    setState(() {
      subjects.add(Subject(name: name, units: units, grade: _selectedGrade));
    });

    // Clear inputs and close modal
    _nameController.clear();
    _unitsController.clear();
    Navigator.of(context).pop();
  }

  // LOGIC: Remove a subject
  void _removeSubject(int index) {
    setState(() {
      subjects.removeAt(index);
    });
  }

  // UI: Show the "Add Subject" Dialog
  void _showAddSubjectDialog() {
    // Reset defaults
    _selectedGrade = 1.00;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Allow full screen height if needed
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          top: 20,
          left: 20,
          right: 20,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Add New Subject',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Subject Code (e.g., CPE 101)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.book),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _unitsController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Units (e.g., 3.0)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.numbers),
              ),
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<double>(
              value: _selectedGrade,
              decoration: const InputDecoration(
                labelText: 'Grade',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.grade),
              ),
              items: _gradeOptions.map((grade) {
                return DropdownMenuItem(
                  value: grade,
                  child: Text(grade.toStringAsFixed(2)),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedGrade = value;
                  });
                }
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _addSubject,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 15),
              ),
              child: const Text('ADD SUBJECT'),
            ),
          ],
        ),
      ),
    );
  }

  // UI: Build the GWA Header Card
  Widget _buildGwaCard() {
    double gwa = _calculateGWA;
    Color gwaColor = gwa <= 1.75
        ? Colors.green
        : (gwa <= 3.0 ? Colors.orange : Colors.red);
    if (subjects.isEmpty) gwaColor = Colors.grey;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            'GENERAL WEIGHTED AVERAGE',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            gwa.toStringAsFixed(2),
            style: TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.w900,
              color: gwaColor,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            subjects.isEmpty
                ? 'Add subjects to calculate'
                : 'Total Units: ${subjects.fold<double>(0, (p, c) => p + c.units)}',
            style: TextStyle(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'UnoDos',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.indigo,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Top Section: GWA Display
          Stack(
            children: [
              Container(
                height: 50,
                decoration: const BoxDecoration(
                  color: Colors.indigo,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 0,
                ),
                child: _buildGwaCard(),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Middle Section: List Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'My Subjects',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                if (subjects.isNotEmpty)
                  TextButton(
                    onPressed: () {
                      setState(() {
                        subjects.clear();
                      });
                    },
                    child: const Text(
                      'Clear All',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
              ],
            ),
          ),

          // Bottom Section: List of Subjects
          Expanded(
            child: subjects.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.assignment_add,
                          size: 60,
                          color: Colors.grey[300],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'No subjects added yet',
                          style: TextStyle(color: Colors.grey[500]),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 80),
                    itemCount: subjects.length,
                    itemBuilder: (context, index) {
                      final subject = subjects[index];
                      return Dismissible(
                        key: UniqueKey(),
                        direction: DismissDirection.endToStart,
                        onDismissed: (_) => _removeSubject(index),
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          color: Colors.red,
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        child: Card(
                          margin: const EdgeInsets.symmetric(
                            vertical: 6,
                          ), // Added simplified margin here
                          elevation: 2, // Added simplified elevation here
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.indigo.withOpacity(0.1),
                              child: Text(
                                subject.name.isNotEmpty
                                    ? subject.name[0].toUpperCase()
                                    : '?',
                                style: const TextStyle(
                                  color: Colors.indigo,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            title: Text(
                              subject.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text('${subject.units} Units'),
                            trailing: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: subject.grade <= 3.0
                                    ? Colors.green.withOpacity(0.1)
                                    : Colors.red.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                subject.grade.toStringAsFixed(2),
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: subject.grade <= 3.0
                                      ? Colors.green
                                      : Colors.red,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddSubjectDialog,
        backgroundColor: Colors.indigo,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Add Subject', style: TextStyle(color: Colors.white)),
      ),
    );
  }
}
