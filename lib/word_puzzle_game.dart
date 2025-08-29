import 'dart:math';

import 'package:crossword_for_programmers/main.dart';
import 'package:crossword_for_programmers/question_info.dart';
import 'package:crossword_for_programmers/questions.dart';
import 'package:flutter/material.dart';

// Lightweight owner tuple for a letter cell: which question and the 1-based index in the answer
class CellOwner {
  final int qid;
  final int idx;
  const CellOwner(this.qid, this.idx);
}

class WordPuzzleGame extends StatefulWidget {
  final VoidCallback? onToggleTheme;
  final bool isDark;

  const WordPuzzleGame({super.key, this.onToggleTheme, this.isDark = false});

  @override
  State<WordPuzzleGame> createState() => _WordPuzzleGameState();
}

class _WordPuzzleGameState extends State<WordPuzzleGame> {
  // Desired question count range
  static const int _minQuestions = 25;
  static const int _maxQuestions = 35;
  late List<List<String>> grid;
  late List<QuestionInfo> questions;
  late Map<int, List<Position>> answerPositions;
  late List<String> userAnswers;
  late Map<int, String> currentAnswers;
  late Map<int, bool> answeredCorrectly;
  // Track one-time hint usage per question
  late Set<int> _hintUsed;
  // Track orientation balance
  int _verticalCount = 0;
  int _horizontalCount = 0;
  // Placement policy: enforce adjacency and trailing boundary rules
  final bool _enforceAdjacency = true;
  // Debounce rapid taps on the hint button
  bool _hintInProgress = false;
  // Lightweight loading state to avoid blocking first paint
  bool _isGenerating = false;

  int currentQuestionIndex = 0;
  int? selectedQuestion;
  List<String> letterButtons = [];
  int _colorIndex = 0; // index in palette to ensure uniqueness
  List<Color> _colorPalette = []; // shuffled palette per game
  double? _gridCellSize; // cache of grid cell size to match button size
  // Reserve grid cells that are used as number blocks to avoid overlaps
  late Set<String> _numberCells;
  bool _hasCelebrated = false; // show win celebration only once

  // Render caches to avoid per-cell O(N) scans during build
  late List<List<int>> _startQidGrid; // -1 if none, else question id
  late List<List<List<CellOwner>>>
  _ownersGrid; // list of owners per cell (letter positions)

  // Responsive font scaling against a baseline device size
  double _screenScale(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final shortest = min(size.width, size.height);
    const base = 400.0; // design baseline
    final scale = shortest / base;
    return scale.clamp(0.8, 1.15);
  }

  double _sp(BuildContext context, double px) => px * _screenScale(context);

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
    _hintUsed = <int>{};
    _hintInProgress = false;
    _numberCells = <String>{};
    _hasCelebrated = false;
    _colorIndex = 0; // Reset color index for new game
    _verticalCount = 0;
    _horizontalCount = 0;
    // Build and shuffle a color palette to guarantee uniqueness per game
    _colorPalette = _buildColorPalette();
    _colorPalette.shuffle(Random());
    _startQidGrid = List.generate(10, (_) => List.filled(10, -1));
    _ownersGrid = List.generate(
      10,
      (_) => List.generate(10, (_) => <CellOwner>[]),
    );

    _isGenerating = true;
    // Run generation after first frame so the loader is visible
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // Tiny yield to event queue to ensure paint
      await Future<void>.delayed(Duration.zero);
      _generateGrid();
      if (!mounted) return;
      setState(() {
        _isGenerating = false;
        if (questions.isNotEmpty) {
          selectedQuestion = questions[0].id;
          _generateLetterButtons();
        }
      });
    });
  }

  void _generateGrid() {
    final random = Random();
    // Strict 5-second time budget as per requirements
    final sw = Stopwatch()..start();
    bool overBudget() =>
        sw.elapsedMilliseconds > 4500; // 4.5s budget with 0.5s buffer

    // Build optimized candidate pool - prioritize shorter words for faster placement
    final allRaw = qA.entries
        .where((e) => e.value.length >= 2 && e.value.length <= 9)
        .toList();

    // Sort by length (shorter first for efficiency) and quality (longer for filling)
    final List<MapEntry<String, String>> shortWords =
        allRaw.where((e) => e.value.length <= 5).toList()..shuffle(random);
    final List<MapEntry<String, String>> mediumWords =
        allRaw.where((e) => e.value.length > 5 && e.value.length <= 7).toList()
          ..shuffle(random);
    final List<MapEntry<String, String>> longWords =
        allRaw.where((e) => e.value.length > 7).toList()..shuffle(random);

    // Deduplicate and create final pool
    final seenKeys = <String>{};
    final List<MapEntry<String, String>> candidatePool = [];

    // Mix lengths for optimal filling: 60% short, 30% medium, 10% long
    final totalCandidates = min(300, allRaw.length); // Increased pool size
    final shortTake = min((totalCandidates * 0.6).round(), shortWords.length);
    final mediumTake = min((totalCandidates * 0.3).round(), mediumWords.length);
    final longTake = min((totalCandidates * 0.1).round(), longWords.length);

    for (final e in [
      ...shortWords.take(shortTake),
      ...mediumWords.take(mediumTake),
      ...longWords.take(longTake),
    ]) {
      if (seenKeys.add(e.key)) {
        candidatePool.add(MapEntry(e.key, e.value.toUpperCase()));
      }
    }

    candidatePool.shuffle(random);

    int questionNumber = 1;
    final usedQuestions = <String>{};

    // Strategy: Start with 8-10 seed words, then use aggressive intersection-based placement
    int seedsPlaced = 0;
    final maxSeeds = min(10, candidatePool.length); // Increased seeds further

    while (seedsPlaced < maxSeeds &&
        candidatePool.isNotEmpty &&
        questions.length < _maxQuestions) {
      if (overBudget()) break;

      final candidateIndex = seedsPlaced % candidatePool.length;
      final candidate = candidatePool[candidateIndex];

      if (usedQuestions.contains(candidate.key)) {
        seedsPlaced++;
        continue;
      }

      final answer = candidate.value;
      final question = candidate.key;
      bool placed = false;

      // First seed: horizontal placement in center
      if (seedsPlaced == 0) {
        int row = 4;
        int startCol = max(0, min(9 - answer.length, 4 - (answer.length ~/ 2)));
        if (_canPlaceWord(answer, row, startCol, true)) {
          _placeWord(answer, row, startCol, true, questionNumber);
          _horizontalCount++;
          placed = true;
        }
      }
      // Second seed: try vertical intersecting with first
      else if (seedsPlaced == 1) {
        // Look for intersection points with existing words
        bool intersectionPlaced = false;
        for (int r = 0; r < 10 && !intersectionPlaced; r++) {
          for (int c = 0; c < 10 && !intersectionPlaced; c++) {
            if (grid[r][c].isNotEmpty && !_numberCells.contains('$r:$c')) {
              final existingLetter = grid[r][c];
              for (int answerIdx = 0; answerIdx < answer.length; answerIdx++) {
                if (answer[answerIdx] == existingLetter) {
                  // Try vertical placement
                  final startRow = r - answerIdx - 1;
                  if (_canPlaceWordAt(answer, startRow, c, false, answerIdx)) {
                    _placeWord(answer, startRow, c, false, questionNumber);
                    _verticalCount++;
                    placed = true;
                    intersectionPlaced = true;
                    break;
                  }
                }
              }
            }
          }
        }

        // If no intersection, try standalone placement
        if (!intersectionPlaced) {
          for (int attempts = 0; attempts < 10 && !placed; attempts++) {
            final col = random.nextInt(6); // Try different columns
            final maxStartRow = 10 - answer.length - 1;
            if (maxStartRow > 0) {
              final startRow = random.nextInt(maxStartRow);
              if (_canPlaceWord(answer, startRow, col, false)) {
                _placeWord(answer, startRow, col, false, questionNumber);
                _verticalCount++;
                placed = true;
              }
            }
          }
        }
      }
      // Subsequent seeds: aggressive intersection attempts
      else {
        // Find all filled cells for potential intersections
        final filledCells = <List<int>>[];
        for (int r = 0; r < 10; r++) {
          for (int c = 0; c < 10; c++) {
            if (grid[r][c].isNotEmpty && !_numberCells.contains('$r:$c')) {
              filledCells.add([r, c]);
            }
          }
        }

        // Prioritize center cells for better symmetry
        filledCells.sort((a, b) {
          final distA = (a[0] - 4.5).abs() + (a[1] - 4.5).abs();
          final distB = (b[0] - 4.5).abs() + (b[1] - 4.5).abs();
          return distA.compareTo(distB);
        });

        for (final cell in filledCells.take(15)) {
          // Limit search for performance
          if (placed || overBudget()) break;
          final r = cell[0], c = cell[1];
          final existingLetter = grid[r][c];

          for (int answerIdx = 0; answerIdx < answer.length; answerIdx++) {
            if (answer[answerIdx] != existingLetter) continue;

            // Determine preferred orientation for balance
            final totalPlaced = _verticalCount + _horizontalCount;
            bool preferVertical = totalPlaced == 0
                ? true
                : (_verticalCount / totalPlaced < 0.5);

            final orientations = preferVertical ? [false, true] : [true, false];

            for (final horiz in orientations) {
              if (horiz) {
                final startCol = c - answerIdx - 1;
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

        // Fallback: try non-intersecting placement
        if (!placed) {
          for (int attempts = 0; attempts < 20 && !placed; attempts++) {
            final horiz = random.nextBool();
            if (horiz) {
              final row = random.nextInt(10);
              final maxStartCol = 9 - answer.length;
              if (maxStartCol >= 0) {
                final startCol = random.nextInt(maxStartCol + 1);
                if (_canPlaceWord(answer, row, startCol, true)) {
                  _placeWord(answer, row, startCol, true, questionNumber);
                  _horizontalCount++;
                  placed = true;
                }
              }
            } else {
              final col = random.nextInt(10);
              final maxStartRow = 10 - answer.length - 1;
              if (maxStartRow > 0) {
                final startRow = random.nextInt(maxStartRow);
                if (_canPlaceWord(answer, startRow, col, false)) {
                  _placeWord(answer, startRow, col, false, questionNumber);
                  _verticalCount++;
                  placed = true;
                }
              }
            }
          }
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
      }

      seedsPlaced++;
    }

    // Main filling loop - continue until we have enough questions
    final placedQuestionTexts = <String>{
      ...questions.map((q) => q.question),
      ...usedQuestions,
    };
    int mainLoopAttempts = 0;
    const maxMainLoopAttempts = 800; // Increased to allow more attempts

    while (questions.length < _minQuestions &&
        mainLoopAttempts < maxMainLoopAttempts &&
        !overBudget()) {
      mainLoopAttempts++;
      bool anyPlaced = false;

      final remainingCandidates = candidatePool
          .where((e) => !placedQuestionTexts.contains(e.key))
          .toList();
      if (remainingCandidates.isEmpty) break;

      // Balance check - ensure we maintain 40-60% ratio with stricter enforcement
      final totalPlaced = _verticalCount + _horizontalCount;
      bool forceVertical = false, forceHorizontal = false;

      if (totalPlaced > 5) {
        // Only start balancing after 5 questions
        final verticalRatio = _verticalCount / totalPlaced;
        if (verticalRatio < 0.35)
          forceVertical = true; // Force vertical if below 35%
        else if (verticalRatio > 0.65)
          forceHorizontal = true; // Force horizontal if above 65%
      }

      // Try each remaining candidate (limit attempts for performance)
      for (final candidate in remainingCandidates.take(150)) {
        if (overBudget() || questions.length >= _maxQuestions) break;

        final answer = candidate.value;
        final question = candidate.key;
        if (placedQuestionTexts.contains(question)) continue;

        bool placed = false;

        // Find all possible intersection points
        final intersections = <Map<String, dynamic>>[];
        for (int r = 0; r < 10; r++) {
          for (int c = 0; c < 10; c++) {
            if (grid[r][c].isNotEmpty && !_numberCells.contains('$r:$c')) {
              final existingLetter = grid[r][c];
              for (int answerIdx = 0; answerIdx < answer.length; answerIdx++) {
                if (answer[answerIdx] == existingLetter) {
                  intersections.add({
                    'r': r, 'c': c, 'idx': answerIdx,
                    'priority':
                        (r - 4.5).abs() + (c - 4.5).abs(), // Center priority
                  });
                }
              }
            }
          }
        }

        // Sort intersections by priority (center first)
        intersections.sort(
          (a, b) =>
              (a['priority'] as double).compareTo(b['priority'] as double),
        );

        // Try each intersection (limit attempts for performance)
        for (final intersection in intersections.take(30)) {
          if (placed || overBudget()) break;

          final r = intersection['r'] as int;
          final c = intersection['c'] as int;
          final answerIdx = intersection['idx'] as int;

          // Determine orientation preference
          List<bool> orientations;
          if (forceVertical)
            orientations = [false];
          else if (forceHorizontal)
            orientations = [true];
          else
            orientations = [true, false]; // Try both

          for (final horiz in orientations) {
            if (horiz) {
              final startCol = c - answerIdx - 1;
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
        }

        // If no intersection worked, try standalone placement
        if (!placed) {
          // Allow standalone placement for ALL questions initially
          for (int attempts = 0; attempts < 25 && !placed; attempts++) {
            final horiz = forceHorizontal
                ? true
                : (forceVertical ? false : random.nextBool());

            if (horiz) {
              final row = random.nextInt(10);
              final maxStartCol = 9 - answer.length;
              if (maxStartCol >= 0) {
                final startCol = random.nextInt(maxStartCol + 1);
                if (_canPlaceWord(answer, row, startCol, true)) {
                  _placeWord(answer, row, startCol, true, questionNumber);
                  _horizontalCount++;
                  placed = true;
                }
              }
            } else {
              final col = random.nextInt(10);
              final maxStartRow = 10 - answer.length - 1;
              if (maxStartRow > 0) {
                final startRow = random.nextInt(maxStartRow);
                if (_canPlaceWord(answer, startRow, col, false)) {
                  _placeWord(answer, startRow, col, false, questionNumber);
                  _verticalCount++;
                  placed = true;
                }
              }
            }
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
          placedQuestionTexts.add(question);
          questionNumber++;
          anyPlaced = true;

          // Check if we've met our requirements
          if (questions.length >= _minQuestions) {
            final totalCells = 100;
            final usedCells = _countUsedCells();
            final unusedPercentage =
                ((totalCells - usedCells) / totalCells) * 100;
            if (unusedPercentage < 5.0) {
              print(
                'Early termination: ${questions.length} questions, ${unusedPercentage.toStringAsFixed(1)}% unused cells',
              );
              break; // Success criteria met
            }
          }
        }

        // Break if we have enough questions and good cell usage
        if (questions.length >= 30) break;
      }

      if (!anyPlaced) {
        print(
          'No more placements possible after ${mainLoopAttempts} attempts with ${questions.length} questions',
        );
        break; // No more placements possible
      }
    }

    // If still need more questions, try exact-length fitting for remaining gaps
    if (questions.length < _minQuestions && !overBudget()) {
      questionNumber = _fillRemainingSlotsWithExactLengthWords(
        questionNumber,
        allowSynthetic: false,
        overBudget: overBudget,
      );
    }

    // Force minimum requirement with synthetic words if needed
    if (questions.length < _minQuestions && !overBudget()) {
      print('Generating synthetic words to meet minimum requirement');
      int syntheticAttempts = 0;
      while (questions.length < _minQuestions &&
          !overBudget() &&
          syntheticAttempts < 50) {
        syntheticAttempts++;
        // Find any empty space and place a synthetic word
        bool syntheticPlaced = false;
        for (int len = 2; len <= 8 && !syntheticPlaced; len++) {
          // Try different lengths
          final syntheticWord = _generateSyntheticWord(len);

          // Try horizontal placement first (more spaces typically available)
          for (int r = 0; r < 10 && !syntheticPlaced; r++) {
            final maxStartCol = 9 - len;
            for (
              int startCol = 0;
              startCol <= maxStartCol && !syntheticPlaced;
              startCol++
            ) {
              if (_canPlaceWord(syntheticWord, r, startCol, true)) {
                _placeWord(syntheticWord, r, startCol, true, questionNumber);
                questions.add(
                  QuestionInfo(
                    id: questionNumber,
                    question: 'Programming concept (${len} letters)',
                    answer: syntheticWord,
                    color: _getNextUniqueColor(),
                    horizontal: true,
                  ),
                );
                questionNumber++;
                _horizontalCount++;
                syntheticPlaced = true;
                print('Placed synthetic horizontal word: $syntheticWord');
              }
            }
          }

          // Try vertical placement if horizontal didn't work
          if (!syntheticPlaced) {
            for (int c = 0; c < 10 && !syntheticPlaced; c++) {
              final maxStartRow = 10 - len - 1;
              for (
                int startRow = 0;
                startRow <= maxStartRow && !syntheticPlaced;
                startRow++
              ) {
                if (_canPlaceWord(syntheticWord, startRow, c, false)) {
                  _placeWord(syntheticWord, startRow, c, false, questionNumber);
                  questions.add(
                    QuestionInfo(
                      id: questionNumber,
                      question: 'Programming concept (${len} letters)',
                      answer: syntheticWord,
                      color: _getNextUniqueColor(),
                      horizontal: false,
                    ),
                  );
                  questionNumber++;
                  _verticalCount++;
                  syntheticPlaced = true;
                  print('Placed synthetic vertical word: $syntheticWord');
                }
              }
            }
          }
        }

        if (!syntheticPlaced) {
          print('Could not place synthetic word in attempt $syntheticAttempts');
          break; // Can't place any more
        }
      }
    }

    // Final balance check and adjustment
    final finalTotal = _verticalCount + _horizontalCount;
    if (finalTotal > 0) {
      // Log the final ratio for debugging (can be removed in production)
      print(
        'Final ratio - Vertical: ${(_verticalCount / finalTotal * 100).toStringAsFixed(1)}%, '
        'Horizontal: ${(_horizontalCount / finalTotal * 100).toStringAsFixed(1)}%',
      );
    }

    // Convert remaining empty cells to walls to meet <5% unused requirement
    _blockFillUnusedCells();

    // Renumber questions in reading order (top-left to bottom-right)
    _renumberQuestionsSequentialLTR();

    // Build render caches for fast grid painting
    _rebuildRenderCaches();

    final totalCells = 100;
    final usedCells = _countUsedCells();
    final unusedPercentage = ((totalCells - usedCells) / totalCells) * 100;

    print(
      'Grid generation completed in ${sw.elapsedMilliseconds}ms with ${questions.length} questions',
    );
    print(
      'Used cells: $usedCells/100 (${unusedPercentage.toStringAsFixed(1)}% unused)',
    );
    print(
      'Balance: ${_verticalCount} vertical, ${_horizontalCount} horizontal',
    );
  }

  // Helper to count used cells (letters + number blocks)
  int _countUsedCells() {
    int count = 0;
    for (int r = 0; r < 10; r++) {
      for (int c = 0; c < 10; c++) {
        if (grid[r][c].isNotEmpty || _numberCells.contains('$r:$c')) {
          count++;
        }
      }
    }
    return count;
  }

  // Try to place more words into exact-length empty slots (rows & columns)
  int _fillRemainingSlotsWithExactLengthWords(
    int startQuestionNumber, {
    bool allowSynthetic = false,
    bool Function()? overBudget,
  }) {
    int questionNumber = startQuestionNumber;
    bool placedSomething;
    do {
      if (overBudget != null && overBudget()) break;
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
        final qtext = 'Added question (len $L)';
        return MapEntry(qtext, ans);
      }

      // Current ratio for balancing
      double ratioVert() {
        final total = _verticalCount + _horizontalCount;
        if (total == 0) return 0.5;
        return _verticalCount / total;
      }

      // Scan rows for empty segments and try to place horizontal words (LTR)
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
          if (questions.length >= _maxQuestions) break;
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
              // For LTR horizontal, number cell is at col = start - 1
              int startCol = start - 1;
              if (_canPlaceWord(' ' * L, r, startCol, true)) {
                // Try to take a word of length L (real or synthetic)
                final pick = takeWordOfLen(L);
                if (pick != null) {
                  final ans = pick.value.toUpperCase();
                  if (_canPlaceWord(ans, r, startCol, true)) {
                    if (questions.length >= _maxQuestions) {
                      return placed; // guard
                    }
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
                    if (questions.length >= _maxQuestions) {
                      return placed;
                    }
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
          if (questions.length >= _maxQuestions) break;
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
                  final ans = pick.value.toUpperCase();
                  if (_canPlaceWord(ans, startRow, c, false)) {
                    if (questions.length >= _maxQuestions) {
                      return placed; // guard
                    }
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
                    if (questions.length >= _maxQuestions) {
                      return placed;
                    }
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

  // Mark all empty cells as solid blocks (reserved number cells) to maximize block usage
  void _blockFillUnusedCells() {
    for (int r = 0; r < 10; r++) {
      for (int c = 0; c < 10; c++) {
        if (grid[r][c].isEmpty) {
          final key = '$r:$c';
          if (!_numberCells.contains(key)) {
            _numberCells.add(key);
          }
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

  // Generate a synthetic English word of given length (1..9) using common letters
  String _generateSyntheticWord(int length) {
    final rand = Random();
    const letters = [
      'A',
      'B',
      'C',
      'D',
      'E',
      'F',
      'G',
      'H',
      'I',
      'J',
      'K',
      'L',
      'M',
      'N',
      'O',
      'P',
      'Q',
      'R',
      'S',
      'T',
      'U',
      'V',
      'W',
      'X',
      'Y',
      'Z',
    ];
    return List.generate(
      length,
      (_) => letters[rand.nextInt(letters.length)],
    ).join();
  }

  // Renumber questions so numbering starts at top-left of each row,
  // moves to the right within the row (LTR), then proceeds to the next row (top to bottom).
  void _renumberQuestionsSequentialLTR() {
    // Collect questions with their start positions
    final items = <Map<String, dynamic>>[];
    for (final q in questions) {
      final pos = answerPositions[q.id];
      if (pos == null || pos.isEmpty) continue;
      final start = pos.first; // start cell (number block)
      items.add({'oldId': q.id, 'row': start.row, 'col': start.col, 'q': q});
    }

    // Sort by row ascending (top to bottom), and within each row
    // by column ascending (left to right) to get 1..n scan order LTR.
    items.sort((a, b) {
      final ra = a['row'] as int;
      final rb = b['row'] as int;
      if (ra != rb) return ra.compareTo(rb);
      final ca = a['col'] as int;
      final cb = b['col'] as int;
      return ca.compareTo(cb);
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

  // Build caches for start cell lookup and letter owners per cell to speed up GridView.builder
  void _rebuildRenderCaches() {
    // Reset
    for (int r = 0; r < 10; r++) {
      for (int c = 0; c < 10; c++) {
        _startQidGrid[r][c] = -1;
        _ownersGrid[r][c].clear();
      }
    }
    for (final q in questions) {
      final pos = answerPositions[q.id];
      if (pos == null || pos.isEmpty) continue;
      // Start cell
      final start = pos.first;
      _startQidGrid[start.row][start.col] = q.id;
      // Letter cells (1..)
      for (int i = 1; i < pos.length; i++) {
        final p = pos[i];
        _ownersGrid[p.row][p.col].add(CellOwner(q.id, i));
      }
    }
  }

  bool _canPlaceWord(String word, int startRow, int startCol, bool horizontal) {
    // Ensure start position is within grid
    if (startRow < 0 || startRow >= 10 || startCol < 0 || startCol >= 10) {
      return false;
    }

    for (int i = 0; i <= word.length; i++) {
      int row = horizontal ? startRow : startRow + i;
      // LTR for horizontal: move right as i increases
      int col = horizontal ? startCol + i : startCol;

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

      // Relaxed adjacency: Only check adjacency for words with more than 25 questions placed
      // This allows more words to be placed initially, then becomes more restrictive
      if (_enforceAdjacency && questions.length >= 25) {
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
    // Relaxed trailing boundary: Only enforce after 25 questions
    if (_enforceAdjacency && questions.length >= 25) {
      if (horizontal) {
        int tailCol = startCol + word.length; // last letter col
        int afterTailCol = tailCol + 1; // must be empty or out of bounds
        if (afterTailCol < 10) {
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
      int col = horizontal ? startCol + i : startCol;

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

      // Relaxed adjacency: Only check adjacency for words with more than 25 questions placed
      if (_enforceAdjacency && questions.length >= 25) {
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
    // Relaxed trailing boundary: Only enforce after 25 questions
    if (_enforceAdjacency && questions.length >= 25) {
      if (horizontal) {
        int tailCol = startCol + word.length;
        int afterTailCol = tailCol + 1;
        if (afterTailCol < 10) {
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
      // LTR for horizontal answers: move right for subsequent chars
      int col = horizontal ? startCol + i : startCol;

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
    Set<String> answerLetters = currentAnswer.toUpperCase().split('').toSet();

    // Add some random English letters
    const englishLetters = [
      'A',
      'B',
      'C',
      'D',
      'E',
      'F',
      'G',
      'H',
      'I',
      'J',
      'K',
      'L',
      'M',
      'N',
      'O',
      'P',
      'Q',
      'R',
      'S',
      'T',
      'U',
      'V',
      'W',
      'X',
      'Y',
      'Z',
    ];

    letterButtons = answerLetters.toList();

    // Add random letters to make 10 total
    while (letterButtons.length < 10) {
      String randomLetter =
          englishLetters[random.nextInt(englishLetters.length)];
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
        currentAnswers[selectedQuestion!] =
            currentAnswer + letter.toUpperCase();
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
        answeredCorrectly[selectedQuestion!] =
            (userAnswer.toUpperCase() == correctAnswer.toUpperCase());
      } else {
        answeredCorrectly.remove(selectedQuestion!);
      }
    });

    // After updating answer state, check if all questions are solved
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkForCompletionAndCelebrate();
    });
  }

  // True when all questions are correctly answered
  bool _allAnsweredCorrect() {
    if (questions.isEmpty) return false;
    for (final q in questions) {
      if (answeredCorrectly[q.id] != true) return false;
    }
    return true;
  }

  void _checkForCompletionAndCelebrate() {
    if (_hasCelebrated) return;
    if (!_allAnsweredCorrect()) return;
    _hasCelebrated = true;
    _showWinCelebration();
  }

  void _showWinCelebration() {
    final bool isDark = widget.isDark;
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'celebration',
      barrierColor: Colors.black.withValues(alpha: 0.65),
      transitionDuration: const Duration(milliseconds: 550),
      pageBuilder: (context, anim1, anim2) => const SizedBox.shrink(),
      transitionBuilder: (context, anim, secAnim, child) {
        final curve = CurvedAnimation(parent: anim, curve: Curves.easeOutBack);
        return Stack(
          children: [
            Opacity(
              opacity: anim.value,
              child: Container(color: Colors.transparent),
            ),
            Center(
              child: Transform.scale(
                scale: curve.value,
                child: Container(
                  width: 360,
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: isDark
                          ? const [Color(0xFF0E2A47), Color(0xFF165A74)]
                          : const [UrmiaColors.deepBlue, UrmiaColors.turquoise],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(
                          alpha: isDark ? 0.5 : 0.18,
                        ),
                        blurRadius: 24,
                        offset: const Offset(0, 12),
                      ),
                    ],
                    border: Border.all(
                      color: (isDark
                          ? Colors.white.withValues(alpha: 0.12)
                          : Colors.white.withValues(alpha: 0.35)),
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Glow ring behind trophy
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 700),
                            curve: Curves.easeOut,
                            width: 110 + 20 * anim.value,
                            height: 110 + 20 * anim.value,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withValues(
                                alpha: 0.12 + 0.08 * anim.value,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.white.withValues(alpha: 0.22),
                                  blurRadius: 30,
                                  spreadRadius: 6,
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            Icons.emoji_events,
                            color: Colors.amberAccent.shade200,
                            size: 72 + 8 * anim.value,
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Text(
                        'Congratulations!',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 22,
                          letterSpacing: 0.2,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'You solved all questions successfully.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontSize: 14.5,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Confetti emojis, animated in
                          Transform.translate(
                            offset: Offset(
                              -40 * (1 - anim.value),
                              -8 * anim.value,
                            ),
                            child: Transform.rotate(
                              angle: (0.2 * anim.value),
                              child: const Text(
                                '🎉',
                                style: TextStyle(fontSize: 22),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Transform.translate(
                            offset: Offset(
                              20 * (1 - anim.value),
                              -4 * anim.value,
                            ),
                            child: Transform.rotate(
                              angle: (-0.15 * anim.value),
                              child: const Text(
                                '🎊',
                                style: TextStyle(fontSize: 20),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Transform.translate(
                            offset: Offset(
                              36 * (1 - anim.value),
                              6 * anim.value,
                            ),
                            child: Transform.rotate(
                              angle: (0.1 * anim.value),
                              child: const Text(
                                '✨',
                                style: TextStyle(fontSize: 20),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(
                          Icons.check_circle_outline,
                          color: Colors.white,
                        ),
                        label: const Text(
                          'Awesome',
                          style: TextStyle(color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white.withValues(alpha: 0.18),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 10,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(
                              color: Colors.white.withValues(alpha: 0.35),
                            ),
                          ),
                          elevation: 0,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // Start a fresh game
  void _newGame() {
    setState(() {
      _initializeGame();
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

  // Delete only the last typed character for the selected question
  void _deleteLastChar() {
    if (selectedQuestion == null) return;
    if (answeredCorrectly[selectedQuestion] == true) return;
    final current = currentAnswers[selectedQuestion!] ?? '';
    if (current.isEmpty) return;
    setState(() {
      currentAnswers[selectedQuestion!] = current.substring(
        0,
        current.length - 1,
      );
      answeredCorrectly.remove(selectedQuestion!);
    });
  }

  // One-time hint: add the next correct letter for the selected question
  void _useHintOneLetter() {
    if (selectedQuestion == null) return;
    final qid = selectedQuestion!;
    if (_hintInProgress) return; // prevent double-taps
    if (_hintUsed.contains(qid)) return; // already used for this question
    if (answeredCorrectly[qid] == true) return; // already solved

    final correctAnswer = questions
        .firstWhere((q) => q.id == qid)
        .answer
        .toUpperCase();
    final current = (currentAnswers[qid] ?? '').toUpperCase();
    if (current.length >= correctAnswer.length) return; // nothing to add
    // Immediately mark in-progress and used to disable button in this frame
    _hintInProgress = true;
    _hintUsed.add(qid);
    setState(() {
      // Append exactly one next correct character
      final nextChar = correctAnswer[current.length];
      currentAnswers[qid] = (currentAnswers[qid] ?? '') + nextChar;
      _hintInProgress = false;
      _checkAnswer();
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
        return SafeArea(
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
                          : const [UrmiaColors.deepBlue, UrmiaColors.turquoise],
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
                          'Word Puzzle Help',
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
                          'How to play',
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
                              'Pick a numbered colored cell on the grid to select a question. The path for that answer will be softly highlighted.',
                          isDark: isDark,
                        ),
                        _HelpBullet(
                          icon: Icons.keyboard,
                          text:
                              'Tap the suggested letters to fill the path. Each question only accepts its own letters.',
                          isDark: isDark,
                        ),
                        _HelpBullet(
                          icon: Icons.backspace,
                          text:
                              'Made a mistake? Until the answer is correct, you can delete or clear and try again.',
                          isDark: isDark,
                        ),
                        _HelpBullet(
                          icon: Icons.check_circle,
                          text:
                              'When your answer has the right length and is correct, it will lock in and the question text turns green.',
                          isDark: isDark,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Controls',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 14.5,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 6),
                        _HelpTile(
                          icon: Icons.arrow_back_ios,
                          title: 'Previous question',
                          subtitle:
                              'Jump to the previous unanswered question (wraps around).',
                          isDark: isDark,
                        ),
                        _HelpTile(
                          icon: Icons.arrow_forward_ios,
                          title: 'Next question',
                          subtitle:
                              'Jump to the next unanswered question (wraps around).',
                          isDark: isDark,
                        ),
                        _HelpTile(
                          icon: isDark ? Icons.light_mode : Icons.dark_mode,
                          title: 'Light/Dark mode',
                          subtitle:
                              'Switch the app appearance anytime for comfortable reading.',
                          isDark: isDark,
                        ),
                        _HelpTile(
                          icon: Icons.cleaning_services,
                          title: 'Clear answer',
                          subtitle:
                              'As long as the answer is not final, you can clear it.',
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
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: const [
                                    Text(
                                      'Win condition',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                    SizedBox(height: 6),
                                    Text(
                                      'When all questions are green and none remain unanswered, you have successfully completed the game.',
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
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.check_circle_outline),
                    label: const Text("Got it, let's start"),
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
          'Crossword For Programmers',
          style: TextStyle(color: Colors.white.withValues(alpha: 0.95)),
        ),
        foregroundColor: Colors.white,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
        actions: [
          Tooltip(
            message: 'Start a new game',
            child: IconButton(
              tooltip: 'New game',
              icon: const Icon(Icons.refresh_rounded, color: Colors.white),
              onPressed: _newGame,
            ),
          ),
          const SizedBox(width: 4),
        ],
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
                                  if (_isGenerating) {
                                    return Center(
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: const [
                                          SizedBox(height: 8),
                                          CircularProgressIndicator(
                                            strokeWidth: 2.5,
                                          ),
                                          SizedBox(height: 10),
                                          Text('Generating puzzle…'),
                                        ],
                                      ),
                                    );
                                  }
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

                                        // Determine if this is a start (number) cell via cache
                                        int? questionId;
                                        final startId = _startQidGrid[row][col];
                                        if (startId != -1) questionId = startId;

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
                                          // Solid wall block – make it visible on light backgrounds
                                          backgroundColor = isDark
                                              ? Colors.white.withValues(
                                                  alpha: 0.12,
                                                )
                                              : Colors.black.withValues(
                                                  alpha: 0.06,
                                                );
                                          displayText = '';
                                          textColor = isDark
                                              ? Colors.white54
                                              : Colors.black45;
                                        }

                                        // Persist typed letters for ALL questions with white background.
                                        // If a cell belongs to any question path (letter cells) and that letter has been typed, show it.
                                        if (!isNumberCell) {
                                          // Use owners cache; show the first owner with a typed character
                                          final owners = _ownersGrid[row][col];
                                          CellOwner? showOwner;
                                          for (final owner in owners) {
                                            final userAns =
                                                currentAnswers[owner.qid] ?? '';
                                            if (userAns.length >= owner.idx) {
                                              showOwner = owner;
                                              break;
                                            }
                                          }

                                          if (showOwner != null) {
                                            final userAns =
                                                currentAnswers[showOwner.qid] ??
                                                '';
                                            displayText =
                                                userAns[showOwner.idx - 1];
                                            // Keep answer block base color scheme; in dark use a subtle glass tint
                                            backgroundColor = isDark
                                                ? Colors.white.withValues(
                                                    alpha: 0.14,
                                                  )
                                                : Colors.white.withValues(
                                                    alpha: 0.9,
                                                  );
                                            final bool isCorrect =
                                                (answeredCorrectly[showOwner
                                                    .qid] ==
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
                                                    : Colors.black.withValues(
                                                        alpha: 0.12,
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
                                              child: Builder(
                                                builder: (context) {
                                                  // Larger font for answer letters, moderate for start numbers/walls
                                                  final bool isStartCell =
                                                      questionId != null;
                                                  final bool isLetterChar =
                                                      !isStartCell &&
                                                      displayText.isNotEmpty;
                                                  final double cellSize =
                                                      _gridCellSize ??
                                                      _computeGridCellSize(
                                                        context,
                                                      );
                                                  final double cellFontSize =
                                                      cellSize *
                                                      (isLetterChar
                                                          ? 0.48
                                                          : 0.36);
                                                  return Text(
                                                    displayText.toUpperCase(),
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: textColor,
                                                      fontSize: cellFontSize,
                                                    ),
                                                  );
                                                },
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
                        padding: const EdgeInsets.fromLTRB(0, 16, 0, 0),
                        child: Stack(
                          children: [
                            // Full-width row: prev (left) | centered question | next (right)
                            Positioned.fill(
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    width: 48,
                                    height: double.infinity,
                                    child: Material(
                                      color: Colors.transparent,
                                      child: Tooltip(
                                        message: 'Previous question',
                                        child: InkWell(
                                          onTap:
                                              questions.any(
                                                (q) =>
                                                    answeredCorrectly[q.id] !=
                                                    true,
                                              )
                                              ? _previousQuestion
                                              : null,
                                          borderRadius:
                                              const BorderRadius.horizontal(
                                                left: Radius.circular(12),
                                              ),
                                          child: Center(
                                            child: Icon(
                                              Icons.arrow_back_ios,
                                              color: strongText,
                                              size: 18,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      _formatQuestionText(
                                        questions[currentQuestionIndex],
                                      ),
                                      textAlign: TextAlign.center,
                                      maxLines: 4,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: _sp(context, 13),
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
                                  SizedBox(
                                    width: 48,
                                    height: double.infinity,
                                    child: Material(
                                      color: Colors.transparent,
                                      child: Tooltip(
                                        message: 'Next question',
                                        child: InkWell(
                                          onTap:
                                              questions.any(
                                                (q) =>
                                                    answeredCorrectly[q.id] !=
                                                    true,
                                              )
                                              ? _nextQuestion
                                              : null,
                                          borderRadius:
                                              const BorderRadius.horizontal(
                                                right: Radius.circular(12),
                                              ),
                                          child: Center(
                                            child: Icon(
                                              Icons.arrow_forward_ios,
                                              color: strongText,
                                              size: 18,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Bottom info row
                            Positioned(
                              left: 0,
                              right: 0,
                              bottom: 0,
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(
                                  16,
                                  0,
                                  16,
                                  0,
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Question ${currentQuestionIndex + 1} of ${questions.length}',
                                      style: TextStyle(
                                        color: mutedText,
                                        fontSize: _sp(context, 12),
                                      ),
                                    ),
                                  ],
                                ),
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
                        double buttonSize =
                            _gridCellSize ?? _computeGridCellSize(context);
                        // Shrink a bit to account for borders/gaps to avoid overflow
                        buttonSize = (buttonSize - 3).clamp(28.0, 100.0);

                        final bool canInteract =
                            (selectedQuestion != null &&
                            answeredCorrectly[selectedQuestion] != true);
                        // Build a single-row strip of 10 buttons with 1px gaps
                        List<Widget> rowChildren = [];
                        final buttons = letterButtons.isEmpty
                            ? List<String>.from([
                                'A',
                                'B',
                                'C',
                                'D',
                                'E',
                                'F',
                                'G',
                                'H',
                                'I',
                                'J',
                              ])
                            : letterButtons;
                        for (int i = 0; i < buttons.length; i++) {
                          final letter = buttons[i];
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
                                letter.toUpperCase(),
                                style: TextStyle(
                                  fontSize: buttonSize * 0.35,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? Colors.white : null,
                                ),
                              ),
                            ),
                          );
                          if (i < buttons.length - 1) {
                            rowChildren.add(const SizedBox(width: 1));
                          }
                        }

                        return SizedBox(
                          height: buttonSize,
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: rowChildren,
                            ),
                          ),
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
                        Tooltip(
                          message: 'Start a new game',
                          child: OutlinedButton(
                            onPressed: _newGame,
                            style: OutlinedButton.styleFrom(
                              foregroundColor: isDark
                                  ? Colors.white
                                  : Colors.black87,
                              side: BorderSide(
                                color:
                                    (isDark ? Colors.white70 : Colors.black12)
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
                            child: Icon(
                              Icons.refresh_rounded,
                              color: isDark ? Colors.white : Colors.black87,
                              size: 18,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Tooltip(
                          message: widget.isDark
                              ? 'Switch to light mode'
                              : 'Switch to dark mode',
                          child: OutlinedButton(
                            onPressed: widget.onToggleTheme,
                            style: OutlinedButton.styleFrom(
                              foregroundColor: isDark
                                  ? Colors.white
                                  : Colors.black87,
                              side: BorderSide(
                                color:
                                    (isDark ? Colors.white70 : Colors.black12)
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
                            child: Icon(
                              isDark ? Icons.light_mode : Icons.dark_mode,
                              color: isDark
                                  ? Colors.amberAccent
                                  : Colors.black87,
                              size: 18,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Tooltip(
                          message:
                              'Use a one-time hint (adds one correct letter)',
                          child: OutlinedButton(
                            onPressed:
                                (selectedQuestion != null &&
                                    answeredCorrectly[selectedQuestion] !=
                                        true &&
                                    !_hintUsed.contains(selectedQuestion!) &&
                                    !_hintInProgress &&
                                    ((currentAnswers[selectedQuestion!] ?? '')
                                            .length <
                                        questions
                                            .firstWhere(
                                              (q) => q.id == selectedQuestion!,
                                            )
                                            .answer
                                            .length))
                                ? _useHintOneLetter
                                : null,
                            style: OutlinedButton.styleFrom(
                              foregroundColor: isDark
                                  ? Colors.white
                                  : Colors.black87,
                              side: BorderSide(
                                color:
                                    (isDark ? Colors.white70 : Colors.black12)
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
                            child: Icon(
                              Icons.lightbulb_outline,
                              color: isDark
                                  ? Colors.amberAccent
                                  : Colors.orange,
                              size: 18,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Tooltip(
                          message: 'Show help',
                          child: OutlinedButton(
                            onPressed: _showHelpDialog,
                            style: OutlinedButton.styleFrom(
                              foregroundColor: isDark
                                  ? Colors.white
                                  : Colors.black87,
                              side: BorderSide(
                                color:
                                    (isDark ? Colors.white70 : Colors.black12)
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
                            child: Icon(
                              Icons.help_outline,
                              color: isDark ? Colors.white : Colors.black87,
                              size: 18,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Tooltip(
                          message: 'Delete last character',
                          child: OutlinedButton(
                            onPressed:
                                (selectedQuestion != null &&
                                    answeredCorrectly[selectedQuestion] !=
                                        true &&
                                    (currentAnswers[selectedQuestion!] ?? '')
                                        .isNotEmpty)
                                ? _deleteLastChar
                                : null,
                            style: OutlinedButton.styleFrom(
                              foregroundColor: isDark
                                  ? Colors.white
                                  : Colors.black87,
                              side: BorderSide(
                                color:
                                    (isDark ? Colors.white70 : Colors.black12)
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
                            child: Icon(
                              Icons.backspace_outlined,
                              color: isDark ? Colors.white : Colors.black87,
                              size: 18,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Tooltip(
                          message:
                              (selectedQuestion != null &&
                                  answeredCorrectly[selectedQuestion] != true)
                              ? 'Clear answer'
                              : 'Clear answer (disabled)',
                          child: OutlinedButton(
                            onPressed:
                                (selectedQuestion != null &&
                                    answeredCorrectly[selectedQuestion] != true)
                                ? _clearAnswer
                                : null,
                            style: OutlinedButton.styleFrom(
                              foregroundColor: isDark
                                  ? Colors.white
                                  : Colors.black87,
                              side: BorderSide(
                                color:
                                    (isDark ? Colors.white70 : Colors.black12)
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
                            child: Icon(
                              Icons.cleaning_services,
                              color: isDark ? Colors.white : Colors.black87,
                              size: 18,
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
