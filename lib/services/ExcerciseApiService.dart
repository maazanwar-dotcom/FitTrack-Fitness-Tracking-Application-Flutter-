import 'dart:convert';
import 'package:fittrack/models/ExcerciseModel.dart';
import 'package:http/http.dart' as http;

class ExcerciseApiService {
  static const String baseUrl = 'https://exercisedb.p.rapidapi.com';
  static const String rapidApiKey =
      '4c5178c8d6msh1fb7ac6027706b6p1733e6jsnd94b7c75c274';
  static const String rapidApiHost = 'exercisedb.p.rapidapi.com';

  static Future<List<Exercise>> fetchExercises({
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final Uri uri = Uri.parse('$baseUrl/exercises').replace(
        queryParameters: {
          'limit': limit.toString(),
          'offset': offset.toString(),
        },
      );

      final response = await http
          .get(
            uri,
            headers: {
              'x-rapidapi-host': rapidApiHost,
              'x-rapidapi-key': rapidApiKey,
              'Content-Type': 'application/json',
            },
          )
          .timeout(Duration(seconds: 15));

      if (response.statusCode == 200) {
        List<dynamic> jsonList = json.decode(response.body);
        return jsonList.map((json) => Exercise.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load exercises: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  static Future<List<Exercise>> fetchExercisesByBodyPart(
    String bodyPart, {
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final Uri uri = Uri.parse('$baseUrl/exercises/bodyPart/$bodyPart')
          .replace(
            queryParameters: {
              'limit': limit.toString(),
              'offset': offset.toString(),
            },
          );

      final response = await http
          .get(
            uri,
            headers: {
              'x-rapidapi-host': rapidApiHost,
              'x-rapidapi-key': rapidApiKey,
              'Content-Type': 'application/json',
            },
          )
          .timeout(Duration(seconds: 15));

      if (response.statusCode == 200) {
        List<dynamic> jsonList = json.decode(response.body);
        return jsonList.map((json) => Exercise.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load exercises: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
}
