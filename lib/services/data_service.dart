import '../models/event.dart';
import '../models/division.dart';
import '../models/team.dart';
import '../models/fixture.dart';
import '../models/ladder_entry.dart';
import '../models/news_item.dart';

class DataService {
  // Static data for demonstration
  static List<NewsItem> getNewsItems() {
    return [
      NewsItem(
        id: '1',
        title: 'Touch World Cup 2024 Announced',
        summary: 'The next Touch World Cup will be held in Australia, featuring teams from over 20 nations.',
        imageUrl: 'https://via.placeholder.com/300x200/1976D2/FFFFFF?text=Touch+World+Cup',
        publishedAt: DateTime.now().subtract(const Duration(days: 2)),
        content: 'Full details about the upcoming Touch World Cup...',
      ),
      NewsItem(
        id: '2',
        title: 'European Touch Championships Update',
        summary: 'Registration is now open for the European Touch Championships with exciting new divisions.',
        imageUrl: 'https://via.placeholder.com/300x200/388E3C/FFFFFF?text=European+Championships',
        publishedAt: DateTime.now().subtract(const Duration(days: 5)),
      ),
      NewsItem(
        id: '3',
        title: 'Asian Touch Cup Results',
        summary: 'Congratulations to all participating teams in the recently concluded Asian Touch Cup.',
        imageUrl: 'https://via.placeholder.com/300x200/F57C00/FFFFFF?text=Asian+Cup',
        publishedAt: DateTime.now().subtract(const Duration(days: 10)),
      ),
    ];
  }

  static List<Event> getEvents() {
    return [
      Event(
        id: '1',
        name: 'Touch World Cup',
        logoUrl: 'https://via.placeholder.com/100x100/1976D2/FFFFFF?text=TWC',
        seasons: ['2024', '2022', '2020'],
        description: 'The premier international touch tournament',
      ),
      Event(
        id: '2',
        name: 'European Touch Championships',
        logoUrl: 'https://via.placeholder.com/100x100/388E3C/FFFFFF?text=ETC',
        seasons: ['2024', '2023'],
        description: 'European regional championship event',
      ),
      Event(
        id: '3',
        name: 'Asian Touch Cup',
        logoUrl: 'https://via.placeholder.com/100x100/F57C00/FFFFFF?text=ATC',
        seasons: ['2024', '2023'],
        description: 'Asian regional tournament',
      ),
      Event(
        id: '4',
        name: 'Pacific Touch Championships',
        logoUrl: 'https://via.placeholder.com/100x100/7B1FA2/FFFFFF?text=PTC',
        seasons: ['2024'],
        description: 'Pacific regional championship',
      ),
    ];
  }

  static List<Division> getDivisions(String eventId, String season) {
    return [
      Division(
        id: '1',
        name: "Men's Open",
        eventId: eventId,
        season: season,
        color: '#1976D2',
      ),
      Division(
        id: '2',
        name: "Women's Open",
        eventId: eventId,
        season: season,
        color: '#388E3C',
      ),
      Division(
        id: '3',
        name: "Men's 30s",
        eventId: eventId,
        season: season,
        color: '#F57C00',
      ),
      Division(
        id: '4',
        name: "Women's 30s",
        eventId: eventId,
        season: season,
        color: '#7B1FA2',
      ),
      Division(
        id: '5',
        name: "Men's 40s",
        eventId: eventId,
        season: season,
        color: '#D32F2F',
      ),
      Division(
        id: '6',
        name: "Women's 40s",
        eventId: eventId,
        season: season,
        color: '#303F9F',
      ),
    ];
  }

  static List<Team> getTeams(String divisionId) {
    return [
      Team(id: '1', name: 'ThunderCats', divisionId: divisionId),
      Team(id: '2', name: 'StormBreakers', divisionId: divisionId),
      Team(id: '3', name: 'Lightning Bolts', divisionId: divisionId),
      Team(id: '4', name: 'Wave Riders', divisionId: divisionId),
      Team(id: '5', name: 'Fire Hawks', divisionId: divisionId),
      Team(id: '6', name: 'Ice Warriors', divisionId: divisionId),
    ];
  }

  static List<Fixture> getFixtures(String divisionId) {
    final teams = getTeams(divisionId);
    final baseDate = DateTime.now();
    
    return [
      Fixture(
        id: '1',
        homeTeamId: teams[0].id,
        awayTeamId: teams[1].id,
        homeTeamName: teams[0].name,
        awayTeamName: teams[1].name,
        dateTime: baseDate.add(const Duration(hours: 2)),
        field: 'Field 1',
        divisionId: divisionId,
        homeScore: 12,
        awayScore: 8,
        isCompleted: true,
      ),
      Fixture(
        id: '2',
        homeTeamId: teams[2].id,
        awayTeamId: teams[3].id,
        homeTeamName: teams[2].name,
        awayTeamName: teams[3].name,
        dateTime: baseDate.add(const Duration(hours: 3)),
        field: 'Field 2',
        divisionId: divisionId,
        homeScore: 10,
        awayScore: 10,
        isCompleted: true,
      ),
      Fixture(
        id: '3',
        homeTeamId: teams[4].id,
        awayTeamId: teams[5].id,
        homeTeamName: teams[4].name,
        awayTeamName: teams[5].name,
        dateTime: baseDate.add(const Duration(hours: 4)),
        field: 'Field 1',
        divisionId: divisionId,
        homeScore: 15,
        awayScore: 6,
        isCompleted: true,
      ),
      Fixture(
        id: '4',
        homeTeamId: teams[0].id,
        awayTeamId: teams[2].id,
        homeTeamName: teams[0].name,
        awayTeamName: teams[2].name,
        dateTime: baseDate.add(const Duration(days: 1, hours: 2)),
        field: 'Field 3',
        divisionId: divisionId,
      ),
      Fixture(
        id: '5',
        homeTeamId: teams[1].id,
        awayTeamId: teams[3].id,
        homeTeamName: teams[1].name,
        awayTeamName: teams[3].name,
        dateTime: baseDate.add(const Duration(days: 1, hours: 3)),
        field: 'Field 2',
        divisionId: divisionId,
      ),
    ];
  }

  static List<LadderEntry> getLadder(String divisionId) {
    return [
      LadderEntry(
        teamId: '1',
        teamName: 'ThunderCats',
        played: 3,
        wins: 3,
        draws: 0,
        losses: 0,
        points: 9,
        goalDifference: 12,
        goalsFor: 36,
        goalsAgainst: 24,
      ),
      LadderEntry(
        teamId: '2',
        teamName: 'StormBreakers',
        played: 3,
        wins: 2,
        draws: 0,
        losses: 1,
        points: 6,
        goalDifference: 5,
        goalsFor: 28,
        goalsAgainst: 23,
      ),
      LadderEntry(
        teamId: '3',
        teamName: 'Lightning Bolts',
        played: 2,
        wins: 1,
        draws: 1,
        losses: 0,
        points: 4,
        goalDifference: 2,
        goalsFor: 20,
        goalsAgainst: 18,
      ),
      LadderEntry(
        teamId: '4',
        teamName: 'Wave Riders',
        played: 2,
        wins: 0,
        draws: 1,
        losses: 1,
        points: 1,
        goalDifference: -2,
        goalsFor: 18,
        goalsAgainst: 20,
      ),
      LadderEntry(
        teamId: '5',
        teamName: 'Fire Hawks',
        played: 1,
        wins: 1,
        draws: 0,
        losses: 0,
        points: 3,
        goalDifference: 9,
        goalsFor: 15,
        goalsAgainst: 6,
      ),
      LadderEntry(
        teamId: '6',
        teamName: 'Ice Warriors',
        played: 1,
        wins: 0,
        draws: 0,
        losses: 1,
        points: 0,
        goalDifference: -9,
        goalsFor: 6,
        goalsAgainst: 15,
      ),
    ]..sort((a, b) {
      // Sort by points first, then goal difference
      if (a.points != b.points) {
        return b.points.compareTo(a.points);
      }
      return b.goalDifference.compareTo(a.goalDifference);
    });
  }
}