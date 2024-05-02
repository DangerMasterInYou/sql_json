import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import '/db/dbMap.dart';
import '/readJsonFile.dart';
import '/developer/editApplication.dart';

class DeveloperApplicationsPage extends StatefulWidget {
  @override
  _DeveloperApplicationsPageState createState() =>
      _DeveloperApplicationsPageState();
}

class _DeveloperApplicationsPageState extends State<DeveloperApplicationsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int? _categoryID;
  int? _userID;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadData();
  }

  Future<void> _loadData() async {
    _categoryID = int.parse((await getFromJsonFile("category_id")).toString());
    _userID = int.parse((await getFromJsonFile("user_id")).toString());
    setState(() {}); // Обновляем состояние после загрузки данных
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Заявки категории'),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'Все'),
            Tab(text: 'Мои'),
            Tab(text: 'Новые'),
          ],
        ),
      ),
      body: _categoryID != null && _userID != null
          ? TabBarView(
              controller: _tabController,
              children: [
                _buildApplicationsList(
                    (int key, Map<String, dynamic> application) {
                  return application["categoryId"] == _categoryID;
                }),
                _buildApplicationsList(
                    (int key, Map<String, dynamic> application) {
                  return application["categoryId"] == _categoryID &&
                      application["developerId"] == _userID;
                }),
                _buildApplicationsList(
                    (int key, Map<String, dynamic> application) {
                  return application["categoryId"] == _categoryID &&
                      application["developerId"] == null;
                }),
              ],
            )
          : CircularProgressIndicator(), // Показываем индикатор загрузки, пока данные загружаются
    );
  }

  Widget _buildApplicationsList(
      bool Function(int, Map<String, dynamic>) filterCondition) {
    final applications = _getApplicationsForDeveloper(filterCondition);

    return ListView.builder(
      itemCount: applications.length,
      itemBuilder: (context, index) {
        final app = applications[index];

        return _ApplicationTile(
          application: app,
        );
      },
    );
  }

  List<Map<String, dynamic>> _getApplicationsForDeveloper(
      bool Function(int, Map<String, dynamic>) filterCondition) {
    final List<Map<String, dynamic>> developerApplications = [];
    applications.forEach((int key, Map<String, dynamic> application) {
      if (filterCondition(key, application)) {
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
