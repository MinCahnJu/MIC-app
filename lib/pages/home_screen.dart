import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider/provider.dart' as app_provider;

import '../providers/user_provider.dart' as user_provider;

import 'contest_screen.dart';
import 'login_screen.dart';
import 'make_contest_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final user =
        app_provider.Provider.of<user_provider.UserProvider>(context).user;
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 215, 237, 255),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 113, 165, 207),
        title: const Text(
          "MiC",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          if (user?.userId == null)
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: const Size(50, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              child: const Icon(Icons.login),
            ),
          if (user?.userId != null)
            ElevatedButton(
              onPressed: () {
                final userProvider =
                    app_provider.Provider.of<user_provider.UserProvider>(
                        context,
                        listen: false);
                userProvider.clearUser();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const HomeScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(0),
                minimumSize: const Size(50, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              child: const Icon(Icons.logout),
            ),
          const SizedBox(width: 5),
          if (user?.userId != null)
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const ProfileScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                minimumSize: const Size(50, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              child: Text(
                user!.name,
                style: const TextStyle(fontSize: 20),
              ),
            ),
          const SizedBox(width: 5),
        ],
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(10.0), // 아래쪽 왼쪽 모서리 둥글게
            bottomRight: Radius.circular(10.0), // 아래쪽 오른쪽 모서리 둥글게
          ),
        ),
      ),
      body: const ContestListView(),
    );
  }
}

class ContestListView extends StatefulWidget {
  const ContestListView({super.key});

  @override
  State<ContestListView> createState() => _ContestListViewState();
}

class _ContestListViewState extends State<ContestListView> {
  final SupabaseClient supabase = Supabase.instance.client;
  late Future<List<Map<String, dynamic>>> _contests;

  @override
  void initState() {
    super.initState();
    _contests = _fetchCompetitions();
  }

  Future<List<Map<String, dynamic>>> _fetchCompetitions() async {
    final response = await supabase
        .from('contests')
        .select()
        .order('created_at', ascending: true)
        .execute();

    if (response.error == null) {
      return (response.data as List)
          .map((e) => e as Map<String, dynamic>)
          .toList();
    } else {
      throw Exception('Failed to load contests: ${response.error!.message}');
    }
  }

  Future<void> _refreshCompetitions() async {
    setState(() {
      _contests = _fetchCompetitions();
    });
  }

  @override
  Widget build(BuildContext context) {
    final user =
        app_provider.Provider.of<user_provider.UserProvider>(context).user;
    return Center(
      child: SizedBox(
        width: 600,
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.only(top: 10.0),
              child: Text(
                "대회 목록",
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w600,
                  color: Colors.purple,
                ),
              ),
            ),
            FutureBuilder<List<Map<String, dynamic>>>(
              future: _contests,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No contests found.'));
                } else {
                  return Flexible(
                    child: RefreshIndicator(
                      onRefresh: _refreshCompetitions,
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: snapshot.data!.length,
                        itemBuilder: (context, index) {
                          final contest = snapshot.data![index];
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 30,
                              vertical: 10,
                            ),
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        ContestScreen(contest: contest),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 15),
                                backgroundColor:
                                    const Color.fromARGB(255, 243, 237, 180),
                              ),
                              child: Text(
                                contest['contest_name'],
                                style: const TextStyle(fontSize: 23),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  );
                }
              },
            ),
            if (user?.authority == "3" ||
                user?.authority == "4" ||
                user?.authority == "5")
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 30,
                      vertical: 10,
                    ),
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const MakeContestScreen(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        padding: const EdgeInsets.symmetric(
                          vertical: 15,
                          horizontal: 10,
                        ),
                        backgroundColor:
                            const Color.fromARGB(255, 243, 237, 180),
                      ),
                      child: const Text(
                        '대회 개최',
                        style: TextStyle(fontSize: 15),
                      ),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
