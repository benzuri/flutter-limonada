import 'package:flutter/material.dart';
import 'package:limonada/constants.dart' as constants;
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return SettingsPageState();
  }
}

class SettingsPageState extends State<SettingsPage> {
  Future<void> _launchUrl(Uri url) async {
    if (!await launchUrl(
      url,
      mode: LaunchMode
          .externalApplication, //[externalApplication, inAppWebView] (android:usesCleartextTraffic="true" in androidmanifest)
    )) {
      throw 'Could not launch $url';
    }
  }

  void _showModal() {
    showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        builder: (context) {
          return SingleChildScrollView(
              child: Container(
                  padding: EdgeInsets.only(
                      top: 25,
                      left: 15,
                      right: 15,
                      bottom: MediaQuery.of(context).viewInsets.bottom),
                  child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Center(
                            child: Text('¿Te gusta ${constants.APP_NAME}?',
                                style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w500))),
                        const SizedBox(
                          height: 20,
                        ),
                        const Center(
                            child: Text('Valóranos para que sigamos mejorando',
                                style: TextStyle(fontSize: 16))),
                        const SizedBox(
                          height: 10,
                        ),
                        const Center(
                            child: Text('Gracias!',
                                style: TextStyle(fontSize: 16))),
                        const SizedBox(
                          height: 40,
                        ),
                        Center(
                            child: ElevatedButton(
                          onPressed: () async {
                            _launchUrl(Uri.parse(
                                constants.STORE_URL + constants.PACKAGE_NAME));
                            // Close the bottom sheet
                            Navigator.of(context).pop();
                          },
                          child: const Text('VALORAR',
                              style: TextStyle(fontSize: 16)),
                        )),
                        const SizedBox(
                          height: 20,
                        ),
                      ])));
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: PreferredSize(
            preferredSize:
                const Size.fromHeight(48.0),
            child: AppBar(
              //backgroundColor: colorPrimary,
              title: const Text(constants.APP_NAME),
            )),
        body: SingleChildScrollView(
            child: Column(
          children: [
            const SizedBox(height: 10),
            ListTile(
                title: const Text('Compartir'),
                trailing: Wrap(
                  spacing: 12,
                  children: const <Widget>[
                    Opacity(
                      opacity: 0.6,
                      child: Icon(Icons.chevron_right),
                    ),
                  ],
                ),
                onTap: () {
                  Share.share('${constants.APP_NAME} | ${constants.STORE_URL}${constants.PACKAGE_NAME}');
                }),
            const Divider(),
            ListTile(
                title: const Text('Valorar'),
                trailing: Wrap(
                  spacing: 12,
                  children: const <Widget>[
                    Opacity(
                      opacity: 0.6,
                      child: Icon(Icons.chevron_right),
                    ),
                  ],
                ),
                onTap: () => _showModal()),

          ],
        )));
  }
}
