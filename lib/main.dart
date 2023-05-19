import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:image/image.dart' as img;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:yolov7_flutter/recognition.dart';
import 'box_widget.dart';
import 'classifier.dart';
import 'package:logger/logger.dart';

Future<void> main() async {
  // Fetch the available cameras before initializing the app.
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Image Classification',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: MyHomePage(title: 'yolov7 testing'),
      builder: EasyLoading.init(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, this.title}) : super(key: key);

  final String? title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late Classifier _classifier;

  var logger = Logger();

  File? _image;
  img.Image? _resizeImage;
  final picker = ImagePicker();

  Image? _imageWidget;
  Recognition? _pred_data;
  img.Image? fox;

  List<Recognition> results = [];

  @override
  void initState() {
    super.initState();
    configLoading();
    _classifier = Classifier();
  }

  configLoading() {
    EasyLoading.instance
      ..indicatorType = EasyLoadingIndicatorType.fadingCircle
      ..loadingStyle = EasyLoadingStyle.dark
      ..indicatorSize = 45.0
      ..radius = 10.0
      ..progressColor = Colors.yellow
      ..backgroundColor = Colors.green
      ..indicatorColor = Colors.yellow
      ..textColor = Colors.yellow
      ..maskColor = Colors.blue.withOpacity(0.5)
      ..userInteractions = true
      ..dismissOnTap = false;
  }

  Future getImage(double screenWidth, double screenHeight) async {
    EasyLoading.show();
    final pickedFile = await picker.getImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      _image = File(pickedFile.path);
      await resigeImage(screenWidth, screenHeight);
      setState(() {
        //_imageWidget = result;
        _predict();
      });
    } else {
      EasyLoading.dismiss();
    }
  }

  void _predict() async {
    img.Image imageInput = img.decodeImage(_image!.readAsBytesSync())!;
    //List<Recognition> recognition = _classifier.predict(imageInput);
    List<Recognition> recognition = _classifier.predict(_resizeImage!);
    results = recognition.isNotEmpty ? recognition : [];
    EasyLoading.dismiss();
    setState(() {
      if (recognition.isNotEmpty) {
        _pred_data = recognition[0];
      } else {
        _pred_data = null;
      }
    });
  }

  Future resigeImage(double screenWidth, double screenHeight) async {
    img.Image imageInput = img.decodeImage(_image!.readAsBytesSync())!;
    img.Image resized = img.copyResize(imageInput,
        width: screenWidth.toInt(), height: screenHeight ~/ 2);
    _resizeImage = resized;
    Image result = Image.memory(Uint8List.fromList(img.encodePng(resized)));
    _imageWidget = Image.memory(Uint8List.fromList(img.encodePng(resized)));
    Future.value(result);
  }

  @override
  Widget build(BuildContext context) {
    double screeWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        title:
            const Text('Yolov7 testing', style: TextStyle(color: Colors.white)),
      ),
      body: Center(
        child: Column(
          children: <Widget>[
            const SizedBox(
              height: 20,
            ),
            _image == null
                ? const Text('No image selected.')
                : Container(
                    height: MediaQuery.of(context).size.height / 2,
                    width: MediaQuery.of(context).size.width,
                    child: Stack(
                      children: [
                        Container(
                            width: _imageWidget?.width,
                            height: _imageWidget?.height,
                            child: _imageWidget),
                        if (results.isNotEmpty)
                          boundingBoxes(results, _imageWidget!),
                      ],
                    ),
                  ),
            const SizedBox(
              height: 50,
            ),
            _pred_data != null && results.isNotEmpty
                ? Text(
                    ' ${_pred_data?.id.toString()} : ${_pred_data?.label} : ${_pred_data?.score.toStringAsFixed(2)}',
                    style: const TextStyle(fontSize: 16),
                  )
                : _image != null
                    ? const Text(
                        "Can't Predict Data!",
                        style: TextStyle(
                            fontSize: 18,
                            color: Colors.red,
                            fontWeight: FontWeight.bold),
                      )
                    : Container(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          getImage(screeWidth, screenHeight);
        },
        tooltip: 'Pick Image',
        child: Icon(Icons.add_a_photo),
      ),
    );
  }

  void resultsCallback(Recognition reg) {
    results = [];
    //&& (reg.score.clamp(0.70, 1) == reg.score)
    //reg.label.toLowerCase() == "person" &&
    results.add(reg);
  }

  Widget boundingBoxes(List<Recognition> results, Image image) {
    if (results.isEmpty) {
      return Container();
    } else {
      return Stack(
        children: results
            .map(
              (e) => BoxWidget(result: e, image: image),
            )
            .toList(),
      );

      //value exists
    }
  }
}
