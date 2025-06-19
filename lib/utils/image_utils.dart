import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:common_utils/common_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

import 'format_util.dart';

enum ImageFrom { camera, gallery }

enum ImageFormat { png, jpg, gif, webp }

extension ImageFormatExtension on ImageFormat {
  String get value => ['png', 'jpg', 'gif', 'webp'][index];
}

class ImageUtils {
  static ImageProvider getAssetImage(String name,
      {ImageFormat format = ImageFormat.png}) {
    return AssetImage(getImgPath(name, format: format));
  }

  static String getImgPath(String name,
      {ImageFormat format = ImageFormat.png}) {
    return 'assets/images/$name.${format.value}';
  }

  static ImageProvider getImageProvider(String? imageUrl,
      {String holderImg = 'none'}) {
    if (TextUtil.isEmpty(imageUrl)) {
      return AssetImage(getImgPath(holderImg));
    }
    return CachedNetworkImageProvider(imageUrl!);
  }


  /**
   * ///选择一个图片
      ///[from] 是相机还是图库
      ///可选参数
      ///[maxWidth] 宽度,
      ///[maxHeight] 高度,
      ///[imageQuality] 质量
   */
  static pickSinglePic(ImageFrom from,
      {double? maxWidth, double? maxHeight, int? imageQuality}) async {
    ImageSource source;
    switch (from) {
      case ImageFrom.camera:
        source = ImageSource.camera;
        break;
      case ImageFrom.gallery:
        source = ImageSource.gallery;
        break;
    }
    final pickerImages = await ImagePicker().pickImage(
      source: source,
      imageQuality: imageQuality,
      maxWidth: maxWidth,
      maxHeight: maxHeight,
    );
    return pickerImages;
  }

  ///裁切图片
  ///[image] 图片路径或文件
  ///[width] 宽度
  ///[height] 高度
  ///[aspectRatio] 比例
  ///[androidUiSettings]UI 参数
  ///[iOSUiSettings] ios的ui 参数
  static cropImage(
      {required image,
        required width,
        required height,
        aspectRatio,
        androidUiSettings,
        iOSUiSettings}) async {
    String imagePth = "";
    if (image is String) {
      imagePth = image;
    } else if (image is File) {
      imagePth = image.path;
    } else {
      throw ("文件路径错误");
    }
    final croppedFile = await ImageCropper().cropImage(
      sourcePath: imagePth,
      maxWidth: FormatUtil.num2int(width),
      maxHeight: FormatUtil.num2int(height),
      aspectRatio: aspectRatio ??
          CropAspectRatio(
              ratioX: FormatUtil.num2double(width),
              ratioY: FormatUtil.num2double(height)),
      uiSettings: [
        androidUiSettings ??
            AndroidUiSettings(
                toolbarTitle:
                '图片裁切(${FormatUtil.num2int(width)}*${FormatUtil.num2int(height)})',
                toolbarColor: Colors.blue,
                toolbarWidgetColor: Colors.white,
                initAspectRatio: CropAspectRatioPreset.original,
                hideBottomControls: false,
                lockAspectRatio: true),
        iOSUiSettings ??
            IOSUiSettings(
              title: 'Cropper',
            ),
      ],
    );
    return croppedFile;
  }
}

