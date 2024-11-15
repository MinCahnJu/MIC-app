import 'package:flutter/material.dart';
import 'package:provider/provider.dart' as app_provider;
import 'package:supabase_flutter/supabase_flutter.dart';

import '../providers/user_provider.dart' as user_provider;

import 'contest_screen.dart';
import 'home_screen.dart';
import 'login_screen.dart';
import 'profile_screen.dart';

class ProblemScreen extends StatefulWidget {
  final Map<String, dynamic> problem;
  final Map<String, dynamic> contest;

  const ProblemScreen(
      {super.key, required this.problem, required this.contest});

  @override
  State<ProblemScreen> createState() => _ProblemScreenState();
}

class _ProblemScreenState extends State<ProblemScreen> {
  @override
  Widget build(BuildContext context) {
    final user =
        app_provider.Provider.of<user_provider.UserProvider>(context).user;

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 215, 237, 255),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 113, 165, 207),
        title: Text(
          widget.problem["problem_name"],
          style: const TextStyle(
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
        leading: Transform.scale(
          scale: 0.7,
          child: ElevatedButton(
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        ContestScreen(contest: widget.contest)),
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
      body: ProblemView(
        problem: widget.problem,
        contest: widget.contest,
      ),
    );
  }
}

class ProblemView extends StatefulWidget {
  final Map<String, dynamic> problem;
  final Map<String, dynamic> contest;

  const ProblemView({super.key, required this.problem, required this.contest});

  @override
  State<ProblemView> createState() => _ProblemViewState();
}

class _ProblemViewState extends State<ProblemView> {
  final SupabaseClient supabase = Supabase.instance.client;
  final TextEditingController codeController = TextEditingController();
  late String _selectedLanguage = "Python";
  late final List<String> _options = [
    'Python',
    'C',
    'JAVA',
  ];

  void _showDeletePopup(BuildContext context, String problemName) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('알림'),
          content: const Text("정말 문제를 삭제 하시겠습니까?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('취소'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _deleteProblem(problemName);
              },
              child: const Text('삭제'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteProblem(String problemName) async {
    final response = await supabase
        .from('problems')
        .delete()
        .eq('problem_name', problemName)
        .execute();

    if (response.error == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('문제 삭제를 완료했습니다.')),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => ContestScreen(contest: widget.contest)),
      );
      return;
    } else {
      throw Exception('Failed to load problems: ${response.error!.message}');
    }
  }

  @override
  Widget build(BuildContext context) {
    final user =
        app_provider.Provider.of<user_provider.UserProvider>(context).user;

    return SingleChildScrollView(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(30.0),
          child: Container(
            width: 600,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26, // 그림자 색상
                  blurRadius: 10.0, // 흐림 반경
                  spreadRadius: 2.0, // 확산 반경
                  offset: Offset(5.0, 5.0), // 그림자 오프셋 (x, y)
                )
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  Text(
                    widget.problem["problem_name"].toString(),
                    style: const TextStyle(fontSize: 40, color: Colors.purple),
                  ),
                  if (user?.userId == widget.contest["user_id"] ||
                      user?.authority == "5")
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 0,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                          ),
                          onPressed: () {},
                          child: const Text('편집'),
                        ),
                        const SizedBox(width: 50),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 0,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                          ),
                          onPressed: () => _showDeletePopup(
                            context,
                            widget.problem["problem_name"],
                          ),
                          child: const Text('삭제'),
                        ),
                      ],
                    ),
                  const SizedBox(height: 10),
                  const Row(
                    children: [
                      Text("문제 설명"),
                    ],
                  ),
                  Container(
                    width: 560,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      child: Text(
                        widget.problem["problem_description"].toString(),
                        style: const TextStyle(fontSize: 15),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Flexible(
                        flex: 1,
                        child: Column(
                          children: [
                            const Row(
                              children: [
                                Text("입력 설명"),
                              ],
                            ),
                            Container(
                              width: 270,
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.black),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 5,
                                ),
                                child: Text(
                                  widget.problem["problem_input_description"]
                                      .toString(),
                                  style: const TextStyle(fontSize: 15),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 20),
                      Flexible(
                        flex: 1,
                        child: Column(
                          children: [
                            const Row(
                              children: [
                                Text("출력 설명"),
                              ],
                            ),
                            Container(
                              width: 270,
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.black),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 5,
                                ),
                                child: Text(
                                  widget.problem["problem_output_description"]
                                      .toString(),
                                  style: const TextStyle(fontSize: 15),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Flexible(
                        flex: 1,
                        child: Column(
                          children: [
                            const Row(
                              children: [
                                Text("입력 예제"),
                              ],
                            ),
                            Container(
                              width: 270,
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.black),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 5,
                                ),
                                child: Text(
                                  widget.problem["problem_example_input"]
                                      .toString(),
                                  style: const TextStyle(fontSize: 15),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 20),
                      Flexible(
                        flex: 1,
                        child: Column(
                          children: [
                            const Row(
                              children: [
                                Text("출력 예제"),
                              ],
                            ),
                            Container(
                              width: 270,
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.black),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 5,
                                ),
                                child: Text(
                                  widget.problem["problem_example_output"]
                                      .toString(),
                                  style: const TextStyle(fontSize: 15),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("답안"),
                      DropdownButton<String>(
                        value: _selectedLanguage,
                        hint: const Text('Select an option'),
                        onChanged: (value) {
                          setState(() {
                            _selectedLanguage = value!;
                          });
                        },
                        items: _options
                            .map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                  Container(
                    height: 290,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Expanded(
                      child: SingleChildScrollView(
                        child: TextField(
                          controller: codeController,
                          keyboardType: TextInputType.multiline,
                          maxLines: null,
                          minLines: 11,
                          decoration: const InputDecoration(
                            hintText: 'Enter your code here...',
                            border:
                                OutlineInputBorder(borderSide: BorderSide.none),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 0,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(10.0), // 모서리 둥글게 설정
                          ),
                        ),
                        onPressed: () {},
                        child: const Text('제출'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
