import 'dart:math';

import 'package:daryache/main.dart';
import 'package:daryache/question_info.dart';
import 'package:daryache/questions.dart';
import 'package:flutter/material.dart';

class WordPuzzleGame extends StatefulWidget {
  final VoidCallback? onToggleTheme;
  final bool isDark;

  const WordPuzzleGame({super.key, this.onToggleTheme, this.isDark = false});

  @override
  State<WordPuzzleGame> createState() => _WordPuzzleGameState();
}

class _WordPuzzleGameState extends State<WordPuzzleGame> {
  late List<List<String>> grid;
  late List<QuestionInfo> questions;
  late Map<int, List<Position>> answerPositions;
  late List<String> userAnswers;
  late Map<int, String> currentAnswers;
  late Map<int, bool> answeredCorrectly;
  // Track orientation balance
  int _verticalCount = 0;
  int _horizontalCount = 0;
  // Placement policy: enforce adjacency and trailing boundary rules
  final bool _enforceAdjacency = true;

  int currentQuestionIndex = 0;
  int? selectedQuestion;
  List<String> letterButtons = [];
  int _colorIndex = 0; // index in palette to ensure uniqueness
  List<Color> _colorPalette = []; // shuffled palette per game
  double? _gridCellSize; // cache of grid cell size to match button size
  // Reserve grid cells that are used as number blocks to avoid overlaps
  late Set<String> _numberCells;
  // Cached center-priority cell order (row,col) pairs for symmetric scanning
  late List<List<int>> _centerCells;
  // Enforce a balanced mix of horizontal/vertical by alternating preference
  bool _placeNextVertical = true; // first word is horizontal -> next vertical

  // Compute grid cell size so we can size the bottom letter buttons to match
  double _computeGridCellSize(BuildContext context) {
    // Body padding: 16 on each side => 32 total
    const bodyHorizontalPadding = 32.0;
    // GridView padding: 4 on each side => 8 total
    const gridHorizontalPadding = 8.0;
    const crossAxisSpacing = 1.0;
    const cells = 10;
    final width = MediaQuery.of(context).size.width;
    final available =
        width -
        bodyHorizontalPadding -
        gridHorizontalPadding -
        crossAxisSpacing * (cells - 1);
    return available / cells;
  }

  @override
  void initState() {
    super.initState();
    _initializeGame();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _initializeGame() {
    grid = List.generate(10, (i) => List.generate(10, (j) => ''));
    questions = [];
    answerPositions = {};
    userAnswers = List.generate(10 * 10, (index) => '');
    currentAnswers = {};
    answeredCorrectly = {};
    _numberCells = <String>{};
    _colorIndex = 0; // Reset color index for new game
    _verticalCount = 0;
    _horizontalCount = 0;
    // Build and shuffle a color palette to guarantee uniqueness per game
    _colorPalette = _buildColorPalette();
    _colorPalette.shuffle(Random());
    _centerCells = _buildCenterPriorityCells();

    _generateGrid();
    if (questions.isNotEmpty) {
      selectedQuestion = questions[0].id;
      _generateLetterButtons();
    }
  }

  void _generateGrid() {
    final random = Random();
    // Build eligible pools (<= 9 letters). We'll schedule ~20% random picks.
    final allEligible = qA.entries.where((e) => e.value.length <= 9).toList();
    final randomPool = List<MapEntry<String, String>>.from(allEligible)
      ..shuffle(random);
    final greedyPool = List<MapEntry<String, String>>.from(allEligible)
      ..sort((a, b) => b.value.length.compareTo(a.value.length));

    int questionNumber = 1;

    final usedQuestions = <String>{};

    // Seed with 5 random questions to start the grid
    int seedsPlaced = 0;
    while (seedsPlaced < 5 && randomPool.isNotEmpty) {
      // pick next unused random entry
      final nextSeed = randomPool.firstWhere(
        (e) => !usedQuestions.contains(e.key),
        orElse: () => randomPool.first,
      );
      if (usedQuestions.contains(nextSeed.key)) break;

      final answer = nextSeed.value;
      final question = nextSeed.key;

      bool placed = false;
      // First seed: place horizontally near center for a strong anchor
      if (seedsPlaced == 0) {
        int row = 4;
        int startCol = 5 + answer.length ~/ 2;
        if (startCol >= 10) startCol = 9;
        if (startCol - answer.length < 0) startCol = answer.length;
        if (_canPlaceWord(answer, row, startCol, true)) {
          _placeWord(answer, row, startCol, true, questionNumber);
          _horizontalCount++;
          placed = true;
        }
      }

      // Subsequent seeds: try to intersect using center-priority cells
      if (!placed) {
        for (final rc in _centerCells) {
          if (placed) break;
          final r = rc[0], c = rc[1];
          if (grid[r][c].isNotEmpty && !_numberCells.contains('$r:$c')) {
            final existingLetter = grid[r][c];
            for (int answerIdx = 0; answerIdx < answer.length; answerIdx++) {
              if (answer[answerIdx] != existingLetter) continue;
              // Try vertical then horizontal to mix orientations early
              for (final horiz in [false, true]) {
                if (horiz) {
                  final startCol = c + answerIdx + 1;
                  if (_canPlaceWordAt(answer, r, startCol, true, answerIdx)) {
                    _placeWord(answer, r, startCol, true, questionNumber);
                    _horizontalCount++;
                    placed = true;
                    break;
                  }
                } else {
                  final startRow = r - answerIdx - 1;
                  if (_canPlaceWordAt(answer, startRow, c, false, answerIdx)) {
                    _placeWord(answer, startRow, c, false, questionNumber);
                    _verticalCount++;
                    placed = true;
                    break;
                  }
                }
              }
              if (placed) break;
            }
          }
        }
      }

      // Fallback: try non-intersecting near center rows/cols
      if (!placed) {
        // Try horizontal near middle rows
        const rowOrder = [4, 5, 3, 6, 2, 7, 1, 8, 0, 9];
        for (final row in rowOrder) {
          int minStartCol = answer.length;
          int maxStartCol = 9;
          final colOrder = [
            5 + answer.length ~/ 2,
            6 + answer.length ~/ 2,
            4 + answer.length ~/ 2,
            7 + answer.length ~/ 2,
            minStartCol,
            maxStartCol,
          ];
          for (var startCol in colOrder) {
            if (_canPlaceWord(answer, row, startCol, true)) {
              _placeWord(answer, row, startCol, true, questionNumber);
              _horizontalCount++;
              placed = true;
              break;
            }
          }
          if (placed) break;
        }
      }

      if (placed) {
        final pos = answerPositions[questionNumber]!;
        final isHoriz = pos.length >= 2 && pos[0].row == pos[1].row;
        questions.add(
          QuestionInfo(
            id: questionNumber,
            question: question,
            answer: answer,
            color: _getNextUniqueColor(),
            horizontal: isHoriz,
          ),
        );
        usedQuestions.add(question);
        questionNumber++;
        seedsPlaced++;
        _placeNextVertical = true;
      } else {
        // Couldn't place this seed; mark as used to avoid infinite loop
        usedQuestions.add(question);
        seedsPlaced++;
      }
    }

    // Attempt to place the rest; multiple passes to fill as much as possible
    final placedQuestionTexts = <String>{...questions.map((q) => q.question)}
      ..addAll(usedQuestions);
    int pass = 0;
    bool anyPlaced;
    do {
      anyPlaced = false;
      pass++;
      // We'll iterate attempts up to total pool size each pass, mixing random/greedy
      final maxAttempts = allEligible.length;
      int attemptsTried = 0;
      while (attemptsTried < maxAttempts) {
        attemptsTried++;
        // Choose next candidate honoring ~20% random
        MapEntry<String, String>? entry;
        // For early phase ensure we reach at least 5 seeds; afterwards go greedy
        if (questions.length < 5 && randomPool.isNotEmpty) {
          entry = randomPool.firstWhere(
            (e) => !placedQuestionTexts.contains(e.key),
            orElse: () => randomPool.first,
          );
        } else if (greedyPool.isNotEmpty) {
          entry = greedyPool.firstWhere(
            (e) => !placedQuestionTexts.contains(e.key),
            orElse: () => greedyPool.first,
          );
        }
        if (entry == null) break;

        final answer = entry.value;
        final question = entry.key;
        if (placedQuestionTexts.contains(question)) continue;

        bool placed = false;
        int attempts = 0;

        // Stronger balance with 45-55% constraint
        final totalPlaced = _verticalCount + _horizontalCount;
        bool preferVertical;
        if (totalPlaced == 0) {
          preferVertical = true;
        } else {
          final ratio = _verticalCount / totalPlaced;
          if (ratio < 0.45) {
            preferVertical = true; // need more verticals
          } else if (ratio > 0.55) {
            preferVertical = false; // need more horizontals
          } else {
            // otherwise alternate for symmetry
            preferVertical = _placeNextVertical;
          }
        }

        while (!placed && attempts < 500) {
          attempts++;

          // 1) Try intersections scanning cells from center outward for symmetry
          for (final rc in _centerCells) {
            if (placed) break;
            final r = rc[0], c = rc[1];
            if (grid[r][c].isNotEmpty && !_numberCells.contains('$r:$c')) {
              final existingLetter = grid[r][c];
              for (int answerIdx = 0; answerIdx < answer.length; answerIdx++) {
                if (answer[answerIdx] != existingLetter) continue;

                // Try preferred orientation first with corrected math
                List<bool> order = preferVertical
                    ? [false, true]
                    : [true, false];
                for (final horiz in order) {
                  if (horiz) {
                    final startCol =
                        c + answerIdx + 1; // ensure letter lands on (r,c)
                    if (_canPlaceWordAt(answer, r, startCol, true, answerIdx)) {
                      _placeWord(answer, r, startCol, true, questionNumber);
                      placed = true;
                      _horizontalCount++;
                      break;
                    }
                  } else {
                    final startRow =
                        r - answerIdx - 1; // ensure letter lands on (r,c)
                    if (_canPlaceWordAt(
                      answer,
                      startRow,
                      c,
                      false,
                      answerIdx,
                    )) {
                      _placeWord(answer, startRow, c, false, questionNumber);
                      placed = true;
                      _verticalCount++;
                      break;
                    }
                  }
                }
                if (placed) break;
              }
            }
          }

          // 2) Random-ish placement with center bias if no intersection found
          if (!placed) {
            List<bool> order = preferVertical ? [false, true] : [true, false];

            bool tryPlace(bool horizontal) {
              if (horizontal) {
                // Choose row near center first
                const rowOrder = [4, 5, 3, 6, 2, 7, 1, 8, 0, 9];
                for (final row in rowOrder) {
                  int minStartCol = answer.length;
                  int maxStartCol = 9; // must be within grid
                  // Try startCols centered around middle
                  final colOrder = [
                    5 + answer.length ~/ 2,
                    6 + answer.length ~/ 2,
                    4 + answer.length ~/ 2,
                    7 + answer.length ~/ 2,
                    3 + answer.length ~/ 2,
                    8 + answer.length ~/ 2,
                    minStartCol,
                    maxStartCol,
                  ];
                  for (var startCol in colOrder) {
                    if (_canPlaceWord(answer, row, startCol, true)) {
                      _placeWord(answer, row, startCol, true, questionNumber);
                      return true;
                    }
                  }
                }
                return false;
              } else {
                // Choose col near center first
                const colOrder = [4, 5, 3, 6, 2, 7, 1, 8, 0, 9];
                for (final col in colOrder) {
                  int maxStartRow = 10 - answer.length;
                  if (maxStartRow < 0) return false;
                  // Try startRows centered around middle
                  final rowOrder = [
                    5 - (answer.length ~/ 2),
                    4 - (answer.length ~/ 2),
                    6 - (answer.length ~/ 2),
                    3 - (answer.length ~/ 2),
                    7 - (answer.length ~/ 2),
                    0,
                    maxStartRow,
                  ];
                  for (var startRow in rowOrder) {
                    if (_canPlaceWord(answer, startRow, col, false)) {
                      _placeWord(answer, startRow, col, false, questionNumber);
                      return true;
                    }
                  }
                }
                return false;
              }
            }

            for (final horiz in order) {
              if (tryPlace(horiz)) {
                placed = true;
                if (horiz) {
                  _horizontalCount++;
                } else {
                  _verticalCount++;
                }
                break;
              }
            }
          }
        }

        if (placed) {
          // Flip preferred orientation for the next placement
          _placeNextVertical = !_placeNextVertical;
          // Determine actual orientation for this placed word by comparing positions
          bool horizPlaced;
          final pos = answerPositions[questionNumber]!;
          horizPlaced = pos.length >= 2 && pos[0].row == pos[1].row;
          questions.add(
            QuestionInfo(
              id: questionNumber,
              question: question,
              answer: answer,
              color: _getNextUniqueColor(),
              horizontal: horizPlaced,
            ),
          );
          placedQuestionTexts.add(question);
          questionNumber++;
          anyPlaced = true;
        }
      }
    } while (anyPlaced && pass < 3); // a couple of passes to fill more cells

    // Aggressive gap fill: iterate until no more placements or no unused cells remain
    int extraPass = 0;
    bool placedInExtra = true;
    while (placedInExtra && extraPass < 6) {
      extraPass++;
      final beforeQNum = questionNumber;
      questionNumber = _fillRemainingSlotsWithExactLengthWords(questionNumber);
      placedInExtra = questionNumber != beforeQNum;
      // stop early if fully packed
      if (!_hasUnusedCells()) break;
    }

    // If still any unused cells remain, try one last mixed-direction pass
    if (_hasUnusedCells()) {
      final remainingEntries =
          allEligible
              .where((e) => !placedQuestionTexts.contains(e.key))
              .toList()
            ..shuffle(random);
      for (final entry in remainingEntries) {
        final answer = entry.value;
        bool placed = false;
        for (final rc in _centerCells) {
          if (placed) break;
          final r = rc[0], c = rc[1];
          // Try both orientations around center
          if (_canPlaceWord(answer, r, c, true)) {
            _placeWord(answer, r, c, true, questionNumber);
            _horizontalCount++;
            placed = true;
          } else if (_canPlaceWord(answer, r, c, false)) {
            _placeWord(answer, r, c, false, questionNumber);
            _verticalCount++;
            placed = true;
          }
        }
        if (placed) {
          questions.add(
            QuestionInfo(
              id: questionNumber,
              question: entry.key,
              answer: entry.value,
              color: _getNextUniqueColor(),
              horizontal:
                  answerPositions[questionNumber]![0].row ==
                  answerPositions[questionNumber]![1].row,
            ),
          );
          placedQuestionTexts.add(entry.key);
          questionNumber++;
          if (!_hasUnusedCells()) break;
        }
      }
    }

    // Final packing: aggressively fill any remaining empty slots with synthetic
    // questions (length 1..9) so no neutral/empty cells remain.
    int synthPass = 0;
    bool progress = true;
    while (progress && _hasUnusedCells() && synthPass < 8) {
      synthPass++;
      final before = questionNumber;
      questionNumber = _fillRemainingSlotsWithExactLengthWords(
        questionNumber,
        allowSynthetic: true,
      );
      progress = questionNumber != before;
    }

    if (_hasUnusedCells()) {
      questionNumber = _forceFillAllGaps(questionNumber);
      // Try to improve symmetry by pairing single-letter synthetic words across vertical axis
      _symmetricPolish();
      // Absolute fallback: tile remaining empties with 1-letter words on a checkerboard
      if (_hasUnusedCells()) {
        questionNumber = _fillAllSinglesCheckerboard(questionNumber);
        if (_hasUnusedCells()) {
          // Try opposite parity to catch any missed cells
          questionNumber = _fillAllSinglesCheckerboard(
            questionNumber,
            startOnOdd: true,
          );
        }
      }
    }

    // After placement, renumber questions so IDs start from top-right downward (RTL order)
    _renumberQuestionsSequentialRTL();
  }

  // Try to place more words into exact-length empty slots (rows & columns)
  int _fillRemainingSlotsWithExactLengthWords(
    int startQuestionNumber, {
    bool allowSynthetic = false,
  }) {
    int questionNumber = startQuestionNumber;
    bool placedSomething;
    do {
      placedSomething = false;

      // Build remaining candidates grouped by length for quick lookup
      final usedQuestions = questions.map((q) => q.question).toSet();
      final remaining =
          qA.entries
              .where(
                (e) => e.value.length <= 9 && !usedQuestions.contains(e.key),
              )
              .toList()
            ..shuffle(Random());
      if (remaining.isEmpty) break;

      Map<int, List<MapEntry<String, String>>> byLen = {};
      for (final e in remaining) {
        byLen.putIfAbsent(e.value.length, () => []).add(e);
      }

      // Helper to pop a word of exact length, or synthesize one if allowed
      MapEntry<String, String>? takeWordOfLen(int L) {
        final list = byLen[L];
        if (list != null && list.isNotEmpty) {
          return list.removeLast();
        }
        if (!allowSynthetic) return null;
        // Synthesize a filler question/answer with length L (1..9)
        final ans = _generateSyntheticWord(L);
        final qtext = 'سوال افزوده (طول $L)';
        return MapEntry(qtext, ans);
      }

      // Current ratio for balancing
      double ratioVert() {
        final total = _verticalCount + _horizontalCount;
        if (total == 0) return 0.5;
        return _verticalCount / total;
      }

      // Scan rows for empty segments and try to place horizontal words
      bool scanRowsFirst = true;
      final rv = ratioVert();
      if (rv > 0.60) {
        scanRowsFirst = true; // need more horizontals
      } else if (rv < 0.40) {
        scanRowsFirst = false; // need more verticals
      }

      bool tryScanRows() {
        bool placed = false;
        for (int r = 0; r < 10; r++) {
          int c = 0;
          while (c < 10) {
            // Find a run of empty letter cells (not walls/number cells)
            while (c < 10 &&
                (grid[r][c].isNotEmpty || _numberCells.contains('$r:$c'))) {
              c++;
            }
            if (c >= 10) break;
            int start = c;
            while (c < 10 &&
                grid[r][c].isEmpty &&
                !_numberCells.contains('$r:$c')) {
              c++;
            }
            int end = c - 1; // inclusive
            int L = end - start + 1;
            if (L > 0 && byLen.containsKey(L)) {
              // For RTL horizontal, number cell is at col = end + 1
              int startCol = end + 1;
              if (_canPlaceWord(' ' * L, r, startCol, true)) {
                // Try to take a word of length L (real or synthetic)
                final pick = takeWordOfLen(L);
                if (pick != null) {
                  final ans = pick.value;
                  if (_canPlaceWord(ans, r, startCol, true)) {
                    _placeWord(ans, r, startCol, true, questionNumber);
                    questions.add(
                      QuestionInfo(
                        id: questionNumber,
                        question: pick.key,
                        answer: ans,
                        color: _getNextUniqueColor(),
                        horizontal: true,
                      ),
                    );
                    questionNumber++;
                    _horizontalCount++;
                    placed = true;
                    placedSomething = true;
                  }
                }
              }
            }
          }
        }
        return placed;
      }

      bool tryScanCols() {
        bool placed = false;
        for (int c = 0; c < 10; c++) {
          int r = 0;
          while (r < 10) {
            while (r < 10 &&
                (grid[r][c].isNotEmpty || _numberCells.contains('$r:$c'))) {
              r++;
            }
            if (r >= 10) break;
            int start = r;
            while (r < 10 &&
                grid[r][c].isEmpty &&
                !_numberCells.contains('$r:$c')) {
              r++;
            }
            int end = r - 1;
            int L = end - start + 1;
            if (L > 0 && byLen.containsKey(L)) {
              int startRow = start - 1; // number cell above first letter
              if (_canPlaceWord(' ' * L, startRow, c, false)) {
                final pick = takeWordOfLen(L);
                if (pick != null) {
                  final ans = pick.value;
                  if (_canPlaceWord(ans, startRow, c, false)) {
                    _placeWord(ans, startRow, c, false, questionNumber);
                    questions.add(
                      QuestionInfo(
                        id: questionNumber,
                        question: pick.key,
                        answer: ans,
                        color: _getNextUniqueColor(),
                        horizontal: false,
                      ),
                    );
                    questionNumber++;
                    _verticalCount++;
                    placed = true;
                    placedSomething = true;
                  }
                }
              }
            }
          }
        }
        return placed;
      }

      // Try preferred orientation first, then the other
      if (scanRowsFirst) {
        final a = tryScanRows();
        final b = tryScanCols();
        if (!a && !b) break;
      } else {
        final a = tryScanCols();
        final b = tryScanRows();
        if (!a && !b) break;
      }
    } while (placedSomething);

    return questionNumber;
  }

  // Force-fill any remaining empty runs with synthetic words (horizontal first, then vertical)
  int _forceFillAllGaps(int startQuestionNumber) {
    int qNum = startQuestionNumber;

    // Helper to place a synthetic word in a row segment [start..end]
    void fillRowRun(int r, int start, int end) {
      int len = end - start + 1;
      if (len <= 0) return;
      // Break long runs به قطعات <= 9
      int cursorEnd = end;
      while (cursorEnd >= start) {
        int segEnd = cursorEnd;
        int segStart = max(start, segEnd - 8); // upto length 9
        int segLen = segEnd - segStart + 1;
        int segStartCol = segEnd + 1;
        final word = _generateSyntheticWord(segLen);
        if (_canPlaceWord(word, r, segStartCol, true)) {
          _placeWord(word, r, segStartCol, true, qNum);
          questions.add(
            QuestionInfo(
              id: qNum,
              question: 'سوال افزوده (طول $segLen)',
              answer: word,
              color: _getNextUniqueColor(),
              horizontal: true,
            ),
          );
          _horizontalCount++;
          qNum++;
        }
        cursorEnd = segStart - 1;
      }
    }

    // Helper to place a synthetic word in a col segment [start..end]
    void fillColRun(int c, int start, int end) {
      int len = end - start + 1;
      if (len <= 0) return;
      int cursorEnd = end;
      while (cursorEnd >= start) {
        int segEnd = cursorEnd;
        int segStart = max(start, segEnd - 8);
        int segLen = segEnd - segStart + 1;
        int segStartRow = segStart - 1; // number cell above first letter
        final word = _generateSyntheticWord(segLen);
        if (_canPlaceWord(word, segStartRow, c, false)) {
          _placeWord(word, segStartRow, c, false, qNum);
          questions.add(
            QuestionInfo(
              id: qNum,
              question: 'سوال افزوده (طول $segLen)',
              answer: word,
              color: _getNextUniqueColor(),
              horizontal: false,
            ),
          );
          _verticalCount++;
          qNum++;
        }
        cursorEnd = segStart - 1;
      }
    }

    // Pass 1: fill row runs
    for (int r = 0; r < 10; r++) {
      int c = 0;
      while (c < 10) {
        while (c < 10 &&
            (grid[r][c].isNotEmpty || _numberCells.contains('$r:$c'))) {
          c++;
        }
        if (c >= 10) break;
        int start = c;
        while (c < 10 &&
            grid[r][c].isEmpty &&
            !_numberCells.contains('$r:$c')) {
          c++;
        }
        int end = c - 1;
        if (end >= start) {
          fillRowRun(r, start, end);
        }
      }
    }

    // Pass 2: fill column runs
    for (int c = 0; c < 10; c++) {
      int r = 0;
      while (r < 10) {
        while (r < 10 &&
            (grid[r][c].isNotEmpty || _numberCells.contains('$r:$c'))) {
          r++;
        }
        if (r >= 10) break;
        int start = r;
        while (r < 10 &&
            grid[r][c].isEmpty &&
            !_numberCells.contains('$r:$c')) {
          r++;
        }
        int end = r - 1;
        if (end >= start) {
          fillColRun(c, start, end);
        }
      }
    }

    return qNum;
  }

  // Pair up remaining singles symmetrically around the vertical axis for a more natural look
  void _symmetricPolish() {
    // Mirror columns around center (col <-> 9-col)
    for (int r = 0; r < 10; r++) {
      for (int c = 0; c < 5; c++) {
        final mc = 9 - c;
        final keyL = '$r:$c';
        final keyR = '$r:$mc';
        final isEmptyL = grid[r][c].isEmpty && !_numberCells.contains(keyL);
        final isEmptyR = grid[r][mc].isEmpty && !_numberCells.contains(keyR);
        if (isEmptyL && !isEmptyR) {
          // Try to clone a single-letter vertical word at left side
          _placeSymmetricSingle(r, c);
        } else if (!isEmptyL && isEmptyR) {
          _placeSymmetricSingle(r, mc);
        }
      }
    }
  }

  // When a question is answered correctly, replace underscores in its text with the actual answer.
  String _formatQuestionText(QuestionInfo q) {
    final String text = q.question;
    final bool isCorrect = answeredCorrectly[q.id] == true;
    if (!isCorrect) return text;
    if (!text.contains('_')) return text;
    final regex = RegExp(r'(_\s*)+');
    // Replace placeholder with answer surrounded by single spaces to avoid sticking to adjacent words.
    final replaced = text.replaceAll(regex, ' ${q.answer} ');
    // Normalize spaces at ends.
    return replaced.trim();
  }

  void _placeSymmetricSingle(int r, int c) {
    // Try horizontal single letter with start cell to the right
    const L = 1;
    final word = _generateSyntheticWord(L);
    final startCol = c + L; // number cell at right of the single
    if (_canPlaceWord(word, r, startCol, true)) {
      final id = (questions.isEmpty ? 0 : questions.last.id) + 1;
      _placeWord(word, r, startCol, true, id);
      questions.add(
        QuestionInfo(
          id: id,
          question: 'سوال افزوده (طول 1)',
          answer: word,
          color: _getNextUniqueColor(),
          horizontal: true,
        ),
      );
      _horizontalCount++;
      return;
    }
    // Try vertical single letter with start above
    final startRow = r - 1;
    if (_canPlaceWord(word, startRow, c, false)) {
      final id = (questions.isEmpty ? 0 : questions.last.id) + 1;
      _placeWord(word, startRow, c, false, id);
      questions.add(
        QuestionInfo(
          id: id,
          question: 'سوال افزوده (طول 1)',
          answer: word,
          color: _getNextUniqueColor(),
          horizontal: false,
        ),
      );
      _verticalCount++;
    }
  }

  // Fill all remaining empties using 1-letter synthetic words in a checkerboard pattern
  int _fillAllSinglesCheckerboard(
    int startQuestionNumber, {
    bool startOnOdd = false,
  }) {
    int qNum = startQuestionNumber;
    for (int r = 0; r < 10; r++) {
      for (int c = 0; c < 10; c++) {
        final parity = ((r + c) % 2 == 0);
        if ((parity && startOnOdd) || (!parity && !startOnOdd)) continue;
        if (grid[r][c].isNotEmpty || _numberCells.contains('$r:$c')) continue;
        final word = _generateSyntheticWord(1);
        // Prefer horizontal with start to the right if in-bounds
        final startCol = c + 1;
        bool placed = false;
        if (startCol < 10 &&
            grid[r][startCol].isEmpty &&
            !_numberCells.contains('$r:$startCol')) {
          if (_canPlaceWord(word, r, startCol, true)) {
            _placeWord(word, r, startCol, true, qNum);
            questions.add(
              QuestionInfo(
                id: qNum,
                question: 'سوال افزوده (طول 1)',
                answer: word,
                color: _getNextUniqueColor(),
                horizontal: true,
              ),
            );
            qNum++;
            _horizontalCount++;
            placed = true;
          }
        }
        if (!placed) {
          // Try vertical with start above
          final startRow = r - 1;
          if (startRow >= 0 &&
              grid[startRow][c].isEmpty &&
              !_numberCells.contains('$startRow:$c')) {
            if (_canPlaceWord(word, startRow, c, false)) {
              _placeWord(word, startRow, c, false, qNum);
              questions.add(
                QuestionInfo(
                  id: qNum,
                  question: 'سوال افزوده (طول 1)',
                  answer: word,
                  color: _getNextUniqueColor(),
                  horizontal: false,
                ),
              );
              qNum++;
              _verticalCount++;
            }
          }
        }
      }
    }
    return qNum;
  }

  // Generate a synthetic Persian word of given length (1..9) using common letters
  String _generateSyntheticWord(int length) {
    final rand = Random();
    const letters = [
      'ا',
      'ب',
      'پ',
      'ت',
      'س',
      'ش',
      'ر',
      'ن',
      'م',
      'ک',
      'گ',
      'ل',
      'د',
      'ف',
      'ق',
      'و',
      'ه',
      'ی',
      'ز',
      'چ',
      'ج',
    ];
    return List.generate(
      length,
      (_) => letters[rand.nextInt(letters.length)],
    ).join();
  }

  // Build a list of grid cells ordered from center outward for symmetric scans
  List<List<int>> _buildCenterPriorityCells() {
    final cells = <List<int>>[];
    for (int r = 0; r < 10; r++) {
      for (int c = 0; c < 10; c++) {
        cells.add([r, c]);
      }
    }
    double center = 4.5; // center between 4 and 5 in a 0-based 10x10 grid
    cells.sort((a, b) {
      final da = (a[0] - center).abs() + (a[1] - center).abs();
      final db = (b[0] - center).abs() + (b[1] - center).abs();
      return da.compareTo(db);
    });
    return cells;
  }

  // Renumber questions so numbering starts at top-right of each row,
  // moves to the left within the row (RTL), then proceeds to the next row (top to bottom).
  void _renumberQuestionsSequentialRTL() {
    // Collect questions with their start positions
    final items = <Map<String, dynamic>>[];
    for (final q in questions) {
      final pos = answerPositions[q.id];
      if (pos == null || pos.isEmpty) continue;
      final start = pos.first; // start cell (number block)
      items.add({'oldId': q.id, 'row': start.row, 'col': start.col, 'q': q});
    }

    // Sort by row ascending (top to bottom), and within each row
    // by column descending (right to left) to get 1..n scan order RTL.
    items.sort((a, b) {
      final ra = a['row'] as int;
      final rb = b['row'] as int;
      if (ra != rb) return ra.compareTo(rb);
      final ca = a['col'] as int;
      final cb = b['col'] as int;
      return cb.compareTo(ca);
    });

    // Build remapped structures
    final Map<int, int> idMap = {}; // oldId -> newId
    final List<QuestionInfo> newQuestions = [];
    final Map<int, List<Position>> newAnswerPositions = {};
    final Map<int, String> newCurrentAnswers = {};
    final Map<int, bool> newAnsweredCorrectly = {};

    for (int i = 0; i < items.length; i++) {
      final newId = i + 1;
      final oldId = items[i]['oldId'] as int;
      final oldQ = items[i]['q'] as QuestionInfo;
      idMap[oldId] = newId;
      // Recreate QuestionInfo with new id, preserve other fields
      newQuestions.add(
        QuestionInfo(
          id: newId,
          question: oldQ.question,
          answer: oldQ.answer,
          color: oldQ.color,
          horizontal: oldQ.horizontal,
        ),
      );
      // Remap dependent maps
      final pos = answerPositions[oldId];
      if (pos != null) newAnswerPositions[newId] = pos;
      if (currentAnswers.containsKey(oldId)) {
        newCurrentAnswers[newId] = currentAnswers[oldId]!;
      }
      if (answeredCorrectly.containsKey(oldId)) {
        newAnsweredCorrectly[newId] = answeredCorrectly[oldId]!;
      }
    }

    // Commit renumbered state
    questions = newQuestions;
    answerPositions = newAnswerPositions;
    currentAnswers = newCurrentAnswers;
    answeredCorrectly = newAnsweredCorrectly;

    // Adjust selectedQuestion to the new id if it was set already
    if (selectedQuestion != null && idMap.containsKey(selectedQuestion)) {
      selectedQuestion = idMap[selectedQuestion]!;
      currentQuestionIndex = questions.indexWhere(
        (q) => q.id == selectedQuestion,
      );
      if (currentQuestionIndex < 0) currentQuestionIndex = 0;
    }
  }

  bool _canPlaceWord(String word, int startRow, int startCol, bool horizontal) {
    // Ensure start position is within grid
    if (startRow < 0 || startRow >= 10 || startCol < 0 || startCol >= 10) {
      return false;
    }

    for (int i = 0; i <= word.length; i++) {
      int row = horizontal ? startRow : startRow + i;
      // RTL for horizontal: move left as i increases
      int col = horizontal ? startCol - i : startCol;

      if (row >= 10 || col >= 10 || col < 0) return false;

      if (i == 0) {
        // Start (number) cell must be empty
        if (grid[row][col].isNotEmpty) return false;
        // And cannot overlap another number block
        if (_numberCells.contains('$row:$col')) return false;
        continue;
      }

      // Letter cells cannot overlap number blocks
      if (_numberCells.contains('$row:$col')) return false;

      // Allow overlapping if letters match or cell is empty (for letters)
      final bool isOverlapHere =
          grid[row][col].isNotEmpty && grid[row][col] == word[i - 1];
      if (grid[row][col].isNotEmpty && !isOverlapHere) {
        return false;
      }

      // Adjacency: Around each letter cell, no other letter cell from another word
      // can be orthogonally adjacent, except when this cell is an overlap (shared).
      if (_enforceAdjacency) {
        List<List<int>> nbrs = [
          [row - 1, col],
          [row + 1, col],
          [row, col - 1],
          [row, col + 1],
        ];
        for (final n in nbrs) {
          final nr = n[0], nc = n[1];
          if (nr < 0 || nr >= 10 || nc < 0 || nc >= 10) continue;
          final key = '$nr:$nc';
          final isNumber = _numberCells.contains(key);
          final hasLetter = grid[nr][nc].isNotEmpty;
          if (!isOverlapHere && hasLetter && !isNumber) {
            return false;
          }
        }
      }
    }
    // Trailing boundary: the cell immediately after the last letter must not be a letter
    if (_enforceAdjacency) {
      if (horizontal) {
        int tailCol = startCol - word.length;
        int afterTailCol = tailCol - 1;
        if (afterTailCol >= 0) {
          if (grid[startRow][afterTailCol].isNotEmpty &&
              !_numberCells.contains('$startRow:$afterTailCol')) {
            return false;
          }
        }
      } else {
        int tailRow = startRow + word.length;
        int afterTailRow = tailRow + 1;
        if (afterTailRow < 10) {
          if (grid[afterTailRow][startCol].isNotEmpty &&
              !_numberCells.contains('$afterTailRow:$startCol')) {
            return false;
          }
        }
      }
    }
    return true;
  }

  // Check if word can be placed with a specific intersection point
  bool _canPlaceWordAt(
    String word,
    int startRow,
    int startCol,
    bool horizontal,
    int intersectionIndex,
  ) {
    // Ensure start position is within grid
    if (startRow < 0 || startRow >= 10 || startCol < 0 || startCol >= 10) {
      return false;
    }
    for (int i = 0; i <= word.length; i++) {
      int row = horizontal ? startRow : startRow + i;
      int col = horizontal ? startCol - i : startCol;

      if (row >= 10 || col >= 10 || col < 0) return false;

      if (i == 0) {
        // Start (number) cell must be empty
        if (grid[row][col].isNotEmpty) return false;
        // And cannot overlap another number block
        if (_numberCells.contains('$row:$col')) return false;
        continue;
      }

      // Letter cells cannot overlap number blocks
      if (_numberCells.contains('$row:$col')) return false;

      // At intersection point, letters must match
      if (i - 1 == intersectionIndex) {
        if (grid[row][col].isEmpty || grid[row][col] == word[i - 1]) {
          // Good intersection; allow adjacency here (handled below with overlap flag)
        } else {
          return false; // Intersection mismatch
        }
      }

      // For non-intersection points: allow overlapping if letters match or cell is empty
      final bool isOverlapHere =
          grid[row][col].isNotEmpty && grid[row][col] == word[i - 1];
      if (grid[row][col].isNotEmpty && !isOverlapHere) {
        return false;
      }

      if (_enforceAdjacency) {
        List<List<int>> nbrs = [
          [row - 1, col],
          [row + 1, col],
          [row, col - 1],
          [row, col + 1],
        ];
        for (final n in nbrs) {
          final nr = n[0], nc = n[1];
          if (nr < 0 || nr >= 10 || nc < 0 || nc >= 10) continue;
          final key = '$nr:$nc';
          final isNumber = _numberCells.contains(key);
          final hasLetter = grid[nr][nc].isNotEmpty;
          if (!isOverlapHere && hasLetter && !isNumber) {
            return false;
          }
        }
      }
    }
    if (_enforceAdjacency) {
      if (horizontal) {
        int tailCol = startCol - word.length;
        int afterTailCol = tailCol - 1;
        if (afterTailCol >= 0) {
          if (grid[startRow][afterTailCol].isNotEmpty &&
              !_numberCells.contains('$startRow:$afterTailCol')) {
            return false;
          }
        }
      } else {
        int tailRow = startRow + word.length;
        int afterTailRow = tailRow + 1;
        if (afterTailRow < 10) {
          if (grid[afterTailRow][startCol].isNotEmpty &&
              !_numberCells.contains('$afterTailRow:$startCol')) {
            return false;
          }
        }
      }
    }
    return true;
  }

  void _placeWord(
    String word,
    int startRow,
    int startCol,
    bool horizontal,
    int questionId,
  ) {
    List<Position> positions = [];

    for (int i = 0; i <= word.length; i++) {
      int row = horizontal ? startRow : startRow + i;
      // RTL for horizontal answers: move left for subsequent chars
      int col = horizontal ? startCol - i : startCol;

      // i==0 is the number cell; keep it reserved, do not place a letter there
      if (i > 0) {
        grid[row][col] = word[i - 1];
      }
      if (i == 0) {
        // Mark number block as reserved so others cannot overlap it
        _numberCells.add('$row:$col');
      }
      positions.add(Position(row, col));
    }

    answerPositions[questionId] = positions;
    currentAnswers[questionId] = '';

    // Do not create trailing neutral walls. The cell beyond tail may stay empty
    // for now and will later become the start of another word or lie out of bounds.
  }

  // Check if there exists any cell that's not a letter and not a start number
  bool _hasUnusedCells() {
    for (int r = 0; r < 10; r++) {
      for (int c = 0; c < 10; c++) {
        if (grid[r][c].isEmpty && !_numberCells.contains('$r:$c')) {
          return true;
        }
      }
    }
    return false;
  }

  List<Color> _buildColorPalette() {
    // Bright, cheerful, and popular colors (avoid dark/dull tones)
    final colors = <Color>[
      // Reds & Oranges
      const Color(0xFFFF6B6B), // Coral Red
      const Color(0xFFFF8C66), // Soft Orange-Red
      const Color(0xFFFF9F43), // Orange
      const Color(0xFFFFC371), // Peach Orange
      // Yellows
      const Color(0xFFFFD93D), // Sunny Yellow
      const Color(0xFFFFE066), // Light Yellow
      // Greens
      const Color(0xFF2ED573), // Fresh Green
      const Color(0xFF7BED9F), // Mint Green
      const Color(0xFF00E3A4), // Aqua Green
      // Teals & Cyans
      const Color(0xFF1DD1A1), // Turquoise
      const Color(0xFF48DBFB), // Cyan Light
      const Color(0xFF00D2D3), // Cyan
      // Blues
      const Color(0xFF54A0FF), // Light Blue
      const Color(0xFF70A1FF), // Soft Blue
      const Color(0xFF45B7D1), // Sky Blue
      const Color(0xFF74C0FC), // Bright Sky Blue
      // Purples & Pinks
      const Color(0xFFB197FC), // Light Purple
      const Color(0xFFA29BFE), // Lavender
      const Color(0xFFFF9FF3), // Pink
      const Color(0xFFFF6BD6), // Candy Pink
      const Color(0xFFF78FB3), // Rose Pink
    ];

    // Deduplicate any repeated entries
    return colors.toSet().toList();
  }

  Color _getNextUniqueColor() {
    if (_colorPalette.isEmpty || _colorIndex >= _colorPalette.length) {
      _colorPalette = _buildColorPalette()..shuffle(Random());
      _colorIndex = 0;
    }
    return _colorPalette[_colorIndex++];
  }

  void _generateLetterButtons() {
    if (questions.isEmpty || selectedQuestion == null) return;

    final currentAnswer = questions
        .firstWhere((q) => q.id == selectedQuestion!)
        .answer;
    final random = Random();

    // Get all unique letters from the current answer
    Set<String> answerLetters = currentAnswer.split('').toSet();

    // Add some random Persian letters
    final persianLetters = [
      'ا',
      'ب',
      'پ',
      'ت',
      'ث',
      'ج',
      'چ',
      'ح',
      'خ',
      'د',
      'ذ',
      'ر',
      'ز',
      'ژ',
      'س',
      'ش',
      'ص',
      'ض',
      'ط',
      'ظ',
      'ع',
      'غ',
      'ف',
      'ق',
      'ک',
      'گ',
      'ل',
      'م',
      'ن',
      'و',
      'ه',
      'ی',
    ];

    letterButtons = answerLetters.toList();

    // Add random letters to make 10 total
    while (letterButtons.length < 10) {
      String randomLetter =
          persianLetters[random.nextInt(persianLetters.length)];
      if (!letterButtons.contains(randomLetter)) {
        letterButtons.add(randomLetter);
      }
    }

    letterButtons.shuffle(random);
  }

  void _onQuestionTap(int questionId) {
    setState(() {
      selectedQuestion = questionId;
      currentQuestionIndex = questions.indexWhere((q) => q.id == questionId);
      _generateLetterButtons();
      // Don't clear existing answers when switching questions
    });
  }

  void _onLetterTap(String letter) {
    if (selectedQuestion == null) return;
    if (answeredCorrectly[selectedQuestion] == true) {
      return; // Can't modify correct answers
    }

    final positions = answerPositions[selectedQuestion!];
    if (positions == null) return;

    String currentAnswer = currentAnswers[selectedQuestion!] ?? '';

    // Allow entering exactly the full answer length
    final correctAnswer = questions
        .firstWhere((q) => q.id == selectedQuestion!)
        .answer;
    if (currentAnswer.length < correctAnswer.length) {
      setState(() {
        currentAnswers[selectedQuestion!] = currentAnswer + letter;
        _checkAnswer();
      });
    }
  }

  void _checkAnswer() {
    if (selectedQuestion == null) return;

    String userAnswer = currentAnswers[selectedQuestion!] ?? '';
    final correctAnswer = questions
        .firstWhere((q) => q.id == selectedQuestion!)
        .answer;

    setState(() {
      if (userAnswer.length == correctAnswer.length) {
        answeredCorrectly[selectedQuestion!] = (userAnswer == correctAnswer);
      } else {
        answeredCorrectly.remove(selectedQuestion!);
      }
    });
  }

  void _clearAnswer() {
    if (selectedQuestion == null) return;
    if (answeredCorrectly[selectedQuestion] == true) return;

    setState(() {
      currentAnswers[selectedQuestion!] = '';
      answeredCorrectly.remove(selectedQuestion!);
    });
  }

  void _previousQuestion() {
    if (questions.isEmpty) return;
    final total = questions.length;
    if (total == 0) return;
    int idx = currentQuestionIndex;
    int steps = 0;
    int? target;
    while (steps < total) {
      idx = (idx - 1 + total) % total;
      final q = questions[idx];
      if (answeredCorrectly[q.id] != true) {
        target = idx;
        break;
      }
      steps++;
    }
    if (target != null) {
      setState(() {
        currentQuestionIndex = target!;
        selectedQuestion = questions[currentQuestionIndex].id;
        _generateLetterButtons();
      });
    }
  }

  void _showHelpDialog() {
    final bool isDark = widget.isDark;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: SafeArea(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF0E1A2A) : Colors.white,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                  bottom: Radius.circular(16),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.5 : 0.14),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
                border: Border.all(
                  color: (isDark
                      ? Colors.white.withValues(alpha: 0.08)
                      : Colors.black.withValues(alpha: 0.05)),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 8),
                  Container(
                    width: 42,
                    height: 4,
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.25)
                          : Colors.black.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: isDark
                            ? const [Color(0xFF0E2A47), Color(0xFF165A74)]
                            : const [
                                UrmiaColors.deepBlue,
                                UrmiaColors.turquoise,
                              ],
                      ),
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(20),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.help_center, color: Colors.white),
                        const SizedBox(width: 10),
                        const Expanded(
                          child: Text(
                            'راهنمای بازی جدول کلمات',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Flexible(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'چطور بازی کنیم',
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 14.5,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 8),
                          _HelpBullet(
                            icon: Icons.grid_on,
                            text:
                                'از خانه‌های رنگی شماره‌دار روی جدول یک سؤال را انتخاب کنید. مسیر پاسخ همان رنگ کمی برجسته می‌شود.',
                            isDark: isDark,
                          ),
                          _HelpBullet(
                            icon: Icons.keyboard,
                            text:
                                'حروف پیشنهادی بالا را به ترتیب بزنید تا در خانه‌های مسیر قرار بگیرند. هر سؤال فقط با حروف خودش پر می‌شود.',
                            isDark: isDark,
                          ),
                          _HelpBullet(
                            icon: Icons.backspace,
                            text:
                                'اگر اشتباه کردید، تا وقتی پاسخ کامل و صحیح نشده «پاک کردن» را بزنید و دوباره تلاش کنید.',
                            isDark: isDark,
                          ),
                          _HelpBullet(
                            icon: Icons.check_circle,
                            text:
                                'وقتی طول پاسخ کامل شد، اگر درست باشد مسیرش قفل می‌شود و متن سؤال به رنگ سبز در می‌آید.',
                            isDark: isDark,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'کنترل‌ها',
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 14.5,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 6),
                          _HelpTile(
                            icon: Icons.arrow_back_ios,
                            title: 'سؤال قبلی',
                            subtitle:
                                'رفتن به سؤال قبلی که هنوز پاسخ نداده‌اید (با چرخش).',
                            isDark: isDark,
                          ),
                          _HelpTile(
                            icon: Icons.arrow_forward_ios,
                            title: 'سؤال بعدی',
                            subtitle:
                                'رفتن به سؤال بعدی که هنوز پاسخ نداده‌اید (با چرخش).',
                            isDark: isDark,
                          ),
                          _HelpTile(
                            icon: isDark ? Icons.light_mode : Icons.dark_mode,
                            title: 'حالت تیره/روشن',
                            subtitle:
                                'برای مطالعهٔ راحت‌تر، ظاهر برنامه را هر زمان که خواستید تغییر دهید.',
                            isDark: isDark,
                          ),
                          _HelpTile(
                            icon: Icons.cleaning_services,
                            title: 'پاک کردن پاسخ',
                            subtitle:
                                'تا وقتی پاسخ یک سؤال نهایی نشده، می‌توانید پاسخ آن را پاک کنید.',
                            isDark: isDark,
                          ),
                          const SizedBox(height: 12),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: (isDark
                                  ? Colors.greenAccent.withValues(alpha: 0.08)
                                  : Colors.green.withValues(alpha: 0.08)),
                              border: Border.all(
                                color: (isDark
                                    ? Colors.greenAccent.withValues(alpha: 0.25)
                                    : Colors.green.withValues(alpha: 0.25)),
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(
                                  Icons.emoji_events,
                                  color: isDark
                                      ? Colors.greenAccent
                                      : Colors.green,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: const [
                                      Text(
                                        'شرط پیروزی',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                      SizedBox(height: 6),
                                      Text(
                                        'وقتی همهٔ سؤال‌ها سبز شدند و هیچ سؤال پاسخ‌نداده‌ای باقی نماند، بازی را با موفقیت تمام کرده‌اید.',
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                        ],
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton.icon(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.check_circle_outline),
                      label: const Text('باشه، شروع کنیم'),
                      style: TextButton.styleFrom(
                        foregroundColor: isDark ? Colors.white : Colors.black87,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _nextQuestion() {
    if (questions.isEmpty) return;
    // Navigate to the next UNANSWERED question (wrap-around)
    final total = questions.length;
    if (total == 0) return;
    int idx = currentQuestionIndex;
    int steps = 0;
    int? target;
    while (steps < total) {
      idx = (idx + 1) % total;
      final q = questions[idx];
      if (answeredCorrectly[q.id] != true) {
        target = idx;
        break;
      }
      steps++;
    }
    if (target != null) {
      setState(() {
        currentQuestionIndex = target!;
        selectedQuestion = questions[currentQuestionIndex].id;
        _generateLetterButtons();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = widget.isDark;
    final Color strongText = isDark ? Colors.white : Colors.black87;
    final Color mutedText = isDark ? Colors.white70 : Colors.black54;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'دریاچه ارومیه',
          style: TextStyle(color: Colors.white.withValues(alpha: 0.95)),
        ),
        foregroundColor: Colors.white,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? const [Color(0xFF0E2A47), Color(0xFF165A74)]
                  : const [UrmiaColors.deepBlue, UrmiaColors.turquoise],
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          // Simple static background (single texture)
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: isDark
                      ? const [Color(0xFF0A121E), Color(0xFF0E1A2A)]
                      : const [Color(0xFFF6FBFE), UrmiaColors.background],
                ),
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Progress bar removed per request
                  // Grid (always square)
                  Expanded(
                    child: LayoutBuilder(
                      builder: (context, outer) {
                        final double squareSize = min(
                          outer.maxWidth,
                          outer.maxHeight,
                        );
                        return Align(
                          alignment: Alignment.topCenter,
                          child: SizedBox(
                            width: squareSize,
                            height: squareSize,
                            child: Glass(
                              radius: 16,
                              padding: EdgeInsets.zero,
                              child: LayoutBuilder(
                                builder: (context, constraints) {
                                  // Cache the exact grid cell size based on actual grid width
                                  const gridPadding =
                                      8.0; // Edge insets all(4) => 8 total
                                  const crossAxisSpacing = 1.0;
                                  const cells = 10;
                                  final gridWidth = constraints.maxWidth;
                                  _gridCellSize =
                                      (gridWidth -
                                          gridPadding -
                                          crossAxisSpacing * (cells - 1)) /
                                      cells;
                                  return Directionality(
                                    textDirection: TextDirection.ltr,
                                    child: GridView.builder(
                                      padding: const EdgeInsets.all(4),
                                      gridDelegate:
                                          const SliverGridDelegateWithFixedCrossAxisCount(
                                            crossAxisCount: 10,
                                            crossAxisSpacing: 1,
                                            mainAxisSpacing: 1,
                                          ),
                                      itemCount: 100,
                                      itemBuilder: (context, index) {
                                        // Direct mapping: row/col follow grid indices
                                        int row = index ~/ 10;
                                        int col = index % 10;

                                        // Determine if this is a number cell (either a real question start or a neutral filler block)
                                        int? questionId;
                                        for (var q in questions) {
                                          final positions =
                                              answerPositions[q.id];
                                          if (positions != null &&
                                              positions.first.row == row &&
                                              positions.first.col == col) {
                                            questionId = q.id;
                                            break;
                                          }
                                        }

                                        final bool isReservedNumberCell =
                                            _numberCells.contains('$row:$col');

                                        Color backgroundColor = isDark
                                            ? Colors.white.withValues(
                                                alpha: 0.08,
                                              )
                                            : Colors.white.withValues(
                                                alpha: 0.6,
                                              );
                                        String displayText = '';
                                        Color textColor = strongText;
                                        final bool isNumberCell =
                                            isReservedNumberCell;

                                        // If this is a question start cell, set base color and show number
                                        if (questionId != null) {
                                          final question = questions.firstWhere(
                                            (q) => q.id == questionId,
                                          );
                                          backgroundColor = question.color;
                                          displayText = questionId.toString();
                                          textColor = Colors.white;
                                        } else if (isReservedNumberCell) {
                                          // Solid wall block – subtle glassy wall
                                          backgroundColor = isDark
                                              ? Colors.white.withValues(
                                                  alpha: 0.12,
                                                )
                                              : Colors.white.withValues(
                                                  alpha: 0.25,
                                                );
                                          displayText = '';
                                          textColor = isDark
                                              ? Colors.white54
                                              : Colors.black45;
                                        }

                                        // Persist typed letters for ALL questions with white background.
                                        // If a cell belongs to any question path (letter cells) and that letter has been typed, show it.
                                        if (!isNumberCell) {
                                          int? owningQId;
                                          int?
                                          letterIndex; // 1-based index within the answer path
                                          for (final q in questions) {
                                            final pos = answerPositions[q.id];
                                            if (pos == null) continue;
                                            final idx = pos.indexWhere(
                                              (p) =>
                                                  p.row == row && p.col == col,
                                            );
                                            if (idx > 0) {
                                              // letter cells only (skip number cell at 0)
                                              final userAns =
                                                  currentAnswers[q.id] ?? '';
                                              if (userAns.length >= idx) {
                                                owningQId = q.id;
                                                letterIndex = idx;
                                                break; // take the first matching (overlaps should agree)
                                              }
                                            }
                                          }

                                          if (owningQId != null &&
                                              letterIndex != null) {
                                            final userAns =
                                                currentAnswers[owningQId] ?? '';
                                            displayText =
                                                userAns[letterIndex - 1];
                                            // Keep answer block base color scheme; in dark use a subtle glass tint
                                            backgroundColor = isDark
                                                ? Colors.white.withValues(
                                                    alpha: 0.14,
                                                  )
                                                : Colors.white.withValues(
                                                    alpha: 0.9,
                                                  );
                                            final bool isCorrect =
                                                (answeredCorrectly[owningQId] ==
                                                true);
                                            if (isCorrect && isDark) {
                                              // Darken correct blocks a bit in dark mode for modern contrast
                                              backgroundColor = Colors.white
                                                  .withValues(alpha: 0.08);
                                            }
                                            textColor = isDark
                                                ? Colors.white
                                                : (isCorrect
                                                      ? Colors.black
                                                      : UrmiaColors.deepBlue);
                                          } else if (selectedQuestion != null) {
                                            // No persisted letter: softly highlight the selected question path for guidance
                                            final pos =
                                                answerPositions[selectedQuestion!];
                                            if (pos != null) {
                                              final idx = pos.indexWhere(
                                                (p) =>
                                                    p.row == row &&
                                                    p.col == col,
                                              );
                                              if (idx != -1 &&
                                                  !(questionId ==
                                                      selectedQuestion)) {
                                                final question = questions
                                                    .firstWhere(
                                                      (q) =>
                                                          q.id ==
                                                          selectedQuestion!,
                                                    );
                                                backgroundColor = question.color
                                                    .withValues(
                                                      alpha: isDark
                                                          ? 0.18
                                                          : 0.25,
                                                    );
                                              }
                                            }
                                          }
                                        }

                                        return GestureDetector(
                                          onTap: questionId != null
                                              ? () =>
                                                    _onQuestionTap(questionId!)
                                              : null,
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color: backgroundColor,
                                              border: Border.all(
                                                color: isDark
                                                    ? Colors.white.withValues(
                                                        alpha: 0.18,
                                                      )
                                                    : Colors.white.withValues(
                                                        alpha: 0.35,
                                                      ),
                                                width: 0.6,
                                              ),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: (isDark
                                                      ? Colors.black.withValues(
                                                          alpha: 0.5,
                                                        )
                                                      : Colors.black.withValues(
                                                          alpha: 0.04,
                                                        )),
                                                  blurRadius: 3,
                                                  offset: const Offset(0, 1),
                                                ),
                                              ],
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: Center(
                                              child: Text(
                                                displayText,
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: textColor,
                                                  fontSize: 14,
                                                ),
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  // Question box: fixed height (~4 lines + 1 line extra space), directly under grid
                  const SizedBox(height: 4),
                  if (questions.isNotEmpty)
                    SizedBox(
                      height: 170,
                      child: Glass(
                        radius: 16,
                        padding: const EdgeInsets.all(16),
                        child: Stack(
                          children: [
                            // Centered row: prev | question text | next
                            Center(
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  IconButton(
                                    onPressed:
                                        questions.any(
                                          (q) =>
                                              answeredCorrectly[q.id] != true,
                                        )
                                        ? _previousQuestion
                                        : null,
                                    icon: Icon(
                                      Icons.arrow_back_ios,
                                      color: strongText,
                                    ),
                                    iconSize: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      _formatQuestionText(
                                        questions[currentQuestionIndex],
                                      ),
                                      textAlign: TextAlign.center,
                                      maxLines: 4,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color:
                                            (selectedQuestion != null &&
                                                answeredCorrectly[selectedQuestion!] ==
                                                    true)
                                            ? (isDark
                                                  ? Colors.greenAccent
                                                  : Colors.green)
                                            : strongText,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  IconButton(
                                    onPressed:
                                        questions.any(
                                          (q) =>
                                              answeredCorrectly[q.id] != true,
                                        )
                                        ? _nextQuestion
                                        : null,
                                    icon: Icon(
                                      Icons.arrow_forward_ios,
                                      color: strongText,
                                    ),
                                    iconSize: 20,
                                  ),
                                ],
                              ),
                            ),
                            // Bottom info row
                            Positioned(
                              left: 0,
                              right: 0,
                              bottom: 6,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'سوال ${currentQuestionIndex + 1} از ${questions.length}',
                                    style: TextStyle(
                                      color: mutedText,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                  const SizedBox(height: 12),

                  // Letter buttons (single row, same size/spacing as grid; clear on separate line)
                  Glass(
                    radius: 16,
                    padding: const EdgeInsets.all(4),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        // Calculate button size to exactly match grid cells
                        final buttonSize =
                            _gridCellSize ?? _computeGridCellSize(context);

                        final bool canInteract =
                            (selectedQuestion != null &&
                            answeredCorrectly[selectedQuestion] != true);
                        // Build a single-row strip of 10 buttons with 1px gaps
                        List<Widget> rowChildren = [];
                        for (int i = 0; i < letterButtons.length; i++) {
                          final letter = letterButtons[i];
                          rowChildren.add(
                            ElevatedButton(
                              onPressed: canInteract
                                  ? () => _onLetterTap(letter)
                                  : null,
                              style: ElevatedButton.styleFrom(
                                minimumSize: Size(buttonSize, buttonSize),
                                maximumSize: Size(buttonSize, buttonSize),
                                backgroundColor: isDark
                                    ? Colors.white.withValues(alpha: 0.12)
                                    : Colors.white.withValues(alpha: 0.9),
                                foregroundColor: isDark
                                    ? Colors.white
                                    : UrmiaColors.deepBlue,
                                elevation: 3,
                                shadowColor: isDark
                                    ? Colors.black.withValues(alpha: 0.4)
                                    : Colors.black.withValues(alpha: 0.08),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  side: BorderSide(
                                    color: isDark
                                        ? Colors.white.withValues(alpha: 0.18)
                                        : Colors.white.withValues(alpha: 0.6),
                                    width: 1,
                                  ),
                                ),
                                padding: EdgeInsets.zero,
                              ),
                              child: Text(
                                letter,
                                style: TextStyle(
                                  fontSize: buttonSize * 0.35,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? Colors.white : null,
                                ),
                              ),
                            ),
                          );
                          if (i < letterButtons.length - 1) {
                            rowChildren.add(const SizedBox(width: 1));
                          }
                        }

                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              height: buttonSize,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: rowChildren,
                              ),
                            ),
                            const SizedBox(height: 8),
                            SizedBox(
                              height: buttonSize,
                              child: Center(
                                child: ElevatedButton(
                                  onPressed: canInteract ? _clearAnswer : null,
                                  style: ElevatedButton.styleFrom(
                                    minimumSize: Size(buttonSize, buttonSize),
                                    maximumSize: Size(buttonSize, buttonSize),
                                    backgroundColor: isDark
                                        ? Colors.white.withValues(alpha: 0.12)
                                        : Colors.white.withValues(alpha: 0.9),
                                    foregroundColor: isDark
                                        ? Colors.white
                                        : UrmiaColors.deepBlue,
                                    elevation: 3,
                                    shadowColor: isDark
                                        ? Colors.black.withValues(alpha: 0.4)
                                        : Colors.black.withValues(alpha: 0.08),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      side: BorderSide(
                                        color: isDark
                                            ? Colors.white.withValues(
                                                alpha: 0.18,
                                              )
                                            : Colors.white.withValues(
                                                alpha: 0.6,
                                              ),
                                        width: 1,
                                      ),
                                    ),
                                    padding: EdgeInsets.zero,
                                  ),
                                  child: Icon(
                                    Icons.backspace_outlined,
                                    size: buttonSize * 0.45,
                                    color: isDark ? Colors.white : null,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 12),

                  const SizedBox(height: 16),
                  Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        OutlinedButton.icon(
                          onPressed: widget.onToggleTheme,
                          icon: Icon(
                            isDark ? Icons.light_mode : Icons.dark_mode,
                            color: isDark ? Colors.amberAccent : Colors.black87,
                            size: 18,
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: isDark
                                ? Colors.white
                                : Colors.black87,
                            side: BorderSide(
                              color: (isDark ? Colors.white70 : Colors.black12)
                                  .withValues(alpha: 0.6),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 10,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          label: Text(
                            isDark ? 'حالت روشن' : 'حالت تیره',
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                        const SizedBox(width: 10),
                        OutlinedButton.icon(
                          onPressed: _showHelpDialog,
                          icon: Icon(
                            Icons.help_outline,
                            color: isDark ? Colors.white : Colors.black87,
                            size: 18,
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: isDark
                                ? Colors.white
                                : Colors.black87,
                            side: BorderSide(
                              color: (isDark ? Colors.white70 : Colors.black12)
                                  .withValues(alpha: 0.6),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 10,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          label: const Text(
                            'راهنما',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HelpBullet extends StatelessWidget {
  final IconData icon;
  final String text;
  final bool isDark;

  const _HelpBullet({
    required this.icon,
    required this.text,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final Color fg = isDark ? Colors.white : Colors.black87;
    final Color sub = isDark ? Colors.white70 : Colors.black54;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: fg.withValues(alpha: 0.9)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text, style: TextStyle(color: sub, height: 1.5)),
          ),
        ],
      ),
    );
  }
}

class _HelpTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool isDark;

  const _HelpTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.06)
            : Colors.black.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.12)
              : Colors.black.withValues(alpha: 0.06),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: isDark ? Colors.white : Colors.black87),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: isDark ? Colors.white70 : Colors.black54,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
