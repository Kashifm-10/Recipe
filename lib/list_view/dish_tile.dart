import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:popover/popover.dart';
import 'package:recipe/collections/names.dart';
import 'package:recipe/pages/biggerScreens/recipePage.dart';
import 'package:recipe/notInUse/dish.dart';

class DishTile extends StatelessWidget {
  DishTile({
    super.key,
    required this.dish,
    required this.duration,
    required this.category,
    required this.text,
    required this.type,
    this.onEditPressed,
    this.onDeletePressed,
    this.fromType,
  });
  String? type;
  String? dish;
  String? duration;
  String? category;
  String? fromType;
  final String text;
  final void Function()? onEditPressed;
  final void Function()? onDeletePressed;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 16.0),
      child: Container(
        width: screenWidth * 0.1,
        height: screenWidth > 600 ? screenHeight * 0.08 : screenHeight * 0.07,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 1,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              right: 5,
              top: 5,
              child: CircleAvatar(
                radius: 10,
                backgroundColor: Colors.white.withOpacity(0.0),
                child: category == "1"
                    ? Icon(Icons.circle_rounded,
                        color: Colors.red,
                        size: screenWidth > 600 ? 15 : screenWidth * 0.025)
                    : Icon(Icons.circle_rounded,
                        color: Colors.green,
                        size: screenWidth > 600 ? 15 : screenWidth * 0.025),
              ),
            ),
            Padding(
              padding: screenWidth > 600
                  ? EdgeInsets.all(20.0)
                  : EdgeInsets.only(left: 15.0, top: 0, bottom: 5),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: screenWidth > 600
                    ? MainAxisAlignment.spaceBetween
                    : MainAxisAlignment.spaceEvenly,
                children: [
                  Text(
                    text,
                    style: GoogleFonts.poppins(
                      color: Colors.black,
                      fontSize: screenWidth > 600 ? 24 : screenWidth * 0.045,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      /*  Padding(
                        padding: const EdgeInsets.only(bottom: 4.0),
                        child: Icon(Icons.timer, color: Colors.grey.shade400),
                      ),
                      SizedBox(width: 5), */
                      Text(
                        duration != null
                            ? (() {
                                double durations =
                                    double.tryParse(duration!) ?? 0.0;
                                int hours = durations.toInt();
                                int minutes =
                                    ((durations - hours) * 60).toInt();

                                if (hours > 0 && minutes > 0) {
                                  return '$hours hour ${minutes} minutes';
                                } else if (hours > 0) {
                                  return '$hours hour';
                                } else if (minutes > 0) {
                                  return '$minutes minutes';
                                } else {
                                  return '0 minutes';
                                }
                              }())
                            : 'Invalid duration',
                        style: GoogleFonts.poppins(
                          color: Colors.grey.shade500,
                          fontSize:
                              screenWidth > 600 ? 12 : screenWidth * 0.025,
                        ),
                      ),
                      if (fromType! != 'no')
                        Padding(
                          padding: EdgeInsets.only(
                              right: MediaQuery.of(context).size.width > 600
                                  ? 0
                                  : MediaQuery.of(context).size.width * 0.02),
                          child: Text(
                            fromType!,
                            style: GoogleFonts.poppins(
                              color: Colors.grey.shade500,
                              fontSize:
                                  screenWidth > 600 ? 12 : screenWidth * 0.025,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
