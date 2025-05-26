import 'package:flutter/material.dart';
import 'package:todo/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:todo/repository/file_manager.dart';
import 'package:todo/screens/edit_screen.dart';
import 'package:todo/screens/settings_screen.dart';
import 'package:todo/screens/start_screen.dart';
import 'package:todo/utils/file_io_manager.dart';
import 'package:todo/utils/preferences_manager.dart';
import 'package:todo/utils/ui_utils.dart';
import 'package:todo/widgets/dialogs/confirmation_dialog.dart';

import '../models/file_item.dart';

class MasterDetailContainer extends StatefulWidget {
  const MasterDetailContainer({super.key});

  @override
  MasterDetailContainerState createState() => MasterDetailContainerState();
}

enum SelectedPage { none, file, settings }

class MasterDetailContainerState extends State<MasterDetailContainer> {
  late FileIOManager _ioManager;
  late FileManager _fileManager;

  // Track the currently selected item here. Only used for
  // tablet layouts.
  FileItem? _selectedItem;
  SelectedPage _selectedPage = SelectedPage.none;
  bool _hasUnsavedChanges = false;
  GlobalKey<EditScreenState> _editScreenKey = GlobalKey<EditScreenState>();
  PreferenceManager? _prefs;

  void _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _prefs = PreferenceManager(prefs);
    });
  }

  @override
  void initState() {
    super.initState();
    // TODO use provider for this one too
    _fileManager = FileManager();
    _ioManager = Provider.of<FileIOManager>(context, listen: false);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _loadPrefs();
      if (_ioManager.fileUri != null) {
        await _fileManager.load();
        _onFileShared(uri: _ioManager.fileUri!);
        _ioManager.consume();
      }
      _ioManager.addListener(() {
        _onFileShared();
      });
    });
  }

  @override
  void dispose() {
    _ioManager.removeListener(_onFileShared);
    super.dispose();
  }

  void _onFileShared({String? uri}) async {
    final file = uri ?? _ioManager.fileUri!;
    debugPrint('Opening file: $file');

    final content = await _ioManager.getContent(file);
    final fileItem = await _fileManager.addFile(
        content.fileName,
        file,
        0.0,
        0,
        0,
        content.fileName?.endsWith(".md") == true ||
                _prefs?.defaultModeText == true
            ? EditMode.text
            : EditMode.todo);
    _fileManager.save();

    if (_editScreenKey.currentState?.mounted == true) {
      _confirmBeforeNavigating(context, () {
        setState(() {
          _selectedItem = fileItem;
          _hasUnsavedChanges = false;
          _editScreenKey = GlobalKey<EditScreenState>();
          _selectedPage = SelectedPage.file;
        });
      }, () {
        setState(() {
          _selectedItem = fileItem;
          _hasUnsavedChanges = false;
          _editScreenKey = GlobalKey<EditScreenState>();
          _selectedPage = SelectedPage.file;
        });
      });
    } else {
      // FIXME don't access the context here
      // use navigatorKey.currentState? instead
      // Disabled for now, because popping leads to an empty stack
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => EditScreen(
              prefs: _prefs!,
              fileItem: fileItem,
              onChanged: () {},
              onSaved: () {}),
        ),
      );
    }
  }

  /// On mobile, we show the start screen (and navigate to the edit screen or settings)
  Widget _buildMobileLayout() {
    return StartScreen(
      prefs: _prefs!,
      isCollapsed: false,
      itemSelectedCallback: <Void>(FileItem? fileItem) {
        // navigatorKey.currentState?.push(
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => EditScreen(
                prefs: _prefs!,
                fileItem: fileItem,
                onChanged: () {},
                onSaved: () {}),
          ),
        );
      },
      onSettingsSelected: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => SettingsScreen(),
          ),
        );
      },
    );
  }

  /// For tablets, return a layout that has the file overview on the left
  /// and details on the right.
  Widget _buildTabletLayout() {
    final theme = Theme.of(context);
    return Padding(
        // FIXME temporary ugly padding to account for captionBar
        // Edge-to-edge APIs should be able to fix this, but I've had no luck on
        // Android's Desktop mode yet in Flutter.
        padding: EdgeInsets.only(top: _prefs!.fixPadding ? 40.0 : 0),
        child: Row(
          children: [
            _prefs?.sidebarCollapsed == true
                ? SizedBox(width: 64, child: _buildLeftPanel())
                : Flexible(
                    flex: 1,
                    child: _buildLeftPanel(),
                  ),
            ScaffoldMessenger(
              child: Builder(
                  builder: (context) => Flexible(
                      flex: 3,
                      child: switch (_selectedPage) {
                        SelectedPage.none => Container(
                            color: theme.scaffoldBackgroundColor,
                          ),
                        SelectedPage.settings => SettingsScreen(),
                        SelectedPage.file => EditScreen(
                            key: _editScreenKey,
                            fileItem: _selectedItem,
                            prefs: _prefs!,
                            onChanged: () => {
                              setState(() {
                                _hasUnsavedChanges = true;
                              })
                            },
                            onSaved: () => {
                              setState(() {
                                _hasUnsavedChanges = false;
                              })
                            },
                          )
                      })),
            ),
          ],
        ));
  }

  @override
  Widget build(BuildContext context) {
    if (_prefs == null) {
      return Container();
    }
    return isTablet(context) ? _buildTabletLayout() : _buildMobileLayout();
  }

  /// Before navigating away from a fille with unsaved changes, we ask for
  /// confirmation. Also we save the scroll position of the current file.
  void _confirmBeforeNavigating(BuildContext context, Function() onDiscard,
      Function() whenAlreadySaved) async {
    // Store scroll position
    await _editScreenKey.currentState?.storeScrollPosition();
    if (_hasUnsavedChanges && context.mounted) {
      bool? discard = await _showConfirmationDialog(context);
      if (discard == true) {
        onDiscard();
      }
    } else {
      whenAlreadySaved();
    }
  }

  /// Before navigating away from a file with unsaved changes, we ask for confirmation
  Future<bool> _showConfirmationDialog(BuildContext context) async {
    AppLocalizations locale = AppLocalizations.of(context)!;

    // Show the dialog and return true if the user decides to discard changes
    return await showDialog(
            context: context,
            builder: (context) => ConfirmationDialog(
                  title: locale.confirm,
                  content: locale.confirm_discard_changes,
                  onConfirmed: () => Navigator.of(context).pop(true),
                  onCancelled: () => Navigator.of(context).pop(false),
                )) ??
        false; // If the user taps outside the dialog or presses the back button, return false
  }

  /// Builds the left-hand panel for the tablet layout (i.e. the start screen)
  Widget _buildLeftPanel() {
    return Material(
        elevation: 4.0,
        child: ScaffoldMessenger(
            child: Builder(
                builder: (context) => StartScreen(
                      prefs: _prefs!,
                      // Instead of pushing a new route here, we update
                      // the currently selected item, which is a part of
                      // our state now.
                      itemSelectedCallback: <Void>(FileItem? fileItem) async {
                        _confirmBeforeNavigating(context, () {
                          setState(() {
                            if (fileItem?.uri == null) {
                              _selectedItem = null;
                              _selectedPage = SelectedPage.none;
                            } else {
                              // fileItem?.title ??= '';
                              _selectedItem = fileItem!;
                              _selectedPage = SelectedPage.file;
                            }
                            _hasUnsavedChanges = false;
                            _editScreenKey = GlobalKey<EditScreenState>();
                            _selectedPage = SelectedPage.file;
                          });
                        }, () {
                          setState(() {
                            if (fileItem == null) {
                              _selectedItem = FileItem(title: '', uri: null);
                            } else if (fileItem.uri == null) {
                              _selectedItem = null;
                            } else {
                              // fileItem.title ??= '';
                              _selectedItem = fileItem;
                            }
                            _hasUnsavedChanges = false;
                            _editScreenKey = GlobalKey<EditScreenState>();
                            _selectedPage = SelectedPage.file;
                          });
                        });
                      },

                      onCollapseExpand: () => {
                        setState(() {
                          _prefs!.sidebarCollapsed = !_prefs!.sidebarCollapsed;
                        })
                      },

                      isCollapsed: _prefs?.sidebarCollapsed ?? false,

                      onSettingsSelected: () => {
                        if (context.mounted)
                          {
                            _confirmBeforeNavigating(context, () {
                              setState(() {
                                _selectedPage = SelectedPage.settings;
                              });
                            }, () {
                              setState(() {
                                _selectedPage = SelectedPage.settings;
                              });
                            })
                          }
                      },
                    ))));
  }
}
