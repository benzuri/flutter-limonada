import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:limonada/constants.dart' as constants;

class UpgradeMoneyFragment extends StatelessWidget {
  const UpgradeMoneyFragment();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: constants.COLOR_BACKGROUND,
      body: Center(child: Text("Upgrade money")),
    );
  }
}