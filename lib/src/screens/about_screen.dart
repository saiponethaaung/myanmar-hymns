import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                  'Myanmar hymns is a collection of modern and classic Christian hymn lyrics in the Myanmar language. Perfect for personal devotion, worship, or choir practice, the app is easy to use.'),
              const SizedBox(
                height: 15,
              ),
              const Text('- Modern and traditional hymns'),
              const Text('- Clear Myanmar script for lyrics'),
              const Text('- Simple navigation for quick song selection'),
              const SizedBox(
                height: 15,
              ),
              RichText(
                text: TextSpan(children: [
                  const TextSpan(
                      text: 'Visit ', style: TextStyle(color: Colors.black)),
                  TextSpan(
                      text: 'www.placeinheart.com',
                      recognizer: TapGestureRecognizer.new()
                        ..onTap = () async {
                          await launchUrl(
                              Uri.parse('https://placeinheart.com'));
                        },
                      style: TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                      )),
                  const TextSpan(
                      text: ' to learn more about us.',
                      style: TextStyle(color: Colors.black)),
                ]),
              )
            ],
          ),
        ),
      ),
    );
  }
}
