import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import '/db/dbMap.dart';
import '/readJsonFile.dart';
import '/developer/listDeveloperApplications.dart';
import 'package:path_provider/path_provider.dart';

class takeApplicationPage extends StatefulWidget {
  final String applicationId;

  takeApplicationPage({required this.applicationId});

  @override
  _takeApplicationPageState createState() => _takeApplicationPageState();
}

class _takeApplicationPageState extends State<takeApplicationPage> {
  late TextEditingController _idController;
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _developerController;
  late TextEditingController _senderController;
  late TextEditingController _categoryController;
  late TextEditingController _locationController;
  late TextEditingController _statuseController;
  late TextEditingController _pathToPhotoController;
  late String _selectedCategory;

  @override
  void initState() {
    super.initState();

    final application = applications[widget.applicationId];

    _idController = TextEditingController(
        text: ((widget.applicationId).toString() ?? '') as String?);
    _nameController =
        TextEditingController(text: (application?['name'] ?? '') as String?);
    _descriptionController = TextEditingController(
        text: (application?['description'] ?? '') as String?);
    _developerController = TextEditingController(
        text: (users[application?['developerId']]?['login'] ?? '') as String?);
    _senderController = TextEditingController(
        text: (users[application?['senderId']]?['login'] ?? '') as String?);
    _categoryController = TextEditingController(
        text: (categories[application?['categoryId']] ?? '') as String?);
    _locationController = TextEditingController(
        text:
            ("${corpuses[application?['corpus']] ?? '?'} / ${application?['cabinet'] ?? '?'}"));
    _statuseController = TextEditingController(
        text: (statuses[application?['statuseId']] ?? '') as String?);
    _pathToPhotoController = TextEditingController(
        text: (application?['pathToPhoto'] ?? '') as String?);
    _selectedCategory =
        categories[application?['categoryId']] ?? categories.keys.first;
  }

  Widget photoWidget() {
    final double screenWidth = MediaQuery.of(context).size.width;
    if (_pathToPhotoController.text.isNotEmpty) {
      return GestureDetector(
        child: Container(
          width: screenWidth,
          height: screenWidth,
          child: Image.file(
            File(_pathToPhotoController.text),
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Center(
                child: Icon(Icons.error, size: screenWidth),
              );
            },
          ),
        ),
      );
    } else {
      return GestureDetector(
        child: Container(
          width: screenWidth,
          height: screenWidth,
          child: Center(
            child: Icon(
              Icons.photo,
              size: screenWidth,
            ),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => DeveloperApplicationsPage(),
              ),
            );
          },
        ),
        title: Text(_idController.text),
      ),
      body: SingleChildScrollView(
        // Обернуть Column в SingleChildScrollView
        child: Padding(
          padding: const EdgeInsets.all(14.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _nameController,
                readOnly: true,
                decoration: InputDecoration(labelText: 'Name'),
              ),
              SizedBox(height: 12.0),
              TextField(
                controller: _descriptionController,
                readOnly: true,
                decoration: InputDecoration(labelText: 'Description'),
              ),
              TextField(
                controller: _senderController,
                readOnly: true,
                decoration: InputDecoration(labelText: 'Отправитель'),
              ),
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                onChanged: (newValue) {
                  setState(() {
                    _selectedCategory = newValue ?? '';
                  });
                },
                items: categories.entries.map((entry) {
                  return DropdownMenuItem<String>(
                    value: entry.value,
                    child: Text(entry.value),
                  );
                }).toList(),
                decoration: InputDecoration(
                  labelText: 'Категория',
                ),
              ),
              TextField(
                controller: _locationController,
                readOnly: true,
                decoration: InputDecoration(labelText: 'Место:'),
              ),
              TextField(
                controller: _statuseController,
                readOnly: true,
                decoration: InputDecoration(labelText: 'Статус'),
              ),
              TextField(
                controller: _developerController,
                readOnly: true,
                decoration: InputDecoration(labelText: 'Исполнитель'),
              ),
              photoWidget(),
              ElevatedButton(
                onPressed: _saveChanges,
                child: Text('Принять'),
              ),
              ElevatedButton(
                onPressed: _saveChanges,
                child: Text('Перенаправить'),
              ),
              SizedBox(height: 24.0),
              ElevatedButton(
                onPressed: _saveChanges,
                child: Text('Отклонить'),
              ),
              SizedBox(height: 24.0),
            ],
          ),
        ),
      ),
    );
  }

  void _saveChanges() async {
    final String name = _nameController.text;
    final String description = _descriptionController.text;

    applications[widget.applicationId]?['name'] = name;
    applications[widget.applicationId]?['description'] = description;

    await _saveDbMap();

    Navigator.pop(context);
  }

  Future<void> _saveDbMap() async {
    final Directory directory = await getApplicationDocumentsDirectory();
    final String path = directory.path + '/dbMap.dart';

    final String dbMapAsString = '''
      var corpuses = ${jsonEncode(corpuses)};
      var statuses = ${jsonEncode(statuses)};
      var roles = ${jsonEncode(roles)};
      var categories = ${jsonEncode(categories)};
      var users = ${jsonEncode(users)};
      var applications = ${jsonEncode(applications)};
    ''';

    final File file = File(path);
    await file.writeAsString(dbMapAsString);
  }
}
