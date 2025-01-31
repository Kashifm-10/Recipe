import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:popover/popover.dart';
import 'package:recipe/collections/dishes.dart';
import 'package:recipe/pages/biggerScreens/recipePage.dart';
import 'package:recipe/notInUse/dish.dart';
import 'package:cached_network_image/cached_network_image.dart';

class DishTile extends StatelessWidget {
  DishTile(
      {super.key,
      required this.dish,
      required this.duration,
      required this.category,
      required this.text,
      required this.type,
      this.onEditPressed,
      this.onDeletePressed,
      this.fromType,
      this.serial,
      this.imageURL});
  String? type;
  String? dish;
  String? duration;
  String? category;
  String? fromType;
  String? serial;
  String? imageURL;
  final String text;
  final void Function()? onEditPressed;
  final void Function()? onDeletePressed;
  List<String> images = [
    'https://img.freepik.com/free-photo/breakfast-consists-bread-fried-egg-salad-dressing-black-grapes-tomatoes-sliced-a-a-onions_1150-24459.jpg?t=st=1737460645~exp=1737464245~hmac=211ae8a793b1d99d23e0892b0f71f4b0efecbc65ea11ee8131a0fc260f287918&w=1380',
    'https://images.pexels.com/photos/25225626/pexels-photo-25225626/free-photo-of-sandwich-baked-potatoes-and-salad-on-plate.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1',
    'https://images.pexels.com/photos/1618913/pexels-photo-1618913.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1',
    'https://images.pexels.com/photos/19834448/pexels-photo-19834448/free-photo-of-soup-and-spices.jpeg',
    'https://images.pexels.com/photos/5602707/pexels-photo-5602707.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1',
    'https://images.pexels.com/photos/3504874/pexels-photo-3504874.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1',
    'https://images.pexels.com/photos/3356409/pexels-photo-3356409.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1',
    'https://images.pexels.com/photos/1320998/pexels-photo-1320998.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1',
    'https://images.pexels.com/photos/14774693/pexels-photo-14774693.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1',
    'https://images.pexels.com/photos/6660071/pexels-photo-6660071.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1'
  ];

  List<Color> colorList = [
    Colors.orange.shade400,
    Colors.green.shade400,
    Colors.red.shade400,
    Colors.brown.shade500,
    Colors.red.shade200,
    Colors.deepOrange.shade500,
    Colors.yellow.shade900,
    Colors.blue.shade300,
    Colors.green.shade700,
    Colors.deepPurple.shade300,
  ];

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
                  : EdgeInsets.only(
                      left: screenWidth > 600 ? 15.0 : screenWidth * 0.015,
                      top: 0,
                      bottom: 5),
              child: Row(
                children: [
                  Padding(
                    padding: EdgeInsets.only(
                        right: 10.0,
                        top: screenWidth > 600 ? 0 : screenHeight * 0.006),
                    child: Container(
                        width: screenWidth > 600
                            ? screenWidth * 0.1
                            : screenWidth * 0.2,
                        height: screenHeight * 0.1,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(
                              8.0), // Adjust the radius as needed
                          child: CachedNetworkImage(
                            imageUrl: imageURL!?? ' ',
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Center(
                                child: CircularProgressIndicator(
                                    color: colorList[int.parse(type!) - 1])),
                            errorWidget: (context, url, error) => ClipRRect(
                                borderRadius: BorderRadius.circular(
                                    8.0), // Same border radius
                                child: CachedNetworkImage(
                                  imageUrl: images[int.parse(type!) - 1],
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) => Center(
                                      child: CircularProgressIndicator(
                                          color:
                                              colorList[int.parse(type!) - 1])),
                                  errorWidget: (context, url, error) =>
                                      Icon(Icons.error),
                                )),
                          ),
                        )),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: screenWidth > 600
                        ? MainAxisAlignment.spaceBetween
                        : MainAxisAlignment.spaceEvenly,
                    children: [
                      Text(
                        screenWidth > 600
                            ? text
                            : text.length > 24
                                ? "${text.substring(0, 22)}..."
                                : text,
                        style: GoogleFonts.poppins(
                          color: Colors.black,
                          fontSize:
                              screenWidth > 600 ? 24 : screenWidth * 0.045,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          /*  Padding(
                            padding: const EdgeInsets.only(bottom: 4.0),
                            child: Icon(Icons.timer, color: Colors.grey.shade400),
                          ),
                          SizedBox(width: 5), */
                           if (fromType! != 'no')
                            Padding(
                              padding: EdgeInsets.only(
                                  right: MediaQuery.of(context).size.width > 600
                                      ? 0
                                      : MediaQuery.of(context).size.width *
                                          0.02),
                              child: Text(
                                fromType!,
                                style: GoogleFonts.poppins(
                                  color: Colors.grey.shade500,
                                  fontSize: screenWidth > 600
                                      ? 12
                                      : screenWidth * 0.025,
                                ),
                              ),
                            ),
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
                         
                        ],
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
