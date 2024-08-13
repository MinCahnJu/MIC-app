import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'home_screen.dart';

class MakeProblemScreen extends StatefulWidget {
  final Map<String, dynamic> contest;

  const MakeProblemScreen({super.key, required this.contest});

  @override
  State<MakeProblemScreen> createState() => _MakeProblemScreenState();
}

class _MakeProblemScreenState extends State<MakeProblemScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 215, 237, 255),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 113, 165, 207),
        title: const Text(
          "문제 만들기",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(10.0), // 아래쪽 왼쪽 모서리 둥글게
            bottomRight: Radius.circular(10.0), // 아래쪽 오른쪽 모서리 둥글게
          ),
        ),
      ),
      body: MakeProblemView(
        contest: widget.contest,
      ),
    );
  }
}

class MakeProblemView extends StatefulWidget {
  final Map<String, dynamic> contest;

  const MakeProblemView({super.key, required this.contest});

  @override
  State<MakeProblemView> createState() => _MakeProblemViewState();
}

class _MakeProblemViewState extends State<MakeProblemView> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController inputDescriptionController =
      TextEditingController();
  final TextEditingController outputDescriptionController =
      TextEditingController();
  final TextEditingController exampleIntputController = TextEditingController();
  final TextEditingController exampleOutputController = TextEditingController();

  @override
  void dispose() {
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

  Future<void> _makeContest(BuildContext context, int con) async {
    if (nameController.text == "" ||
        inputDescriptionController.text == "" ||
        outputDescriptionController.text == "" ||
        exampleIntputController.text == "" ||
        exampleOutputController.text == "") {
      if (con == 0) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('빈칸을 채워주세요.')),
        );
      }
    } else {
      try {
        final SupabaseClient supabase = Supabase.instance.client;
        final response = await supabase.from('problems').insert({
          'contest_name': widget.contest["contest_name"],
          'problem_name': nameController.text,
          'problem_description': descriptionController.text,
          'problem_input_description': inputDescriptionController.text,
          'problem_output_description': outputDescriptionController.text,
          'problem_example_input': exampleIntputController.text,
          'problem_example_output': exampleOutputController.text,
        }).execute();

        if (response.error == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('대회를 만들었습니다!\n대회에 포함될 문제를 만들어주세요.')),
          );
          if (con == 1) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => MakeProblemScreen(
                  contest: widget.contest,
                ),
              ),
            );
          } else {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const HomeScreen()),
            );
          }
        } else {
          _showPopup(
              context, '대회를 만들지 못했습니다.\n\n중복된 대회 제목!\n\n${response.error}');
        }
      } catch (e) {
        _showPopup(context, '대회를 만들지 못했습니다.\n\n서버 오류: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
                    controller: nameController,
                    decoration: const InputDecoration(labelText: '문제 제목'),
                    keyboardType: TextInputType.multiline,
                    maxLines: null,
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  TextField(
                    controller: descriptionController,
                    decoration: const InputDecoration(labelText: '문제 설명'),
                    keyboardType: TextInputType.multiline,
                    maxLines: null,
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  TextField(
                    controller: inputDescriptionController,
                    decoration: const InputDecoration(labelText: '입력에 대한 설명'),
                    keyboardType: TextInputType.multiline,
                    maxLines: null,
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  TextField(
                    controller: outputDescriptionController,
                    decoration: const InputDecoration(labelText: '출력에 대한 설명'),
                    keyboardType: TextInputType.multiline,
                    maxLines: null,
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  TextField(
                    controller: exampleIntputController,
                    decoration: const InputDecoration(labelText: '입력에 대한 예제'),
                    keyboardType: TextInputType.multiline,
                    maxLines: null,
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  TextField(
                    controller: exampleOutputController,
                    decoration: const InputDecoration(labelText: '출력에 대한 예제'),
                    keyboardType: TextInputType.multiline,
                    maxLines: null,
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
                        onPressed: () => _makeContest(context, 0),
                        child: const Text('대회 완성'),
                      ),
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
                        onPressed: () => _makeContest(context, 1),
                        child: const Text('문제 추가'),
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
