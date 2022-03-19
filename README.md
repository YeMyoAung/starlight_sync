# Starlight Sync

If you want use a Future as a Stream,If you want to invoke a method one more times using that result,you can use this package.

## Features
| Name |  Status |
|------|------|
| execute | ✅ |
| repeat | ✅ |


## Preview

[Video](https://drive.google.com/file/d/1gKr_qawcUBNYLohD1jhARHgWaVajMX24/preview)


## Installation

Add starlight_sync as dependency to your pubspec file.

```
   starlight_sync: 
    git:
      url: https://github.com/YeMyoAung/starlight_sync.git
```
## Setup

No additional integration steps are required for Android and Ios.

## Usage

First of all you need to import our package.

```dart
import 'package:starlight_sync/starlight_sync.dart';
```

And then you can use easily.

Register a process
```dart
   StarlightSync.register(id:"process 1");
```

Terminate a process
```dart
   StarlightSync.terminate(id:"process 1");
 ```

Terminate all process
```dart
   StarlightSync.terminateAll();
```

Execute a future
 ```dart
    StarlightSync.register(id:"process 1");
    StarlightSync.stream(id:"process 1").listen((event){
        print("future stream is ${event['body']}");
    });
    Timer.periodic(Duration(seconds:1), (){
        StarlightSync.execute(id:"process 1",task:()async{
            await http.get('/get/random-images');
        })
    });
 ```
Execute a Future one more times using that result
 ```dart
   StarlightSync.register<String?, ResponseModel>(id: 'all user');
   int i = 0;
   StarlightSync.stream<String?, ResponseModel>(id: 'all user')
       .listen((event) {
     i += (event.body['users'] as List).length;
     print("listen body ${event.body}");
     print("listen data is $i");
   });
   StarlightSync.repeat<String?, ResponseModel>(
     id: 'all user',
     next: (result) => result.body['next_page'],
     stop: (next) => next == null,
     task: ([next]) async {
       return appInstance<ApiService>().getMethod(
           query: "/get/users/$next",
       );
     },
   );
```

## Example

```dart
import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:starlight_sync/starlight_sync.dart';
import 'package:http/http.dart' as http;
import 'package:starlight_utils/starlight_utils.dart';

void main(){
    StarlightSync.register(id: "dog.ceo");
    StarlightSync.register(id: "dog.ceo/repeat");
    runApp(MaterialApp(home:ExecuteExampleScreen()));
}


class ExecuteExampleScreen extends StatelessWidget {
  const ExecuteExampleScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("StarlightSync.execute Method"),
        actions: [
          IconButton(
              onPressed: () {
                StarlightUtils.push(RepeatExampleScreen());
              },
              icon: Icon(Icons.arrow_circle_right_outlined))
        ],
      ),
      body: Center(
        child: StreamBuilder(
          stream: StarlightSync.stream(id: 'dog.ceo'),
          builder: (_, AsyncSnapshot snap) {
            if (snap.connectionState == ConnectionState.waiting)
              return Text("Waiting a Future....");
            if (snap.hasError) return Icon(Icons.error);
            return CachedNetworkImage(
              imageUrl: jsonDecode(snap.data!.body)["message"],
              placeholder: (_, e) => CircularProgressIndicator(),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          StarlightSync.execute(
            id: 'dog.ceo',
            task: () async => http.get(
              Uri.parse('https://dog.ceo/api/breeds/image/random'),
            ),
          );
        },
        child: Icon(Icons.refresh),
      ),
    );
  }
}

class RepeatExampleScreen extends StatelessWidget {
  const RepeatExampleScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("StarlightSync.repeat Method"),
      ),
      body: Center(
        child: StreamBuilder(
          stream: StarlightSync.stream(id: 'dog.ceo/repeat'),
          builder: (_, AsyncSnapshot snap) {
            if (snap.connectionState == ConnectionState.waiting)
              return Text("Wating For a Future ");
            if (snap.hasError) return Icon(Icons.error);
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Execute Last Value is ${StarlightSync.last(id: 'dog.ceo')?.body}",
                ),
                SizedBox(
                  height: 20,
                ),
                Expanded(
                  child: CachedNetworkImage(
                    imageUrl: jsonDecode(snap.data!.body)["message"],
                    placeholder: (_, e) =>
                        Center(child: CircularProgressIndicator()),
                  ),
                ),
              ],
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          StarlightSync.repeat(
            id: 'dog.ceo/repeat',
            next: (result) => result,
            stop: (index) => index == 10,
            task: ([_]) async => http.get(
              Uri.parse(
                'https://dog.ceo/api/breeds/image/random',
              ),
            ),
            delay: Duration(seconds: 3),
          );
        },
        child: Icon(Icons.play_arrow),
      ),
    );
  }
}


```

## Contact Us


[Starlight Studio](https://www.facebook.com/starlightstudio.of/)
	
