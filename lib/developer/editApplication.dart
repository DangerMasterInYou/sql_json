import 'dart:convert';
import 'dart:ffi';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '/db/dbMap.dart';
import '/readJsonFile.dart';
import '/developer/listDeveloperApplications.dart';
import 'package:path_provider/path_provider.dart';

class editApplicationPage extends StatefulWidget {
  final int applicationId;

  editApplicationPage({required this.applicationId});

  @override
  _editApplicationPageState createState() => _editApplicationPageState();
}

class _editApplicationPageState extends State<editApplicationPage> {
  late TextEditingController _idController;
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _developerController;
  late TextEditingController _senderController;
  late TextEditingController _categoryController;
  late TextEditingController _locationController;
  late TextEditingController _statuseController;
  late TextEditingController _pathToPhotoController;

  bool _isImagePickerActive = false; // Проверка активности пикера изображений

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
  }

  Widget photoWidget() {
    final double screenWidth = MediaQuery.of(context).size.width;
    if (_pathToPhotoController.text.isNotEmpty) {
      return GestureDetector(
        onTap: _changePhoto,
        child: Container(
          width: screenWidth,
          height: screenWidth,
          child: Image.file(
            File(_pathToPhotoController
                .text), // Используйте File для загрузки изображения с пути
            fit: BoxFit.cover,
            errorBuilder:
                (BuildContext context, Object error, StackTrace? stackTrace) {
              print(
                  'Error loading image: $error'); // Выводим ошибку в консоль для дальнейшего анализа
              return Center(
                child: Icon(Icons.error, size: screenWidth),
              );
            },
          ),
        ),
      );
    } else {
      return GestureDetector(
        onTap: _changePhoto,
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
                controller: _senderController,
                readOnly: true,
                decoration: InputDecoration(labelText: 'Отправитель'),
              ),
              TextField(
                controller: _developerController,
                readOnly: true,
                decoration: InputDecoration(labelText: 'Исполнитель'),
              ),
              TextField(
                controller: _categoryController,
                readOnly: true,
                decoration: InputDecoration(labelText: 'Категория'),
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
                controller: _descriptionController,
                decoration: InputDecoration(labelText: 'Description'),
              ),
              photoWidget(),
              SizedBox(height: 24.0),
              ElevatedButton(
                onPressed: _completeChanges,
                child: Text('Завершить'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _completeChanges() async {
    applications[widget.applicationId]?['description'] =
        _descriptionController.text;
    applications[widget.applicationId]?['pathToPhoto'] =
        _pathToPhotoController.text;

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

  void _changePhoto() async {
    if (_isImagePickerActive)
      return; // Проверка на активность пикера изображений
    _isImagePickerActive = true; // Установка флага активности

    final ImagePicker _picker = ImagePicker();
    final XFile? pickedFile =
        await _picker.pickImage(source: ImageSource.gallery);

    _isImagePickerActive = false; // Сброс флага активности

    if (pickedFile != null) {
      setState(() {
        _pathToPhotoController.text = pickedFile.path;
      });
    }
  }
}
