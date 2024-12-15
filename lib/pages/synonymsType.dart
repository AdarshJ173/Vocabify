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

class SynonymsType extends StatefulWidget {
  const SynonymsType({super.key});

  @override
  _SynonymsTypeState createState() => _SynonymsTypeState();
}

class _SynonymsTypeState extends State<SynonymsType> {
  final List<Map<String, String>> _questions = [];
  int _currentQuestionIndex = 0;
  String? _selectedAnswer;
  bool _quizStarted = false;
  List<String> _options = []; // Store options here

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    try {
      final ByteData data = await rootBundle.load('assets/synonyms.xlsx');
      final excelData = excel.Excel.decodeBytes(data.buffer.asUint8List());
      final sheet = excelData.tables[excelData.tables.keys.first];

      if (sheet == null || sheet.rows.length <= 1) {
        throw Exception('No data found in the Excel file');
      }

      for (var row in sheet.rows.skip(1)) {
        if (row.length > 3 &&
            row[1]?.value?.toString().trim().isNotEmpty == true &&
            row[2]?.value?.toString().trim().isNotEmpty == true) {
          _questions.add({
            'word': row[1]!.value.toString().trim(),
            'synonym': row[2]!.value.toString().trim(),
          });
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
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: const Text('Error'),
            content:
                const Text('Failed to load questions. Please try again later.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    }
  }

  void _setOptions() {
    if (_questions.isEmpty || _currentQuestionIndex >= _questions.length) {
      return;
    }

    final currentQuestion = _questions[_currentQuestionIndex];
    final wrongAnswers = _questions
        .where((q) => q['synonym'] != currentQuestion['synonym'])
        .map((q) => q['synonym']!)
        .toList();

    if (wrongAnswers.length < 3) {
      wrongAnswers.addAll(
        List.filled(3 - wrongAnswers.length, 'No option available'),
      );
    }

    wrongAnswers.shuffle();
    _options = [
      currentQuestion['synonym']!,
      ...wrongAnswers.take(3),
    ]..shuffle();
  }

  void _checkAnswer(String selectedOption) {
    setState(() {
      _selectedAnswer = selectedOption;
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
      _setOptions();
    });
  }

  void _retryQuestion() {
    setState(() {
      _selectedAnswer = null;
      _options.shuffle(Random());
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_questions.isEmpty) {
      return Scaffold(
        backgroundColor: const Color(0xFF222831),
        appBar: AppBar(
          title: const Text(
            'Typing Practice',
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

    if (!_quizStarted) {
      return Scaffold(
        backgroundColor: const Color(0xFF222831),
        appBar: AppBar(
          title: const Text(
            'Typing Practice',
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
          'Typing Practice',
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
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                child: Center(
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 600),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 20),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: 30,
                            horizontal: 25,
                          ),
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
                            overflow: TextOverflow.visible,
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
                                        ? const Color(0xFF393E46)
                                            .withOpacity(0.85)
                                        : _selectedAnswer == option
                                            ? option ==
                                                    currentQuestion['synonym']
                                                ? Colors.green.withOpacity(0.85)
                                                : Colors.red.withOpacity(0.85)
                                            : option ==
                                                        currentQuestion[
                                                            'synonym'] &&
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
                                                ? option ==
                                                        currentQuestion[
                                                            'synonym']
                                                    ? Colors.green
                                                        .withOpacity(0.35)
                                                    : Colors.red
                                                        .withOpacity(0.35)
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
                                            ? const Color(0xFF393E46)
                                                .withOpacity(0.9)
                                            : _selectedAnswer == option
                                                ? option ==
                                                        currentQuestion[
                                                            'synonym']
                                                    ? Colors.green
                                                        .withOpacity(0.9)
                                                    : Colors.red
                                                        .withOpacity(0.9)
                                                : const Color(0xFF393E46)
                                                    .withOpacity(0.9),
                                        _selectedAnswer == null
                                            ? const Color(0xFF393E46)
                                            : _selectedAnswer == option
                                                ? option ==
                                                        currentQuestion[
                                                            'synonym']
                                                    ? Colors.green
                                                    : Colors.red
                                                : const Color(0xFF393E46),
                                      ],
                                    ),
                                  ),
                                  child: Text(
                                    option,
                                    textAlign: TextAlign.center,
                                    overflow: TextOverflow.visible,
                                    softWrap: true,
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: const Color(0xFFEEEEEE),
                                      fontWeight: _selectedAnswer == option ||
                                              (option ==
                                                      currentQuestion[
                                                          'synonym'] &&
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
                          Padding(
                            padding: const EdgeInsets.only(bottom: 20),
                            child: Row(
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
                                  onPressed: _selectedAnswer ==
                                          currentQuestion['synonym']
                                      ? _nextQuestion
                                      : _retryQuestion,
                                  child: Text(
                                    _selectedAnswer ==
                                            currentQuestion['synonym']
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
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
