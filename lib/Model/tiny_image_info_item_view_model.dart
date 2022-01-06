import 'dart:io';

import 'tiny_image_info.dart';

extension FileExtention on FileSystemEntity{
  String get fileName {
    return this.path.split("/").last;
  }
}

enum TinyImageInfoStatus {
  uploading,
  uploadFail,
  downloading,
  downloadFail,
  success
}

class TinyImageInfoItemViewModel {

  File file;
  String fileName = "";
  String statusInfo = "wait for upload";
  TinyImageInfoStatus status = TinyImageInfoStatus.uploading;
  TinyImageInfo? imageInfo;

  set setImageInfo(TinyImageInfo? imageInfo) {
    this.imageInfo = imageInfo;
    print("setting image info ");
    
  }

  TinyImageInfoItemViewModel.file(this.file) {
    this.fileName = file.fileName;
  }


}