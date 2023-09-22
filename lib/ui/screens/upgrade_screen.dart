import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:limonada/constants.dart' as constants;
import 'package:limonada/ui/screens/fragments/upgrade_limonade_fragment.dart';
import 'package:limonada/ui/screens/fragments/upgrade_money_fragment.dart';

class UpgradeScreen extends StatelessWidget {
  const UpgradeScreen();

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: PreferredSize(
            preferredSize: const Size(90.0, 90.0),
            child: AppBar(
                backgroundColor: constants.COLOR_SECONDARY,
                title: Text(AppLocalizations.of(context)!.back),
                bottom: const PreferredSize(
                  preferredSize: Size(45.0, 45.0),
                  child: ColoredBox(
                    color: constants.COLOR_PRIMARY,
                    child: TabBar(
                      indicatorColor: Colors.white,
                      tabs: [
                        SizedBox(
                          height: 45.0,
                          child: Tab(
                            child: Text(
                              'Limonada',
                              style: TextStyle(fontSize: 18),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 45.0,
                          child: Tab(
                            child: Text(
                              'Dinero',
                              style: TextStyle(fontSize: 18),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ))),
        body: const TabBarView(
          children: [
            UpgradeLimonadeFragment(),
            UpgradeMoneyFragment(),
          ],
        ),
      ),
    );
  }
}