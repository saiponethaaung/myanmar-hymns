import 'package:flutter/material.dart';
import 'package:myanmar_hymns/src/models/base_model.dart';
import 'package:myanmar_hymns/src/widget/zoom_widget.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({
    super.key,
  });

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late BaseModel _baseModel;

  void openWebsite() async {
    Uri url = Uri.parse("https://placeinheart.com");

    await launchUrl(url);
  }

  Widget _buildCategoryCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconBgColor,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Material(
        color: Colors.white,
        elevation: 2,
        shadowColor: Colors.black12,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: iconBgColor,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(icon, color: iconColor, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: _baseModel.textFontSize * 1.15,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: _baseModel.textFontSize * 0.85,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 18,
                  color: Colors.black38,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    _baseModel = Provider.of<BaseModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Myanmar Hymns"),
      ),
      body: ZoomWidget(
        SizedBox(
          width: double.infinity,
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 560),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Warm Welcome Header
                    Padding(
                      padding: const EdgeInsets.only(bottom: 24, left: 4),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'မြန်မာ ဓ္ဓမသီချင်းများ',
                            style: TextStyle(
                              fontSize: _baseModel.textFontSize * 1.35,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'သခင်ယေရှုကို ချီးမွမ်းကိုးကွယ်ကြစို့',
                            style: TextStyle(
                              fontSize: _baseModel.textFontSize * 0.9,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Category 1: Traditional Hymns
                    _buildCategoryCard(
                      title: 'ဓ္ဓမသီချင်း',
                      subtitle: 'Traditional Hymns (၄၁၀ ပုဒ်)',
                      icon: Icons.auto_stories_rounded,
                      iconBgColor: const Color.fromRGBO(255, 133, 27, 0.15),
                      iconColor: const Color.fromRGBO(210, 90, 0, 1),
                      onTap: () {
                        _baseModel.type = 'hymn';
                        Navigator.pushNamed(context, '/song-list');
                      },
                    ),

                    // Category 2: Modern Hymns
                    _buildCategoryCard(
                      title: 'ခေတ်ပေါ် ဓ္ဓမသီချင်း',
                      subtitle: 'Modern Hymns',
                      icon: Icons.music_note_rounded,
                      iconBgColor: const Color.fromRGBO(255, 193, 7, 0.2),
                      iconColor: const Color.fromRGBO(180, 110, 0, 1),
                      onTap: () {
                        _baseModel.type = 'modern';
                        Navigator.pushNamed(context, '/song-list');
                      },
                    ),

                    // Category 3: Favorites
                    _buildCategoryCard(
                      title: 'အကြိုက်ဆုံး သီချင်းများ',
                      subtitle: _baseModel.favoriteSongKeys.isEmpty
                          ? 'Favorites (မရှိသေးပါ)'
                          : 'Favorites (${_baseModel.favoriteSongKeys.length} ပုဒ်)',
                      icon: Icons.favorite_rounded,
                      iconBgColor: const Color.fromRGBO(244, 67, 54, 0.12),
                      iconColor: Colors.red,
                      onTap: () {
                        _baseModel.type = 'favorite';
                        Navigator.pushNamed(context, '/song-list');
                      },
                    ),

                    const SizedBox(height: 16),

                    // About & Website Footer on screen
                    Center(
                      child: InkWell(
                        onTap: () => Navigator.pushNamed(context, '/about'),
                        borderRadius: BorderRadius.circular(12),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 8,
                            horizontal: 14,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.info_outline_rounded,
                                size: 18,
                                color: Colors.black54,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'About Myanmar Hymns',
                                style: TextStyle(
                                  fontSize: _baseModel.textFontSize * 0.85,
                                  color: Colors.black54,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    GestureDetector(
                      onTap: openWebsite,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          '❤️ by Place in Heart ❤️\nwww.placeinheart.com',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.black45,
                            fontSize: _baseModel.textFontSize * 0.75,
                            height: 1.5,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
