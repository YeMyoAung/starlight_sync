import 'dart:convert';

import 'package:example/const.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:starlight_sync/starlight_sync.dart';

void main() {
  StarlightSync.register(id: 'dog.ceo/all');
  StarlightSync.register(id: "dog.ceo/random");
  runApp(const MyApp());
}

class MyApp extends MaterialApp {
  const MyApp({Key? key}) : super(key: key, home: const _MyApp());
}

class _MyApp extends StatelessWidget {
  const _MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    StarlightSync.execute(
      id: "dog.ceo/all",
      task: () async {
        try {
          final Map data = (jsonDecode(
            (await http.get(Uri.parse(allBreeds))).body,
          )['message'] as Map);

          final List _response = [];

          data.forEach((key, value) {
            _response.add(key);
          });
          return _response;
        } catch (e) {
          debugPrint("$e");
        }
      },
    );
    return Scaffold(
      appBar: AppBar(
        title: const Text("Starlight Sync Example"),
      ),
      body: StreamBuilder(
        stream: StarlightSync.stream(id: "dog.ceo/all"),
        builder: (_, all) {
          if (all.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (all.hasError) {
            return const Center(
              child: Icon(Icons.error),
            );
          }

          return StreamBuilder(
            stream: StarlightSync.stream(id: "dog.ceo/random"),
            builder: (_, random) {
              if (!random.hasData) {
                return Center(
                  child: Text("Dog Type ${(all.data as List).length}"),
                );
              }
              return Center(
                child: Image.network(
                  (random.data as Map)['image'],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          StarlightSync.repeat(
            id: "dog.ceo/random",
            next: (Map result) {
              if (result['status'] != "success") return null;
              return (result['next'] as int) + 1;
            },
            stop: (int? next) => next == null,
            task: ([int? next]) async {
              final Map body = jsonDecode((await http.get(
                Uri.parse(
                  singleDog(
                    StarlightSync.last(id: "dog.ceo/all")[next ?? 0],
                  ),
                ),
              ))
                  .body);
              return {
                "image": body['message'],
                "status": body['status'],
                "next": next ?? 0,
              };
            },
            // delay: const Duration(seconds: 3),
          );
        },
        child: const Icon(Icons.play_arrow),
      ),
    );
  }
}
