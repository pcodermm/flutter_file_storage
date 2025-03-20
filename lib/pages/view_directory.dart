import 'dart:io';
import 'package:flutter/material.dart';
import 'view_data.dart';

class ViewDirectory extends StatefulWidget {
  ViewDirectory({super.key, required this.directory, required this.folderName});
  Directory directory;
  String folderName;
  @override
  State<ViewDirectory> createState() => _ViewDirectoryState();
}

class _ViewDirectoryState extends State<ViewDirectory> {
  late List<FileSystemEntity> _entities = [];
  TextEditingController controller = TextEditingController();
  @override
  void initState() {
    super.initState();
    _loadDirectory();
  }

  void _loadDirectory() async {
    List<FileSystemEntity> listEntities = widget.directory.listSync();
    _entities = listEntities;
  }

  void _loadFile(String fileName, FileSystemEntity entity) async {
    String path = "${widget.directory.path}/$fileName";
    File file = File(path);
    String data = await file.readAsString();
    Navigator.push(context, MaterialPageRoute(builder: (builder) {
      return ViewData(
        fileName: fileName,
        data: data,
        entity: entity,
      );
    }));
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          leading: IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const Icon(Icons.arrow_back)),
          title: Text(widget.folderName),
          actions: [
            IconButton(
              onPressed: () async {
                bool? isCreated = await showDialog(
                    context: context,
                    builder: (builder) {
                      return AlertDialog(
                        title: const Text('Create New File'),
                        content: TextField(
                          controller: controller,
                          decoration:
                              const InputDecoration(label: Text('File Name')),
                        ),
                        actions: [
                          TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: const Text(
                                'Cancel',
                              )),
                          TextButton(
                              onPressed: () async {
                                Directory appDirectory = widget.directory;
                                String filPath =
                                    "${appDirectory.path}/${controller.text}";
                                print(filPath);
                                File file = File(filPath);
                                await file.create();
                                String message =
                                    "File Created : ${controller.text}";
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(message),
                                  ),
                                );
                                Navigator.pop(context, true);
                                setState(() {
                                  controller.text = '';
                                });
                              },
                              child: const Text(
                                'Create',
                              ))
                        ],
                      );
                    });
                print(isCreated);
                if (isCreated == true) {
                  _loadDirectory();
                }
              },
              icon: const Icon(Icons.insert_drive_file),
            ),
          ],
        ),
        body: ListView.builder(
          itemCount: _entities.length,
          itemBuilder: (context, index) {
            return _fileOrFolder(_entities[index]);
          },
        ),
      ),
    );
  }

  Widget _fileOrFolder(FileSystemEntity entity) {
    String fileName = entity.path.split('/').last;
    if (entity is Directory) {
      return ListTile(
        leading: const Icon(Icons.folder),
        title: Text(fileName),
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (builder) {
            return ViewDirectory(
              directory: entity,
              folderName: fileName,
            );
          }));
        },
      );
    } else {
      return ListTile(
        leading: const Icon(Icons.insert_drive_file),
        title: Text(fileName),
        onTap: () {
          _loadFile(fileName, entity);
        },
        onLongPress: () async {
          bool? isConfirmed = await showDialog(
              context: context,
              builder: (builder) {
                return AlertDialog(
                  title: const Text('Delete'),
                  icon: const Icon(Icons.delete),
                  content: Text('Are you sure want to delete this $fileName ?'),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context, true);
                      },
                      child: const Text('Delete'),
                    ),
                  ],
                );
              });
          if (isConfirmed == true) {
            File file = File(entity.path);
            if (file.existsSync()) {
              file.delete();
            }
            _loadDirectory();
          }
        },
      );
    }
  }
}
