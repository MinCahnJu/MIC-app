import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 215, 237, 255),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 113, 165, 207),
        title: const Text(
          "MiC Register",
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
                MaterialPageRoute(builder: (context) => const LoginScreen()),
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
      body: const RegisterView(),
    );
  }
}

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  final SupabaseClient supabase = Supabase.instance.client;
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController idController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController password2Controller = TextEditingController();

  bool containsAlphabet(String input) {
    RegExp regex = RegExp(r'[a-zA-Z]');
    return regex.hasMatch(input);
  }

  bool containsNumber(String input) {
    RegExp regex = RegExp(r'[0-9]');
    return regex.hasMatch(input);
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

  void _signUp(BuildContext context) async {
    if (nameController.text == "" ||
        phoneController.text == "" ||
        idController.text == "" ||
        passwordController.text == "" ||
        password2Controller.text == "") {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('빈칸을 입력해주세요.')),
      );
    } else if (passwordController.text != password2Controller.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content:
                Text('비밀번호가 서로 다릅니다.\n비밀번호는 8자 이상이어야 하고,\n영문자, 숫자가 필수입니다.')),
      );
    } else if (passwordController.text.length < 8) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
                '비밀번호는 8자 이상이어야 합니다.\n\n비밀번호는 8자 이상이어야 하고,\n영문자, 숫자가 필수입니다.')),
      );
    } else if (!containsAlphabet(passwordController.text)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
                '비밀번호는 영문자를 포함해야 합니다.\n\n비밀번호는 8자 이상이어야 하고,\n영문자, 숫자가 필수입니다.')),
      );
    } else if (!containsNumber(passwordController.text)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
                '비밀번호는 숫자를 포함해야 합니다.\n\n비밀번호는 8자 이상이어야 하고,\n영문자, 숫자가 필수입니다.')),
      );
    } else {
      try {
        final response = await supabase.from('users').insert({
          'user_id': idController.text,
          'user_pw': passwordController.text,
          'name': nameController.text,
          'phone': phoneController.text,
          'authority': 0,
        }).execute();

        if (response.error == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('회원 가입에 성공했습니다!\n로그인 해주세요.')),
          );
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const LoginScreen()),
          );
        } else {
          _showPopup(context, '회원 가입에 실패했습니다.\n\n중복된 아이디!');
        }
      } catch (e) {
        _showPopup(context, '회원 가입에 실패했습니다.\n\n서버 오류: $e');
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
              padding: const EdgeInsets.all(25.0),
              child: Center(
                child: Column(
                  children: [
                    const Text(
                      "정보 입력",
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w700,
                        color: Color.fromARGB(255, 119, 139, 228),
                        fontStyle: FontStyle.normal,
                      ),
                    ),
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(labelText: '이름'),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    TextField(
                      controller: phoneController,
                      decoration: const InputDecoration(labelText: '전화번호'),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    TextField(
                      controller: idController,
                      decoration: const InputDecoration(labelText: '아이디'),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    TextField(
                      controller: passwordController,
                      decoration: const InputDecoration(labelText: '비밀번호'),
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
                      height: 30,
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
                      onPressed: () => _signUp(context),
                      child: const Text('회원가입'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
