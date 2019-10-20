import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'constants.dart';
import 'package:dio/dio.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool loading;
  Dio dio = Dio(BaseOptions(baseUrl: server));
  Timer timer;
  @override
  void initState() {
    load();
    super.initState();
  }

  void load() async {
    timer?.cancel();

    timer = Timer.periodic(Duration(seconds: 2), (t) {
      getStatus();
    });
    loading = true;
    if (mounted) {
      setState(() {});
    }
    //get data from server and update
    Map<String, dynamic> map = (await dio.get('/info')).data;
    map['statuses'] = List.generate(map['size'], (i) => 0);
    setState(() {
      dummy = map;
      loading = false;
    });
  }

  Future<void> getStatus() async {
    Map<String, dynamic> map = (await dio.get('/status')).data;
    setState(() {
      dummy['statuses'] = map['statuses'];
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Parking-Monitor',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        primaryColor: Colors.blue[900],
        accentColor: Colors.blue[900]
      ),
      home: Scaffold(
        appBar: AppBar(
          title: Text("Parking-Monitor"),
          centerTitle: true,
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: load,
          child: Icon(Icons.refresh),
        ),
        body: loading
            ? Center(
                child: CircularProgressIndicator(),
              )
            : Plotter(),
      ),
    );
  }
}

class Plotter extends StatefulWidget {
  @override
  PlotterState createState() => PlotterState();
}

class PlotterState extends State<Plotter> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      alignment: Alignment.center,
      child: AspectRatio(
        aspectRatio: (dummy['width'] / dummy['height']),
        child: CustomPaint(
          foregroundPainter: PaintBox(MediaQuery.of(context).size),
          child: Container(
            color: Colors.grey[200],
          ),
        ),
      ),
    );
  }
}

class PaintBox extends CustomPainter {
  final Size size;

  PaintBox(this.size);
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    paint.strokeWidth = 3;

    for (int i = 0; i < (dummy["size"]); i++) {
      if (dummy['statuses'][i]==0)
        paint.color = Colors.red;
      else
        paint.color = Colors.green;

      List<dynamic> coordinatess = dummy["boxes"][i]['coordinates'];
      double wr = size.width / dummy["width"];
      double hr = size.height / dummy["height"];
      Offset init = Offset(coordinatess[0][0] * wr, coordinatess[0][1] * hr);
      Offset p1 = init;
      for (int j = 0; j < 4; j++) {
        Offset p2 = Offset(coordinatess[j][0] * wr, coordinatess[j][1] * hr);
        canvas.drawLine(p1, p2, paint);
        p1 = p2;
      }
      canvas.drawLine(p1, init, paint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
