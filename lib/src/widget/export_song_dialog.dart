import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:myanmar_hymns/src/dto/song_dto.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class ExportSongDialog extends StatefulWidget {
  final SongDTO song;
  final double fontScale;

  const ExportSongDialog({
    super.key,
    required this.song,
    required this.fontScale,
  });

  @override
  State<ExportSongDialog> createState() => _ExportSongDialogState();
}

class _ExportSongDialogState extends State<ExportSongDialog> {
  // Key for capturing the fixed-width offscreen export card
  final GlobalKey _exportBoundaryKey = GlobalKey();
  // Key for the preview card (used as fallback)
  final GlobalKey _previewBoundaryKey = GlobalKey();

  bool _isProcessing = false;

  // Fixed card width for export so the generated image is always high-res (1440px wide at 2x)
  static const double kExportCardWidth = 720.0;

  String _sanitizeFileName(String name) {
    return name.replaceAll(RegExp(r'[\\/:*?"<>|]'), '_').trim();
  }

  Future<Uint8List?> _capturePng() async {
    try {
      final boundary = _exportBoundaryKey.currentContext?.findRenderObject()
          as RenderRepaintBoundary?;
      if (boundary == null) {
        final previewBoundary = _previewBoundaryKey.currentContext
            ?.findRenderObject() as RenderRepaintBoundary?;
        if (previewBoundary == null) return null;
        final ui.Image image = await previewBoundary.toImage(pixelRatio: 2.5);
        final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
        return byteData?.buffer.asUint8List();
      }

      if (boundary.debugNeedsPaint) {
        await Future.delayed(const Duration(milliseconds: 60));
      }

      final ui.Image image = await boundary.toImage(pixelRatio: 2.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      return byteData?.buffer.asUint8List();
    } catch (e) {
      debugPrint('Error capturing song image: $e');
      return null;
    }
  }

  Future<String> _getDestinationDirectoryPath() async {
    if (Platform.isIOS) {
      // On iOS, the sandbox strictly forbids creating or accessing a "Downloads" directory.
      // getApplicationDocumentsDirectory() is the sanctioned location.
      // With UIFileSharingEnabled + LSSupportsOpeningDocumentsInPlace in Info.plist,
      // files saved here appear directly in the iOS Files app under "On My iPhone".
      final dir = await getApplicationDocumentsDirectory();
      return dir.path;
    } else if (Platform.isMacOS) {
      try {
        final dir = await getDownloadsDirectory();
        if (dir != null) return dir.path;
      } catch (_) {}
      final docDir = await getApplicationDocumentsDirectory();
      return docDir.path;
    } else if (Platform.isAndroid) {
      try {
        final downloadDir = Directory('/storage/emulated/0/Download');
        if (await downloadDir.exists()) {
          return downloadDir.path;
        }
      } catch (_) {}
      try {
        final dir = await getDownloadsDirectory();
        if (dir != null) return dir.path;
      } catch (_) {}
      try {
        final extDir = await getExternalStorageDirectory();
        if (extDir != null) return extDir.path;
      } catch (_) {}
      final docDir = await getApplicationDocumentsDirectory();
      return docDir.path;
    } else {
      final dir = await getApplicationDocumentsDirectory();
      return dir.path;
    }
  }

  Future<void> _handleSave() async {
    setState(() => _isProcessing = true);
    try {
      final bytes = await _capturePng();
      if (bytes == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to generate image')),
          );
        }
        return;
      }

      final safeTitle = _sanitizeFileName(widget.song.title);
      final fileName = 'Myanmar_Hymns_$safeTitle.png';

      final dirPath = await _getDestinationDirectoryPath();
      final dir = Directory(dirPath);
      if (!await dir.exists()) {
        await dir.create(recursive: true);
      }

      final file = File('$dirPath/$fileName');
      await file.writeAsBytes(bytes);

      if (mounted) {
        Navigator.of(context).pop();

        String feedbackText;
        if (Platform.isIOS) {
          feedbackText = 'Saved to Files app: $fileName';
        } else if (Platform.isMacOS) {
          feedbackText = 'Saved to Downloads: $fileName';
        } else {
          feedbackText = 'Saved image: $fileName';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(feedbackText),
            duration: const Duration(seconds: 4),
            action: SnackBarAction(
              label: Platform.isIOS ? 'Share' : 'Open',
              onPressed: () async {
                if (Platform.isIOS) {
                  await SharePlus.instance.share(
                    ShareParams(
                      files: [
                        XFile(file.path, mimeType: 'image/png', name: fileName)
                      ],
                      text: '${widget.song.title} — Myanmar Hymns',
                    ),
                  );
                } else {
                  try {
                    await launchUrl(Uri.file(file.path));
                  } catch (_) {}
                }
              },
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving image: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  Future<void> _handleShare() async {
    final box = context.findRenderObject() as RenderBox?;
    final origin =
        box != null ? box.localToGlobal(Offset.zero) & box.size : null;

    setState(() => _isProcessing = true);
    try {
      final bytes = await _capturePng();
      if (bytes == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to generate image')),
          );
        }
        return;
      }

      final safeTitle = _sanitizeFileName(widget.song.title);
      final fileName = 'Myanmar_Hymns_$safeTitle.png';
      final tempDir = await getTemporaryDirectory();
      final tempFile = File('${tempDir.path}/$fileName');
      if (!await tempFile.parent.exists()) {
        await tempFile.parent.create(recursive: true);
      }
      await tempFile.writeAsBytes(bytes);

      if (mounted) {
        Navigator.of(context).pop();
      }

      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(tempFile.path, mimeType: 'image/png', name: fileName)],
          text:
              '${widget.song.title}\n\nShared via Myanmar Hymns (placeinheart.com)',
          subject: widget.song.title,
          sharePositionOrigin: origin,
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error sharing image: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  /// The offscreen fixed-width card rendered into a high-res (1440px wide) PNG
  Widget _buildExportCardContent() {
    return Container(
      width: kExportCardWidth,
      padding: const EdgeInsets.symmetric(horizontal: 44, vertical: 44),
      decoration: const BoxDecoration(
        color: Color.fromRGBO(246, 239, 209, 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Title
          Text(
            widget.song.title,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              decoration: TextDecoration.none,
              color: Colors.black87,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            height: 3.5,
            width: 72,
            decoration: BoxDecoration(
              color: const Color.fromRGBO(255, 133, 27, 1),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 28),

          // Lyrics formatted with senior-friendly readability (explicit normal weight & no underline)
          Text(
            widget.song.formattedContent,
            style: TextStyle(
              fontSize: 17 * widget.fontScale,
              height: 1.85,
              fontWeight: FontWeight.normal,
              decoration: TextDecoration.none,
              color: Colors.black87,
            ),
          ),

          const SizedBox(height: 48),

          // Single line plain text watermark (No box, no logo)
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Myanmar Hymns',
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                  decoration: TextDecoration.none,
                  color: Colors.black38,
                ),
              ),
              SizedBox(width: 12),
              Flexible(
                child: Text(
                  '❤️ by Place in Heart ❤️ • placeinheart.com',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.normal,
                    decoration: TextDecoration.none,
                    color: Colors.black54,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final dialogWidth =
        mediaQuery.size.width > 680 ? 620.0 : mediaQuery.size.width * 0.94;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Visible Dialog
        Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          backgroundColor: Colors.white,
          clipBehavior: Clip.antiAlias,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: dialogWidth,
              maxHeight: mediaQuery.size.height * 0.88,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Refined Header
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: const BoxDecoration(
                    color: Color.fromRGBO(255, 133, 27, 1),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(
                          color: Color.fromRGBO(255, 255, 255, 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.image_rounded,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Export Song Card',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'High quality lyrics image',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon:
                            const Icon(Icons.close_rounded, color: Colors.white),
                        tooltip: 'Close',
                        onPressed: _isProcessing
                            ? null
                            : () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                ),

                // Scrollable Preview area
                Expanded(
                  child: Container(
                    color: const Color(0xFFEDE7DA),
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Center(
                        child: RepaintBoundary(
                          key: _previewBoundaryKey,
                          child: Container(
                            constraints: const BoxConstraints(maxWidth: 580),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 22,
                              vertical: 24,
                            ),
                            decoration: BoxDecoration(
                              color: const Color.fromRGBO(246, 239, 209, 1),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: const Color(0xFFE2D6C0),
                                width: 1,
                              ),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color.fromRGBO(0, 0, 0, 0.06),
                                  blurRadius: 10,
                                  offset: Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Song title
                                Text(
                                  widget.song.title,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    decoration: TextDecoration.none,
                                    color: Colors.black87,
                                    height: 1.4,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  height: 2.5,
                                  width: 50,
                                  decoration: BoxDecoration(
                                    color: const Color.fromRGBO(255, 133, 27, 1),
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                                const SizedBox(height: 20),

                                // Full Lyrics preview (explicit normal weight & no underline)
                                Text(
                                  widget.song.formattedContent,
                                  style: TextStyle(
                                    fontSize: 15 * widget.fontScale,
                                    height: 1.8,
                                    fontWeight: FontWeight.normal,
                                    decoration: TextDecoration.none,
                                    color: Colors.black87,
                                  ),
                                ),

                                const SizedBox(height: 32),

                                // Single line plain text watermark with scale-down protection
                                const FittedBox(
                                  fit: BoxFit.scaleDown,
                                  alignment: Alignment.centerLeft,
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Text(
                                        'Myanmar Hymns',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          decoration: TextDecoration.none,
                                          color: Colors.black38,
                                        ),
                                      ),
                                      SizedBox(width: 20),
                                      Text(
                                        '❤️ by Place in Heart ❤️ • placeinheart.com',
                                        style: TextStyle(
                                          fontSize: 11.5,
                                          fontWeight: FontWeight.normal,
                                          decoration: TextDecoration.none,
                                          color: Colors.black54,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                // Refined Bottom Actions (Vertical Top-Bottom layout, Copy removed)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    border: Border(top: BorderSide(color: Color(0xFFEEEEEE))),
                  ),
                  child: _isProcessing
                      ? const Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Color.fromRGBO(255, 133, 27, 1),
                                  ),
                                ),
                                SizedBox(width: 12),
                                Text(
                                  'Generating image...',
                                  style: TextStyle(color: Colors.black54),
                                ),
                              ],
                            ),
                          ),
                        )
                      : Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // 1. Share Image Button (Top - Hero Action)
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: _handleShare,
                                icon: const Icon(Icons.share_rounded, size: 20),
                                label: const Text(
                                  'Share Image',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      const Color.fromRGBO(255, 133, 27, 1),
                                  foregroundColor: Colors.white,
                                  elevation: 0.5,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 13),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),

                            // 2. Save Image Button (Bottom - Secondary Action)
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton.icon(
                                onPressed: _handleSave,
                                icon:
                                    const Icon(Icons.download_rounded, size: 20),
                                label: const Text(
                                  'Save Image',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: const Color(0xFFD35400),
                                  side: const BorderSide(
                                    color: Color(0xFFE08E45),
                                    width: 1.5,
                                  ),
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                ),
              ],
            ),
          ),
        ),

        // Dedicated Offscreen Fixed-Width Export Card (720px wide)
        // Wrapped in Material & DefaultTextStyle to eliminate yellow underline and enforce normal font weight
        Positioned(
          left: -9999,
          top: 0,
          child: RepaintBoundary(
            key: _exportBoundaryKey,
            child: Material(
              type: MaterialType.transparency,
              child: DefaultTextStyle(
                style: const TextStyle(
                  decoration: TextDecoration.none,
                  fontWeight: FontWeight.normal,
                  color: Colors.black87,
                ),
                child: _buildExportCardContent(),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
