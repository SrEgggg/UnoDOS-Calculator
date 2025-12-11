import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math';

// ==========================================
// 1. THIS IS THE MISSING PART YOU NEEDED
// ==========================================
void main() {
  runApp(const GwaCalculatorApp());
}
// ==========================================

// --- I. DATA MODELS ---

// Model class to represent a Subject
class Subject {
  String name;
  double units;
  double grade;

  Subject({required this.name, required this.units, required this.grade});
}

// Model class to represent a Semester
class Semester {
  String name; // e.g., "1st Semester"
  List<Subject> subjects;

  Semester({required this.name, required this.subjects});

  double get totalUnits => subjects.fold(0, (p, c) => p + c.units);
  double get totalGradePoints =>
      subjects.fold(0, (p, c) => p + (c.grade * c.units));
  double get gwa => totalUnits == 0 ? 0.0 : totalGradePoints / totalUnits;
}

// Model class to represent an Academic Year
class AcademicYear {
  String name; // e.g., "Year 1"
  List<Semester> semesters;

  AcademicYear({required this.name, required this.semesters});

  double get yearUnits => semesters.fold(0, (p, c) => p + c.totalUnits);
  double get yearGradePoints =>
      semesters.fold(0, (p, c) => p + c.totalGradePoints);
  double get yearGwa => yearUnits == 0 ? 0.0 : yearGradePoints / yearUnits;
}

// --- II. MAIN APP & THEME ---

class GwaCalculatorApp extends StatelessWidget {
  const GwaCalculatorApp({super.key});

  static const Color primaryColor = Color(0xFF4527A0);
  static const Color accentColor = Color(0xFF26C6DA);
  static const Color backgroundColor = Color(0xFFF0F4F8);

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );

    // Define the desired text color once
    const Color bodyTextColor = Color(0xFF333333);

    return MaterialApp(
      title: 'UnoDos GWA Tracker',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: primaryColor,
          primary: primaryColor,
          secondary: accentColor,
        ),
        useMaterial3: true,
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
        textTheme: Theme.of(context).textTheme.copyWith(
          bodyLarge: Theme.of(
            context,
          ).textTheme.bodyLarge?.copyWith(color: bodyTextColor),
          bodyMedium: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: bodyTextColor),
        ),
      ),
      home: const TrackerScreen(),
    );
  }
}

// --- III. TRACKER SCREEN (Stateful Widget) ---

class TrackerScreen extends StatefulWidget {
  const TrackerScreen({super.key});

  @override
  State<TrackerScreen> createState() => _TrackerScreenState();
}

class _TrackerScreenState extends State<TrackerScreen>
    with SingleTickerProviderStateMixin {
  // Data Structure: List of Academic Years
  List<AcademicYear> academicYears = [
    AcademicYear(
      name: 'Year 1',
      semesters: [
        Semester(name: '1st Semester', subjects: []),
        Semester(name: '2nd Semester', subjects: []),
      ],
    ),
    AcademicYear(
      name: 'Year 2',
      semesters: [
        Semester(name: '1st Semester', subjects: []),
        Semester(name: '2nd Semester', subjects: []),
      ],
    ),
    // Add more years/semesters as needed (up to 5 years total)
  ];

  late TabController _tabController;
  int _selectedYearIndex = 0; // Current year shown
  int _selectedSemesterIndex = 0; // Current semester shown

  // Controllers for input fields
  final _nameController = TextEditingController();
  final _unitsController = TextEditingController();
  final _unitsRemainingController = TextEditingController();
  final _targetGwaController = TextEditingController();

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
  void initState() {
    super.initState();
    _tabController = TabController(
      length: academicYears[_selectedYearIndex].semesters.length,
      vsync: this,
    );
    _tabController.addListener(_handleTabSelection);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _nameController.dispose();
    _unitsController.dispose();
    _unitsRemainingController.dispose();
    _targetGwaController.dispose();
    super.dispose();
  }

  void _handleTabSelection() {
    if (_tabController.indexIsChanging) {
      setState(() {
        _selectedSemesterIndex = _tabController.index;
      });
    }
  }

  // --- LOGIC: GWA CALCULATION & STATUS ---

  double get _overallGWA {
    double totalUnits = academicYears.fold(0, (p, c) => p + c.yearUnits);
    double totalGradePoints = academicYears.fold(
      0,
      (p, c) => p + c.yearGradePoints,
    );
    return totalUnits == 0 ? 0.0 : totalGradePoints / totalUnits;
  }

  Semester get _currentSemester =>
      academicYears[_selectedYearIndex].semesters[_selectedSemesterIndex];

  (String, Color) _getGWAStatus(double gwa) {
    if (gwa == 0.0) return ('Awaiting Input', Colors.white70);
    if (gwa <= 1.25) return ('Summa Cum Laude Status', Colors.white);
    if (gwa <= 1.50) return ('Magna Cum Laude Status', Colors.white);
    if (gwa <= 1.75) return ('Dean\'s List Standing', Colors.white);
    if (gwa <= 3.00) return ('Good Academic Standing', Colors.yellow.shade200);
    return ('Needs Improvement', Colors.red.shade200);
  }

  // --- LOGIC: HONORS PREDICTION ---

  String _predictHonors() {
    const Map<String, double> honorTargets = {
      'Summa Cum Laude': 1.20,
      'Magna Cum Laude': 1.45,
      'Cum Laude': 1.75,
    };

    double overallGWA = _overallGWA;
    double currentUnits = academicYears.fold(0, (p, c) => p + c.yearUnits);
    double currentGradePoints = academicYears.fold(
      0,
      (p, c) => p + c.yearGradePoints,
    );

    // Filter out targets that are impossible to reach (GWA is already worse)
    final possibleHonors = honorTargets.entries
        .where((entry) => overallGWA <= entry.value)
        .toList();

    if (possibleHonors.isEmpty) {
      return 'No Latin Honors predicted based on current GWA.';
    }

    // Attempt to predict required GWA for remaining units (simplified estimation)
    final targetGwaText = _targetGwaController.text.trim();
    final remainingUnitsText = _unitsRemainingController.text.trim();

    final targetHonorGWA = double.tryParse(targetGwaText) ?? 0.0;
    final remainingUnits = double.tryParse(remainingUnitsText) ?? 0.0;

    if (remainingUnits <= 0 || targetHonorGWA <= 0) {
      if (currentUnits == 0) return 'Start adding subjects!';
      return 'Enter target GWA and remaining units for prediction.';
    }

    // Required Total Grade Points: Total Units * Target Overall GWA
    double requiredTotalUnits = currentUnits + remainingUnits;
    double requiredTotalGradePoints = requiredTotalUnits * targetHonorGWA;

    // Required Grade Points from Remaining Units
    double requiredRemainingGradePoints =
        requiredTotalGradePoints - currentGradePoints;

    // Required GWA for Remaining Units
    double requiredRemainingGWA = requiredRemainingGradePoints / remainingUnits;

    if (requiredRemainingGWA < 1.00) {
      return 'To achieve ${targetHonorGWA.toStringAsFixed(2)} overall GWA, you need ${requiredRemainingGWA.toStringAsFixed(2)} in remaining units. Highly possible!';
    } else if (requiredRemainingGWA <= 3.00) {
      return 'To achieve ${targetHonorGWA.toStringAsFixed(2)} overall GWA, you need ${requiredRemainingGWA.toStringAsFixed(2)} in remaining units.';
    } else {
      return 'To achieve ${targetHonorGWA.toStringAsFixed(2)} overall GWA, you need ${requiredRemainingGWA.toStringAsFixed(2)}. This goal is likely unattainable.';
    }
  }

  // --- LOGIC: SUBJECT MANAGEMENT ---

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
      _currentSemester.subjects.add(
        Subject(name: name, units: units, grade: _selectedGrade),
      );
    });

    _nameController.clear();
    _unitsController.clear();
    Navigator.of(context).pop();
  }

  void _removeSubject(int index) {
    setState(() {
      _currentSemester.subjects.removeAt(index);
    });
  }

  // --- UI WIDGETS ---

  // UI: Honors Prediction Panel
  void _showHonorsPredictionPanel() {
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
              'Honors Prediction & Planning',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: GwaCalculatorApp.primaryColor,
              ),
            ),
            const SizedBox(height: 15),
            const Text(
              'Enter your target overall GWA and the units you still need to complete.',
              style: TextStyle(fontSize: 14, color: Color(0xFF333333)),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _targetGwaController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(
                labelText: 'Target Overall GWA (e.g., 1.45 for Magna)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
                prefixIcon: Icon(
                  Icons.star,
                  color: GwaCalculatorApp.primaryColor,
                ),
              ),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: _unitsRemainingController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(
                labelText: 'Remaining Total Units (e.g., 48.0)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
                prefixIcon: Icon(
                  Icons.numbers,
                  color: GwaCalculatorApp.primaryColor,
                ),
              ),
            ),
            const SizedBox(height: 25),
            ElevatedButton(
              onPressed: () {
                setState(() {}); // Force UI update to show prediction
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text('Prediction updated!')));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: GwaCalculatorApp.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'CALCULATE REQUIRED GWA',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.blueGrey.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blueGrey.shade100),
              ),
              child: Text(
                _predictHonors(),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // UI: Show Add Subject Dialog (similar to previous)
  void _showAddSubjectDialog() {
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
            Text(
              'Add to ${_currentSemester.name}, ${academicYears[_selectedYearIndex].name}',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: GwaCalculatorApp.primaryColor,
              ),
            ),
            const SizedBox(height: 25),
            // ... (Input Fields for Name, Units, Grade) ...
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
                      child: Text(grade.toStringAsFixed(2)),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      dropDownSetState(() => _selectedGrade = value);
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

  // UI: GWA Header Card (Displays Overall GWA)
  Widget _buildGwaCard() {
    double gwa = _overallGWA;
    final (statusText, statusColor) = _getGWAStatus(gwa);

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [GwaCalculatorApp.primaryColor, Color(0xFF673AB7)],
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
            'CUMULATIVE GWA (Overall)',
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
              fontSize: 64,
              fontWeight: FontWeight.w900,
              color: Colors.white,
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
              _overallGWA == 0.0 ? 'Start tracking your journey' : statusText,
              style: TextStyle(
                color: statusColor.withOpacity(1.0),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- UI: MAIN BUILD METHOD ---

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('UnoDos GWA Tracker'),
        toolbarHeight: 80,
        actions: [
          IconButton(
            icon: const Icon(Icons.analytics_outlined, color: Colors.white),
            onPressed: _showHonorsPredictionPanel,
            tooltip: 'Honors Prediction',
          ),
        ],
      ),

      // Use a Drawer/Sidebar for switching academic years
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: const BoxDecoration(
                color: GwaCalculatorApp.primaryColor,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const Text(
                    'Academic Years',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Current GWA: ${_overallGWA.toStringAsFixed(2)}',
                    style: const TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),
            ...List.generate(academicYears.length, (index) {
              final year = academicYears[index];
              return ListTile(
                leading: const Icon(Icons.school),
                title: Text(year.name),
                subtitle: Text('Year GWA: ${year.yearGwa.toStringAsFixed(2)}'),
                selected: index == _selectedYearIndex,
                onTap: () {
                  setState(() {
                    _selectedYearIndex = index;
                    _tabController = TabController(
                      length: year.semesters.length,
                      vsync: this,
                    );
                    _tabController.addListener(_handleTabSelection);
                    _selectedSemesterIndex = 0; // Reset semester tab
                  });
                  Navigator.pop(context); // Close the drawer
                },
              );
            }),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.add_circle_outline),
              title: const Text('Add New Academic Year'),
              onTap: () {
                setState(() {
                  int newYearNum = academicYears.length + 1;
                  academicYears.add(
                    AcademicYear(
                      name: 'Year $newYearNum',
                      semesters: [
                        Semester(name: '1st Semester', subjects: []),
                        Semester(name: '2nd Semester', subjects: []),
                      ],
                    ),
                  );
                });
                Navigator.pop(context); // Close the drawer
              },
            ),
          ],
        ),
      ),

      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Overall GWA Card
          Transform.translate(
            offset: const Offset(0, -30),
            child: _buildGwaCard(),
          ),

          // 2. Tab Bar for Semesters (Navigation)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(color: Colors.grey.shade300, blurRadius: 5),
                ],
              ),
              child: TabBar(
                controller: _tabController,
                indicatorSize: TabBarIndicatorSize.tab,
                labelColor: GwaCalculatorApp.primaryColor,
                unselectedLabelColor: Colors.grey.shade600,
                indicator: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  color: GwaCalculatorApp.accentColor.withOpacity(0.2),
                ),
                tabs: _currentSemester.subjects.isEmpty
                    ? academicYears[_selectedYearIndex].semesters
                          .map((s) => Tab(text: s.name))
                          .toList()
                    : academicYears[_selectedYearIndex].semesters
                          .map(
                            (s) => Tab(
                              text: '${s.name} (${s.gwa.toStringAsFixed(2)})',
                            ),
                          )
                          .toList(),
              ),
            ),
          ),
          const SizedBox(height: 10),

          // 3. Semester Subject List
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: academicYears[_selectedYearIndex].semesters.map((
                semester,
              ) {
                return _buildSubjectList(semester);
              }).toList(),
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
        label: Text(
          'Add to ${_currentSemester.name}',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  // UI: Build the Subject List for a specific Semester
  Widget _buildSubjectList(Semester semester) {
    if (semester.subjects.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.assignment_add, size: 70, color: Colors.grey[300]),
            const SizedBox(height: 10),
            Text(
              'No subjects in ${semester.name}. Tap + to add one!',
              style: TextStyle(color: Colors.grey[500], fontSize: 16),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 100),
      itemCount: semester.subjects.length,
      itemBuilder: (context, index) {
        final subject = semester.subjects[index];
        final gradeColor = subject.grade <= 3.0
            ? GwaCalculatorApp.accentColor
            : Colors.red.shade400;

        return Dismissible(
          key: ValueKey(subject.name + index.toString() + semester.name),
          direction: DismissDirection.endToStart,
          onDismissed: (_) => _removeSubject(
            index,
          ), // Note: Need to manage index relative to current list
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
                        style: TextStyle(color: Colors.grey[600], fontSize: 14),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_back_ios, size: 16, color: Colors.grey),
              ],
            ),
          ),
        );
      },
    );
  }
}

