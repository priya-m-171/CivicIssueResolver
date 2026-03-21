import 'dart:io';
import 'package:flutter/material.dart';

Widget getPlatformImage(String path, {double? width, double? height, BoxFit? fit}) {
  return Image.file(
    File(path),
    width: width,
    height: height,
    fit: fit ?? BoxFit.cover,
    errorBuilder: (context, error, stackTrace) => Container(
      width: width,
      height: height,
      color: Colors.grey[200],
      child: const Icon(Icons.broken_image, color: Colors.grey),
    ),
  );
}
