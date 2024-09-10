import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class dish extends StatefulWidget {
  const dish({super.key});

  @override
  State<dish> createState() => _dishState();
}

class _dishState extends State<dish> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(25.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "name",
                  style: GoogleFonts.lato(fontSize: 50),
                ),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(
                    Icons.link,
                    size: 40,
                  ),
                  alignment: Alignment.topRight,
                ),
              ],
            ),
          ),
          Text(
            "Ingredients",
            style: GoogleFonts.lato(fontSize: 30),
            textAlign: TextAlign.left,
          ),
          Text(
            "_____________",
            style: GoogleFonts.lato(fontSize: 30),
            textAlign: TextAlign.left,
          ),
          Text(
            "Recipe",
            style: GoogleFonts.lato(fontSize: 30),
            textAlign: TextAlign.left,
          ),
          Text(
            "_____________",
            style: GoogleFonts.lato(fontSize: 30),
            textAlign: TextAlign.left,
          ),
        ],
      ),
    );
  }
}
