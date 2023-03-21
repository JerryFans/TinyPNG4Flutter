import 'package:flutter/material.dart';
import 'dart:convert';

class ImagesAnim extends StatefulWidget {
  final List<Image>? imageCaches;
  final double width;
  final double height;
  final Color backColor;
  final int duration;
  final String filePath;

  ImagesAnim(this.width, this.height, this.duration,{Key? key, required this.filePath,  this.imageCaches,this.backColor = Colors.transparent})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return new _WOActionImageState();
  }
}

class _WOActionImageState extends State<ImagesAnim> {
  late bool _disposed;
  late Duration _duration;
  late int _imageIndex;
  late Container _container;
  late List<Image> _imageList;

  @override
  void initState() {
    super.initState();
    _disposed = false;
    _duration = Duration(milliseconds: widget.duration);
    _imageIndex = 1;
    _container = Container(height: widget.height, width: widget.width);
    _initImageList();

  }

  void _initImageList() async{
    if (widget.filePath.isEmpty) {
      _updateImageV2();
      return;
    }
    _imageList = [];
    var imageStrList = await getImageList();
    if (imageStrList.isNotEmpty) {
      imageStrList.forEach((element) {
        _imageList.add(Image.asset(element,height: widget.height,width: widget.width, gaplessPlayback: true,));
      });
    }
    if (_imageList.isEmpty) {
      _updateImage();
    }else{
      _updateImageV2();
    }

  }

  void _updateImage() {

    if (widget.imageCaches == null) {
      return;
    }

    if (_disposed ||  widget.imageCaches!.isEmpty) {
      return;
    }

    setState(() {
      if (_imageIndex >= widget.imageCaches!.length) {
        _imageIndex = 0;
      }
      _container = Container(
          color: widget.backColor,
          child: widget.imageCaches![_imageIndex],
          height: widget.height,
          width: widget.width);
      _imageIndex++;
    });
    Future.delayed(_duration, () {
      _updateImage();
    });
  }

  void _updateImageV2() {
    if (_disposed || _imageList.isEmpty) {
      return;
    }

    setState(() {
      int size = _imageList.length;
      if (_imageIndex >= size) {
        _imageIndex = 0;
      }
      _container = Container(
          color: widget.backColor,
          child: _imageList[_imageIndex],
          height: widget.height,
          width: widget.width);
      _imageIndex++;
    });
    Future.delayed(_duration, () {
      _updateImageV2();
    });
  }

  Future<List<String>> getImageList() async {
    final manifestJson = await DefaultAssetBundle.of(context).loadString('AssetManifest.json');
    // final images = json.decode(manifestJson).keys.where((String key) => key.contains(widget.filePath));
    Map<String,dynamic> map = json.decode(manifestJson);
    List<String> resList = <String>[];
    map.keys.forEach((element) {
      if (element.startsWith(widget.filePath) && element.contains(".DS_Store") == false) {
        resList.add(element);
      }
    });
    return resList;
  }

  @override
  void dispose() {
    super.dispose();
    _disposed = true;
    if (widget.imageCaches!=null && widget.imageCaches!.isNotEmpty) {
      widget.imageCaches!.clear();
    }
    if (this._imageList.isNotEmpty) {
      this._imageList.clear();
    }

  }

  @override
  Widget build(BuildContext context) {
    return _container;
  }
}
