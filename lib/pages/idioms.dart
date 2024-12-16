import 'package:flutter/material.dart';
import 'dart:math';
import 'package:excel/excel.dart' as excel; // Use alias for excel
import 'package:flutter/services.dart' show ByteData, rootBundle;

const _glowColor = Color(0xFF00ADB5);
const _appBarGradient = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [Color(0xFF00ADB5), Color(0xFF393E46)],
);

class IdiomsPage extends StatefulWidget {
  const IdiomsPage({super.key});

  @override
  _IdiomsPageState createState() => _IdiomsPageState();
}

class _IdiomsPageState extends State<IdiomsPage> {
  final List<Map<String, String>> _questions = [];
  int _currentQuestionIndex = 0;
  String? _selectedAnswer;
  bool _quizStarted = false;
  bool _showIntroduction = true;
  List<String> _options = []; // Store options here

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    try {
      final ByteData data = await rootBundle.load('assets/idioms.xlsx');
      final excelData = excel.Excel.decodeBytes(data.buffer.asUint8List());
      final sheet = excelData.tables[excelData.tables.keys.first];

      if (sheet != null) {
        for (var row in sheet.rows.skip(1)) {
          if (row[1]?.value != null && row[2]?.value != null) {
            _questions.add({
              'idiom': row[1]!.value.toString(),
              'meaning': row[2]!.value.toString(),
            });
          }
        }
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
    // Get all meanings except the current one
    final wrongAnswers = List<String>.from(_questions
        .where((q) => q['meaning'] != currentQuestion['meaning'])
        .map((q) => q['meaning']!));

    // Thoroughly shuffle wrong answers
    wrongAnswers.shuffle(Random());

    // Take 3 wrong answers and add the correct one
    _options = [
      ...wrongAnswers.take(3),
      currentQuestion['meaning']!,
    ];

    // Final shuffle of all options
    _options.shuffle(Random());
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
        _currentQuestionIndex = 0;
        _questions.shuffle(Random());
      }
      _selectedAnswer = null;
      _setOptions(); // This will now properly randomize options
    });
  }

  void _retryQuestion() {
    setState(() {
      _selectedAnswer = null;
      _setOptions(); // This will now properly randomize options for retry
    });
  }

  Widget _buildIntroductionScreen() {
    return Scaffold(
      backgroundColor: const Color(0xFF222831),
      appBar: AppBar(
        title: const Text(
          'About Idioms',
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
          decoration: const BoxDecoration(gradient: _appBarGradient),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoSection(
              'What is an Idiom?',
              'An idiom is a group of words whose meaning differs from the literal meanings of the individual words.',
              Icons.lightbulb_outline,
            ),
            _buildInfoSection(
              'Types of Idioms',
              '• Pure Idioms: Meanings cannot be inferred (e.g., "under the weather")\n'
                  '• Binomial Idioms: Two words joined by conjunctions (e.g., "by and large")\n'
                  '• Partial Idioms: Shortened forms (e.g., "when in Rome")\n'
                  '• Prepositional Idioms: Verb + preposition combinations (e.g., "agree on")',
              Icons.category_outlined,
            ),
            _buildInfoSection(
              'Why Learn Idioms?',
              '• Improves language fluency\n'
                  '• Provides cultural insights\n'
                  '• Enhances expressiveness\n'
                  '• Makes communication more engaging',
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
                        horizontal: 50, vertical: 20),
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
              Text(
                title,
                style: const TextStyle(
                  color: Color(0xFFEEEEEE),
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
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
            'Idioms Quiz',
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
            decoration: const BoxDecoration(gradient: _appBarGradient),
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
            'Idioms Quiz',
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
            decoration: const BoxDecoration(gradient: _appBarGradient),
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
          'Idioms Quiz',
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
          decoration: const BoxDecoration(gradient: _appBarGradient),
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
                  currentQuestion['idiom']!,
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
                                  ? option == currentQuestion['meaning']
                                      ? Colors.green.withOpacity(0.85)
                                      : Colors.red.withOpacity(0.85)
                                  : option == currentQuestion['meaning'] &&
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
                                      ? option == currentQuestion['meaning']
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
                                      ? option == currentQuestion['meaning']
                                          ? Colors.green.withOpacity(0.9)
                                          : Colors.red.withOpacity(0.9)
                                      : const Color(0xFF393E46)
                                          .withOpacity(0.9),
                              _selectedAnswer == null
                                  ? const Color(0xFF393E46)
                                  : _selectedAnswer == option
                                      ? option == currentQuestion['meaning']
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
                                    (option == currentQuestion['meaning'] &&
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
                      onPressed: _selectedAnswer == currentQuestion['meaning']
                          ? _nextQuestion
                          : _retryQuestion,
                      child: Text(
                        _selectedAnswer == currentQuestion['meaning']
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
