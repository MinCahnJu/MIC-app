import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider/provider.dart' as app_provider;

import '../providers/user_provider.dart' as user_provider;

import 'profile_screen.dart';

class UserScreen extends StatefulWidget {
  const UserScreen({super.key});

  @override
  State<UserScreen> createState() => _UserScreenState();
}

class _UserScreenState extends State<UserScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 215, 237, 255),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 113, 165, 207),
        title: const Text(
          "회원 정보",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: Transform.scale(
          scale: 0.7,
          child: ElevatedButton(
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const ProfileScreen()),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromARGB(255, 113, 165, 207),
              elevation: 0,
              padding: EdgeInsets.zero,
              minimumSize: const Size(50, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
            child: const Icon(
              Icons.chevron_left_rounded,
              size: 50,
              color: Colors.white,
            ),
          ),
        ),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(10.0), // 아래쪽 왼쪽 모서리 둥글게
            bottomRight: Radius.circular(10.0), // 아래쪽 오른쪽 모서리 둥글게
          ),
        ),
      ),
      body: const UserListView(),
    );
  }
}

class UserListView extends StatefulWidget {
  const UserListView({super.key});

  @override
  State<UserListView> createState() => _UserListViewState();
}

class _UserListViewState extends State<UserListView> {
  final SupabaseClient supabase = Supabase.instance.client;
  final TextEditingController authorityController = TextEditingController();
  late Future<List<Map<String, dynamic>>> _users;
  late final List<int> _options = [0, 1, 2, 3, 4, 5];

  @override
  void initState() {
    super.initState();
    _users = _fetchUsers();
  }

  Future<void> updateData(int authority, String userId) async {
    final response = await Supabase.instance.client
        .from('users')
        .update({
          'authority': authority,
        })
        .eq('user_id', userId) // 수정할 레코드의 ID
        .execute();

    if (response.error == null) {
      print('업데이트 성공: ${response.data}');
    } else {
      print('업데이트 실패: ${response.error!.message}');
    }
  }

  Future<List<Map<String, dynamic>>> _fetchUsers() async {
    final response = await supabase
        .from('users')
        .select()
        .order('created_at', ascending: true)
        .execute();

    if (response.error == null) {
      return (response.data as List)
          .map((e) => e as Map<String, dynamic>)
          .toList();
    } else {
      throw Exception('Failed to load users: ${response.error!.message}');
    }
  }

  Future<void> _refreshUsers() async {
    setState(() {
      _users = _fetchUsers();
    });
  }

  @override
  Widget build(BuildContext context) {
    final user =
        app_provider.Provider.of<user_provider.UserProvider>(context).user;
    return Center(
      child: SizedBox(
        width: 1000,
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.only(top: 10.0),
              child: Text(
                "회원 목록",
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w600,
                  color: Colors.purple,
                ),
              ),
            ),
            if (user?.authority == "5")
              FutureBuilder<List<Map<String, dynamic>>>(
                future: _users,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('No contests found.'));
                  } else {
                    return Padding(
                      padding: const EdgeInsets.all(30.0),
                      child: Flexible(
                        child: RefreshIndicator(
                          onRefresh: _refreshUsers,
                          child: ListView.builder(
                            shrinkWrap: true,
                            itemCount: snapshot.data!.length,
                            itemBuilder: (context, index) {
                              final user = snapshot.data![index];
                              return Table(
                                border: TableBorder.all(color: Colors.black),
                                columnWidths: const {
                                  0: FlexColumnWidth(2),
                                  1: FlexColumnWidth(3),
                                  2: FlexColumnWidth(4),
                                  3: FlexColumnWidth(5),
                                  4: FlexColumnWidth(2),
                                },
                                children: [
                                  if (index == 0)
                                    const TableRow(
                                      children: [
                                        TableCell(
                                          child: Center(
                                            child: Padding(
                                              padding: EdgeInsets.all(8.0),
                                              child: Text("번호"),
                                            ),
                                          ),
                                        ),
                                        TableCell(
                                          child: Center(
                                            child: Padding(
                                              padding: EdgeInsets.all(8.0),
                                              child: Text("이름"),
                                            ),
                                          ),
                                        ),
                                        TableCell(
                                          child: Center(
                                            child: Padding(
                                              padding: EdgeInsets.all(8.0),
                                              child: Text("아이디"),
                                            ),
                                          ),
                                        ),
                                        TableCell(
                                          child: Center(
                                            child: Padding(
                                              padding: EdgeInsets.all(8.0),
                                              child: Text("전화번호"),
                                            ),
                                          ),
                                        ),
                                        TableCell(
                                          child: Center(
                                            child: Padding(
                                              padding: EdgeInsets.all(8.0),
                                              child: Text("권한"),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  TableRow(
                                    children: [
                                      TableCell(
                                        child: Center(
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Text((index + 1).toString()),
                                          ),
                                        ),
                                      ),
                                      TableCell(
                                        child: Center(
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Text(user["name"]),
                                          ),
                                        ),
                                      ),
                                      TableCell(
                                        child: Center(
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Text(user["user_id"]),
                                          ),
                                        ),
                                      ),
                                      TableCell(
                                        child: Center(
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Text(user["phone"]),
                                          ),
                                        ),
                                      ),
                                      TableCell(
                                        child: Center(
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 0,
                                            ),
                                            child: SizedBox(
                                              height: 40,
                                              child: DropdownButton<int>(
                                                isExpanded: true,
                                                value: user["authority"],
                                                hint: const Text(
                                                    'Select an option'),
                                                onChanged: (value) {
                                                  setState(() {
                                                    updateData(
                                                      value!,
                                                      user["user_id"],
                                                    );
                                                    user["authority"] = value;
                                                  });
                                                },
                                                items: _options
                                                    .map<DropdownMenuItem<int>>(
                                                        (int value) {
                                                  return DropdownMenuItem<int>(
                                                    value: value,
                                                    child:
                                                        Text(value.toString()),
                                                  );
                                                }).toList(),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                      ),
                    );
                  }
                },
              ),
          ],
        ),
      ),
    );
  }
}
