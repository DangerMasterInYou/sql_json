import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import '/db/dbMap.dart';
import '/readJsonFile.dart';
import '/developer/editApplication.dart';

class DeveloperApplicationsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final category_id = getFromJsonFile("category_id");

    return Scaffold(
      appBar: AppBar(
        title: Text('Заявки категории'),
      ),
      body: _buildApplicationsList(category_id),
    );
  }

  Widget _buildApplicationsList(dynamic category_id) {
    final applications = _getApplicationsForDeveloper(category_id);

    return ListView.builder(
        itemCount: applications.length,
        itemBuilder: (context, index) {
          final app = applications[index];

          return _ApplicationTile(
            application: app,
          );
        });
  }

  List<Map<String, dynamic>> _getApplicationsForDeveloper(dynamic category_id) {
    final List<Map<String, dynamic>> developerApplications = [];
    applications.forEach((int key, Map<String, dynamic> application) {
      if (application["categoryId"] == category_id ||
          application["developerId"] == 3) {
        developerApplications.add(application);
      }
    });
    return developerApplications;
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
      subtitle: Text(statuses[int.parse(statusId)].toString()),
      onTap: () {},
    );
  }
}
