import 'package:flutter/material.dart';
import 'dart:math';
import 'package:excel/excel.dart' as excel;
import 'package:flutter/services.dart' show ByteData, rootBundle;

const _glowColor = Color(0xFF00ADB5);
const _appBarGradient = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [Color(0xFF00ADB5), Color(0xFF393E46)],
);

class AntonymsPage extends StatefulWidget {
  const AntonymsPage({super.key});

  @override
  State<AntonymsPage> createState() => AntonymsPageState();
}

class AntonymsPageState extends State<AntonymsPage> {
  final List<Map<String, String>> _questions = [];
  int _currentQuestionIndex = 0;
  String? _selectedAnswer;
  bool _quizStarted = false;
  bool _showIntroduction = true;
  List<String> _options = [];

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    try {
      final ByteData data = await rootBundle.load('assets/antonyms.xlsx');
      final excelData = excel.Excel.decodeBytes(data.buffer.asUint8List());
      final sheet = excelData.tables[excelData.tables.keys.first];

      if (sheet != null) {
        for (var row in sheet.rows.skip(1)) {
          if (row[1]?.value?.toString().trim().isNotEmpty == true &&
              row[2]?.value?.toString().trim().isNotEmpty == true) {
            _questions.add({
              'word': row[1]!.value.toString().trim(),
              'antonym': row[2]!.value.toString().trim(),
            });
          }
        }
      }

      if (_questions.isEmpty) {
        throw Exception('No valid questions found in the Excel file');
      }

      setState(() {
        _questions.shuffle(Random());
      });
    } catch (e) {
      print("Error loading questions: $e");
    }
  }

  void _setOptions() {
    final currentQuestion = _questions[_currentQuestionIndex];
    _options = [
      currentQuestion['antonym']!,
      ..._questions
          .map((q) => q['antonym']!)
          .where((option) => option != currentQuestion['antonym'])
          .take(3)
    ];

    // Shuffle options only when retrying
    if (_selectedAnswer != null &&
        _selectedAnswer != currentQuestion['antonym']) {
      _options.shuffle(Random());
    }
  }

  void _checkAnswer(String selectedOption) {
    setState(() {
      _selectedAnswer = selectedOption; // Set the selected answer
    });
  }

  void _nextQuestion() {
    setState(() {
      _currentQuestionIndex++;
      if (_currentQuestionIndex >= _questions.length) {
        _currentQuestionIndex = 0; // Reset to first question
        _questions.shuffle(Random()); // Shuffle again for new round
      }
      _selectedAnswer = null; // Reset selected answer for next question
      // Set options for the next question
      _setOptions();
    });
  }

  void _retryQuestion() {
    setState(() {
      // Reset selected answer without changing the question
      _selectedAnswer = null;
      // Shuffle options when retrying the same question
      _options.shuffle(Random());
    });
  }

  Widget _buildIntroductionScreen() {
    return Scaffold(
      backgroundColor: const Color(0xFF222831),
      appBar: AppBar(
        title: const Text(
          'About Antonyms',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.8,
            color: Color(0xFFEEEEEE),
            shadows: [
              Shadow(offset: Offset(0, 1), blurRadius: 2, color: Colors.black26)
            ],
          ),
        ),
        centerTitle: true,
        elevation: 4,
        shadowColor: Colors.black.withOpacity(0.2),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(17)),
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(gradient: _appBarGradient),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoSection(
              'What Are Antonyms?',
              'Antonyms are words that have opposite meanings. For example, "hot" and "cold" represent opposing concepts.',
              Icons.lightbulb_outline,
            ),
            _buildInfoSection(
              'Types of Antonyms',
              '• Gradable Antonyms: Words that exist on a spectrum (e.g., "big" and "small")\n'
                  '• Complementary Antonyms: Words that are mutually exclusive (e.g., "alive" and "dead")\n'
                  '• Relational Antonyms: Words that describe relationships from opposite perspectives (e.g., "parent" and "child")',
              Icons.category_outlined,
            ),
            _buildInfoSection(
              'Why Learn Antonyms?',
              '• Vocabulary Development: Expands language skills\n'
                  '• Enhanced Communication: Allows for more nuanced expression\n'
                  '• Critical Thinking: Encourages deeper understanding through comparison',
              Icons.school_outlined,
            ),
            const SizedBox(height: 30),
            Center(
              child: Container(
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: _glowColor.withOpacity(0.3),
                      blurRadius: 25,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _glowColor,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 50,
                      vertical: 20,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  onPressed: () {
                    setState(() {
                      _showIntroduction = false;
                    });
                  },
                  child: const Text(
                    'Continue to Quiz',
                    style: TextStyle(
                      color: Color(0xFFEEEEEE),
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoSection(String title, String content, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF393E46),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: _glowColor.withOpacity(0.2),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: _glowColor, size: 24),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFFEEEEEE),
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            content,
            style: const TextStyle(
              color: Color(0xFFEEEEEE),
              fontSize: 16,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_questions.isEmpty) {
      return Scaffold(
        backgroundColor: const Color(0xFF222831),
        appBar: AppBar(
          title: const Text(
            'Antonyms Quiz',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.8,
              color: Color(0xFFEEEEEE),
              shadows: [
                Shadow(
                  offset: Offset(0, 1),
                  blurRadius: 2,
                  color: Colors.black26,
                ),
              ],
            ),
          ),
          centerTitle: true,
          elevation: 4,
          shadowColor: Colors.black.withOpacity(0.2),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
              bottom: Radius.circular(17),
            ),
          ),
          flexibleSpace: Container(
            decoration: BoxDecoration(gradient: _appBarGradient),
          ),
        ),
        body: Center(
          child: Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: _glowColor.withOpacity(0.5),
                  blurRadius: 20,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: const CircularProgressIndicator(
              color: _glowColor,
            ),
          ),
        ),
      );
    }

    if (_showIntroduction) {
      return _buildIntroductionScreen();
    }

    if (!_quizStarted) {
      return Scaffold(
        backgroundColor: const Color(0xFF222831),
        appBar: AppBar(
          title: const Text(
            'Antonyms Quiz',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.8,
              color: Color(0xFFEEEEEE),
              shadows: [
                Shadow(
                  offset: Offset(0, 1),
                  blurRadius: 2,
                  color: Colors.black26,
                ),
              ],
            ),
          ),
          centerTitle: true,
          elevation: 4,
          shadowColor: Colors.black.withOpacity(0.2),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
              bottom: Radius.circular(17),
            ),
          ),
          flexibleSpace: Container(
            decoration: BoxDecoration(gradient: _appBarGradient),
          ),
        ),
        body: Center(
          child: Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: _glowColor.withOpacity(0.3),
                  blurRadius: 25,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: _glowColor,
                padding:
                    const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              onPressed: () {
                setState(() {
                  _quizStarted = true;
                  _setOptions();
                });
              },
              child: const Text(
                'Start Quiz',
                style: TextStyle(
                  color: Color(0xFFEEEEEE),
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.2,
                ),
              ),
            ),
          ),
        ),
      );
    }

    final currentQuestion = _questions[_currentQuestionIndex];

    return Scaffold(
      backgroundColor: const Color(0xFF222831),
      appBar: AppBar(
        title: const Text(
          'Antonyms Quiz',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.8,
            color: Color(0xFFEEEEEE),
            shadows: [
              Shadow(
                offset: Offset(0, 1),
                blurRadius: 2,
                color: Colors.black26,
              ),
            ],
          ),
        ),
        centerTitle: true,
        elevation: 4,
        shadowColor: Colors.black.withOpacity(0.2),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(17),
          ),
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(gradient: _appBarGradient),
        ),
        actions: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
            decoration: BoxDecoration(
              color: Colors.black12,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Q ${_currentQuestionIndex + 1}/${_questions.length}',
              style: const TextStyle(
                color: Color(0xFFEEEEEE),
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 30, horizontal: 25),
                margin: const EdgeInsets.symmetric(horizontal: 5),
                decoration: BoxDecoration(
                  color: const Color(0xFF393E46),
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(
                      color: _glowColor.withOpacity(0.3),
                      blurRadius: 20,
                      spreadRadius: 2,
                      offset: const Offset(0, 7),
                    ),
                  ],
                  border: Border.all(
                    color: _glowColor.withOpacity(0.4),
                    width: 2.5,
                  ),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      const Color(0xFF393E46).withOpacity(0.9),
                      const Color(0xFF393E46),
                    ],
                  ),
                ),
                child: Text(
                  currentQuestion['word']!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFFEEEEEE),
                    letterSpacing: 0.8,
                    height: 1.4,
                    fontFamily: 'Poppins',
                    shadows: [
                      Shadow(
                        offset: Offset(0, 2),
                        blurRadius: 4,
                        color: Colors.black26,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 35),
              ..._options.map((option) => Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 7,
                      horizontal: 3,
                    ),
                    child: GestureDetector(
                      onTap: _selectedAnswer == null
                          ? () => _checkAnswer(option)
                          : null,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        padding: const EdgeInsets.symmetric(
                          vertical: 18,
                          horizontal: 22,
                        ),
                        decoration: BoxDecoration(
                          color: _selectedAnswer == null
                              ? const Color(0xFF393E46).withOpacity(0.85)
                              : _selectedAnswer == option
                                  ? option == currentQuestion['antonym']
                                      ? Colors.green.withOpacity(0.85)
                                      : Colors.red.withOpacity(0.85)
                                  : option == currentQuestion['antonym'] &&
                                          _selectedAnswer != null
                                      ? Colors.green.withOpacity(0.85)
                                      : const Color(0xFF393E46)
                                          .withOpacity(0.85),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: _selectedAnswer == null
                                ? _glowColor.withOpacity(0.6)
                                : Colors.transparent,
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: _selectedAnswer == null
                                  ? _glowColor.withOpacity(0.15)
                                  : _selectedAnswer == option
                                      ? option == currentQuestion['antonym']
                                          ? Colors.green.withOpacity(0.35)
                                          : Colors.red.withOpacity(0.35)
                                      : _glowColor.withOpacity(0.15),
                              blurRadius: 12,
                              spreadRadius: 2,
                              offset: const Offset(0, 4),
                            ),
                          ],
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              _selectedAnswer == null
                                  ? const Color(0xFF393E46).withOpacity(0.9)
                                  : _selectedAnswer == option
                                      ? option == currentQuestion['antonym']
                                          ? Colors.green.withOpacity(0.9)
                                          : Colors.red.withOpacity(0.9)
                                      : const Color(0xFF393E46)
                                          .withOpacity(0.9),
                              _selectedAnswer == null
                                  ? const Color(0xFF393E46)
                                  : _selectedAnswer == option
                                      ? option == currentQuestion['antonym']
                                          ? Colors.green
                                          : Colors.red
                                      : const Color(0xFF393E46),
                            ],
                          ),
                        ),
                        child: Text(
                          option,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 18,
                            color: const Color(0xFFEEEEEE),
                            fontWeight: _selectedAnswer == option ||
                                    (option == currentQuestion['antonym'] &&
                                        _selectedAnswer != null)
                                ? FontWeight.w600
                                : FontWeight.w500,
                            letterSpacing: 0.6,
                            fontFamily: 'Roboto',
                            height: 1.3,
                            shadows: const [
                              Shadow(
                                offset: Offset(0, 1),
                                blurRadius: 2,
                                color: Colors.black26,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  )),
              const SizedBox(height: 30),
              if (_selectedAnswer != null)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _glowColor,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 35,
                          vertical: 15,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 8,
                        shadowColor: _glowColor.withOpacity(0.5),
                      ),
                      onPressed: _selectedAnswer == currentQuestion['antonym']
                          ? _nextQuestion
                          : _retryQuestion,
                      child: Text(
                        _selectedAnswer == currentQuestion['antonym']
                            ? 'Next Question'
                            : 'Try Again',
                        style: const TextStyle(
                          color: Color(0xFFEEEEEE),
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
