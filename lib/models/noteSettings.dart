import 'package:flutter/material.dart';

class Notesettings extends StatelessWidget {
  const Notesettings({super.key, this.onEditTap, this.onDeleteTap});

  final void Function()? onEditTap;
  final void Function()? onDeleteTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        //edit option
        GestureDetector(
            onTap: () {
              Navigator.pop(context);
              onEditTap!();
            },
            child: Container(
              height: 50,
              color: Theme.of(context).colorScheme.surface,
              child: const Center(child: Text('Edit')),
            )),
        //delete option
        GestureDetector(
            onTap: () {
              Navigator.pop(context);
              onDeleteTap!();
            },
            child: Container(
              height: 50,
              color: Theme.of(context).colorScheme.surface,
              child: const Center(child: Text('Delete')),
            )),
      ],
    );
  }
}
