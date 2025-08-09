import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class IconDataAdapter extends TypeAdapter<IconData> {
  @override
  final int typeId = 42; // A unique ID for this adapter

  @override
  IconData read(BinaryReader reader) {
    var codePoint = reader.readInt();
    var fontFamily = reader.readString();
    var fontPackage = reader.readString();
    return IconData(codePoint, fontFamily: fontFamily, fontPackage: fontPackage);
  }

  @override
  void write(BinaryWriter writer, IconData obj) {
    writer.writeInt(obj.codePoint);
    writer.writeString(obj.fontFamily!);
    writer.writeString(obj.fontPackage ?? '');
  }
}