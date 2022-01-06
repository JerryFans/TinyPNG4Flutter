import 'dart:io';
import 'package:TinyPNG4Flutter/Controller/tiny_image_info_controller.dart';
import 'package:TinyPNG4Flutter/ImagesAnim.dart';
import 'package:TinyPNG4Flutter/View/image_task_cell.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:get/route_manager.dart';
import 'package:path_provider_macos/path_provider_macos.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:oktoast/oktoast.dart';

void main() {
  runApp(GetMaterialApp(
    navigatorKey: Get.key,
    home: OKToast(child: MyApp(),),
  ));
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TinyPNG4Flutter',
      theme: ThemeData(),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey,
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            backgroundColor: Colors.grey,
            onPressed: () async {
              Process.run("open", ["/Users/jerryfans/Desktop"]);
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
              showModalBottomSheet(
                  context: context,
                  enableDrag: false,
                  builder: (BuildContext context) {
                    return Container(
                      height: 130,
                      decoration: BoxDecoration(
                        color: Colors.blueGrey,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text("       API Key:"),
                                Container(
                                  padding: EdgeInsets.only(left: 5),
                                  height: 50,
                                  width: 300,
                                  child: TextField(
                                      cursorHeight: 20,
                                      cursorColor: Colors.black,
                                      decoration: InputDecoration(
                                          hintText:
                                              "paste your tinyPng api key in here",
                                          focusedBorder: OutlineInputBorder(
                                              borderSide: const BorderSide(
                                                  color: Colors.black)),
                                          enabledBorder: OutlineInputBorder(
                                              borderSide: const BorderSide(
                                                  color: Colors.black)),
                                          border: OutlineInputBorder())),
                                ),
                                SizedBox(
                                  width: 5,
                                ),
                                TextButton(
                                    onPressed: () {
                                      Process.run("open", ["https://tinypng.com/developers"]);
                                    },
                                    child: Text(
                                      "Get your API key",
                                      style: TextStyle(
                                        color: Colors.black,
                                        decoration: TextDecoration.underline,
                                      ),
                                    )),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text("Output Path:"),
                                Container(
                                  padding: EdgeInsets.only(left: 5),
                                  height: 50,
                                  width: 300,
                                  child: TextField(
                                      cursorHeight: 10,
                                      cursorColor: Colors.black,
                                      decoration: InputDecoration(
                                          focusedBorder: OutlineInputBorder(
                                              borderSide: const BorderSide(
                                                  color: Colors.black)),
                                          enabledBorder: OutlineInputBorder(
                                              borderSide: const BorderSide(
                                                  color: Colors.black)),
                                          border: OutlineInputBorder())),
                                ),
                                SizedBox(
                                  width: 118,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  });
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
              FilePickerResult? result =
                  await FilePicker.platform.pickFiles(allowMultiple: true);
              if (result != null) {
                List<File> files =
                    result.paths.map((path) => File(path ?? "")).toList();
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
                // User canceled the picker
              }
            },
            tooltip: 'Add Files',
            child: Icon(Icons.add),
          ),
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
                child: TextButton(child: Text("Drop or add your file here", style: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.w600),), onPressed: () {

                },),
              ),
            );
          }
        }),
      ),
    );
  }
}
