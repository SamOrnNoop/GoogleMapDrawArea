import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class ApppTestImage extends StatefulWidget {
  const ApppTestImage({super.key});

  @override
  State<ApppTestImage> createState() => _ApppTestImageState();
}

Future<List<int>> get() async {
  final value = await Dio().get(
    'https://random-image-pepebigotes.vercel.app/api/random-image',
    options: Options(
      responseType: ResponseType.bytes,
    ),
  );
  return value.data;
}

class _ApppTestImageState extends State<ApppTestImage> {
  Map<int, Widget?> imageStore = {};
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: ListView.builder(
        itemCount: 50,
        itemBuilder: (context, index) {
          if (imageStore[index] != null) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Container(
                  height: 300,
                  width: double.infinity,
                  clipBehavior: Clip.hardEdge,
                  // padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.grey.shade200)),
                  child: Column(
                    children: [
                      ListTile(
                        leading: CircleAvatar(
                          backgroundImage: (imageStore[index] as Image).image,
                        ),
                        title: const Text("Dara Long"),
                        subtitle: const Text("2025-07-11"),
                      ),
                      Flexible(
                        child: SizedBox(
                          child: imageStore[index],
                        ),
                      )
                    ],
                  )),
            );
          }
          return SizedBox(
            height: 300,
            width: double.infinity,
            child: FutureBuilder<List<int>>(
                future: get(),
                builder: (context, sna) {
                  if (!sna.hasData) {
                    Widget loading = const Center(
                      child: CircularProgressIndicator(),
                    );
                    imageStore[index] = null;
                    return loading;
                  } else {
                    final Widget image = Image.memory(
                      Uint8List.fromList(sna.data!),
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.fill,
                    );
                    imageStore[index] = image;
                    return image;
                  }
                }),
          );
        },
      ),
    );
  }
}
