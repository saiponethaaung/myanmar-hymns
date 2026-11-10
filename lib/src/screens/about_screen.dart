import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  Future<void> _openWebsite() async {
    final uri = Uri.parse('https://placeinheart.com');
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Widget _buildFeatureItem({
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required String title,
    required String description,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconBgColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.black54,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About Myanmar Hymns'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // App Logo in elevated circle
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 10,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Image.asset(
                    'assets/logo/main-logo.png',
                    height: 64,
                    width: 64,
                  ),
                ),
                const SizedBox(height: 14),

                // App Title & Myanmar subhead
                const Text(
                  'Myanmar Hymns',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'မြန်မာ ဓ္ဓမသီချင်းများ',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color.fromRGBO(210, 90, 0, 1),
                  ),
                ),
                const SizedBox(height: 8),

                // Version Badge
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color.fromRGBO(255, 133, 27, 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'Version 0.0.4',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color.fromRGBO(210, 90, 0, 1),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Overview Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 6,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Text(
                    'Myanmar Hymns is a collection of classic and modern Christian hymn lyrics in the Myanmar language. Perfect for personal devotion, worship services, choir practice, and family prayers.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14.5,
                      height: 1.6,
                      color: Colors.black87,
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Features Section Title
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: EdgeInsets.only(left: 4, bottom: 10),
                    child: Text(
                      'အဓိက အင်္ဂါရပ်များ (Key Features)',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ),

                // Feature Cards
                _buildFeatureItem(
                  icon: Icons.auto_stories_rounded,
                  iconColor: const Color.fromRGBO(210, 90, 0, 1),
                  iconBgColor: const Color.fromRGBO(255, 133, 27, 0.15),
                  title: 'Classic & Modern Hymns',
                  description:
                      '၄၁၀ ပုဒ်သော ရှေးရိုး ဓ္ဓမသီချင်းများနှင့် ခေတ်ပေါ် ကိုးကွယ်ခြင်း သီချင်းများ။',
                ),
                _buildFeatureItem(
                  icon: Icons.favorite_rounded,
                  iconColor: Colors.red,
                  iconBgColor: const Color.fromRGBO(244, 67, 54, 0.12),
                  title: 'Favorite Songs (အကြိုက်ဆုံးများ)',
                  description:
                      'နှစ်သက်ရာ သီချင်းများကို အမှတ်အသားပြုပြီး အချိန်မရွေး ပြန်လည်ရှာဖွေနိုင်ခြင်း။',
                ),
                _buildFeatureItem(
                  icon: Icons.image_outlined,
                  iconColor: Colors.teal,
                  iconBgColor: const Color.fromRGBO(0, 150, 136, 0.12),
                  title: 'Export & Share as Image',
                  description:
                      'သီချင်းစာသားအပြည့်အစုံကို လှပသော ပုံအဖြစ် ထုတ်ယူ၍ သူငယ်ချင်းများထံ မျှဝေနိုင်ခြင်း။',
                ),
                _buildFeatureItem(
                  icon: Icons.smart_display_rounded,
                  iconColor: Colors.red.shade700,
                  iconBgColor: const Color.fromRGBO(244, 67, 54, 0.12),
                  title: 'YouTube Search (နားဆင်ရန်)',
                  description:
                      'သီချင်းခေါင်းစဉ်ဖြင့် YouTube တွင် တိုက်ရိုက် ရှာဖွေနားဆင်နိုင်ခြင်း။',
                ),
                _buildFeatureItem(
                  icon: Icons.format_size_rounded,
                  iconColor: Colors.indigo,
                  iconBgColor: const Color.fromRGBO(63, 81, 181, 0.12),
                  title: 'Adjustable Font Size',
                  description:
                      'သက်ကြီးရွယ်အိုများနှင့် စာဖတ်သူများအတွက် A- / A+ ဖြင့် စာလုံးအရွယ်အစား လွတ်လပ်စွာ ချိန်ညှိနိုင်ခြင်း။',
                ),

                const SizedBox(height: 20),

                // Place in Heart Developer Card
                Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 6,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      const Text(
                        '❤️ Developed by Place in Heart ❤️',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Learn more about our mission and projects:',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.black54,
                        ),
                      ),
                      const SizedBox(height: 14),
                      ElevatedButton.icon(
                        onPressed: _openWebsite,
                        icon: const Icon(Icons.language_rounded, size: 18),
                        label: const Text('www.placeinheart.com'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              const Color.fromRGBO(255, 133, 27, 1),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 10,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 26),

                // God bless note
                const Text(
                  'ဘုရားသခင် ကောင်းချီးပေးပါစေ။',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black45,
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
