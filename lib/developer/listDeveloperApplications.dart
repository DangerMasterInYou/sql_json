import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_try_with_api/home.dart';
import '/db/dbMap.dart';
import '/readJsonFile.dart';
import '/developer/editApplication.dart';
import '/developer/takeApplication.dart';

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
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => HomePage()),
            );
          },
        ),
        title: Text('Заявки категории'),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'Все'),
            Tab(text: 'Мои'),
            Tab(text: 'Не принятые'),
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
                  final statuse = statuses[application["statuseId"]];
                  return application["categoryId"] == _categoryID &&
                      statuse == "Создано" &&
                      application["developerId"] == null;
                }),
              ],
            )
          : CircularProgressIndicator(), // Показываем индикатор загрузки, пока данные загружаются
    );
  }

  Widget _buildApplicationsList(
      bool Function(int, Map<String, dynamic>) filterCondition) {
    final appKeys = _getApplicationsForDeveloper(filterCondition);

    return ListView.builder(
      itemCount: appKeys.length,
      itemBuilder: (context, index) {
        final applicationId = appKeys[index];
        return _ApplicationTile(
          applicationId: applicationId,
          application: applications[applicationId]!,
        );
      },
    );
  }

  List<int> _getApplicationsForDeveloper(
      bool Function(int, Map<String, dynamic>) filterCondition) {
    final List<int> appKeys = [];
    applications.entries.toList().forEach((entry) {
      if (filterCondition(entry.key, entry.value)) {
        appKeys.add(entry.key);
      }
    });
    return appKeys;
  }
}

class _ApplicationTile extends StatelessWidget {
  final int applicationId;
  final Map<String, dynamic> application;

  const _ApplicationTile(
      {required this.applicationId, required this.application});

  @override
  Widget build(BuildContext context) {
    final name = application['name'];
    final statuseId = application['statuseId'].toString();
    final statuse = statuses[int.parse(statuseId)].toString();

    return ListTile(
      title: Text(name),
      subtitle: Text(statuse),
      onTap: () {
        if (statuse == "Создано") {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  takeApplicationPage(applicationId: applicationId),
            ),
          );
        } else if (statuse != 'Выполнено' || statuse != 'Завершено') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  editApplicationPage(applicationId: applicationId),
            ),
          );
        }
      },
    );
  }
}
