import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:url_launcher/url_launcher.dart';

import '../screens/notice_details_screen.dart';

class LinkifyDescription extends StatelessWidget {
  const LinkifyDescription({
    super.key,
    required this.description,
  });

  final String description;

  @override
  Widget build(BuildContext context) {
    return Linkify(
      text: description,
      style: const TextStyle(
        fontSize: 16,
        height: 1.6,
        color: Colors.black87,
      ),
      linkStyle: const TextStyle(
        color: Colors.blue,
        decoration: TextDecoration.underline,
      ),
      onOpen: (link) async {
        final url = Uri.parse(link.url);

        try {
          await launchUrl(
            url,
            mode: LaunchMode.externalApplication,
          );
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Could not open link: ${link.url}")),
          );
        }
      },
    );
  }
}
