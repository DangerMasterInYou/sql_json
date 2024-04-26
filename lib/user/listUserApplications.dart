import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import '/db/db.dart';
import '/readJsonFile.dart';
import '/home.dart';
import 'package:mysql1/mysql1.dart';

class UserApplicationsPage extends StatefulWidget {
  @override
  _UserApplicationsState createState() => _UserApplicationsState();
}

class _UserApplicationsState extends State with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () async {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => HomePage()),
                );
              },
            );
          },
        ),
        title: Text('Заявки'),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'Новые'),
            Tab(text: 'Мои'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          NewApplicationsTab(),
          MyApplicationsTab(),
        ],
      ),
    );
  }
}

class NewApplicationsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: fetchNewApplications(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Ошибка загрузки данных'));
        } else {
          final applications = snapshot.data!;
          return ListView.builder(
            itemCount: applications.length,
            itemBuilder: (context, index) {
              final application = applications[index];
              return ListTile(
                title: Text(application['name']),
                subtitle: Text(application['status']),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditApplicationsPage(
                          applicationId: application['id']),
                    ),
                  );
                },
              );
            },
          );
        }
      },
    );
  }
}

class MyApplicationsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: fetchMyApplications(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Ошибка загрузки данных'));
        } else {
          final applications = snapshot.data!;
          return ListView.builder(
            itemCount: applications.length,
            itemBuilder: (context, index) {
              final application = applications[index];
              return ListTile(
                title: Text(application['name']),
                subtitle: Text(application['status']),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditApplicationsPage(
                          applicationId: application['id']),
                    ),
                  );
                },
              );
            },
          );
        }
      },
    );
  }
}

Future<List<Map<String, dynamic>>> fetchNewApplications() async {
  final conn = await Database().connectToDatabase();
  dynamic user_id = getFromJsonFile("user_id");

  final results = await conn.query('''
    SELECT id, name, status
    FROM Applications
    WHERE sender_id = ?;
  ''', [user_id]);

  await conn.close();

  return results.toList();
}

Future<List<Map<String, dynamic>>> fetchMyApplications() async {
  final conn = await Database().connectToDatabase();
  dynamic user_id = getFromJsonFile("user_id");
  dynamic role_id = getFromJsonFile("role_id");

  final results = await conn.query('''
    SELECT id, name, status
    FROM Applications
    WHERE role_id = ? AND sender_id = ?;
  ''', [role_id, user_id]);

  await conn.close();

  //return results.toList();
  return results.toList();
}

class EditApplicationsPage extends StatelessWidget {
  final int applicationId;

  const EditApplicationsPage({required this.applicationId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Редактировать Заявку'),
      ),
      body: Center(
        child: Text('Редактирование заявки с id: $applicationId'),
      ),
    );
  }
}
