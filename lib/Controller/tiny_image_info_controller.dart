import 'dart:ffi';

import 'package:TinyPNG4Flutter/Controller/path_provider_util.dart';
import 'package:TinyPNG4Flutter/Model/tiny_image_info.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:TinyPNG4Flutter/Model/tiny_image_info_item_view_model.dart';
import 'package:get/get.dart';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'const_util.dart';

class TinyImageInfoController extends GetxController {

  final PathProviderPlatform provider = PathProviderUtil.provider();
  var taskList = <TinyImageInfoItemViewModel>[].obs;
  var savePath = "".obs;
  var apiKey = "".obs;
  var taskCount = 0.obs;
  var saveKb = 0.0.obs;

  void refreshWithFileList(List<File> files) {
    var vms = <TinyImageInfoItemViewModel>[];
    files.forEach((element) {
      vms.add(TinyImageInfoItemViewModel.file(element));
    });
    vms.forEach((element) {
      beginCompressTask(vm: element);
    });
    taskList.addAll(vms);
    taskCount.value = taskList.length;
  }

  void beginCompressTask({required TinyImageInfoItemViewModel vm}) async {
    var pre =  await SharedPreferences.getInstance();

    var data = await vm.file.readAsBytes();

    var buffer = data.buffer.asUint8List();

    vm.updateStatus(TinyImageInfoStatus.uploading);
    taskList.refresh();

    TinyImageInfo? info = await uploadOriginImage(buffer: buffer);
    if (info == null) {
      //upload fail
      vm.updateStatus(TinyImageInfoStatus.uploadFail);
      taskList.refresh();
      return;
    }
    vm.imageInfo = info;
    vm.updateStatus(TinyImageInfoStatus.downloading);
    taskList.refresh();

    String? path = pre.getString(KSavePathKey);

    if (path == null) {
      vm.updateStatus(TinyImageInfoStatus.downloadFail);
      taskList.refresh();
      return;
    }

    Directory? folder = await createDirectory(path);

    if (folder == null) {
      vm.updateStatus(TinyImageInfoStatus.downloadFail);
      taskList.refresh();
      return;
    }

    vm.updateStatus(TinyImageInfoStatus.downloading);
    taskList.refresh();
    var compressFile = await createFile(folder.path, vm.file.fileName);
    
    if (compressFile == null) {
      vm.updateStatus(TinyImageInfoStatus.downloadFail);
      taskList.refresh();
      return;
    }

    var isSuc = await downloadOutputImage(
      info,
      compressFile.path,
      onReceiveProgress: (count, total) {
        vm.updateProgress(count, total);
        taskList.refresh();
      },
    );
    if (isSuc) {
      vm.updateStatus(TinyImageInfoStatus.success);
      taskList.refresh();
      saveKb.value += vm.saveKB;
    } else {
      vm.updateStatus(TinyImageInfoStatus.downloadFail);
      taskList.refresh();
    }
    print("$isSuc save $compressFile");
  }

  Future<TinyImageInfo?> uploadOriginImage({required Uint8List? buffer}) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var apiKey =  prefs.getString(KApiKey);
    if (apiKey == null || apiKey.length == 0) {
      return null;
    }
    var url = "api.tinify.com";
    Uri uri = Uri.https(url, "/shrink");
    var auth = "api:$apiKey";
    var authData = base64Encode(utf8.encode(auth));
    var authorizationHeader = "Basic " + authData;
    var headers = {
      "Accept": "application/json",
      "Authorization": authorizationHeader,
    };
    try {
      var response = await http.post(uri, headers: headers, body: buffer);
      if (response.statusCode != 201) {
        print("fail code is ${response.statusCode}");
        return null;
      } else {
        var json = jsonDecode(utf8.decode(response.bodyBytes));
        var jsonString = jsonEncode(json);
        print("success json $jsonString");
        return TinyImageInfo.fromJson(json);
      }
    } catch (e) {
      print("catch upload error $e");
      return null;
    }
  }

  Future<bool> checkHaveApiKey() async {
    var pre = await SharedPreferences.getInstance();
    return pre.getString(KApiKey) != null;
  }

  Future<bool> downloadOutputImage(TinyImageInfo imageInfo, String savePath,
      {Function(int count, int total)? onReceiveProgress}) async {
    String? url = imageInfo.output?.url;
    String? type = imageInfo.output?.type;
    if (url == null || type == null) {
      return false;
    }
    Uri uri = Uri.parse(url);
    var dio = Dio();
    try {
      var rsp = await dio.downloadUri(
        uri,
        savePath,
        options: Options(
          headers: {"Accept": type, "Content-Type": "application/json"},
        ),
        onReceiveProgress: (count, total) {
          onReceiveProgress?.call(count, total);
        },
      );
      return rsp.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  Future<File?> createFile(String path, String fileName) async {
    try {
      bool isExist = true;
      var filePath = path + "/" + fileName;
      var count = 0;
      while (true) {
        if (count > 0) {
          var onlyName = fileName.split(".").first;
          var type = fileName.split(".").last;
          filePath = path + "/" + onlyName + "_$count" + "." + type;
        }
        isExist = await File(filePath).exists();
        print("try create path $filePath isExist $isExist");
        if (isExist == false) {
          break;
        }
        count++;
      }
      return await File(filePath).create();
    } catch (e) {
      return null;
    }
  }

  Future<Directory?> createDirectory(String path) async {
    final filePath = path;
    var file = Directory(filePath);
    try {
      bool exist = await file.exists();
      if (!exist) {
        print("no directory try create");
        return await file.create();
      } else {
        return file;
      }
    } catch (e) {
      return null;
    }
  }
}
