import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import '/db/dbMap.dart';
import '/readJsonFile.dart';
import '/user/createApplication.dart';

class UserApplicationsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final user_id = getFromJsonFile("user_id");

    return Scaffold(
      appBar: AppBar(
        title: Text('Заявки'),
      ),
      body: _buildApplicationsList(user_id),
    );
  }

  Widget _buildApplicationsList(dynamic user_id) {
    final applications = _getApplicationsForUser(user_id);

    return ListView.builder(
        itemCount: applications.length,
        itemBuilder: (context, index) {
          final app = applications[index];

          return _ApplicationTile(
            application: app,
          );
        });
  }

  List<Map<String, dynamic>> _getApplicationsForUser(dynamic user_id) {
    final List<Map<String, dynamic>> userApplications = [];
    applications.forEach((int key, Map<String, dynamic> application) {
      if (application["senderId"] == user_id || 1 == 1) {
        userApplications.add(application);
      }
    });
    return userApplications;
  }
}

class _ApplicationTile extends StatelessWidget {
  final Map<String, dynamic> application;

  const _ApplicationTile({required this.application});

  @override
  Widget build(BuildContext context) {
    final name = application['name'];
    final statusId = application['statusId'].toString();

    return ListTile(
      title: Text(name),
      subtitle: Text(statuses[statusId].toString()),
      onTap: () {},
    );
  }
}
