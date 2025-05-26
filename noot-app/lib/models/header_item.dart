import 'package:todo/models/item.dart';

enum Section { pinned, files, folders }

/// Represents an entry in the list that is only a section header
class HeaderItem extends Item {
  Section section = Section.pinned;

  HeaderItem({required this.section}) : super(title: '');

  @override
  Map<String, dynamic> toJson() => {};

  factory HeaderItem.fromJson(Map<String, dynamic> json, Uri? parentUri) {
    return HeaderItem(section: Section.pinned);
  }
}
