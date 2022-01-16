import 'dart:io';
import 'package:file_drag_and_drop/drag_container_listener.dart';
import 'package:file_drag_and_drop/file_result.dart';
import 'package:tiny_png4_flutter/Controller/const_util.dart';
import 'package:tiny_png4_flutter/Controller/path_provider_util.dart';
import 'package:tiny_png4_flutter/Controller/tiny_image_info_controller.dart';
import 'package:tiny_png4_flutter/View/image_task_cell.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:get/route_manager.dart';
import 'package:oktoast/oktoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'View/bottom_setting_view.dart';
import 'package:file_drag_and_drop/file_drag_and_drop_channel.dart';
import 'package:window_manager/window_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dragAndDropChannel.initializedMainView();
  await windowManager.ensureInitialized();
  windowManager.waitUntilReadyToShow().then((_) async {
    await windowManager.setResizable(false);
    await windowManager.setSize(Size(800, 600));
    await windowManager.show();
  });
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
      title: 'tiny_png4_flutter',
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

class _MyHomePageState extends State<MyHomePage>
    implements DragContainerListener {
  final controller = TinyImageInfoController();
  var visibilityTips = false;

  @override
  void initState() {
    super.initState();
    dragAndDropChannel.addListener(this);
    SharedPreferences.getInstance().then((pre) async {
      var savePath = pre.getString(KSavePathKey);
      if (savePath == null || savePath.isEmpty) {
        try {
          var provider = PathProviderUtil.provider();
          String? path = await provider.getDownloadsPath();
          if (path == null) return;
          final filePath = path +
              PathProviderUtil.platformDirectoryLine() +
              "tinyPngFlutterOutput";
          pre.setString(KSavePathKey, filePath);
        } catch (e) {}
      }
    });
  }

  @override
  void dispose() {
    dragAndDropChannel.removeListener(this);
    super.dispose();
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
                  "${controller.taskCount.value} task(s) saved ${controller.getSavedString()}",
                  style: TextStyle(color: Colors.white),
                ),
              )),
          Row(
            children: [
              FloatingActionButton(
                backgroundColor: Colors.grey,
                onPressed: () {
                  controller.clear();
                },
                tooltip: 'Clear Data',
                child: Icon(Icons.cleaning_services),
              ),
              SizedBox(
                width: 15,
              ),
              FloatingActionButton(
                backgroundColor: Colors.grey,
                onPressed: () async {
                  var pre = await SharedPreferences.getInstance();
                  var savePath = pre.getString(KSavePathKey);
                  if (savePath == null) return;
                  var checkCreate = await controller.createDirectory(savePath);
                  if (checkCreate != null) {
                    if (Platform.isMacOS) {
                      Process.run("open", [savePath]);
                    } else if (Platform.isWindows) {
                      Process.run("explorer", [savePath]);
                    }
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
      body: Stack(
        children: [
          Container(
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
                    retryCallBack: (model) {
                      controller.beginCompressTask(vm: model);
                    },
                    vm: controller.taskList[index],
                  ),
                );
              } else {
                return Container(
                  child: Center(
                    child: TextButton(
                      child: Text(
                        "Add or Drag Your File Here",
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
          Visibility(
            visible: visibilityTips,
            child: Positioned(
                left: 0,
                right: 0,
                top: 0,
                bottom: 0,
                child: Container(
                  color: Colors.black54,
                  child: Column(
                    children: [
                      SizedBox(
                        height: 45,
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.blueGrey,
                          borderRadius: BorderRadius.all(Radius.circular(12)),
                        ),
                        padding: EdgeInsets.all(15),
                        child: Text("Drag your image file Here", style: TextStyle(color: Colors.white),),
                      ),
                    ],
                  ),
                )),
          )
        ],
      ),
    );
  }

  void _pickFiles() async {
    if (await checkCanPicker() == false) {
      return;
    }
    FilePickerResult? result =
        await FilePicker.platform.pickFiles(allowMultiple: true);
    if (result != null) {
      List<File> files = result.paths.map((path) => File(path ?? "")).toList();
      List<File> chooseFiles = chooseImageFiles(files);
      if (chooseFiles.isNotEmpty) {
        controller.refreshWithFileList(chooseFiles);
      }
    } else {
      showToast("Cancel Pick files", textPadding: EdgeInsets.all(15));
    }
  }

  List<File> chooseImageFiles(List<File> receiverFiles) {
    List<File> chooseFiles = [];
    receiverFiles.forEach((element) {
      if (element.path.toLowerCase().endsWith("jpg") ||
          element.path.toLowerCase().endsWith("jpeg") ||
          element.path.toLowerCase().endsWith("webp") ||
          element.path.toLowerCase().endsWith("png")) {
        chooseFiles.add(element);
      } else {
        showToast('have invalid image file', textPadding: EdgeInsets.all(15));
        print("invalid image file : ${element.path}");
      }
    });
    return chooseFiles;
  }

  Future<bool> checkCanPicker() async {
    if (await controller.checkHaveApiKey() == false) {
      _showSettingBottomSheet();
      showToast("Please enter your TinyPNG Apikey",
          textPadding: EdgeInsets.all(15));
      return false;
    }
    if (await controller.checkHaveSavePath() == false) {
      _showSettingBottomSheet();
      showToast("Please choose your output path",
          textPadding: EdgeInsets.all(15));
      return false;
    }
    return true;
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

  @override
  void draggingFileEntered() {
    print("flutter: draggingFileEntered");
    setState(() {
      visibilityTips = true;
    });
  }

  @override
  void draggingFileExit() {
    print("flutter: draggingFileExit");
    setState(() {
      visibilityTips = false;
    });
  }

  @override
  void prepareForDragFileOperation() {
    print("flutter: prepareForDragFileOperation");
    setState(() {
      visibilityTips = false;
    });
  }

  @override
  void performDragFileOperation(List<DragFileResult> fileResults) {
    print("flutter: performDragFileOperation");
    checkCanPicker().then((canPicker) {
      if (canPicker) {
        var collectionFiles = <File>[];
        fileResults.forEach((element) {
          if (element.isDirectory == false) {
            collectionFiles.add(File(element.path));
          }
          //TODO Also can collect the image file in Directory
        });
        var chooseFiles = chooseImageFiles(collectionFiles);
        if (chooseFiles.isNotEmpty) {
          controller.refreshWithFileList(chooseFiles);
        }
      }
    });
  }
}
