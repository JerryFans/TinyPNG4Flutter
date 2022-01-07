import 'dart:io';
import 'package:TinyPNG4Flutter/Controller/const_util.dart';
import 'package:TinyPNG4Flutter/Controller/path_provider_util.dart';
import 'package:TinyPNG4Flutter/Controller/tiny_image_info_controller.dart';
import 'package:TinyPNG4Flutter/View/image_task_cell.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:get/route_manager.dart';
import 'package:oktoast/oktoast.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'View/bottom_setting_view.dart';

void main() {
  runApp(GetMaterialApp(
    navigatorKey: Get.key,
    home: OKToast(
      child: MyApp(),
    ),
  ));
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TinyPNG4Flutter',
      theme: ThemeData(),
      home: MyHomePage(title: 'TinyPNGFlutter'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final controller = TinyImageInfoController();

  @override
  void initState() {
    super.initState();
    SharedPreferences.getInstance().then((pre) async {
      var savePath = pre.getString(KSavePathKey);
      if (savePath == null || savePath.isEmpty) {
        var provider = PathProviderUtil.provider();
        String? path = await provider.getDownloadsPath();
        if (path == null) return;
        final filePath = path + "/" + "tinyPngFlutterOutput";
        pre.setString(KSavePathKey, filePath);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey,
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Obx(() => Padding(
                padding: EdgeInsets.only(left: 30),
                child: Text(
                    "${controller.taskCount.value} task(s) saved ${controller.saveKb.value.toStringAsFixed(2)}KB",
                    style: TextStyle(color: Colors.white),
                    ),
              )),
          Row(
            children: [
              FloatingActionButton(
                backgroundColor: Colors.grey,
                onPressed: () async {
                  var pre = await SharedPreferences.getInstance();
                  var savePath = pre.getString(KSavePathKey);
                  if (savePath == null) return;
                  var checkCreate = await controller.createDirectory(savePath);
                  if (checkCreate != null) {
                    Process.run("open", [savePath]);
                  }
                },
                tooltip: 'Open compress image folder',
                child: Icon(Icons.folder_open_outlined),
              ),
              SizedBox(
                width: 15,
              ),
              FloatingActionButton(
                backgroundColor: Colors.grey,
                onPressed: () async {
                  _showSettingBottomSheet();
                },
                tooltip: 'Setting path and apiKey',
                child: Icon(Icons.settings),
              ),
              SizedBox(
                width: 15,
              ),
              FloatingActionButton(
                backgroundColor: Colors.grey,
                onPressed: () async {
                  _pickFiles();
                },
                tooltip: 'Add Files',
                child: Icon(Icons.add),
              ),
            ],
          )
        ],
      ),
      body: Container(
        margin: EdgeInsets.only(top: 15, bottom: 80),
        child: Obx(() {
          if (controller.taskList.length > 0) {
            return ListView.separated(
              itemCount: controller.taskList.length,
              separatorBuilder: (BuildContext context, int index) {
                return Divider(
                  height: 15,
                  color: Colors.transparent,
                );
              },
              itemBuilder: (_, int index) => ImageTaskCell(
                vm: controller.taskList[index],
              ),
            );
          } else {
            return Container(
              child: Center(
                child: TextButton(
                  child: Text(
                    "Drop or Add your file here",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w600),
                  ),
                  onPressed: () {
                    _pickFiles();
                  },
                ),
              ),
            );
          }
        }),
      ),
    );
  }

  void _pickFiles() async {
    if (await controller.checkHaveApiKey() == false) {
      _showSettingBottomSheet();
      showToast("Please enter your TinyPNG Apikey",
          textPadding: EdgeInsets.all(15));
      return;
    }
    FilePickerResult? result =
        await FilePicker.platform.pickFiles(allowMultiple: true);
    if (result != null) {
      List<File> files = result.paths.map((path) => File(path ?? "")).toList();
      List<File> chooseFiles = [];
      files.forEach((element) {
        if (element.path.toLowerCase().endsWith("jpg") ||
            element.path.toLowerCase().endsWith("jpeg") ||
            element.path.toLowerCase().endsWith("png")) {
          chooseFiles.add(element);
        } else {
          showToast('invalid image file', textPadding: EdgeInsets.all(15));
          print("invalid image file : ${element.path}");
        }
      });
      if (chooseFiles.isNotEmpty) {
        controller.refreshWithFileList(chooseFiles);
      }
    } else {
      showToast("Cancel Pick files", textPadding: EdgeInsets.all(15));
    }
  }

  void _showSettingBottomSheet() {
    showModalBottomSheet(
        context: context,
        enableDrag: false,
        builder: (BuildContext context) {
          return BottomSettingView(
            controller: controller,
          );
        });
  }
}
