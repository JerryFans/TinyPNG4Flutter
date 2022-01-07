import 'package:TinyPNG4Flutter/ImagesAnim.dart';
import 'package:TinyPNG4Flutter/Model/tiny_image_info_item_view_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ImageTaskCell extends StatelessWidget {
  final TinyImageInfoItemViewModel vm;

  ImageTaskCell({Key? key, required this.vm}) : super(key: key);

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
                  Text(vm.fileName, style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 18),),
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
          _getStatusWidget(),
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
        return Container(child: ImagesAnim(30, 30, 50, filePath: "images/loading/"), width: 30, height: 30,);
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
