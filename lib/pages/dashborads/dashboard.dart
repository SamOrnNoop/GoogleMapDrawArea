import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:learn_map/pages/draw_point/draw_with_point_map_page.dart';
import 'package:learn_map/utils/base_print.dart';
import 'package:learn_map/utils/constants.dart';
import '../draw_and_drag_custom/map_view_page.dart';
import '../image_test.dart';

class DashboardPageView extends StatefulWidget {
  const DashboardPageView({super.key});

  @override
  State<DashboardPageView> createState() => _DashboardPageViewState();
}

class _DashboardPageViewState extends State<DashboardPageView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: Stack(
        children: [
          Positioned.fill(
              child: Container(
            decoration: BoxDecoration(
                color: Colors.yellow,
                gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomLeft, colors: [
                  Colors.grey.shade50,
                  Colors.teal.shade100,
                  Colors.teal.shade200,
                  Colors.teal.shade100,
                  Colors.white70,
                ])),
          )),
          const Positioned.fill(
            child: BackdropFilter(
              filter: ColorFilter.mode(Colors.grey, BlendMode.lighten),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: ListView(
              // crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _appBarBuilder(),
                Padding(
                  padding: const EdgeInsets.only(top: 25, bottom: 5),
                  child: _title("Menu"),
                ),
                _builderMenu(),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: _title("Recently"),
                ),
                ListView.separated(
                    physics: const ClampingScrollPhysics(),
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      return const ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: CircleAvatar(
                          child: Text("B"),
                        ),
                        title: Text(
                          'Chan Dara Flower',
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        subtitle: Text(
                          'The easiest way to measure the acreage of a plot of land is to start by entering an address that is associated with the plot of land you need the area of.',
                          maxLines: 2,
                        ),
                      );
                    },
                    separatorBuilder: (context, index) {
                      return const Divider();
                    },
                    itemCount: 5)
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class DashboardItem {
  final String? title;
  final String? value;

  const DashboardItem({this.title, this.value});

  static int get itemLength => items.length;
  static List<DashboardItem> get items {
    return const [
      DashboardItem(title: "Draw with point", value: 'draw'),
      DashboardItem(title: "Walk Drawing", value: 'walk'),
      DashboardItem(title: "Drag Custom", value: 'drag-and-draw'),
      DashboardItem(title: "History", value: 'history'),
    ];
  }
}

Widget _appBarBuilder() {
  return const Padding(
    padding: EdgeInsets.only(top: kToolbarHeight),
    child: Card(
      margin: EdgeInsets.zero,
      child: SizedBox(
        width: double.infinity,
        height: 55,
        child: Center(
            child: Text(
          'GoogleMap Drawing',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Constants.primaryColor),
        )),
      ),
    ),
  );
  // return AppBar(title: const Text("GoogleMap Draw"), centerTitle: true);
}

Widget _title(String title) {
  return Text(
    title,
    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
  );
}

Widget _builderMenu() {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 10),
    child: GridView.builder(
        itemCount: DashboardItem.itemLength,
        shrinkWrap: true,
        padding: EdgeInsets.zero,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, crossAxisSpacing: 8, mainAxisSpacing: 8, childAspectRatio: 1.5),
        itemBuilder: (context, index) {
          DashboardItem item = DashboardItem.items[index];
          return _itemBuilderWidget(context, item, () {
            switch (item.value) {
              case 'draw':
                Get.to(const DrawWitPointMapPage());

                break;
              case 'drag-and-draw':
                Get.to(const DrawAndDragCustomEventPage());
              default:
                Get.to(const ApppTestImage());
            }
            BaseLogger.log(item.value);
            // print(item.value);
          });
        }),
  );
}

Widget _itemBuilderWidget(BuildContext context, DashboardItem item, void Function() callback) {
  return ElevatedButton(
    onPressed: callback,
    style: ElevatedButton.styleFrom(
        foregroundColor: Constants.primaryColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        )),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.map, size: 40),
        const SizedBox(height: 5),
        Text(
          item.title ?? '',
          textAlign: TextAlign.center,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ],
    ),
  );
}
