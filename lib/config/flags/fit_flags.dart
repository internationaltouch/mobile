import 'package:flag/flag.dart';
import 'package:flutter/widgets.dart';
import 'flags_interface.dart';

class FITFlags extends FlagsInterface {
  static const Map<String, String> _clubToFlagMapping = {
    'hong kong china': 'HK',
    'hong kong': 'HK',
    'england': 'GB_ENG',
    'scotland': 'GB_SCT',
    'wales': 'GB_WLS',
    'northern ireland': 'GB_NIR',
    'united states': 'US',
    'usa': 'US',
    'new zealand': 'NZ',
    'south africa': 'ZA',
    'south korea': 'KR',
  };

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
    'europe': 'EU',
    'bulgaria': 'BG',
    'catalonia': 'ES_CT',
    'estonia': 'EE',
    'iran': 'IR',
    'kiribati': 'KI',
    'luxembourg': 'LU',
    'mauritius': 'MU',
    'monaco': 'MC',
    'niue': 'NU',
    'norfolk island': 'NF',
    'pakistan': 'PK',
    'qatar': 'QA',
    'seychelles': 'SC',
    'sri lanka': 'LK',
    'tokelau': 'TK',
    'trinidad and tobago': 'TT',
    'trinidad & tobago': 'TT',
    'tuvalu': 'TV',
    'ukraine': 'UA',
  };

  static const Map<String, String> _abbreviationToISO = {
    'ENG': 'GB_ENG',
    'SCO': 'GB_SCT',
    'WAL': 'GB_WLS',
    'NIR': 'GB_NIR',
    'USA': 'US',
    'NZL': 'NZ',
    'AUS': 'AU',
    'CAN': 'CA',
    'FRA': 'FR',
    'GER': 'DE',
    'DEU': 'DE',
    'ESP': 'ES',
    'ITA': 'IT',
    'JPN': 'JP',
    'CHN': 'CN',
    'IND': 'IN',
    'BRA': 'BR',
    'ARG': 'AR',
    'MEX': 'MX',
    'RUS': 'RU',
    'NED': 'NL',
    'HOL': 'NL',
    'SWE': 'SE',
    'NOR': 'NO',
    'DEN': 'DK',
    'DNK': 'DK',
    'FIN': 'FI',
    'POL': 'PL',
    'CZE': 'CZ',
    'HUN': 'HU',
    'AUT': 'AT',
    'SUI': 'CH',
    'CHE': 'CH',
    'IRE': 'IE',
    'IRL': 'IE',
    'POR': 'PT',
    'GRE': 'GR',
    'TUR': 'TR',
    'ISR': 'IL',
    'EGY': 'EG',
    'RSA': 'ZA',
    'NGA': 'NG',
    'KEN': 'KE',
    'THA': 'TH',
    'SIN': 'SG',
    'SGP': 'SG',
    'MAS': 'MY',
    'MYS': 'MY',
    'IDN': 'ID',
    'PHI': 'PH',
    'PHL': 'PH',
    'VIE': 'VN',
    'VNM': 'VN',
    'KOR': 'KR',
    'FIJ': 'FJ',
    'PNG': 'PG',
    'SAM': 'WS',
    'TON': 'TO',
    'VAN': 'VU',
    'SOL': 'SB',
    'COK': 'CK',
    'CHL': 'CL',
    'CYM': 'KY',
    'LBN': 'LB',
    'GGY': 'GG',
    'JEY': 'JE',
    'OMN': 'OM',
    'EUR': 'EU',
    'BGR': 'BG',
    'BUL': 'BG',
    'CAT': 'ES_CT',
    'EST': 'EE',
    'IRN': 'IR',
    'IRI': 'IR',
    'KIR': 'KI',
    'LUX': 'LU',
    'MRI': 'MU',
    'MUS': 'MU',
    'MON': 'MC',
    'MCO': 'MC',
    'NIU': 'NU',
    'NFK': 'NF',
    'PAK': 'PK',
    'QAT': 'QA',
    'SEY': 'SC',
    'SYC': 'SC',
    'SRI': 'LK',
    'LKA': 'LK',
    'TKL': 'TK',
    'TTO': 'TT',
    'TRI': 'TT',
    'TUV': 'TV',
    'UKR': 'UA',
  };

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
        fit: BoxFit.contain,
      );
    } catch (e) {
      return null;
    }
  }

  static String? _getFlagCode(String teamName, String? clubAbbreviation) {
    final normalizedTeamName = teamName.toLowerCase().trim();

    if (_clubToFlagMapping.containsKey(normalizedTeamName)) {
      return _clubToFlagMapping[normalizedTeamName];
    }

    if (_countryNameToISO.containsKey(normalizedTeamName)) {
      return _countryNameToISO[normalizedTeamName];
    }

    if (clubAbbreviation != null && clubAbbreviation.isNotEmpty) {
      final abbrevUpper = clubAbbreviation.toUpperCase();

      if (abbrevUpper.length == 2) {
        return abbrevUpper;
      } else if (abbrevUpper.length == 3 && _abbreviationToISO.containsKey(abbrevUpper)) {
        return _abbreviationToISO[abbrevUpper];
      }
    }

    return null;
  }

  static bool hasFlagForTeam(String teamName, String? clubAbbreviation) {
    return _getFlagCode(teamName, clubAbbreviation) != null;
  }
}