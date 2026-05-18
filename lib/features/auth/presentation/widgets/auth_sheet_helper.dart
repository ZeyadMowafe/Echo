import 'package:echo_explorer/features/auth/presentation/widgets/auth_bottom_sheet.dart';
import 'package:flutter/material.dart';

Future<void> showAuthSheet(BuildContext context, String subtitle) async {
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withOpacity(0.55),
    builder: (context) => Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: AuthBottomSheet(subtitle: subtitle),
    ),
  );
}
