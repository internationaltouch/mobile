import 'package:flutter/material.dart';
import '../models/club.dart';
import '../services/api_service.dart';
import '../services/flag_service.dart';
import '../theme/fit_colors.dart';
import 'member_detail_view.dart';

class MembersView extends StatefulWidget {
  const MembersView({super.key});

  @override
  State<MembersView> createState() => _MembersViewState();
}

class _MembersViewState extends State<MembersView> {
  List<Club> _clubs = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadClubs();
  }

  Future<void> _loadClubs() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final clubsData = await ApiService.fetchClubs();
      final clubs = clubsData.map((json) => Club.fromJson(json)).toList();

      // Sort clubs alphabetically by title
      clubs.sort((a, b) => a.title.compareTo(b.title));

      setState(() {
        _clubs = clubs;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load member nations: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Member Nations',
          style: TextStyle(
            color: FITColors.primaryBlack,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: FITColors.accentYellow,
        elevation: 0,
        iconTheme: const IconThemeData(color: FITColors.primaryBlack),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: FITColors.primaryBlue,
        ),
      );
    }

    if (_error != null) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: FITColors.errorRed,
            ),
            const SizedBox(height: 16),
            Text(
              _error!,
              style: const TextStyle(
                fontSize: 16,
                color: FITColors.darkGrey,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadClubs,
              style: ElevatedButton.styleFrom(
                backgroundColor: FITColors.primaryBlue,
                foregroundColor: FITColors.white,
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_clubs.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.public_off,
              size: 64,
              color: FITColors.mediumGrey,
            ),
            SizedBox(height: 16),
            Text(
              'No member nations found',
              style: TextStyle(
                fontSize: 16,
                color: FITColors.darkGrey,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadClubs,
      color: FITColors.primaryBlue,
      child: GridView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16.0),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 1.2,
          crossAxisSpacing: 16.0,
          mainAxisSpacing: 16.0,
        ),
        itemCount: _clubs.length,
        itemBuilder: (context, index) {
          final club = _clubs[index];
          return _buildClubTile(club);
        },
      ),
    );
  }

  Widget _buildClubTile(Club club) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MemberDetailView(club: club),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Country flag using 4x3 aspect ratio
              Expanded(
                flex: 3,
                child: Container(
                  width: double.infinity,
                  constraints: const BoxConstraints(maxHeight: 60),
                  child: FlagService.getFlagWidget(
                        teamName: club.title,
                        clubAbbreviation: club.abbreviation,
                        size: 60.0,
                      ) ??
                      Container(
                        decoration: BoxDecoration(
                          color: FITColors.lightGrey,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: FITColors.outline,
                            width: 1,
                          ),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.flag,
                            color: FITColors.mediumGrey,
                            size: 32,
                          ),
                        ),
                      ),
                ),
              ),
              const SizedBox(height: 8),
              // Country name
              Expanded(
                flex: 1,
                child: Text(
                  club.title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: FITColors.primaryBlack,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
