import 'dart:async';

import 'package:content_resolver/content_resolver.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';

/// Monitors a file for changes and reports back when the file has changed
/// or is deleted.
/// Since Android does not allow us to get the lastModified of a file,
/// we read it, hash it, and compare it periodically.
class FileMonitorService {
  final String fileUri;
  Digest? _previousHash;
  Timer? _timer;
  final Duration checkInterval;
  final Function onFileChanged;
  final Function onFileDeleted;
  bool _ignoreNextChange = false;

  FileMonitorService(
      {required this.fileUri,
      this.checkInterval = const Duration(seconds: 5),
      required this.onFileChanged,
      required this.onFileDeleted});

  void startMonitoring() {
    // Initial hash computation
    _computeHash().then((hash) {
      _previousHash = hash;
      // Start periodic monitoring
      _timer = Timer.periodic(checkInterval, (_) async {
        Digest? currentHash = await _computeHash();
        if (currentHash == null) {
          onFileDeleted();
          return;
        }
        if (_previousHash == null) {
          _previousHash = currentHash;
        } else if (currentHash != _previousHash) {
          _previousHash = currentHash;
          if (_ignoreNextChange) {
            _ignoreNextChange = false;
          } else {
            onFileChanged();
          }
        }
      });
    });
  }

  void stopMonitoring() {
    _timer?.cancel();
    _timer = null;
  }

  /// Call this method before saving the file, so we don't report a change
  /// that was made from within the app.
  void ignoreNextChange() {
    _ignoreNextChange = true;
  }

  Future<Digest?> _computeHash() async {
    try {
      // Fetch file bytes from content provider via platform channel
      Uint8List? fileBytes = await _fetchFileBytes(fileUri);
      if (fileBytes.isEmpty) {
        return Digest([]);
      }

      // Compute SHA-256 hash
      Digest hash = sha256.convert(fileBytes);
      return hash;
    } catch (e) {
      debugPrint('Error computing hash: $e');
      return null;
    }
  }

  Future<Uint8List> _fetchFileBytes(String uri) async {
    try {
      final content = await ContentResolver.resolveContent(fileUri);
      return content.data;
    } catch (e) {
      debugPrint('Error fetching file bytes from uri $uri, file deleted?\n'
          'Error: $e');
      return Uint8List(0);
    }
  }

  bool isMonitoring() {
    return _timer != null;
  }
}
