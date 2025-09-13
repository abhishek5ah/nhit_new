import 'package:flutter/material.dart';

typedef DialogButton = Widget Function(BuildContext context);

class CustomDialog extends StatelessWidget {
  final Widget? header;
  final Widget? body;
  final List<DialogButton>? footerButtons;
  final bool barrierDismissible;

  const CustomDialog({
    super.key,
    this.header,
    this.body,
    this.footerButtons,
    this.barrierDismissible = true,
  });

  static Future<T?> show<T>({
    required BuildContext context,
    Widget? header,
    Widget? body,
    List<DialogButton>? footerButtons,
    bool barrierDismissible = true,
  }) {
    return showDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (context) => CustomDialog(
        header: header,
        body: body,
        footerButtons: footerButtons,
        barrierDismissible: barrierDismissible,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
        canPop: barrierDismissible,
        onPopInvokedWithResult: (context, result) {
          if (!barrierDismissible) {
            //Perform custom logic
          } else {
            // Allow pop
          }
        },
        child: Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: IntrinsicWidth(
            stepWidth: 280,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (header != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: DefaultTextStyle(
                      style: Theme.of(context)
                          .textTheme
                          .headlineSmall!
                          .copyWith(fontWeight: FontWeight.bold),
                      child: header!,
                    ),
                  ),
                if (body != null)
                  Flexible(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 24),
                      child: body,
                    ),
                  ),
                if (footerButtons != null && footerButtons!.isNotEmpty)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      for (final buttonBuilder in footerButtons!) ...[
                        buttonBuilder(context),
                        const SizedBox(width: 12),
                      ],
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
