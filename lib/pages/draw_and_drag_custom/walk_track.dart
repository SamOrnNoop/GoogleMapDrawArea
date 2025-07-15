import 'package:flutter/material.dart';

class WalkTrackPointWidget extends StatelessWidget {
  final void Function()? onPresssed;
  const WalkTrackPointWidget({
    super.key,
    required this.onPresssed,
  });

  void onShowDialog(BuildContext context) {
    showModalBottomSheet(
        constraints: const BoxConstraints(maxHeight: 100),
        context: context,
        builder: build,
        backgroundColor: Colors.transparent,
        clipBehavior: Clip.none,
        barrierColor: Colors.transparent);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 10, left: 20, right: 20),
      decoration:
          const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(10))),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Please pressed on that button for getting your point",
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          Center(
              child: Container(
                  margin: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: Colors.blue[50], borderRadius: BorderRadius.circular(10)),
                  child: IconButton(onPressed: onPresssed, icon: const Icon(Icons.track_changes)))),
        ],
      ),
    );
  }
}
