import 'dart:io';

import 'package:TinyPNG4Flutter/Controller/const_util.dart';
import 'package:TinyPNG4Flutter/Controller/tiny_image_info_controller.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:oktoast/oktoast.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BottomSettingView extends StatelessWidget {
  final TinyImageInfoController controller;

  BottomSettingView({Key? key, required this.controller}) : super(key: key);

  final savePathController = TextEditingController(text: "");
  final apiKeyController = TextEditingController(text: "");

  @override
  Widget build(BuildContext context) {
    SharedPreferences.getInstance().then((value) {
      if (value.getString(KSavePathKey) != null) {
        savePathController.text = value.getString(KSavePathKey)!;
        controller.savePath.value = value.getString(KSavePathKey)!;
      }
      if (value.getString(KApiKey) != null) {
        apiKeyController.text = value.getString(KApiKey)!;
        controller.apiKey.value = value.getString(KApiKey)!;
      }
    });
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
                  width: 500,
                  child: TextField(
                      onChanged: (value) {
                        print("change value $value");
                        apiKeyController.text = value;
                        controller.apiKey.value = value;
                        SharedPreferences.getInstance().then((pre) {
                          pre.setString(KApiKey, value);
                        });
                      },
                      controller: apiKeyController,
                      cursorHeight: 20,
                      cursorColor: Colors.black,
                      decoration: InputDecoration(
                          hintText: "paste your tinyPng api key in here",
                          focusedBorder: OutlineInputBorder(
                              borderSide:
                                  const BorderSide(color: Colors.black)),
                          enabledBorder: OutlineInputBorder(
                              borderSide:
                                  const BorderSide(color: Colors.black)),
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
                  width: 500,
                  child: GestureDetector(
                    onTap: () {
                      showToast(
                          "Can't enter text, please choose a folder \n or use default",
                          textPadding: EdgeInsets.all(15));
                    },
                    child: TextField(
                        controller: savePathController,
                        enabled: false,
                        cursorHeight: 10,
                        cursorColor: Colors.black,
                        decoration: InputDecoration(
                            focusedBorder: OutlineInputBorder(
                                borderSide:
                                    const BorderSide(color: Colors.black)),
                            enabledBorder: OutlineInputBorder(
                                borderSide:
                                    const BorderSide(color: Colors.black)),
                            border: OutlineInputBorder())),
                  ),
                ),
                Container(
                  width: 118,
                  child: Row(
                    children: [
                      SizedBox(
                        width: 5,
                      ),
                      TextButton(
                          onPressed: () async {
                            String? result =
                                await FilePicker.platform.getDirectoryPath();
                            if (result != null) {
                              savePathController.text = result;
                              controller.savePath.value = result;
                              SharedPreferences.getInstance().then((value) {
                                value.setString(KSavePathKey, result);
                              });
                            }
                          },
                          child: Text(
                            "Choose",
                            style: TextStyle(
                              color: Colors.black,
                              decoration: TextDecoration.underline,
                            ),
                          )),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
