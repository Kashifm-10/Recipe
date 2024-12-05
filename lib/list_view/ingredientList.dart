import 'package:flutter/material.dart';
import 'package:popover/popover.dart';
import 'package:recipe/pages/recipe.dart';

import 'package:flutter/material.dart';

class ingredientList extends StatelessWidget {
  ingredientList({
    super.key,
    required this.dish,
    required this.text,
    required this.quantity,
    required this.count,
    required this.uom,
    this.onEditPressed,
    this.onDeletePressed,
  });
  String? count;
  final String? dish;
  final double? quantity;
  final String? uom;
  final String text;
  final void Function()? onEditPressed;
  final void Function()? onDeletePressed;

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    // Set responsive font size and padding based on screen width
    double fontSize =
        screenWidth * 0.04; // Adjust font size based on screen width
    double paddingValue =
        screenWidth * 0.02; // Adjust padding based on screen width
    double cellPadding = screenWidth * 0.01; // Padding for table cells
    String convertFractionToDecimal(String count) {
      if (count == '1/2') {
        return '0.5';
      } else if (count == '1/4') {
        return '0.25';
      }
      // Return the original value if it's not a fraction.
      return count;
    }

    String quantityCount =
        (double.parse(convertFractionToDecimal(count!))).toString();
    // Sample data for demonstration
    final List<Map<String, String>> items = [
      {
        'text': text,
        'quantity': quantity!.toString(),
        'uom': uom!,
        'quantityCal': (quantity! * double.parse(quantityCount!)).toString(),
      },
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (MediaQuery.of(context).size.width > 600) ...[
            Container(
              height: 50.0, // Limit the height of the whole list
              child: ListView.builder(
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];
                  return GestureDetector(
                    onLongPress: () {
                      onEditPressed!();
                    },
                    child: Container(
                      // margin: const EdgeInsets.only(bottom: 8.0),
                      child: Table(
                        // border: TableBorder.all(),
                        columnWidths: const {
                          0: FlexColumnWidth(2),
                          1: FlexColumnWidth(.4),
                          2: FlexColumnWidth(1),
                          3: FlexColumnWidth(.4),
                          4: FlexColumnWidth(1),
                        },
                        children: [
                          TableRow(
                            children: [
                              TableCell(
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    item['text']!,
                                    style: const TextStyle(
                                      fontSize: 20,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                              ),
                              TableCell(
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    (() {
                                      // Parse and trim quantity value
                                      String quantityStr =
                                          item['quantity']!.trim();
                                      double? quantity =
                                          double.tryParse(quantityStr);

                                      if (quantity == null) {
                                        return quantityStr; // Fallback if parsing fails
                                      } else if (quantity == 0.5) {
                                        return '1/2';
                                      } else if (quantity == 0.25) {
                                        return '1/4';
                                      } else if (quantity % 1 == 0) {
                                        return quantity
                                            .toInt()
                                            .toString(); // Display integer if no decimal part
                                      } else {
                                        return quantity
                                            .toString(); // Display full decimal if needed
                                      }
                                    })(),
                                    style: const TextStyle(
                                      fontSize: 20,
                                      color: Colors.grey,
                                    ),
                                    textAlign: TextAlign.right,
                                  ),
                                ),
                              ),
                              TableCell(
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    item['uom']!,
                                    style: const TextStyle(
                                      fontSize: 20,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ),
                              ),
                              TableCell(
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    (() {
                                      // Parse and trim quantityCal value
                                      String quantityCal =
                                          item['quantityCal']!.trim();
                                      double? quantity =
                                          double.tryParse(quantityCal);

                                      if (quantity == null) {
                                        return quantityCal; // Fallback if parsing fails
                                      } else if (quantity == 0.5) {
                                        return '1/2';
                                      } else if (quantity == 0.25) {
                                        return '1/4';
                                      } else if (quantity % 1 == 0) {
                                        return quantity
                                            .toInt()
                                            .toString(); // Display integer if no decimal part
                                      } else {
                                        return quantity
                                            .toString(); // Display full decimal if needed
                                      }
                                    })(),
                                    style: const TextStyle(
                                      fontSize: 20,
                                      color: Colors.grey,
                                    ),
                                    textAlign: TextAlign.right,
                                  ),
                                ),
                              ),
                              TableCell(
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    item['uom']!,
                                    style: const TextStyle(
                                      fontSize: 20,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ] else ...[
            Container(
              height: 50.0, // Limit the height of the whole list
              child: ListView.builder(
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];
                  return GestureDetector(
                    onLongPress: () {
                      onEditPressed!();
                    },
                    child: Container(
                      child: Table(
                        columnWidths: const {
                          0: FlexColumnWidth(1.2),
                          1: FlexColumnWidth(.7),
                          2: FlexColumnWidth(0.4),
                          3: FlexColumnWidth(1),
                          4: FlexColumnWidth(.1),
                        },
                        children: [
                          TableRow(
                            children: [
                              TableCell(
                                child: Padding(
                                  padding: EdgeInsets.only(
                                      right: cellPadding, top: cellPadding),
                                  child: Text(
                                    item['text']!,
                                    style: TextStyle(
                                      fontSize: fontSize,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                              ),
                              TableCell(
                                child: Padding(
                                  padding: EdgeInsets.all(cellPadding),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Text(
                                        (() {
                                          // Parse and trim quantity value
                                          String quantityStr =
                                              item['quantity']!.trim();
                                          double? quantity =
                                              double.tryParse(quantityStr);

                                          if (quantity == null) {
                                            return quantityStr; // Fallback if parsing fails
                                          } else if (quantity == 0.5) {
                                            return '1/2';
                                          } else if (quantity == 0.25) {
                                            return '1/4';
                                          } else if (quantity % 1 == 0) {
                                            return quantity
                                                .toInt()
                                                .toString(); // Display integer if no decimal part
                                          } else {
                                            return quantity
                                                .toString(); // Display full decimal if needed
                                          }
                                        })(),
                                        style: TextStyle(
                                          fontSize: fontSize,
                                          color: Colors.grey,
                                        ),
                                        //  textAlign: TextAlign.left,
                                      ),
                                      Text(
                                        " ${item['uom']!}",
                                        style: TextStyle(
                                          fontSize: fontSize,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                                 TableCell(
                                child: Padding(
                                  padding: EdgeInsets.only(
                                      right: cellPadding, top: cellPadding),
                                  child: const Text("")
                                ),
                              ), 
                              TableCell(
                                child: Padding(
                                  padding: EdgeInsets.all(cellPadding),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Text(
                                        (() {
                                          // Parse and trim quantityCal value
                                          String quantityCal =
                                              item['quantityCal']!.trim();
                                          double? quantity =
                                              double.tryParse(quantityCal);

                                          if (quantity == null) {
                                            return quantityCal; // Fallback if parsing fails
                                          } else if (quantity == 0.5) {
                                            return '1/2';
                                          } else if (quantity == 0.25) {
                                            return '1/4';
                                          } else if (quantity % 1 == 0) {
                                            return quantity
                                                .toInt()
                                                .toString(); // Display integer if no decimal part
                                          } else {
                                            return quantity
                                                .toString(); // Display full decimal if needed
                                          }
                                        })(),
                                        style: TextStyle(
                                          fontSize: fontSize,
                                          color: Colors.grey,
                                        ),
                                        textAlign: TextAlign.right,
                                      ),
                                      Text(
                                        " ${item['uom']!}",
                                        style: TextStyle(
                                          fontSize: fontSize,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                                 TableCell(
                                child: Padding(
                                  padding: EdgeInsets.all(cellPadding),
                                  child: const Text('')
                                ),
                              ), 
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ]
        ],
      ),
    );
  }
}






 /* Expanded(
                    flex: 1,
                    child: Text(
                      "$quantity $uom",
                      style: const TextStyle(
                        fontSize: 25,
                        color: Colors.black,
                      ),
                      textAlign: TextAlign.left,
                    ),
                  ), */

  /*  title: GestureDetector(
              onLongPress: () => showPopover(
                width: 100,
                height: 100,
                backgroundColor: Theme.of(context).colorScheme.surface,
                context: context,
                bodyBuilder: (context) => Notesettings(
                  onEditTap: onEditPressed,
                  onDeleteTap: onDeletePressed,
                ),
              ), */