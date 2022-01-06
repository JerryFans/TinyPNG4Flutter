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
                width: 5,
              ),
              Text(vm.fileName),
            ],
          ),
          Text(vm.statusInfo),
        ],
      ),
    );
  }
}
