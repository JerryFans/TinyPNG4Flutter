import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TinyPNG4Flutter',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
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
  List<File> fileList = [];

  Future<Uint8List?> getImage() async {
    var data = await rootBundle.load("images/test.jpg");
    var buffer = data.buffer.asUint8List();
    return await sendHttpProtocReq(buffer: buffer);
  }

  Future<Uint8List?> sendHttpProtocReq({@required Uint8List? buffer}) async {
    var url = "api.tinify.com";
    Uri uri = Uri.https(url, "/shrink");
    var apiKey = "Y0v_xtfXJ6bSYkAITkCR6ROVKxw3BJK4";
    var auth = "api:$apiKey";
    var authData = base64Encode(utf8.encode(auth));
    var authorizationHeader = "Basic " + authData;
    var headers = {
      "Accept": "application/json",
      "Authorization": authorizationHeader
    };
    var response = await http.post(uri, headers: headers, body: buffer);
    if (response.statusCode != 201) {
      print("fail code is ${response.statusCode}");
      return null;
    } else {
      var json = jsonDecode(utf8.decode(response.bodyBytes));
      var jsonString = jsonEncode(json);
      print("success json $jsonString");
      return response.bodyBytes;
    }
  }

  @override
  void initState() {
    getImage().then((value) {
      setState(() {
        // imageData = value;
      });
    });
    super.initState();
  }

  List<Widget> widgetList() {
    var list = [
            Text(
              'Hello Word',
            ),
            TextButton(
                onPressed: () async {
                  FilePickerResult? result =
                      await FilePicker.platform.pickFiles(allowMultiple: true);
                  if (result != null) {
                    List<File> files =
                        result.paths.map((path) => File(path ?? "")).toList();
                    List<File> chooseFiles = [];
                    files.forEach((element) {
                      if (element.path.toLowerCase().endsWith("jpg")
                       || element.path.toLowerCase().endsWith("jpeg")
                       || element.path.toLowerCase().endsWith("png")) {
                         chooseFiles.add(element);
                      } else {
                        print("invalid image file : ${element.path}");
                      }
                    });
                    if (chooseFiles.isNotEmpty) {
                      setState(() {
                      fileList.addAll(chooseFiles);
                    });
                    }
                  } else {
                    // User canceled the picker
                  }
                },
                child: Text("添加"))
          ];
    fileList.forEach((element) { 
      list.add(Image.file(element, height: 50, fit: BoxFit.fitHeight,));
    });
    return list;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: widgetList(),
      ),
    );
  }
}
