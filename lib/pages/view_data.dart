import 'dart:io';

import 'package:flutter/material.dart';

class ViewData extends StatefulWidget {
  ViewData(
      {super.key,
      required this.fileName,
      required this.data,
      required this.entity});
  String fileName;
  String data;
  FileSystemEntity entity;

  @override
  State<ViewData> createState() => _ViewDataState();
}

class _ViewDataState extends State<ViewData> {
  TextEditingController _dataController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _dataController.text = widget.data;
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
              icon: const Icon(Icons.arrow_back),
            ),
            actions: [
              IconButton(
                onPressed: () async {
                  File oldFile = File(widget.entity.path);
                  Directory parentDirectory = oldFile.parent;
                  String filPath = "${parentDirectory.path}/${widget.fileName}";

                  File file = File(filPath);
                  try {
                    await file.writeAsString(_dataController.text);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('File Edited Successfully'),
                      ),
                    );
                    if (context.mounted) {
                      Navigator.pop(context, true); // Go back and return true
                    }
                  } catch (e) {
                    print("Error renaming file: $e");
                  }
                },
                icon: const Icon(Icons.save),
              ),
            ],
            title: Text(widget.fileName),
          ),
          body: Column(
            children: [
              TextField(
                controller: _dataController,
                maxLines: 10,
              ),
            ],
          )),
    );
  }
}
