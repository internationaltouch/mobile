import 'package:flag/flag.dart';
import 'package:flutter/widgets.dart';

/// Service to map team names to country flags using the flag library
class FlagService {
  // Static mapping for club titles to flag names for special cases
  static const Map<String, String> _clubToFlagMapping = {
    // Hong Kong SAR
    'hong kong china': 'HK',
    'hong kong': 'HK',

    // UK sub-countries
    'england': 'GB_ENG',
    'scotland': 'GB_SCT',
    'wales': 'GB_WLS',
    'northern ireland': 'GB_NIR',

    // Other common variations
    'united states': 'US',
    'usa': 'US',
    'new zealand': 'NZ',
    'south africa': 'ZA',
    'south korea': 'KR',

    // Chinese Taipei (Olympic name for Taiwan)
    'chinese taipei': 'TW',
  };

  // Common country name variations to ISO codes
  static const Map<String, String> _countryNameToISO = {
    'france': 'FR',
    'germany': 'DE',
    'spain': 'ES',
    'italy': 'IT',
    'australia': 'AU',
    'canada': 'CA',
    'japan': 'JP',
    'china': 'CN',
    'india': 'IN',
    'brazil': 'BR',
    'argentina': 'AR',
    'mexico': 'MX',
    'russia': 'RU',
    'united states': 'US',
    'united kingdom': 'GB',
    'great britain': 'GB',
    'netherlands': 'NL',
    'belgium': 'BE',
    'sweden': 'SE',
    'norway': 'NO',
    'denmark': 'DK',
    'finland': 'FI',
    'poland': 'PL',
    'czech republic': 'CZ',
    'hungary': 'HU',
    'austria': 'AT',
    'switzerland': 'CH',
    'ireland': 'IE',
    'portugal': 'PT',
    'greece': 'GR',
    'turkey': 'TR',
    'israel': 'IL',
    'egypt': 'EG',
    'south africa': 'ZA',
    'nigeria': 'NG',
    'kenya': 'KE',
    'thailand': 'TH',
    'singapore': 'SG',
    'malaysia': 'MY',
    'indonesia': 'ID',
    'philippines': 'PH',
    'vietnam': 'VN',
    'south korea': 'KR',
    'taiwan': 'TW',
    'new zealand': 'NZ',
    'fiji': 'FJ',
    'papua new guinea': 'PG',
    'samoa': 'WS',
    'tonga': 'TO',
    'vanuatu': 'VU',
    'solomon islands': 'SB',
    'cook islands': 'CK',
    'chile': 'CL',
    'cayman islands': 'KY',
    'lebanon': 'LB',
    'guernsey': 'GG',
    'jersey': 'JE',
    'oman': 'OM',
  };

  /// Get flag widget for a team name or club abbreviation
  static Widget? getFlagWidget({
    required String teamName,
    String? clubAbbreviation,
    double size = 45.0,
  }) {
    final String? flagCode = _getFlagCode(teamName, clubAbbreviation);

    if (flagCode == null) {
      return null;
    }

    try {
      return Flag.fromString(
        flagCode,
        width: size,
        height: size,
        fit: BoxFit.cover,
      );
    } catch (e) {
      // If flag code is not supported by the library, return null
      return null;
    }
  }

  /// Get flag code (ISO country code) for a team
  static String? _getFlagCode(String teamName, String? clubAbbreviation) {
    final normalizedTeamName = teamName.toLowerCase().trim();

    // First, check if we have an explicit club mapping
    if (_clubToFlagMapping.containsKey(normalizedTeamName)) {
      return _clubToFlagMapping[normalizedTeamName];
    }

    // Check if team name matches a country name exactly
    if (_countryNameToISO.containsKey(normalizedTeamName)) {
      return _countryNameToISO[normalizedTeamName];
    }

    // If we have a club abbreviation, check if it matches a country
    if (clubAbbreviation != null && clubAbbreviation.isNotEmpty) {
      final abbrevUpper = clubAbbreviation.toUpperCase();

      // Check if the abbreviation is a direct ISO country code
      if (abbrevUpper.length == 2) {
        // Common 2-letter country codes
        return abbrevUpper;
      } else if (abbrevUpper.length == 3) {
        // Convert some common 3-letter codes to 2-letter
        switch (abbrevUpper) {
          case 'ENG':
            return 'GB_ENG';
          case 'SCO':
            return 'GB_SCT';
          case 'WAL':
            return 'GB_WLS';
          case 'NIR':
            return 'GB_NIR';
          case 'USA':
            return 'US';
          case 'NZL':
            return 'NZ';
          case 'AUS':
            return 'AU';
          case 'CAN':
            return 'CA';
          case 'FRA':
            return 'FR';
          case 'GER':
          case 'DEU':
            return 'DE';
          case 'ESP':
            return 'ES';
          case 'ITA':
            return 'IT';
          case 'JPN':
            return 'JP';
          case 'CHN':
            return 'CN';
          case 'IND':
            return 'IN';
          case 'BRA':
            return 'BR';
          case 'ARG':
            return 'AR';
          case 'MEX':
            return 'MX';
          case 'RUS':
            return 'RU';
          case 'NED':
          case 'HOL':
            return 'NL';
          case 'SWE':
            return 'SE';
          case 'NOR':
            return 'NO';
          case 'DEN':
          case 'DNK':
            return 'DK';
          case 'FIN':
            return 'FI';
          case 'POL':
            return 'PL';
          case 'CZE':
            return 'CZ';
          case 'HUN':
            return 'HU';
          case 'AUT':
            return 'AT';
          case 'SUI':
          case 'CHE':
            return 'CH';
          case 'IRE':
          case 'IRL':
            return 'IE';
          case 'POR':
            return 'PT';
          case 'GRE':
            return 'GR';
          case 'TUR':
            return 'TR';
          case 'ISR':
            return 'IL';
          case 'EGY':
            return 'EG';
          case 'RSA':
            return 'ZA';
          case 'NGA':
            return 'NG';
          case 'KEN':
            return 'KE';
          case 'THA':
            return 'TH';
          case 'SIN':
          case 'SGP':
            return 'SG';
          case 'MAS':
          case 'MYS':
            return 'MY';
          case 'IDN':
            return 'ID';
          case 'PHI':
          case 'PHL':
            return 'PH';
          case 'VIE':
          case 'VNM':
            return 'VN';
          case 'KOR':
            return 'KR';
          case 'TPE':
          case 'TWN':
            return 'TW';
          case 'FIJ':
            return 'FJ';
          case 'PNG':
            return 'PG';
          case 'SAM':
            return 'WS';
          case 'TON':
            return 'TO';
          case 'VAN':
            return 'VU';
          case 'SOL':
            return 'SB';
          case 'COK':
            return 'CK';
          case 'CHL':
            return 'CL';
          case 'CYM':
            return 'KY';
          case 'LBN':
            return 'LB';
          case 'GGY':
            return 'GG';
          case 'JEY':
            return 'JE';
          case 'OMN':
            return 'OM';
        }
      }
    }

    // No match found
    return null;
  }

  /// Check if a flag exists for the given team
  static bool hasFlagForTeam(String teamName, String? clubAbbreviation) {
    return _getFlagCode(teamName, clubAbbreviation) != null;
  }
}
