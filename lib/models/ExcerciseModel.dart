import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

// Exercise model based on ExerciseDB API response
class Exercise {
  final String id;
  final String name;
  final String bodyPart;
  final String equipment;
  final String gifUrl;
  final String target;
  final List<String> secondaryMuscles;
  final List<String> instructions;

  Exercise({
    required this.id,
    required this.name,
    required this.bodyPart,
    required this.equipment,
    required this.gifUrl,
    required this.target,
    required this.secondaryMuscles,
    required this.instructions,
  });

  factory Exercise.fromJson(Map<String, dynamic> json) {
    return Exercise(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? 'Unknown Exercise',
      bodyPart: json['bodyPart'] ?? 'Unknown',
      equipment: json['equipment'] ?? 'Unknown',
      gifUrl: json['gifUrl'] ?? '',
      target: json['target'] ?? 'Unknown',
      secondaryMuscles: List<String>.from(json['secondaryMuscles'] ?? []),
      instructions: List<String>.from(json['instructions'] ?? []),
    );
  }
}
