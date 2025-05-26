import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:saf_util/saf_util_platform_interface.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:todo/models/file_item.dart';
import 'package:todo/models/folder_item.dart';
import 'package:todo/models/header_item.dart';
import 'package:todo/models/item.dart';
import 'package:todo/utils/file_io_manager.dart';
import 'package:todo/utils/preferences_manager.dart';

/// Manages file and folder data, and serialization to json.
class FileManager {
  /// Toggle to enable demo mode (fake files) for screenshots
  static const enableDemoMode = false;

  /// When enabling demo mode, usually we also want to hide the banner (for screenshots)
  static const showBanner = false;

  /// The file tree structure, containing both picked files and folders.
  List<Item> _tree = List.empty(growable: true);

  /// Converts the _tree to a flat list of all files, folders and child-files.
  /// Items are sorted, and headers are injected at the right places.
  /// Sorting happens as follows:
  /// 1. Pinned files are always at the top
  /// 2. Folders and children of folders are always at the bottom
  /// 3. If enabled, files are sorted by lastOpenedTime, otherwise by name
  List<Item> getItems(PreferenceManager prefs) {
    // Expand all folders
    _tree.sort((a, b) {
      // Folders and children of folders should always come after others.
      if ((a.isFolder || a.isChild) && !(b.isFolder || b.isChild)) {
        return 1;
      }
      if (!(a.isFolder || a.isChild) && (b.isFolder || b.isChild)) {
        return -1;
      }

      if (a.isPinned == b.isPinned) {
        // If both items have the same pinned status, and are not folders or children,
        // then sort by lastOpenedTime
        if (prefs.sortByOpened &&
            !a.isFolder &&
            !a.isChild &&
            !b.isFolder &&
            !b.isChild) {
          return (b as FileItem)
              .lastOpenedTime
              .compareTo((a as FileItem).lastOpenedTime);
        }
        // ... sort by name / path
        return a.sortPath.compareTo(b.sortPath);
      }
      // Otherwise, prioritize pinned items
      return a.isPinned ? -1 : 1;
    });

    // Expand, add child items to their parent items
    var result = _tree.expand((i) {
      if (i.isFolder) {
        return [i, ...(i as FolderItem).children];
      } else {
        return [i];
      }
    });

    final resultList = result.toList();

    // Add header for pinned files
    if (result.isNotEmpty && !result.first.isFolder && result.first.isPinned) {
      resultList.insert(0, HeaderItem(section: Section.pinned));
    }
    // Insert header for files
    for (int i = 0; i < resultList.length; i++) {
      if (!resultList[i].isFolder &&
          !resultList[i].isPinned &&
          !resultList[i].isHeader) {
        resultList.insert(i, HeaderItem(section: Section.files));
        break;
      }
    }
    // Insert header for folders
    for (int i = 0; i < resultList.length; i++) {
      if (resultList[i].isFolder) {
        resultList.insert(i, HeaderItem(section: Section.folders));
        break;
      }
    }

    return resultList;
  }

  /// Serializes the file tree to json in the preferences.
  Future<void> save() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> fileItemJsonList =
        _tree.map((fileItem) => jsonEncode(fileItem.toJson())).toList();
    await prefs.setStringList('fileItems', fileItemJsonList);
  }

  /// Loads the json from the prefs into the _tree.
  /// If demo mode is enabled, returns a fake list of files.
  Future<List<Item>> load() async {
    if (enableDemoMode && kDebugMode) {
      _tree = [
        FileItem(
          title: 'To Do.txt',
          uri: Uri.parse('file:///To Do.txt'),
          lastOpenedTime: DateTime.now().millisecondsSinceEpoch,
          isPinned: true,
        ),
        FolderItem(
            title: 'Shopping',
            uri: Uri.parse('file:///Shopping'),
            children: [
              FileItem(
                title: 'Shopping list.txt',
                uri: Uri.parse('file:///Shopping list.txt'),
                parentUri: Uri.parse('file:///Shopping'),
                lastOpenedTime: DateTime.now()
                    .subtract(const Duration(hours: 4))
                    .millisecondsSinceEpoch,
              ),
              FileItem(
                title: 'Records whishlist.txt',
                uri: Uri.parse('file:///Records whishlist.txt'),
                parentUri: Uri.parse('file:///Shopping'),
                lastOpenedTime: DateTime.now()
                    .subtract(const Duration(days: 3))
                    .millisecondsSinceEpoch,
              ),
            ])
      ];
    } else {
      final prefs = await SharedPreferences.getInstance();
      List<String>? fileItemJsonList = prefs.getStringList('fileItems');
      if (fileItemJsonList != null) {
        _tree = fileItemJsonList
            .map(
                (fileItemJson) => Item.fromJson(jsonDecode(fileItemJson), null))
            .toList();
      }
    }

    final prefs = await SharedPreferences.getInstance();
    return getItems(PreferenceManager(prefs));
  }

  Item getFileAtPosition(int index) {
    return _tree[index];
  }

  Future<Item?> removeFile(Uri uri) async {
    final item = getItemByUri(uri.toString());
    if (item != null) {
      _tree.remove(item);
      await save();
    }
    return item;
  }

  Future<Item?> removeFolder(Uri uri) async {
    return removeFile(uri);
  }

  Future<Item?> pin(Uri uri) async {
    final item = getItemByUri(uri.toString());
    if (item != null) {
      item.pin();
      await save();
    }
    return item;
  }

  Future<Item?> unpin(Uri uri) async {
    final item = getItemByUri(uri.toString());
    if (item != null) {
      item.unpin();
      await save();
    }
    return item;
  }

  /// Adds a hew file to the tree. If the file already exists, it will be updated.
  Future<FileItem?> addFile(
      String? title,
      String fileUri,
      double scrollPosition,
      int selectionStart,
      int selectionEnd,
      EditMode editMode) async {
    final item = getItemByUri(fileUri);
    // If item is null, we add it as a new item
    if (item == null) {
      title ??= fileUri.split('/').last;
      final newItem = FileItem(
          title: title,
          uri: Uri.parse(fileUri),
          scrollPositionTodo: 0.0,
          scrollPositionText: 0.0);
      newItem.editMode = editMode;
      if (editMode == EditMode.text) {
        newItem.scrollPositionText = scrollPosition;
        newItem.selectionStart = selectionStart;
        newItem.selectionEnd = selectionEnd;
      } else {
        newItem.scrollPositionTodo = scrollPosition;
      }
      _tree.add(newItem);
      await save();
      return newItem;
    } else if (item is FileItem) {
      // Update existing item
      item.editMode = editMode;
      if (editMode == EditMode.text) {
        item.scrollPositionText = scrollPosition;
        item.selectionStart = selectionStart;
        item.selectionEnd = selectionEnd;
      } else {
        item.scrollPositionTodo = scrollPosition;
      }
      return item;
    }
    return null;
  }

  /// Adds a new folder to the tree, updates its content if it already exists.
  Future<void> addFolder(
      String uriString,
      String foldername,
      bool recurse,
      FileIOManager ioManager,
      bool includeNonTxtOrMd,
      bool includeHidden) async {
    FolderItem folderItem = await _readFolder(uriString, ioManager, foldername,
        recurse, includeNonTxtOrMd, includeHidden);
    // If already added, replace the old one
    if (_tree.any((item) => item.uri == folderItem.uri && item.isFolder)) {
      _tree.removeWhere((item) => item.uri == folderItem.uri && item.isFolder);
    }
    _tree.add(folderItem);
    save();
  }

  /// Rescans the content of a folder, updates its content if needed.
  /// Changes might occur if new files are added on disk, or if the user's
  /// preferences have changed regarding which files to include.
  Future<void> refreshFolder(
      String uriString,
      bool recurse,
      FileIOManager ioManager,
      bool includeNonTxtOrMd,
      bool includeHidden) async {
    final oldFolderItem = findItemByUri(uriString);
    if (oldFolderItem != null) {
      FolderItem folderItem = await _readFolder(uriString, ioManager,
          oldFolderItem.title, recurse, includeNonTxtOrMd, includeHidden);
      _tree.removeWhere((item) => item.uri == folderItem.uri && item.isFolder);
      _tree.add(folderItem);
      save();
    }
  }

  /// Reads the content of a folder, and returns a [FolderItem] object
  /// representing it.
  Future<FolderItem> _readFolder(
      String uriString,
      FileIOManager ioManager,
      String foldername,
      bool recurse,
      bool includeNonTxtOrMd,
      bool includeHidden,
      {int depth = 0}) async {
    debugPrint('Reading folder $foldername');
    final uri = Uri.parse(uriString);
    List<SafDocumentFile> files = await ioManager.listFiles(uriString);
    final children = List<Item>.empty(growable: true);
    for (var file in files) {
      bool isHidden = file.name.startsWith('.');
      bool isTxtOrMd = file.name.endsWith('.txt') || file.name.endsWith('.md');
      if (isHidden && (!includeHidden || !includeNonTxtOrMd)) {
        // ignore dotfiles
        debugPrint('  ignoring dotfile ${file.uri}');
      } else if (!isTxtOrMd && !includeNonTxtOrMd) {
        debugPrint('  ignoring non-compatible file ${file.uri}');
      } else if (file.isDir) {
        debugPrint('  child ${file.uri}');
        if (recurse) {
          final child = await _readFolder(file.uri, ioManager, file.name,
              recurse, includeNonTxtOrMd, includeHidden,
              depth: depth + 1);
          // child.parentUri = file.uri;
          children.add(child);
        }
      } else {
        children.add(FileItem(
          title: file.name,
          uri: Uri.parse(file.uri),
          lastOpenedTime: file.lastModified,
          isPinned: false,
          parentUri: uri,
        ));
      }
    }
    final folderItem = FolderItem(
        title: foldername,
        uri: uri,
        isPinned: false,
        children: children.toList(),
        parentUri: uri);
    return folderItem;
  }

  /// Finds an item by its URI.
  /// Note: does not find items in second level. Use `findItemByUri` instead to
  /// do a nested search.
  Item? getItemByUri(String? fileUri) {
    try {
      return _tree.firstWhere((fileItem) => fileItem.uri.toString() == fileUri);
    } on StateError {
      return null;
    }
  }

  /// Finds an item by its URI.
  Item? findItemByUri(String? fileUri) {
    for (var value in _tree) {
      var item = _findItemByUri(value, fileUri);
      if (item != null) {
        return item;
      }
    }
    return null;
  }

  /// Inner helper method for `findItemByUri`. Takes an item as the root
  /// for a nested search instead of the tree.
  Item? _findItemByUri(Item item, String? fileUri) {
    if (item.uri.toString() == fileUri) {
      return item;
    }
    if (item is FolderItem) {
      for (var child in item.children) {
        var found = _findItemByUri(child, fileUri);
        if (found != null) {
          return found;
        }
      }
    }
    return null;
  }

  Future<Item?> updateScrollOffset(String? fileUri, double scrollPosition,
      int selectionStart, int selectionEnd, EditMode editMode) async {
    final item = findItemByUri(fileUri);
    if (item != null && !item.isFolder) {
      final fi = item as FileItem;
      fi.editMode = editMode;
      if (editMode == EditMode.text) {
        fi.scrollPositionText = scrollPosition;
        fi.selectionStart = selectionStart;
        fi.selectionEnd = selectionEnd;
      } else {
        fi.scrollPositionTodo = scrollPosition;
      }
      await save();
    }
    return item;
  }

  Future<Item?> resetLastOpened(String? fileUri) async {
    final item = getItemByUri(fileUri);
    if (item != null && !item.isFolder) {
      final fi = item as FileItem;
      fi.resetLastOpened();
      await save();
    }
    return item;
  }

  void updateTitle(String title, String? fileUri) {
    final item = getItemByUri(fileUri);
    item?.title = title;
    save();
  }

  /// Clears the entire tree and saves it.
  void clear() async {
    _tree.clear();
    await save();
  }

  /// Checks if an item is hidden because its parent is collapsed.
  bool hasCollapsedParent(Item fileItem) {
    if (fileItem.isChild) {
      final parent = getItemByUri(fileItem.parentUri.toString());
      // TODO when supporting nested folders, we should recurse
      return (parent is FolderItem && parent.isCollapsed);
    }
    return false;
  }
}
