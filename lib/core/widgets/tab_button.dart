import 'package:flutter/material.dart';

class TabButton extends StatefulWidget {
  const TabButton(
      {super.key,
      required this.onPressed,
      required this.title,
      required this.selected});

  final VoidCallback onPressed;

  final String title;

  final bool selected;

  @override
  State<TabButton> createState() => _TabButtonState();
}

class _TabButtonState extends State<TabButton> {
  @override
  Widget build(BuildContext context) {
    return TextButton(
        onPressed: widget.onPressed,
        style: ButtonStyle(
            shape: WidgetStatePropertyAll(RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(32),
                side: widget.selected
                    ? BorderSide.none
                    : const BorderSide(color: Color(0xFFE5E5E7)))),
            backgroundColor: widget.selected
                ? WidgetStatePropertyAll(
                    Theme.of(context).colorScheme.onSurface)
                : WidgetStatePropertyAll(Theme.of(context).colorScheme.surface),
            foregroundColor: widget.selected
                ? WidgetStatePropertyAll(Theme.of(context).colorScheme.surface)
                : WidgetStatePropertyAll(
                    Theme.of(context).colorScheme.onSurfaceVariant),
            textStyle:
                WidgetStatePropertyAll(Theme.of(context).textTheme.bodyMedium)),
        child: Text(
          widget.title,
        ));
  }
}
