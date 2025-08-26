import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';

class ApiService {
  static const String baseUrl = AppConfig.apiBaseUrl;
  static const Map<String, String> headers = {
    'Content-Type': 'application/json',
  };

  // HTTP client for dependency injection in tests
  static http.Client? _httpClient;
  static http.Client get httpClient => _httpClient ?? http.Client();

  // Method to set HTTP client for testing
  static void setHttpClient(http.Client client) {
    _httpClient = client;
  }

  // Method to reset HTTP client (for tests)
  static void resetHttpClient() {
    _httpClient = null;
  }

  // Fetch competitions from the API
  static Future<List<Map<String, dynamic>>> fetchCompetitions() async {
    try {
      final response = await httpClient.get(
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
  static Future<Map<String, dynamic>> fetchCompetitionDetails(
      String slug) async {
    try {
      final response = await httpClient.get(
        Uri.parse('$baseUrl/competitions/$slug/?format=json'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception(
            'Failed to load competition details: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to fetch competition details: $e');
    }
  }

  // Fetch season details (divisions)
  static Future<Map<String, dynamic>> fetchSeasonDetails(
      String competitionSlug, String seasonSlug) async {
    try {
      final response = await httpClient.get(
        Uri.parse(
            '$baseUrl/competitions/$competitionSlug/seasons/$seasonSlug/?format=json'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception(
            'Failed to load season details: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to fetch season details: $e');
    }
  }

  // Fetch division details (teams and matches)
  static Future<Map<String, dynamic>> fetchDivisionDetails(
      String competitionSlug, String seasonSlug, String divisionSlug) async {
    try {
      final response = await httpClient.get(
        Uri.parse(
            '$baseUrl/competitions/$competitionSlug/seasons/$seasonSlug/divisions/$divisionSlug/?format=json'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception(
            'Failed to load division details: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to fetch division details: $e');
    }
  }

  // Fetch clubs/member nations from the API
  static Future<List<Map<String, dynamic>>> fetchClubs() async {
    try {
      final response = await httpClient.get(
        Uri.parse('$baseUrl/clubs/?format=json'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> clubs = json.decode(response.body);
        return clubs.cast<Map<String, dynamic>>();
      } else {
        throw Exception('Failed to load clubs: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to fetch clubs: $e');
    }
  }
}
