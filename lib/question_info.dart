import 'package:flutter/material.dart';

class QuestionInfo {
  final int id;
  final String question;
  final String answer;
  final Color color;
  final bool horizontal; // true = row-wise (RTL), false = column-wise

  QuestionInfo({
    required this.id,
    required this.question,
    required this.answer,
    required this.color,
    required this.horizontal,
  });
}
