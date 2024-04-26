//authorization.dart
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import '/db/db.dart';
import '/message.dart';

class LoginScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
      ),
      body: LoginForm(),
    );
  }
}

class LoginForm extends StatefulWidget {
  @override
  _LoginFormState createState() => _LoginFormState();
}

class _LoginFormState extends State {
  final TextEditingController _loginController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<void> _login() async {
    final String login = _loginController.text;
    final String password = _passwordController.text;

    final conn = await Database().connectToDatabase();

    final results = await conn.query(
        'SELECT * FROM Users WHERE login = ? AND password = ?',
        [login, password]);
    if (results.isNotEmpty) {
      final row = results.first;
      final int userId = row['id'];
      final int roleId = row['role_id'];
      final int categoryId = row['category_id'];

      // Создание JSON файла при успешной авторизации
      final Map<String, dynamic> user = {
        'user_id': userId,
        'username': login,
        'password': password,
        'role_id': roleId,
        'category_id': categoryId,
      };
      final String jsonString = jsonEncode(user);

      // Получение директории документов
      final Directory directory = await getApplicationDocumentsDirectory();
      final String path = directory.path + '/user_data.json';

      // Запись данных в файл
      final File file = File(path);
      await file.writeAsString(jsonString);

      // Переход на следующий экран или выполнение других действий
    } else {
      showAlertDialog(context, "Hello");
    }

    await conn.close();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            controller: _loginController,
            decoration: InputDecoration(
              labelText: 'Login',
            ),
          ),
          SizedBox(height: 12.0),
          TextFormField(
            controller: _passwordController,
            obscureText: true,
            decoration: InputDecoration(
              labelText: 'Password',
            ),
          ),
          SizedBox(height: 24.0),
          ElevatedButton(
            onPressed: _login,
            child: Text('Вход'),
          ),
        ],
      ),
    );
  }
}
