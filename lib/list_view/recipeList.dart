import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:heroicons_flutter/heroicons_flutter.dart';
import 'package:ionicons/ionicons.dart';
import 'package:popover/popover.dart';
import 'package:recipe/pages/biggerScreens/recipePage.dart';

class RecipeList extends StatelessWidget {
  RecipeList({
    super.key,
    required this.dish,
    required this.text,
    required this.access,
    this.onEditPressed,
    this.onDeletePressed,
  });

  final String? dish;
  final String text;
  final bool? access;
  final void Function()? onEditPressed;
  final void Function()? onDeletePressed;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(
          vertical: MediaQuery.of(context).size.width > 600 ? 8 : 0,
          horizontal: MediaQuery.of(context).size.width > 600
              ? 20
              : 20), // Padding around the list item
      leading:  Padding(
        padding: const EdgeInsets.only(left: 8.0),
        child: Icon(Icons.circle,
            size: 10, color: Colors.grey[850]),
      ), // Small circle as a point
      title: GestureDetector(
        onLongPress: () {
          if (access!) onEditPressed!();
        },
        child: Text(
          '${text[0].toUpperCase()}${text.substring(1)}',
          style: GoogleFonts.poppins(
            fontSize: MediaQuery.of(context).size.width > 600
                ? MediaQuery.of(context).size.width * 0.04
                : MediaQuery.of(context).size.width * 0.04,
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
          textAlign:
              TextAlign.left, // Justified text alignment for cleaner look
        ),
      ),
      // Optional actions at the end of each item, if needed (e.g., delete, edit)
    );
  }
}
