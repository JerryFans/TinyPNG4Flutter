import 'package:oktoast/oktoast.dart';
import 'package:tiny_png4_flutter/ImagesAnim.dart';
import 'package:tiny_png4_flutter/Model/tiny_image_info_item_view_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ImageTaskCell extends StatelessWidget {
  final TinyImageInfoItemViewModel vm;
  final Function(TinyImageInfoItemViewModel vm) retryCallBack;

  ImageTaskCell({Key? key, required this.vm, required this.retryCallBack}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(left: 15, right: 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Image.file(
                vm.file,
                height: 100,
                fit: BoxFit.fitHeight,
              ),
              SizedBox(
                width: 15,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    vm.fileName,
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 18),
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Text(
                    vm.statusInfo,
                    style: TextStyle(color: vm.statusColor),
                  ),
                ],
              ),
            ],
          ),
          Row(
            children: [
              Visibility(
                  visible: vm.status == TinyImageInfoStatus.downloadFail ||
                      vm.status == TinyImageInfoStatus.uploadFail,
                  child: GestureDetector(
                    onTap: () {
                      this.retryCallBack(vm);
                    },
                    child: Row(
                      children: [
                        Container(
                          width: 25,
                          height: 25,
                          decoration: BoxDecoration(
                              color: Colors.grey,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(12.5))),
                          child: Center(
                            child: Container(
                              width: 18,
                              height: 18,
                              child: Image.asset(
                                "images/retry.png",
                                width: 15,
                                height: 15,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 15,
                        ),
                      ],
                    ),
                  )),
              _getStatusWidget(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _getStatusWidget() {
    switch (vm.status) {
      case TinyImageInfoStatus.downloadFail:
      case TinyImageInfoStatus.uploadFail:
        return Image.asset(
          "images/error.png",
          width: 30,
          height: 30,
        );
      case TinyImageInfoStatus.downloading:
      case TinyImageInfoStatus.uploading:
        return Container(
          child: ImagesAnim(30, 30, 50, filePath: "images/loading/"),
          width: 30,
          height: 30,
        );
      case TinyImageInfoStatus.success:
        {
          return Image.asset(
            "images/success.png",
            width: 30,
            height: 30,
          );
        }
    }
  }
}
