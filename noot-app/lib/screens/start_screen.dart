import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:todo/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:todo/models/file_item.dart';
import 'package:todo/models/folder_item.dart';
import 'package:todo/models/header_item.dart';
import 'package:todo/models/item.dart';
import 'package:todo/repository/file_manager.dart';
import 'package:todo/theme/state_colors.dart';
import 'package:todo/utils/file_io_manager.dart';
import 'package:todo/utils/preferences_manager.dart';
import 'package:todo/utils/ui_utils.dart';
import 'package:todo/widgets/dialogs/filename_dialog.dart';
import 'package:todo/widgets/file_item_widget.dart';
import 'package:todo/widgets/folder_item_widget.dart';

import '../theme/theme.dart';

/// The starting screen of the application, displaying a list of files and folders.
/// In tablet mode, this is the sidebar.
class StartScreen extends StatefulWidget {
  /// Callback when an item is selected.
  final Function<Void>(FileItem?) itemSelectedCallback;
  /// When the settings button is selected
  final VoidCallback onSettingsSelected;
  /// When sidebar is expanded or collapsed (tablet only)
  final VoidCallback? onCollapseExpand;
  final bool isCollapsed;
  final PreferenceManager prefs;

  const StartScreen(
      {super.key,
      required this.itemSelectedCallback,
      required this.onSettingsSelected,
      required this.isCollapsed,
      this.onCollapseExpand,
      required this.prefs});

  @override
  StartScreenState createState() => StartScreenState();
}

/// State class for [StartScreen].
class StartScreenState extends State<StartScreen> {
  /// Manages the list of files and folders opened.
  final FileManager _fileManager = FileManager();

  /// Manages file access and permissions
  late FileIOManager _ioManager;

  /// List of file items to display.
  List<Item> _fileItems = [];

  /// The currently selected item.
  Uri? _selectedItemUri;

  late AppLocalizations _locale;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    WidgetsBinding.instance.addPostFrameCallback((_) => _reload());
  }

  /// Shows a snackbar with the given [message].
  void _showSnackbar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }

  /// Reloads the list of file items from disk.
  Future<void> _reload() async {
    final list = await _fileManager.load();
    setState(() {
      _fileItems = list;
    });
  }

  /// Refreshes the list of file items.
  void _refresh() {
    setState(() {
      _fileItems = _fileManager.getItems(widget.prefs);
    });
  }

  /// Removes a file with the given [uri].
  void _removeFile(Uri uri) async {
    await _fileManager.removeFile(uri);
    _refresh();
  }

  /// Removes a file with the given [uri].
  void _removeFolder(Uri uri) async {
    await _fileManager.removeFolder(uri);
    _refresh();
  }

  /// Refreshes content of a folder
  void _refreshFolder(Uri uri) async {
    try {
      await _fileManager.refreshFolder(uri.toString(), false, _ioManager,
          !widget.prefs.limitToTxtAndMD, widget.prefs.showHiddenFiles);
      _refresh();
    } on PlatformException catch (e) {
      debugPrint(e.toString());
      _showSnackbar(_locale.unable_to_open_folder);
    }
    _refresh();
  }

  /// Pins a file with the given [uri].
  void _pinFile(Uri uri) async {
    await _fileManager.pin(uri);
    _refresh();
  }

  /// Unpins a file with the given [uri].
  void _unpinFile(Uri uri) async {
    await _fileManager.unpin(uri);
    _refresh();
  }

  /// Shares a file with the given [uri].
  Future<void> _shareFile(Uri uri) async {
    Share.share(await _ioManager.getContentString(uri.toString()));
  }

  /// Navigates to the edit screen for the given [fileUri].
  void _navigateToEditScreen(FileItem? fileItem) {
    widget.itemSelectedCallback(fileItem);
    _refresh();
  }

  /// Creates a new file.
  void _createFile({bool replace = false}) async {
    _selectedItemUri = null;

    final fileName = await showDialog<String>(
      context: context,
      builder: (context) {
        return FilenameDialog(
            onCancelled: () => Navigator.of(context).pop(null),
            onConfirmed: (value) => Navigator.of(context).pop(value));
      },
    );

    if (fileName != null) {
      final dir = await _ioManager.pickFolder();
      if (dir != null) {
        try {
          final isMarkdown = fileName.toLowerCase().endsWith(".md");
          final fileUri = await _ioManager.saveFileToDirectory(
              dir.uri, fileName,
              mimeType: isMarkdown ? 'text/markdown' : 'text/plain');
          final editMode = isMarkdown ? EditMode.text : EditMode.todo;
          final fileItem = await _fileManager.addFile(
              fileName, fileUri, 0.0, 0, 0, editMode);

          setState(() {
            _selectedItemUri = fileItem?.uri;
            _navigateToEditScreen(fileItem);
          });
        } on PlatformException catch (e) {
          // FIXME magic string
          if (e.code == 'file_already_exists') {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _showSnackbar(_locale.file_exists);
            });
            return null;
          }
        }
      }
    }
  }

  /// Picks a file using the file dialog.
  Future<void> _pickFile() async {
    try {
      final fileUri = await _ioManager.pickFile();
      if (fileUri != null) {
        await _openFileUri(fileUri);
      }
    } on PlatformException catch (e) {
      // FIXME magic string
      if (e.code == 'invalid_file_extension') {
        _showSnackbar(_locale.cannot_open_this_type);
      }
    }
  }

  /// Loads the file, adds it to the filemanager, requests persistent
  /// permissions, and opens the associated editor.
  Future<void> _openFileUri(String fileUri) async {
    // Take persistable URI permission
    await _ioManager.takePersistableUriPermission(fileUri);

    final content = await _ioManager.getContent(fileUri);
    final item = await _fileManager.addFile(
        content.fileName ?? _locale.untitled,
        fileUri,
        0.0,
        0,
        0,
        content.fileName?.endsWith(".md") == true ||
                widget.prefs.defaultModeText
            ? EditMode.text
            : EditMode.todo);
    setState(() {
      _fileItems = _fileManager.getItems(widget.prefs);
    });
    _navigateToEditScreen(item);
  }

  /// Picks a folder using the file dialog.
  Future<void> _pickFolder() async {
    try {
      final dir = await _ioManager.pickFolder();

      if (dir != null) {
        await _fileManager.addFolder(dir.uri, dir.name, false, _ioManager,
            !widget.prefs.limitToTxtAndMD, widget.prefs.showHiddenFiles);
        _refresh();
      } else {
        // failed to get the permission
        _showSnackbar(_locale.unable_to_open_folder);
      }
    } on PlatformException catch (e) {
      debugPrint(e.toString());
      _showSnackbar(_locale.unable_to_open_folder);
    }
  }

  @override
  void initState() {
    super.initState();
    _ioManager = Provider.of<FileIOManager>(context, listen: false);
  }

  void _navigateToSettingsScreen() {
    widget.onSettingsSelected();
  }

  @override
  Widget build(BuildContext context) {
    _locale = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colors = theme.extension<StateColors>()!;
    var useTabletLayout = isTablet(context);

    return Scaffold(
      backgroundColor:
          useTabletLayout ? colors.backgroundDarker : colors.background,
      appBar: _buildAppBar(theme, colors, useTabletLayout),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            if (widget.isCollapsed)
              Expanded(child: Container())
            else if (_fileItems.isNotEmpty)
              _buildFileTree(theme)
            else
              Expanded(
                child: Center(
                  child: Text(
                    _locale.press_plus_to_create,
                    style: theme.textTheme.bodyMedium,
                  ),
                ),
              ),
            _buildBottomBar(colors)
          ],
        ),
      ),
    );
  }

  /// Top bar, with app name and optional expand/collapse button
  AppBar _buildAppBar(
      ThemeData theme, StateColors colors, bool useTabletLayout) {
    final orangeStyle = theme.textTheme.bodyMedium?.copyWith(
        color: AppTheme.orange, fontWeight: FontWeight.bold, fontSize: 19.0);

    return AppBar(
      backgroundColor:
          useTabletLayout ? colors.backgroundDarker : colors.background,
      elevation: 4.0,
      title: widget.isCollapsed
          ? null
          : RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: _locale.app_name_shorter,
                    style: theme.textTheme.bodyMedium!
                        .copyWith(fontWeight: FontWeight.bold, fontSize: 19.0),
                  ),
                  TextSpan(
                    text: '.',
                    style: orangeStyle,
                  ),
                ],
              ),
            ),
      actions: [
        if (widget.onCollapseExpand != null)
          Padding(
              padding: const EdgeInsets.only(right: 10.0),
              child: IconButton(
                icon: Transform.rotate(
                  angle: -math.pi / 2,
                  child: Icon(
                      widget.isCollapsed
                          ? Icons.expand_circle_down
                          : Icons.expand_less,
                      color: colors.icons),
                ),
                onPressed: () {
                  widget.onCollapseExpand!();
                },
              )),
      ],
    );
  }

  Expanded _buildFileTree(ThemeData theme) {
    return Expanded(
        child: RefreshIndicator(
            onRefresh: _reload,
            backgroundColor: AppTheme.bright_backgroundDarker,
            child: ListView.builder(
              itemCount: _fileItems.length,
              padding: EdgeInsets.only(bottom: 96.0),
              itemBuilder: (context, index) {
                final fileItem = _fileItems[index];
                if (fileItem.isHeader) {
                  return _buildSectionHeader(theme, fileItem as HeaderItem);
                } else if (fileItem.isFolder) {
                  return _buildFolderItem(fileItem);
                } else if (fileItem.isChild &&
                    _fileManager.hasCollapsedParent(fileItem)) {
                  return Container();
                } else {
                  return _buildFileItem(fileItem);
                }
              },
            )));
  }

  Widget _buildSectionHeader(ThemeData theme, HeaderItem fileItem) {
    String title = fileItem.title;
    if (fileItem.section == Section.pinned) {
      title = _locale.section_header_pinned;
    } else if (fileItem.section == Section.files) {
      title = _locale.section_header_files;
    } else if (fileItem.section == Section.folders) {
      title = _locale.section_header_folders;
    }
    return Padding(
        padding: EdgeInsets.only(top: 8.0, bottom: 8.0, left: 16.0),
        child: Text(
          title,
          style: theme.textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ));
  }

  Widget _buildFileItem(Item fileItem) {
    return FileItemWidget(
      fileItem: fileItem as FileItem,
      isSelected: fileItem.uri == _selectedItemUri,
      onTap: () async {
        setState(() {
          _selectedItemUri = fileItem.uri;
        });
        await _fileManager.resetLastOpened(fileItem.uri.toString());
        _navigateToEditScreen(fileItem);
      },
      onPin: () {
        _pinFile(fileItem.uri!);
      },
      onUnpin: () {
        _unpinFile(fileItem.uri!);
      },
      onShare: () {
        _shareFile(fileItem.uri!);
      },
      onDelete: () {
        _removeFile(fileItem.uri!);
      },
    );
  }

  Widget _buildFolderItem(Item fileItem) {
    return FolderItemWidget(
        folderItem: fileItem as FolderItem,
        onTap: () {
          setState(() {
            fileItem.isCollapsed = !fileItem.isCollapsed;
            _fileManager.save();
          });
        },
        onPin: () {},
        onUnpin: () {},
        onDelete: () {
          _removeFolder(fileItem.uri!);
        },
        onRefresh: () {
          _refreshFolder(fileItem.uri!);
        });
  }

  /// Button toolbar, with file add/open buttons and settings.
  /// When the screen is collapsed, only the settingsbutton shows.
  Widget _buildBottomBar(StateColors colors) {
    return Container(
      color: colors.backgroundDarker,
      child: Align(
          alignment: Alignment.bottomRight,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 8.0, right: 8.0, top: 8.0),
            child: SafeArea(
                child: Row(
              children: [
                Expanded(child: SizedBox(height: 1.0)),
                if (!widget.isCollapsed)
                  IconButton(
                    padding: const EdgeInsets.all(8.0),
                    icon: Icon(Icons.add, color: colors.icons),
                    onPressed: _createFile,
                    tooltip: _locale.tooltip_create,
                  ),
                if (!widget.isCollapsed)
                  IconButton(
                    padding: const EdgeInsets.all(8.0),
                    icon: Icon(Icons.file_open, color: colors.icons),
                    onPressed: _pickFile,
                    tooltip: _locale.tooltip_open,
                  ),
                if (!widget.isCollapsed)
                  IconButton(
                    padding: const EdgeInsets.all(8.0),
                    icon: Icon(Icons.folder, color: colors.icons),
                    onPressed: _pickFolder,
                    tooltip: _locale.tooltip_open_folder,
                  ),
                IconButton(
                  padding: const EdgeInsets.all(8.0),
                  icon: Icon(Icons.settings, color: colors.icons),
                  onPressed: _navigateToSettingsScreen,
                  tooltip: _locale.tooltip_settings,
                ),
              ],
            )),
          )),
    );
  }
}
