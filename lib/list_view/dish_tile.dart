import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:popover/popover.dart';
import 'package:recipe/collections/dishes.dart';
import 'package:recipe/pages/biggerScreens/recipePage.dart';
import 'package:recipe/notInUse/dish.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

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
    this.serial,
    this.imageURL,
  });

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
    final GlobalKey _floatingButtonKey = GlobalKey();

    Future<void> createTutorial() async {
      final prefs = await SharedPreferences.getInstance();
      bool isTutorialShown = prefs.getBool('tutorialShowndishes') ?? false;

      if (isTutorialShown) return;

      final targets = [
        TargetFocus(
          identify: 'floatingButton',
          keyTarget: _floatingButtonKey,
          alignSkip: Alignment.bottomCenter,
          contents: [
            TargetContent(
              align: ContentAlign.bottom,
              builder: (context, controller) => Text(
                'Use this button to add new dishes to the list',
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(color: Colors.white),
              ),
            ),
          ],
        ),
      ];

      final tutorial = TutorialCoachMark(
        targets: targets,
      );

      Future.delayed(const Duration(milliseconds: 500), () {
        tutorial.show(context: context);
        prefs.setBool('tutorialShowndishes', true);
      });
    }

    createTutorial();

    return Container(
      key: _floatingButtonKey,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Main content
          Padding(
            padding: EdgeInsets.all(screenWidth > 600 ? 12.0 : 10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image
                Expanded(
                  flex: 2,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: CachedNetworkImage(
                      imageUrl: imageURL!,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Shimmer.fromColors(
                        baseColor: Colors.grey[300]!,
                        highlightColor: Colors.grey[100]!,
                        child: Container(
                          color: Colors.white,
                        ),
                      ),
                      errorWidget: (context, url, error) => ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: CachedNetworkImage(
                          imageUrl: images[int.parse(type!) - 1],
                          width: double.infinity,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Shimmer.fromColors(
                            baseColor: Colors.grey[200]!,
                            highlightColor: Colors.grey[100]!,
                            child: Container(color: Colors.white),
                          ),
                          errorWidget: (context, url, error) =>
                              Center(child: Icon(Icons.error)),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 8),
                // Title
                Expanded(
                  flex: 0,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              text,
                              maxLines: 1, // 👈 always 2 lines
                              overflow: TextOverflow.ellipsis,
                              softWrap: true,
                              style: GoogleFonts.hammersmithOne(
                                color: Colors.black,
                                fontSize: screenWidth > 600 ? 16 : 14,
                                fontWeight: FontWeight.bold,
                                height: 1.2, // 👈 consistent line height
                              ),
                            ),
                          ),
                          if (fromType! == 'no') SizedBox(width: 6),
                          if (fromType! == 'no')
                            Text(
                              duration != null
                                  ? (() {
                                      double durations =
                                          double.tryParse(duration!) ?? 0.0;
                                      int hours = durations.toInt();
                                      int minutes =
                                          ((durations - hours) * 60).toInt();

                                      if (hours > 0 && minutes > 0) {
                                        return '$hours hr $minutes min';
                                      } else if (hours > 0) {
                                        return '$hours hr';
                                      } else if (minutes > 0) {
                                        return '$minutes min';
                                      } else {
                                        return '0 min';
                                      }
                                    }())
                                  : 'Invalid duration',
                              style: GoogleFonts.hammersmithOne(
                                color: Colors.grey.shade500,
                                fontSize: screenWidth > 600 ? 11 : 10,
                              ),
                            ),
                        ],
                      ),
                      SizedBox(height: 4),
                      // From type

                      // Duration
                      if (fromType! != 'no')
                        Row(
                          mainAxisAlignment: fromType! != 'no'
                              ? MainAxisAlignment.spaceBetween
                              : MainAxisAlignment.end,
                          children: [
                            Text(
                              fromType!,
                              style: GoogleFonts.hammersmithOne(
                                color: Colors.grey.shade500,
                                fontSize: screenWidth > 600 ? 11 : 10,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
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
                                        return '$hours hr $minutes min';
                                      } else if (hours > 0) {
                                        return '$hours hr';
                                      } else if (minutes > 0) {
                                        return '$minutes min';
                                      } else {
                                        return '0 min';
                                      }
                                    }())
                                  : 'Invalid duration',
                              style: GoogleFonts.hammersmithOne(
                                color: Colors.grey.shade500,
                                fontSize: screenWidth > 600 ? 11 : 10,
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
          Positioned(
            right: 15,
            top: 15,
            child: Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4), // 👈 rounded square
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                Icons.circle_rounded,
                color: category == "1" ? Colors.red : Colors.green,
                size: screenWidth > 600 ? 10 : 8,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
