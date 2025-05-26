import 'package:todo/models/item.dart';

/// Represents a folder item with a list of child items.
/// The child items are the ones to be displayed in the [start_screen] and
/// are not necessarily all files in the folder.
///
/// Properties:
/// - `children`: A list of child items contained within the folder.
class FolderItem extends Item {
  List<Item> children = [];
  bool isCollapsed = false;

  FolderItem(
      {required super.title,
      required super.uri,
      super.parentUri,
      super.isPinned = false,
      this.isCollapsed = false,
      required this.children});

  @override
  Map<String, dynamic> toJson() => {
        'title': title,
        'uri': uri.toString(),
        'isPinned': isPinned,
        'isFolder': true,
        'isCollapsed': isCollapsed,
        'children': children.map((e) => e.toJson()).toList()
      };

  factory FolderItem.fromJson(Map<String, dynamic> json, Uri? parentUri) {
    final uri = Uri.parse(json['uri']);
    try {
      var jkids = json['children'] as List<dynamic>?;
      var children =
          jkids?.map((e) => Item.fromJson(e, uri)).toList() ?? List.empty();
      return FolderItem(
        title: json['title'] ?? Item.titleFromUri(uri),
        uri: uri,
        parentUri: parentUri,
        isPinned: json['isPinned'] ?? false,
        isCollapsed: json['isCollapsed'] ?? false,
        children: children,
      );
    } catch (e) {
      return FolderItem(
          title: Item.titleFromUri(uri),
          uri: uri,
          parentUri: parentUri,
          isPinned: false,
          isCollapsed: false,
          children: []);
    }
  }
}
