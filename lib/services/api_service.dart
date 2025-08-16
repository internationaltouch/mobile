import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'https://www.internationaltouch.org/api/v1';
  static const Map<String, String> headers = {
    'Content-Type': 'application/json',
  };

  // Fetch competitions from the API
  static Future<List<Map<String, dynamic>>> fetchCompetitions() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/competitions/?format=json'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> competitions = json.decode(response.body);
        return competitions.cast<Map<String, dynamic>>();
      } else {
        throw Exception('Failed to load competitions: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to fetch competitions: $e');
    }
  }

  // Fetch competition details (seasons)
  static Future<Map<String, dynamic>> fetchCompetitionDetails(String slug) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/competitions/$slug/?format=json'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load competition details: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to fetch competition details: $e');
    }
  }

  // Fetch season details (divisions)
  static Future<Map<String, dynamic>> fetchSeasonDetails(String competitionSlug, String seasonSlug) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/competitions/$competitionSlug/seasons/$seasonSlug/?format=json'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load season details: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to fetch season details: $e');
    }
  }

  // Fetch division details (teams and matches)
  static Future<Map<String, dynamic>> fetchDivisionDetails(
      String competitionSlug, String seasonSlug, String divisionSlug) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/competitions/$competitionSlug/seasons/$seasonSlug/divisions/$divisionSlug/?format=json'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load division details: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to fetch division details: $e');
    }
  }
}