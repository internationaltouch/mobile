import 'package:flutter/material.dart';
import '../models/event.dart';
import '../models/season.dart';
import '../models/division.dart';
import '../models/team.dart';
import '../services/data_service.dart';
import '../services/database_service.dart';
import 'event_detail_view.dart';
import 'divisions_view.dart';
import 'fixtures_results_view.dart';
import 'main_navigation_view.dart';

class MyTouchView extends StatefulWidget {
  const MyTouchView({super.key});

  @override
  State<MyTouchView> createState() => _MyTouchViewState();
}

class _MyTouchViewState extends State<MyTouchView> {
  List<Map<String, dynamic>> _favourites = [];
  List<Event> _competitions = [];
  List<Season> _seasons = [];
  List<Division> _divisions = [];
  List<Team> _teams = [];

  Event? _selectedCompetition;
  Season? _selectedSeason;
  Division? _selectedDivision;
  Team? _selectedTeam;

  bool _isLoadingCompetitions = false;
  bool _isLoadingDivisions = false;
  bool _isLoadingTeams = false;
  bool _showAddForm = false;

  @override
  void initState() {
    super.initState();
    _loadFavourites();
    // Don't load competitions immediately - wait until user wants to add something
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Refresh competitions when coming back to this tab (if form is open)
    if (_showAddForm && _competitions.isEmpty && !_isLoadingCompetitions) {
      _loadCompetitions();
    }
  }

  Future<void> _loadFavourites() async {
    final favourites = await DatabaseService.getFavourites();
    setState(() {
      _favourites = favourites;
    });
  }

  Future<void> _loadCompetitions() async {
    setState(() {
      _isLoadingCompetitions = true;
    });

    try {
      final competitions = await DataService.getEvents();

      if (mounted) {
        setState(() {
          _competitions = competitions;
          _isLoadingCompetitions = false;

          // Preserve selected competition if it exists in new data (by ID/slug)
          if (_selectedCompetition != null) {
            final matchingCompetition = competitions.firstWhere(
              (comp) =>
                  comp.id == _selectedCompetition!.id ||
                  (comp.slug != null &&
                      comp.slug == _selectedCompetition!.slug),
              orElse: () => competitions.firstWhere(
                (comp) => comp.name == _selectedCompetition!.name,
                orElse: () => competitions.isEmpty
                    ? Event(
                        id: '',
                        name: '',
                        logoUrl: '',
                        seasons: [],
                        description: '')
                    : competitions.first,
              ),
            );

            // Only reset if we couldn't find a match
            if (matchingCompetition.id.isEmpty ||
                !competitions.contains(matchingCompetition)) {
              _selectedCompetition = null;
              _selectedSeason = null;
              _selectedDivision = null;
              _selectedTeam = null;
              _seasons = [];
              _divisions = [];
              _teams = [];
            } else {
              // Update reference to the new object
              _selectedCompetition = matchingCompetition;
            }
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingCompetitions = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load competitions: $e')),
        );
      }
    }
  }

  Future<void> _onCompetitionSelected(Event competition) async {
    setState(() {
      _selectedCompetition = competition;
      _selectedSeason = null;
      _selectedDivision = null;
      _selectedTeam = null;
      _seasons = [];
      _divisions = [];
      _teams = [];
    });

    // If seasons are already loaded, use them directly
    if (competition.seasonsLoaded && competition.seasons.isNotEmpty) {
      setState(() {
        _seasons = competition.seasons;
      });
      return;
    }

    // Load seasons if they haven't been loaded yet
    try {
      final competitionWithSeasons =
          await DataService.loadEventSeasons(competition);

      setState(() {
        // Don't change _selectedCompetition - just use the loaded seasons
        _seasons = competitionWithSeasons.seasons;
      });
    } catch (e) {
      // Fallback to competition.seasons
      setState(() {
        _seasons = competition.seasons;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load seasons: $e')),
        );
      }
    }
  }

  Future<void> _onSeasonSelected(Season season) async {
    setState(() {
      _selectedSeason = season;
      _selectedDivision = null;
      _selectedTeam = null;
      _isLoadingDivisions = true;
      _divisions = [];
      _teams = [];
    });

    try {
      final divisions = await DataService.getDivisions(
        _selectedCompetition!.slug ?? _selectedCompetition!.id,
        season.slug,
      );
      setState(() {
        _divisions = divisions;
        _isLoadingDivisions = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingDivisions = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load divisions: $e')),
        );
      }
    }
  }

  Future<void> _onDivisionSelected(Division division) async {
    setState(() {
      _selectedDivision = division;
      _selectedTeam = null;
      _isLoadingTeams = true;
      _teams = [];
    });

    try {
      final teams = await DataService.getTeams(
        division.slug ?? division.id,
        eventId: _selectedCompetition!.slug ?? _selectedCompetition!.id,
        season: _selectedSeason!.slug,
      );
      setState(() {
        _teams = teams;
        _isLoadingTeams = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingTeams = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load teams: $e')),
        );
      }
    }
  }

  Future<void> _onTeamSelected(Team team) async {
    setState(() {
      _selectedTeam = team;
    });
  }

  Future<void> _addCurrentSelection() async {
    // Determine what level to add based on current selections
    String type;
    if (_selectedTeam != null) {
      type = 'team';
    } else if (_selectedDivision != null) {
      type = 'division';
    } else if (_selectedSeason != null) {
      type = 'season';
    } else if (_selectedCompetition != null) {
      type = 'competition';
    } else {
      return; // Nothing selected
    }

    await _addFavourite(type);
  }

  String _getAddButtonText() {
    if (_selectedTeam != null) {
      return 'Add Team';
    } else if (_selectedDivision != null) {
      return 'Add Division';
    } else if (_selectedSeason != null) {
      return 'Add Season';
    } else if (_selectedCompetition != null) {
      return 'Add Competition';
    }
    return 'Add';
  }

  Future<void> _addFavourite(String type) async {
    try {
      switch (type) {
        case 'competition':
          if (_selectedCompetition != null) {
            await DatabaseService.addFavourite(
              type: 'competition',
              competitionSlug:
                  _selectedCompetition!.slug ?? _selectedCompetition!.id,
              competitionName: _selectedCompetition!.name,
            );
          }
          break;
        case 'season':
          if (_selectedCompetition != null && _selectedSeason != null) {
            await DatabaseService.addFavourite(
              type: 'season',
              competitionSlug:
                  _selectedCompetition!.slug ?? _selectedCompetition!.id,
              competitionName: _selectedCompetition!.name,
              seasonSlug: _selectedSeason!.slug,
              seasonName: _selectedSeason!.title,
            );
          }
          break;
        case 'division':
          if (_selectedCompetition != null &&
              _selectedSeason != null &&
              _selectedDivision != null) {
            await DatabaseService.addFavourite(
              type: 'division',
              competitionSlug:
                  _selectedCompetition!.slug ?? _selectedCompetition!.id,
              competitionName: _selectedCompetition!.name,
              seasonSlug: _selectedSeason!.slug,
              seasonName: _selectedSeason!.title,
              divisionSlug: _selectedDivision!.slug ?? _selectedDivision!.id,
              divisionName: _selectedDivision!.name,
            );
          }
          break;
        case 'team':
          if (_selectedCompetition != null &&
              _selectedSeason != null &&
              _selectedDivision != null &&
              _selectedTeam != null) {
            await DatabaseService.addFavourite(
              type: 'team',
              competitionSlug:
                  _selectedCompetition!.slug ?? _selectedCompetition!.id,
              competitionName: _selectedCompetition!.name,
              seasonSlug: _selectedSeason!.slug,
              seasonName: _selectedSeason!.title,
              divisionSlug: _selectedDivision!.slug ?? _selectedDivision!.id,
              divisionName: _selectedDivision!.name,
              teamId: _selectedTeam!.id,
              teamName: _selectedTeam!.name,
            );
          }
          break;
      }

      await _loadFavourites();

      // Hide the form and reset selections after successful add
      setState(() {
        _showAddForm = false;
        _selectedCompetition = null;
        _selectedSeason = null;
        _selectedDivision = null;
        _selectedTeam = null;
        _seasons = [];
        _divisions = [];
        _teams = [];
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Added $type to favourites')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add favourite: $e')),
        );
      }
    }
  }

  Future<void> _removeFavourite(String id) async {
    try {
      await DatabaseService.removeFavourite(id);
      await _loadFavourites();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Removed from favourites')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to remove favourite: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Clean up any stale selections that don't exist in current lists (by ID/slug)
    if (_selectedCompetition != null &&
        !_competitions.any((comp) =>
            comp.id == _selectedCompetition!.id ||
            (comp.slug != null && comp.slug == _selectedCompetition!.slug))) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            _selectedCompetition = null;
            _selectedSeason = null;
            _selectedDivision = null;
            _selectedTeam = null;
            _seasons = [];
            _divisions = [];
            _teams = [];
          });
        }
      });
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Touch'),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              _loadFavourites();
              if (_showAddForm || _competitions.isNotEmpty) {
                _loadCompetitions();
              }
            },
            tooltip: 'Refresh',
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              setState(() {
                _showAddForm = !_showAddForm;
                if (_showAddForm) {
                  // Reset selections when opening form
                  _selectedCompetition = null;
                  _selectedSeason = null;
                  _selectedDivision = null;
                  _selectedTeam = null;
                  _seasons = [];
                  _divisions = [];
                  _teams = [];
                }
              });

              // Load competitions when opening the form (ensures fresh data)
              if (_showAddForm) {
                _loadCompetitions();
              }
            },
            tooltip: 'Add favourite',
          ),
        ],
      ),
      body: Column(
        children: [
          // Add new favourite section - only show when _showAddForm is true
          if (_showAddForm)
            Card(
              margin: const EdgeInsets.all(16.0),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Add to Favourites',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Competition dropdown
                    if (_isLoadingCompetitions) ...[
                      const Center(child: CircularProgressIndicator()),
                    ] else ...[
                      DropdownButtonFormField<Event>(
                        decoration: const InputDecoration(
                          labelText: 'Competition',
                          border: OutlineInputBorder(),
                        ),
                        value: _selectedCompetition != null &&
                                _competitions.any((comp) =>
                                    comp.id == _selectedCompetition!.id ||
                                    (comp.slug != null &&
                                        comp.slug ==
                                            _selectedCompetition!.slug))
                            ? _competitions.firstWhere((comp) =>
                                comp.id == _selectedCompetition!.id ||
                                (comp.slug != null &&
                                    comp.slug == _selectedCompetition!.slug))
                            : null,
                        isExpanded: true,
                        onChanged: _competitions.isEmpty
                            ? null
                            : (Event? competition) {
                                if (competition != null) {
                                  _onCompetitionSelected(competition);
                                }
                              },
                        hint: _competitions.isEmpty
                            ? const Text('No competitions available')
                            : const Text('Select a competition'),
                        items: _competitions
                            .map<DropdownMenuItem<Event>>((Event competition) {
                          return DropdownMenuItem<Event>(
                            value: competition,
                            child: Text(
                              competition.name,
                              overflow: TextOverflow.ellipsis,
                            ),
                          );
                        }).toList(),
                      ),
                    ],

                    // Season dropdown
                    if (_selectedCompetition != null &&
                        _seasons.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      DropdownButtonFormField<Season>(
                        decoration: const InputDecoration(
                          labelText: 'Season',
                          border: OutlineInputBorder(),
                        ),
                        value: _selectedSeason,
                        isExpanded: true,
                        onChanged: (Season? season) {
                          if (season != null) {
                            _onSeasonSelected(season);
                          }
                        },
                        items: _seasons
                            .map<DropdownMenuItem<Season>>((Season season) {
                          return DropdownMenuItem<Season>(
                            value: season,
                            child: Text(
                              season.title,
                              overflow: TextOverflow.ellipsis,
                            ),
                          );
                        }).toList(),
                      ),
                    ],

                    // Division dropdown
                    if (_isLoadingDivisions) ...[
                      const SizedBox(height: 16),
                      const Center(child: CircularProgressIndicator()),
                    ] else if (_divisions.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      DropdownButtonFormField<Division>(
                        decoration: const InputDecoration(
                          labelText: 'Division',
                          border: OutlineInputBorder(),
                        ),
                        value: _selectedDivision,
                        isExpanded: true,
                        onChanged: (Division? division) {
                          if (division != null) {
                            _onDivisionSelected(division);
                          }
                        },
                        items: _divisions.map<DropdownMenuItem<Division>>(
                            (Division division) {
                          return DropdownMenuItem<Division>(
                            value: division,
                            child: Text(
                              division.name,
                              overflow: TextOverflow.ellipsis,
                            ),
                          );
                        }).toList(),
                      ),
                    ],

                    // Team dropdown
                    if (_isLoadingTeams) ...[
                      const SizedBox(height: 16),
                      const Center(child: CircularProgressIndicator()),
                    ] else if (_teams.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      DropdownButtonFormField<Team>(
                        decoration: const InputDecoration(
                          labelText: 'Team',
                          border: OutlineInputBorder(),
                        ),
                        value: _selectedTeam,
                        isExpanded: true,
                        onChanged: (Team? team) {
                          if (team != null) {
                            _onTeamSelected(team);
                          }
                        },
                        items: _teams.map<DropdownMenuItem<Team>>((Team team) {
                          return DropdownMenuItem<Team>(
                            value: team,
                            child: Text(
                              team.name,
                              overflow: TextOverflow.ellipsis,
                            ),
                          );
                        }).toList(),
                      ),
                    ],

                    // Add button - appears when something is selected
                    if (_selectedCompetition != null) ...[
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _addCurrentSelection,
                          child: Text(_getAddButtonText()),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),

          // Favourites list
          Expanded(
            child: _favourites.isEmpty
                ? const Center(
                    child: Text(
                      'No favourites yet. Tap the + button to add some!',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                  )
                : ListView.builder(
                    itemCount: _favourites.length,
                    itemBuilder: (context, index) {
                      final favourite = _favourites[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 4.0,
                        ),
                        child: ListTile(
                          leading: CircleAvatar(
                            child: Icon(
                                _getIconForType(favourite['type'] as String)),
                          ),
                          title: Text(_getFavouriteTitle(favourite)),
                          subtitle: Text(_getFavouriteSubtitle(favourite)),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () =>
                                _removeFavourite(favourite['id'] as String),
                          ),
                          onTap: () {
                            // TODO: Navigate to the favourite item
                            _navigateToFavourite(favourite);
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  IconData _getIconForType(String type) {
    switch (type) {
      case 'competition':
        return Icons.sports;
      case 'season':
        return Icons.calendar_today;
      case 'division':
        return Icons.category;
      case 'team':
        return Icons.group;
      default:
        return Icons.star;
    }
  }

  String _getFavouriteTitle(Map<String, dynamic> favourite) {
    final type = favourite['type'] as String;
    switch (type) {
      case 'competition':
        return favourite['competition_name'] as String;
      case 'season':
        return '${favourite['competition_name']} - ${favourite['season_name']}';
      case 'division':
        return favourite['division_name'] as String;
      case 'team':
        return favourite['team_name'] as String;
      default:
        return 'Unknown';
    }
  }

  String _getFavouriteSubtitle(Map<String, dynamic> favourite) {
    final type = favourite['type'] as String;
    switch (type) {
      case 'competition':
        return 'Competition';
      case 'season':
        return 'Season';
      case 'division':
        return '${favourite['competition_name']} - ${favourite['season_name']}';
      case 'team':
        return '${favourite['competition_name']} - ${favourite['season_name']} - ${favourite['division_name']}';
      default:
        return type;
    }
  }

  void _navigateToFavourite(Map<String, dynamic> favourite) {
    final type = favourite['type'] as String;

    try {
      // Create Event object from favourite data
      final event = Event(
        id: favourite['competition_slug'] as String,
        slug: favourite['competition_slug'] as String,
        name: favourite['competition_name'] as String,
        logoUrl: '',
        seasons: [],
        description: '',
        seasonsLoaded: false,
      );

      switch (type) {
        case 'competition':
          // Navigate to Event Detail View
          _pushToCompetitionsAndNavigate(EventDetailView(event: event));
          break;

        case 'season':
          // Navigate directly to Divisions View
          _pushToCompetitionsAndNavigate(
            DivisionsView(
              event: event,
              season: favourite['season_name'] as String,
            ),
          );
          break;

        case 'division':
          // Navigate directly to Fixtures Results View
          final division = Division(
            id: favourite['division_slug'] as String,
            slug: favourite['division_slug'] as String,
            name: favourite['division_name'] as String,
            eventId: favourite['competition_slug'] as String,
            season: favourite['season_slug'] as String,
            color: '#2196F3', // Default color
          );

          _pushToCompetitionsAndNavigate(
            FixturesResultsView(
              event: event,
              season: favourite['season_name'] as String,
              division: division,
            ),
          );
          break;

        case 'team':
          // Navigate to Fixtures Results View with pre-selected team
          final division = Division(
            id: favourite['division_slug'] as String,
            slug: favourite['division_slug'] as String,
            name: favourite['division_name'] as String,
            eventId: favourite['competition_slug'] as String,
            season: favourite['season_slug'] as String,
            color: '#2196F3', // Default color
          );

          _pushToCompetitionsAndNavigate(
            FixturesResultsView(
              event: event,
              season: favourite['season_name'] as String,
              division: division,
              initialTeamId: favourite['team_id'] as String?,
            ),
          );
          break;

        default:
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Unknown favourite type: $type')),
            );
          }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to navigate to favourite: $e')),
        );
      }
    }
  }

  void _pushToCompetitionsAndNavigate(Widget destinationView) {
    // Use the new extension method to switch to Competitions tab (index 2) and navigate
    context.switchToTabAndNavigate(2, destinationView);
  }
}
