import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Needed for Status Bar color

void main() {
  // Ensure we set the system UI overlays for a full-screen look
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );
  runApp(const GwaCalculatorApp());
}

// Model class to represent a Subject (No change, it's perfect)
class Subject {
  String name;
  double units;
  double grade;

  Subject({required this.name, required this.units, required this.grade});
}

class GwaCalculatorApp extends StatelessWidget {
  const GwaCalculatorApp({super.key});

  // Define the new color palette
  static const Color primaryColor = Color(
    0xFF4527A0,
  ); // Deep Purple (Indigo 800)
  static const Color accentColor = Color(0xFF26C6DA); // Cyan/Teal
  static const Color backgroundColor = Color(
    0xFFF0F4F8,
  ); // Very light grey blue

  @override
  Widget build(BuildContext context) {
    // Define the desired text color once
    const Color bodyTextColor = Color(0xFF333333);

    return MaterialApp(
      title: 'UnoDos GWA Calculator',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: primaryColor,
          primary: primaryColor,
          secondary: accentColor,
        ),
        useMaterial3: true,
        // Set a cleaner overall background
        scaffoldBackgroundColor: backgroundColor,
        appBarTheme: const AppBarTheme(
          color: primaryColor,
          elevation: 0,
          titleTextStyle: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 24,
            color: Colors.white,
          ),
          iconTheme: IconThemeData(color: Colors.white),
        ),

        // ----------------- THE CORRECTED TEXTTHEME BLOCK -----------------
        // We use .copyWith() instead of the removed .apply() method to safely change the default text color.
        textTheme: Theme.of(context).textTheme.copyWith(
          // Apply the desired color to common body text styles
          bodyLarge: Theme.of(
            context,
          ).textTheme.bodyLarge?.copyWith(color: bodyTextColor),
          bodyMedium: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: bodyTextColor),
          // You can continue to copyWith specific styles if needed.
        ),
        // -----------------------------------------------------------------
      ),
      home: const CalculatorScreen(),
    );
  }
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

  // LOGIC: Calculate GWA (same as before)
  double get _calculateGWA {
    if (subjects.isEmpty) return 0.0;
    double totalUnits = subjects.fold<double>(0, (p, c) => p + c.units);
    double totalGradePoints = subjects.fold<double>(
      0,
      (p, c) => p + (c.grade * c.units),
    );
    return totalUnits == 0 ? 0.0 : totalGradePoints / totalUnits;
  }

  // LOGIC: Get status based on GWA
  (String, Color) _getGWAStatus(double gwa) {
    if (subjects.isEmpty) return ('Awaiting Input', Colors.white70);
    if (gwa <= 1.25) return ('Summa Cum Laude Status', Colors.white);
    if (gwa <= 1.50) return ('Magna Cum Laude Status', Colors.white);
    if (gwa <= 1.75) return ('Dean\'s List Standing', Colors.white);
    if (gwa <= 3.00) return ('Good Academic Standing', Colors.yellow.shade200);
    return ('Needs Improvement', Colors.red.shade200);
  }

  // LOGIC: Add a new subject (same as before, minor UI adjustment)
  void _addSubject() {
    final name = _nameController.text.trim();
    final units = double.tryParse(_unitsController.text.trim());

    if (name.isEmpty || units == null || units <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid subject name and units!'),
        ),
      );
      return;
    }

    setState(() {
      subjects.add(Subject(name: name, units: units, grade: _selectedGrade));
    });

    _nameController.clear();
    _unitsController.clear();
    Navigator.of(context).pop();
  }

  // LOGIC: Remove a subject (same as before)
  void _removeSubject(int index) {
    setState(() {
      subjects.removeAt(index);
    });
  }

  // UI: Show the "Add Subject" Dialog (using a more stylized bottom sheet)
  void _showAddSubjectDialog() {
    // Reset defaults
    _selectedGrade = 1.00;
    _nameController.clear();
    _unitsController.clear();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          top: 30,
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
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: GwaCalculatorApp.primaryColor,
              ),
            ),
            const SizedBox(height: 25),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Subject Code (e.g., CPE 101)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
                prefixIcon: Icon(
                  Icons.book,
                  color: GwaCalculatorApp.primaryColor,
                ),
              ),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: _unitsController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Units (e.g., 3.0)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
                prefixIcon: Icon(
                  Icons.numbers,
                  color: GwaCalculatorApp.primaryColor,
                ),
              ),
            ),
            const SizedBox(height: 15),
            StatefulBuilder(
              builder: (BuildContext context, StateSetter dropDownSetState) {
                return DropdownButtonFormField<double>(
                  value: _selectedGrade,
                  decoration: const InputDecoration(
                    labelText: 'Grade',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                    ),
                    prefixIcon: Icon(
                      Icons.grade,
                      color: GwaCalculatorApp.primaryColor,
                    ),
                  ),
                  items: _gradeOptions.map((grade) {
                    return DropdownMenuItem(
                      value: grade,
                      child: Text(
                        grade.toStringAsFixed(2),
                        style: TextStyle(
                          fontWeight: grade <= 3.0
                              ? FontWeight.bold
                              : FontWeight.normal,
                          color: grade <= 3.0
                              ? GwaCalculatorApp.primaryColor
                              : Colors.red,
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      dropDownSetState(() {
                        _selectedGrade = value;
                      });
                    }
                  },
                );
              },
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _addSubject,
              style: ElevatedButton.styleFrom(
                backgroundColor: GwaCalculatorApp.accentColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'ADD SUBJECT',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // UI: Build the GWA Header Card (with Gradient and Status)
  Widget _buildGwaCard() {
    double gwa = _calculateGWA;
    final (statusText, statusColor) = _getGWAStatus(gwa);

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        // Use a gradient for a premium look
        gradient: const LinearGradient(
          colors: [
            GwaCalculatorApp.primaryColor,
            Color(0xFF673AB7), // Lighter Purple
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: GwaCalculatorApp.primaryColor.withOpacity(0.4),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            'GENERAL WEIGHTED AVERAGE',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.5,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            gwa.toStringAsFixed(2),
            style: const TextStyle(
              fontSize: 64, // Larger font size
              fontWeight: FontWeight.w900,
              color:
                  Colors.white, // White score for contrast on dark background
            ),
          ),
          const SizedBox(height: 5),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              subjects.isEmpty ? 'Add subjects to calculate' : statusText,
              style: TextStyle(
                color: statusColor.withOpacity(1.0),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Total Units: ${subjects.fold<double>(0, (p, c) => p + c.units).toStringAsFixed(1)}',
            style: const TextStyle(color: Colors.white60, fontSize: 14),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('UnoDos GWA Tracker'),
        toolbarHeight: 80, // Make the App Bar a bit taller
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // GWA Display Card (positioned right below the AppBar)
          Transform.translate(
            offset: const Offset(
              0,
              -30,
            ), // Move the card up to overlap the AppBar
            child: _buildGwaCard(),
          ),

          const Padding(
            padding: EdgeInsets.fromLTRB(20, 0, 20, 10),
            child: Text(
              'My Subjects',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: Color(0xFF333333),
              ),
            ),
          ),

          // Clear All Button
          if (subjects.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  icon: const Icon(Icons.delete_sweep, color: Colors.red),
                  label: const Text(
                    'Clear All',
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  onPressed: () {
                    setState(() {
                      subjects.clear();
                    });
                  },
                ),
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
                          Icons.calculate_outlined,
                          size: 70,
                          color: Colors.grey[300],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Tap + to add your first subject!',
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                    itemCount: subjects.length,
                    itemBuilder: (context, index) {
                      final subject = subjects[index];
                      // Determine the visual grade color
                      final gradeColor = subject.grade <= 3.0
                          ? GwaCalculatorApp.accentColor
                          : Colors.red.shade400;

                      return Dismissible(
                        key: ValueKey(subject.name + index.toString()),
                        direction: DismissDirection.endToStart,
                        onDismissed: (_) => _removeSubject(index),
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 25),
                          decoration: BoxDecoration(
                            color: Colors.red.shade600,
                            borderRadius: BorderRadius.circular(15),
                          ),
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          child: const Icon(
                            Icons.delete_forever,
                            color: Colors.white,
                            size: 30,
                          ),
                        ),
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              // Grade Circle
                              Container(
                                width: 50,
                                height: 50,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: gradeColor.withOpacity(0.15),
                                  shape: BoxShape.circle,
                                ),
                                child: Text(
                                  subject.grade.toStringAsFixed(2),
                                  style: TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 16,
                                    color: gradeColor,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 15),
                              // Subject Details
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      subject.name,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 16,
                                        color: Color(0xFF333333),
                                      ),
                                    ),
                                    Text(
                                      '${subject.units} Units',
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(
                                Icons.arrow_back_ios,
                                size: 16,
                                color: Colors.grey,
                              ), // Hint to swipe
                            ],
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
        backgroundColor: GwaCalculatorApp.accentColor,
        icon: const Icon(
          Icons.add_circle_outline,
          color: Colors.white,
          size: 28,
        ),
        label: const Text(
          'Add Subject',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
