import 'package:todo/models/file_item.dart';
import 'package:todo/models/folder_item.dart';
import 'package:todo/models/header_item.dart';

/// Base class for file and folder items.
/// An item is an entry in the start screen and can either be a single file, or
/// a folder with subitems, or a section header.
abstract class Item {
  String title;
  Uri? uri;
  Uri? parentUri;
  bool isPinned = false;

  Item({required this.title, this.uri, this.parentUri, this.isPinned = false});

  get isFolder => this is FolderItem;

  get isHeader => this is HeaderItem;

  bool get isChild => parentUri != null;

  get sortPath => '${parentUri.toString()}/$title';

  Item pin() {
    isPinned = true;
    return this;
  }

  Item unpin() {
    isPinned = false;
    return this;
  }

  Map<String, dynamic> toJson();

  factory Item.fromJson(Map<String, dynamic> json, Uri? parentUri) {
    if (json['isFolder'] == true) {
      return FolderItem.fromJson(json, parentUri);
    } else {
      return FileItem.fromJson(json, parentUri);
    }
  }

  static String titleFromUri(Uri uri) {
    return uri.pathSegments.last.split('.').first;
  }

  @override
  String toString() {
    return 'Item{title: $title, uri: $uri, isFolder: $isFolder, isChild: $isChild}';
  }
}
