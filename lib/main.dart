import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_circle_color_picker/flutter_circle_color_picker.dart';
import 'package:nice_button/nice_button.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Salon Prélaz LED'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Socket socket;
  bool isDone = true;
  bool isConnecting = false;
  var oldTime = DateTime.now().millisecondsSinceEpoch;
  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    //Connect standard in to the socket
  }

  void dataHandler(data) {
    print(new String.fromCharCodes(data).trim());
  }

  void errorHandler(error, StackTrace trace) {
    isDone = true;
    print(error);
  }

  void doneHandler() {
    isDone = true;
    socket.destroy();
  }

  void onchange(Color c) async {
    var newTime = DateTime.now().millisecondsSinceEpoch;

    if (isDone) {
      if (!isConnecting) {
        isConnecting = true;
        await Socket.connect('192.168.1.195', 2018).then((Socket sock) {
          socket = sock;
          socket.listen(dataHandler,
              onError: errorHandler, onDone: doneHandler, cancelOnError: false);
        }).catchError((Object e) {
          print("Unable to connect: $e");
        });
        isConnecting = false;
        isDone = false;
      }
    }
    if (newTime - oldTime > 15) {
      if (!isDone && !isConnecting) {
        print("New Color !");
        var message = Uint8List(4);
        var bytedata = ByteData.view(message.buffer);
        bytedata.setUint8(0, 0);
        bytedata.setUint8(1, c.red);
        bytedata.setUint8(2, c.green);
        bytedata.setUint8(3, c.blue);
        socket.add(message);
        oldTime = newTime;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.cyan,
        centerTitle: true,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            CircleColorPicker(
              initialColor: Colors.blue,
              onChanged: (color) => onchange(color),
              size: const Size(280, 280),
              strokeWidth: 11,
              thumbSize: 30,
            ),
            SizedBox(
              height: 50,
            ),
            NiceButton(
              width: 255,
              elevation: 8.0,
              radius: 52.0,
              text: "Eteindre",
              background: Colors.cyan,
              onPressed: () async {
                var newTime = DateTime.now().millisecondsSinceEpoch;

                if (isDone) {
                  if (!isConnecting) {
                    isConnecting = true;
                    await Socket.connect('192.168.1.195', 2018)
                        .then((Socket sock) {
                      socket = sock;
                      socket.listen(dataHandler,
                          onError: errorHandler,
                          onDone: doneHandler,
                          cancelOnError: false);
                    }).catchError((Object e) {
                      print("Unable to connect: $e");
                    });
                    isConnecting = false;
                    isDone = false;
                  }
                }
                if (newTime - oldTime > 15) {
                  if (!isDone && !isConnecting) {
                    print("New Color !");
                    var message = Uint8List(4);
                    var bytedata = ByteData.view(message.buffer);
                    bytedata.setUint8(0, 0);
                    bytedata.setUint8(1, 0);
                    bytedata.setUint8(2, 0);
                    bytedata.setUint8(3, 0);
                    socket.add(message);
                    oldTime = newTime;
                  }
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
