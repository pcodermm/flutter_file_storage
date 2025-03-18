import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MyHome(),
    );
  }
}

class MyHome extends StatefulWidget {
  MyHome({super.key});
  @override
  State<MyHome> createState() => _MyHomeState();
}

class _MyHomeState extends State<MyHome> {
  final TextEditingController _dataController = TextEditingController();
  final TextEditingController _fileNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  void _loadDirectory(String fileName) async {
    Directory directory = await getPath();
    String path = "${directory.path}/$fileName";
    _readFile(path);
  }

  void _readFile(String filePath) async {
    File file = File(filePath);
    String data = await file.readAsString();
    _dataController.text = data;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Storage Lesson'),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.create_new_folder),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.insert_drive_file),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            TextField(
              controller: _dataController,
              minLines: 3,
              maxLines: 10,
              decoration:
                  const InputDecoration(label: Text('Enter something here...')),
            ),
            TextField(
              controller: _fileNameController,
              decoration:
                  const InputDecoration(label: Text('Enter file name...')),
            ),
            const SizedBox(height: 10),
            FilledButton(
              onPressed: () async {
                Directory appDirectory = await getPath();
                String filPath =
                    "${appDirectory.path}/${_fileNameController.text}";
                File file = File(filPath);
                await file.writeAsString(_dataController.text);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Saved Successfully'),
                  ),
                );
              },
              child: const Text('save'),
            ),
          ],
        ),
      ),
    );
  }
}

Future<Directory> getPath() async {
  return await getApplicationDocumentsDirectory();
}
