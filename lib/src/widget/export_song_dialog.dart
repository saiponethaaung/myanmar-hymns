import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
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
  final GlobalKey _boundaryKey = GlobalKey();
  bool _isProcessing = false;

  String _sanitizeFileName(String name) {
    return name.replaceAll(RegExp(r'[\\/:*?"<>|]'), '_').trim();
  }

  Future<Uint8List?> _capturePng() async {
    try {
      final boundary = _boundaryKey.currentContext?.findRenderObject()
          as RenderRepaintBoundary?;
      if (boundary == null) return null;
      final ui.Image image = await boundary.toImage(pixelRatio: 2.5);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      return byteData?.buffer.asUint8List();
    } catch (e) {
      debugPrint('Error capturing song image: $e');
      return null;
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

      Directory? dir;
      try {
        dir = await getDownloadsDirectory();
      } catch (_) {}
      dir ??= await getApplicationDocumentsDirectory();

      final file = File('${dir.path}/$fileName');
      if (!await file.parent.exists()) {
        await file.parent.create(recursive: true);
      }
      await file.writeAsBytes(bytes);

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Saved image to:\n${file.path}'),
            duration: const Duration(seconds: 4),
            action: SnackBarAction(
              label: 'Open',
              onPressed: () async {
                try {
                  await launchUrl(Uri.file(file.path));
                } catch (_) {}
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

  Future<void> _handleCopy() async {
    final textToCopy =
        '${widget.song.title}\n\n${widget.song.formattedContent}\n\n— Myanmar Hymns (placeinheart.com)';
    await Clipboard.setData(ClipboardData(text: textToCopy));
    if (mounted) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'သီချင်းစာသား ကူးယူပြီးပါပြီ (Lyrics copied to clipboard)',
          ),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final dialogWidth =
        mediaQuery.size.width > 680 ? 620.0 : mediaQuery.size.width * 0.92;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
            // Dialog Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: const BoxDecoration(
                color: Color.fromRGBO(255, 133, 27, 1),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.image, color: Colors.white, size: 22),
                      SizedBox(width: 8),
                      Text(
                        'Export Image',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    tooltip: 'Close',
                    onPressed:
                        _isProcessing ? null : () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),

            // Scrollable Preview with full card
            Expanded(
              child: Container(
                color: const Color.fromRGBO(235, 230, 215, 1),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Center(
                    child: RepaintBoundary(
                      key: _boundaryKey,
                      child: Container(
                        width: 580,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 28,
                          vertical: 32,
                        ),
                        decoration: BoxDecoration(
                          color: const Color.fromRGBO(246, 239, 209, 1),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black12,
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
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                                height: 1.4,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Container(
                              height: 2,
                              width: 60,
                              color: const Color.fromRGBO(255, 133, 27, 1),
                            ),
                            const SizedBox(height: 22),

                            // Full Lyrics
                            Text(
                              widget.song.formattedContent,
                              style: TextStyle(
                                fontSize: 16 * widget.fontScale,
                                height: 1.8,
                                color: Colors.black87,
                              ),
                            ),

                            const SizedBox(height: 36),

                            // Single line plain text watermark (No box, no logo)
                            const Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  'Myanmar Hymns',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black38,
                                  ),
                                ),
                                Text(
                                  '❤️ by Place in Heart ❤️ • placeinheart.com',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.black54,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Dialog Actions: Save & Share
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: Colors.black12)),
              ),
              child: _isProcessing
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
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
                  : Row(
                      children: [
                        TextButton.icon(
                          onPressed: _handleCopy,
                          icon: const Icon(Icons.copy_rounded, size: 18),
                          label: const Text('Copy Text'),
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.black87,
                          ),
                        ),
                        const Spacer(),
                        OutlinedButton.icon(
                          onPressed: _handleSave,
                          icon: const Icon(Icons.download, size: 20),
                          label: const Text('Save Image'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.black87,
                            side: const BorderSide(color: Colors.black26),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 10,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton.icon(
                          onPressed: _handleShare,
                          icon: const Icon(Icons.share, size: 20),
                          label: const Text('Share'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                const Color.fromRGBO(255, 133, 27, 1),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),
                          ),
                        ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
