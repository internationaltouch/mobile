import 'ladder_entry.dart';

class LadderStage {
  final String title;
  final List<LadderEntry> ladder;

  LadderStage({
    required this.title,
    required this.ladder,
  });

  factory LadderStage.fromJson(Map<String, dynamic> json,
      {List<dynamic>? teams}) {
    final ladderData = json['ladder_summary'] as List<dynamic>? ?? [];

    // Create a map for quick team ID to name lookup
    final teamIdToName = <String, String>{};
    if (teams != null) {
      for (final team in teams) {
        final teamMap = team as Map<String, dynamic>;
        final teamId = teamMap['id']?.toString();
        final teamName = teamMap['title'] ?? teamMap['name'] ?? '';
        if (teamId != null && teamName.isNotEmpty) {
          teamIdToName[teamId] = teamName;
        }
      }
    }

    // Create ladder entries and populate team names
    final ladder = ladderData.map((entry) {
      final entryMap = entry as Map<String, dynamic>;
      final ladderEntry = LadderEntry.fromJson(entryMap);

      // Look up and set the team name based on team ID
      final teamName =
          teamIdToName[ladderEntry.teamId] ?? 'Team ${ladderEntry.teamId}';

      return LadderEntry(
        teamId: ladderEntry.teamId,
        teamName: teamName,
        played: ladderEntry.played,
        wins: ladderEntry.wins,
        draws: ladderEntry.draws,
        losses: ladderEntry.losses,
        points: ladderEntry.points,
        goalDifference: ladderEntry.goalDifference,
        goalsFor: ladderEntry.goalsFor,
        goalsAgainst: ladderEntry.goalsAgainst,
        percentage: ladderEntry.percentage,
      );
    }).toList();

    return LadderStage(
      title: json['title'] ?? 'Stage',
      ladder: ladder,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'ladder': ladder.map((entry) => entry.toJson()).toList(),
    };
  }
}
