import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_storage_lessons_test/pages/view_data.dart';
import 'package:path_provider/path_provider.dart';

import 'pages/view_directory.dart';

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
  final TextEditingController _folderNameController = TextEditingController();
  @override
  void initState() {
    super.initState();
    _loadRefresh();
  }

  /*void _loadDirectory(String fileName) async {
    Directory directory = await getPath();
    String path = "${directory.path}/$fileName";
    _readFile(path);
  }*/

  void _loadFile(String fileName, FileSystemEntity entity) async {
    Directory directory = await getPath();
    String path = "${directory.path}/$fileName";
    File file = File(path);
    String data = await file.readAsString();
    bool? refresh =
        await Navigator.push(context, MaterialPageRoute(builder: (builder) {
      return ViewData(
        fileName: fileName,
        data: data,
        entity: entity,
      );
    }));
    if (refresh == true) {
      _loadRefresh();
    }
  }

  void _loadRefresh() {
    setState(() {});
  }

  /*void _readFile(String filePath) async {
    File file = File(filePath);
    String data = await file.readAsString();
    _dataController.text = data;
  }*/

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Storage Lesson'),
        actions: [
          IconButton(
            onPressed: () {
              showDialog(
                  context: context,
                  builder: (builder) {
                    return AlertDialog(
                      title: const Text('Create New Folder'),
                      content: TextField(
                        controller: _folderNameController,
                        decoration:
                            const InputDecoration(label: Text('Folder Name')),
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
                              Directory appDirectory = await getPath();
                              String filPath =
                                  "${appDirectory.path}/${_folderNameController.text}";
                              Directory folder = Directory(filPath);
                              await folder.create();
                              String message =
                                  "Folder Created : ${_folderNameController.text}";
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(message),
                                ),
                              );
                              Navigator.pop(
                                context,
                              );
                              setState(() {});
                            },
                            child: const Text(
                              'Create',
                            ))
                      ],
                    );
                  });
            },
            icon: const Icon(Icons.create_new_folder),
          ),
          IconButton(
            onPressed: () {
              showDialog(
                  context: context,
                  builder: (builder) {
                    return AlertDialog(
                      title: const Text('Create New File'),
                      content: TextField(
                        controller: _fileNameController,
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
                              Directory appDirectory = await getPath();
                              String filPath =
                                  "${appDirectory.path}/${_fileNameController.text}";
                              File file = File(filPath);
                              await file.create();
                              String message =
                                  "Folder Created : ${_fileNameController.text}";
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(message),
                                ),
                              );
                              Navigator.pop(context);
                              setState(() {
                                _fileNameController.text = '';
                              });
                            },
                            child: const Text(
                              'Create',
                            ))
                      ],
                    );
                  });
            },
            icon: const Icon(Icons.insert_drive_file),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            /*TextField(
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
            const SizedBox(height: 10),*/
            FutureBuilder(
              key: UniqueKey(),
              future: getPath(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  Directory directory = snapshot.data!;
                  List<FileSystemEntity> entities = directory.listSync();
                  return Column(
                    children: [
                      for (FileSystemEntity entity in entities)
                        _fileOrFolder(entity)
                    ],
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ],
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
        subtitle: Text(("${entity.statSync().size ~/ 8} B").toString()),
        /*trailing: Text(
            "${entity.statSync().changed.day}/${entity.statSync().changed.month}/"
            "${entity.statSync().changed.year} ${entity.statSync().changed.hour}:${entity.statSync().changed.minute}:${entity.statSync().changed.second}"),*/
        trailing: IconButton(
            /*onPressed: () {
              showModalBottomSheet(
                  context: context,
                  builder: (builder) {
                    return BottomSheet(
                        showDragHandle: true,
                        onClosing: () {
                          Navigator.pop(context);
                        },
                        builder: (builder) {
                          return Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: SizedBox(
                              height: 200,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Text(
                                    'Details',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 22),
                                  ),
                                  const SizedBox(
                                    height: 5,
                                    child: Divider(
                                      color: Colors.blueGrey,
                                      thickness: 1,
                                    ),
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text(
                                        "Name :",
                                        style: const TextStyle(fontSize: 20),
                                      ),
                                      Text(
                                        fileName,
                                        style: const TextStyle(fontSize: 20),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 5),
                                ],
                              ),
                            ),
                          );
                        });
                  });
            },*/
            onPressed: () {
              showMyBottomSheet(context, fileName, entity);
            },
            icon: const Icon(Icons.info)),
        onTap: () async {
          Navigator.push(context, MaterialPageRoute(builder: (builder) {
            return ViewDirectory(
              directory: entity,
              folderName: fileName,
            );
          }));
        },
        onLongPress: () async {
          bool? isDeleteFolder = await showDialog(
              context: context,
              builder: (builder) {
                return AlertDialog(
                  title: const Text('Delete'),
                  icon: const Icon(Icons.folder_delete),
                  content: RichText(
                      text: TextSpan(children: [
                    const TextSpan(
                        text: 'Are you sure want to delete this \n',
                        style: TextStyle(color: Colors.black)),
                    TextSpan(
                        text: '$fileName?',
                        style: const TextStyle(color: Colors.red))
                  ])),
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
          if (isDeleteFolder == true) {
            String folderPath = entity.path;
            Directory dir = Directory(folderPath);
            if (dir.existsSync()) {
              dir.delete();
              setState(() {});
            }
          }
        },
      );
    } else {
      return ListTile(
        leading: const Icon(Icons.insert_drive_file),
        title: Text(fileName),
        subtitle: Text(("${entity.statSync().size ~/ 8} B").toString()),
        /*trailing: Text(
            "${entity.statSync().changed.day}/${entity.statSync().changed.month}/${entity.statSync().changed.year} ${entity.statSync().changed.hour}:${entity.statSync().changed.minute}:${entity.statSync().changed.second}"),
        */
        trailing: PopupMenuButton<int>(onSelected: (item) {
          switch (item) {
            case 0:
              showDialog(
                  context: context,
                  builder: (builder) {
                    return AlertDialog(
                      title: const Text('Rename'),
                      content: TextField(
                        controller: _fileNameController,
                        decoration: const InputDecoration(
                            label: Text('Enter file name')),
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
                              //Get the old file (the one to rename)
                              File oldFile = File(entity.path);
                              Directory parentDirectory = oldFile.parent;
                              String newPath =
                                  "${parentDirectory.path}/${_fileNameController.text}";
                              try {
                                await oldFile.rename(newPath);
                                print("File renamed successfully to: $newPath");
                                _fileNameController.text = '';
                                if (context.mounted) {
                                  Navigator.pop(
                                      context, true); // Go back and return true
                                }
                              } catch (e) {
                                print("Error renaming file: $e");
                              }
                              setState(() {});
                            },
                            child: const Text(
                              'Ok',
                            ))
                      ],
                    );
                  });
              break;
            case 1:
              showMyBottomSheet(context, fileName, entity);
              break;
          }
        }, itemBuilder: (context) {
          return [
            const PopupMenuItem<int>(value: 0, child: Text('Rename')),
            const PopupMenuItem<int>(value: 1, child: Text('Info')),
          ];
        }),
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
                  content: RichText(
                      text: TextSpan(children: [
                    const TextSpan(
                        text: 'Are you sure want to delete this \n',
                        style: TextStyle(color: Colors.black)),
                    TextSpan(
                        text: '$fileName?',
                        style: const TextStyle(color: Colors.red))
                  ])),
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
              setState(() {});
            }
          }
        },
      );
    }
  }
}

void showMyBottomSheet(
    BuildContext context, String fileName, FileSystemEntity entity) {
  showModalBottomSheet(
      showDragHandle: true,
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return DraggableScrollableSheet(
            initialChildSize: 0.3, // Initial height (30% of screen)
            minChildSize: 0.1, // Mini height (10% of screen)
            maxChildSize: 0.9, // Maxi height (90% of screen)
            expand:
                false, // Prevent the sheet from automatically expanding to full screen
            builder: (context, scrollController) {
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    const Divider(
                      color: Colors.blueGrey,
                      thickness: 1,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Name :",
                          style: TextStyle(fontSize: 20),
                        ),
                        Text(
                          fileName,
                          style: const TextStyle(fontSize: 20),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Modified Date :",
                          style: TextStyle(fontSize: 20),
                        ),
                        Text(
                          "${entity.statSync().changed.day}/${entity.statSync().changed.month}/${entity.statSync().changed.year}",
                          style: const TextStyle(fontSize: 20),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Modified Time :",
                          style: TextStyle(fontSize: 20),
                        ),
                        Text(
                          "${entity.statSync().changed.hour}:${entity.statSync().changed.minute}:${entity.statSync().changed.second}",
                          style: const TextStyle(fontSize: 20),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Size :",
                          style: TextStyle(fontSize: 20),
                        ),
                        Text(
                          "${entity.statSync().size ~/ 8} B",
                          style: const TextStyle(fontSize: 20),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            });
      });
}

Future<Directory> getPath() async {
  return await getApplicationDocumentsDirectory();
}
