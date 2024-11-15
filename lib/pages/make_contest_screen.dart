import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider/provider.dart' as app_provider;

import '../providers/user_provider.dart' as user_provider;

import 'home_screen.dart';
import 'make_problem_screen.dart';

class MakeContestScreen extends StatefulWidget {
  const MakeContestScreen({super.key});

  @override
  State<MakeContestScreen> createState() => _MakeContestScreenState();
}

class _MakeContestScreenState extends State<MakeContestScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 215, 237, 255),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 113, 165, 207),
        title: const Text(
          "대회 개최",
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
                MaterialPageRoute(builder: (context) => const HomeScreen()),
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
      body: const MakeContestScreenView(),
    );
  }
}

class MakeContestScreenView extends StatefulWidget {
  const MakeContestScreenView({super.key});

  @override
  State<MakeContestScreenView> createState() => _MakeContestScreenViewState();
}

class _MakeContestScreenViewState extends State<MakeContestScreenView> {
  final TextEditingController idController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController password2Controller = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  @override
  void dispose() {
    idController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void _showPopup(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('알림'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('닫기'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _makeContest(BuildContext context, String userId) async {
    if (idController.text == "" || nameController.text == "") {
      print(1);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('본인 아이디와 대회 제목은 필수입니다.')),
      );
    } else if (passwordController.text != password2Controller.text) {
      print(2);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('비밀번호가 서로 다릅니다.')),
      );
    } else if (userId != idController.text) {
      print(3);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('본인 아이디를 사용해주세요.')),
      );
    } else {
      print(4);
      try {
        final SupabaseClient supabase = Supabase.instance.client;
        final response = await supabase.from('contests').insert({
          'contest_name': nameController.text,
          'contest_description': descriptionController.text,
          'user_id': idController.text,
          'contest_pw': passwordController.text,
        }).execute();

        if (response.error == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('대회를 만들었습니다!\n대회에 포함될 문제를 만들어주세요.')),
          );
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => MakeProblemScreen(
                contest: response.data[0],
              ),
            ),
          );
        } else {
          _showPopup(context, '대회를 만들지 못했습니다.\n\n중복된 대회 제목!');
        }
      } catch (e) {
        _showPopup(context, '대회를 만들지 못했습니다.\n\n서버 오류: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user =
        app_provider.Provider.of<user_provider.UserProvider>(context).user;
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Align(
        alignment: Alignment.center,
        child: SingleChildScrollView(
          child: Container(
            width: 300,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26, // 그림자 색상
                  blurRadius: 10.0, // 흐림 반경
                  spreadRadius: 2.0, // 확산 반경
                  offset: Offset(5.0, 5.0), // 그림자 오프셋 (x, y)
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(30.0),
              child: Column(
                children: [
                  const Text(
                    "대회 정보",
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w700,
                      color: Color.fromARGB(255, 119, 139, 228),
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  TextField(
                    controller: idController,
                    decoration: const InputDecoration(labelText: '본인 아이디'),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: '대회 제목'),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  TextField(
                    controller: passwordController,
                    decoration: const InputDecoration(labelText: '대회 비밀번호'),
                    obscureText: true,
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  TextField(
                    controller: password2Controller,
                    decoration: const InputDecoration(labelText: '비밀번호 확인'),
                    obscureText: true,
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  TextField(
                    controller: descriptionController,
                    decoration: const InputDecoration(labelText: '대회 설명'),
                  ),
                  const SizedBox(
                    height: 40,
                  ),
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
                        onPressed: () => _makeContest(context, user!.userId),
                        child: const Text('대회 개최'),
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
