# Starlight Sync

If you want use a Future as a Stream,If you want to invoke a method one more times using that result,you can use this package.

## Features
| Method |  type |
|------|------|
| register | void |
| terminate | void |
| terminateAll | void |
| stream | stream |
| last | dynamic |
| execute | void |
| repeat | void |


## Preview

[Starlight Sync Tutorial](https://drive.google.com/file/d/1hu8IkwPIbydiCLdS5bEwozvafF1P-26z/view)


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

## Note
If you want to use a Future as a Stream or want to invoke a method one more times using that result,
you need to register a process


## Register 
You can register a process by [id].[id] must be a unique string.
```dart
   StarlightSync.register(id:"process 1");
```

## Stream
You can get a stream with a registered [id] and watch the changes directly.
```dart
    StarlightSync.stream(id:"process 1").listen((event){
        print("future stream is ${event['body']}");
    });
```

## Terminate 
You can terminate a process by [id].After terminate a process,
you can't execute that process anymore.
```dart
   StarlightSync.terminate(id:"process 1");
 ```

## TerminateAll
You can terminate all process by using terminateAll method.
```dart
   StarlightSync.terminateAll();
```



## Last
You can also get your last value by [id].
```dart
    final String lastValue = StarlightSync.last<String>(id"process 1");
```

## Execute 
If you want to execute a [Future] like this
<https://drive.google.com/file/d/1gKr_qawcUBNYLohD1jhARHgWaVajMX24/preview>
you need to register and listen by id
eg.
 ```dart
    ///Register a process
    StarlightSync.register(id:"process 1");
    ///Listen our future
    StarlightSync.stream(id:"process 1").listen((event){
        print("future stream is ${event['body']}");
    });
    ///Invoke a futuer 
    Timer.periodic(Duration(seconds:1), (){
        StarlightSync.execute(id:"process 1",task:()async{
            await http.get('/get/random-images');
        })
    });
 ```

## Repeat
If you want to invoke a method one more times using that result,
  
you can use this [repeat] method by providing
  
[id],[next],[stop],[task],[terminate] and [delay].
  
[id] must be registered.
  
[next] parameter will use in next time invoke.
  
[stop] parameter will determine the [task] method need to invoke or not.
  
[task] parameter is your [Future] work.
  
[terminate] parameter will determine the [Stream] and [Sink] should be terminated or not.
  
[delay] parameter will invoke after [task] is done.
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
            next: (result) async => result,
            stop: (index) async => index == 10,
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
	
