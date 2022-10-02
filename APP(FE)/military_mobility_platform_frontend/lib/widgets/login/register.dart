import 'package:flutter/material.dart';
import 'package:military_mobility_platform_frontend/model/user.dart';
import 'package:military_mobility_platform_frontend/service/api.dart';
import 'package:military_mobility_platform_frontend/widgets/login/components.dart';

class RegisterTab extends StatefulWidget {
  const RegisterTab({super.key});

  @override
  RegisterTabState createState() => RegisterTabState();

  void cancel() {}
}

class RegisterTabState extends State<RegisterTab> {
  static const availableRoles = ['탑승자', '수송업무 담당자', '운영자'];

  final _formKey = GlobalKey<FormState>();
  String id = "";
  String name = "";
  String email = "";
  String baseName = "";
  String passwd = "";
  String role = availableRoles[0];

  RegisterTabState();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("회원가입"),
        ),
        body: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 50.0, vertical: 20.0),
            child: Form(
                key: _formKey,
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildInputFields(context),
                      _buildRegisterButton(context),
                    ]))));
  }

  Widget _buildInputFields(BuildContext context) {
    return Column(children: [
      buildTextFormField(
          setter: (val) => id = val ?? "",
          labelText: '아이디',
          helperText: '아이디를 입력해주세요'),
      buildVerticalPadding(15.0),
      buildTextFormField(
          setter: (val) => name = val ?? "",
          labelText: '이름',
          helperText: '이름을 입력해주세요'),
      buildVerticalPadding(15.0),
      buildTextFormField(
          setter: (val) => email = val ?? "",
          labelText: '이메일',
          helperText: '이메일을 입력해주세요'),
      buildVerticalPadding(15.0),
      buildTextFormField(
          setter: (val) => baseName = val ?? "",
          labelText: '소속부대',
          helperText: '소속부대를 입력해주세요'),
      buildVerticalPadding(15.0),
      PasswordField(
        setter: (val) => passwd = val ?? "",
        labelText: '비밀번호',
        helperText: '비밀번호를 입력해주세요',
      ),
      buildVerticalPadding(15.0),
      _buildRoleDropDown(context),
    ]);
  }

  Widget _buildRoleDropDown(BuildContext context) {
    return DropdownButtonFormField(
        value: role,
        items: availableRoles
            .map((e) => DropdownMenuItem(value: e, child: Text(e)))
            .toList(),
        onChanged: (val) => role = val ?? availableRoles[0]);
  }

  Widget _buildRegisterButton(BuildContext context) {
    return ElevatedButton(
      onPressed: _register,
      child: const Text('회원가입'),
    );
  }

  void _register() {
    Future<bool> registerRequest() async {
      _formKey.currentState?.save();
      final response = await APIService.register(RegisterReqDTO(
          login_id: id,
          password: passwd,
          email: email,
          battalion_id: baseName));
      print(response);
      return response != null;
    }

    registerRequest().then((success) {
      if (success) {
        Navigator.pop(context);
      }
    });
  }
}