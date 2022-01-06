import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';

import 'tiny_image_info.dart';

extension FileExtention on FileSystemEntity {
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
  String statusInfo = "Processing";
  Color  statusColor = Colors.grey;
  TinyImageInfoStatus status = TinyImageInfoStatus.uploading;
  TinyImageInfo? imageInfo;
  
  void updateProgress(int count ,int total) {
    if (status == TinyImageInfoStatus.downloading) {
      var progress = (count / total).toStringAsFixed(2);
      statusInfo = "downloading $progress%";
    }
  }

  void updateStatus(TinyImageInfoStatus status) {
    this.status = status;
    print("setting status");
    switch (status) {
      case TinyImageInfoStatus.downloadFail:
        statusInfo = "downloadFail";
        statusColor = Colors.red;
        break;
      case TinyImageInfoStatus.downloading:
        statusInfo = "downloading";
        statusColor = Colors.grey;
        break;
      case TinyImageInfoStatus.uploadFail:
        statusInfo = "uploadFail";
        statusColor = Colors.red;
        break;
      case TinyImageInfoStatus.uploading:
        statusInfo = "uploading";
        statusColor = Colors.grey;
        break;
      case TinyImageInfoStatus.success: {
        statusInfo = "success";
        statusColor = Colors.greenAccent;
        if (imageInfo != null && imageInfo?.output != null && imageInfo?.input != null) {
          var ouput = imageInfo!.output!;
          var input = imageInfo!.input!;
           var kb = ((input.size - ouput.size) / 1024).toStringAsFixed(2);
           var ratio = ((1 - (ouput.ratio ?? 0)) * 100).toStringAsFixed(1);
           statusInfo = "-${kb}K($ratio%)";
        }
      }
        break;
    }
  }

  void updateImageInfo(TinyImageInfo? imageInfo) {
    this.imageInfo = imageInfo;
    print("setting image info ");
  }

  TinyImageInfoItemViewModel.file(this.file) {
    this.fileName = file.fileName;
  }
}
