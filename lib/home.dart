// home.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '/authorization.dart';
import '/developer/listDeveloperApplications.dart';
import '/user/listUserApplications.dart';
import '/db/dbMap.dart';
import '/readJsonFile.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
      ),
      body: Center(
        child: Column(
          children: [
            Container(
              child: ElevatedButton(
                onPressed: () async {
                  SharedPreferences prefs =
                      await SharedPreferences.getInstance();
                  prefs.remove('user_id');
                  prefs.remove('username');
                  prefs.remove('password');
                  prefs.remove('category_id');
                  prefs.remove('role_id');
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => LoginScreen()),
                  );
                },
                child: Text('Log Out'),
              ),
            ),
            Container(
              child: ElevatedButton(
                onPressed: () async {
                  Widget nextPage;
                  final role_id = await getFromJsonFile("role_id");

                  if (role_id == 'Developer' || 3 == 3) {
                    nextPage = DeveloperApplicationsPage();
                  } else if (role_id == 'User' || 3 == 3) {
                    nextPage = UserApplicationsPage();
                  } else {
                    nextPage = LoginScreen();
                  }

                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => nextPage,
                    ),
                  );
                },
                child: Text('List'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
