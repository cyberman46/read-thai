import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mobile_vision_2/flutter_mobile_vision_2.dart';
import 'package:img_to_text/ocr_read.dart';
//import 'package:img_to_text/ocr_read.dart';

import 'barcode_detail.dart';
import 'face_detail.dart';
import 'ocr_text_detail.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      //title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  bool isInitilized = false;
  String _platformVersion = 'Unknown';

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    String platformVersion;
    // Platform messages may fail, so we use a try/catch PlatformException.
    // We also handle the message potentially returning null.
    try {
      platformVersion = await FlutterMobileVision.platformVersion ??
          'Unknown platform version';
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
    });
  }

  int? _cameraBarcode = FlutterMobileVision.CAMERA_BACK;
  int? _onlyFormatBarcode = Barcode.ALL_FORMATS;
  bool _autoFocusBarcode = true;
  bool _torchBarcode = false;
  bool _multipleBarcode = false;
  bool _waitTapBarcode = false;
  bool _showTextBarcode = false;
  Size? _previewBarcode;
  List<Barcode> _barcodes = [];

  int? _cameraOcr = FlutterMobileVision.CAMERA_BACK;
  bool _autoFocusOcr = true;
  bool _torchOcr = false;
  bool _multipleOcr = false;
  bool _waitTapOcr = false;
  bool _showTextOcr = true;
  Size? _previewOcr;
  List<OcrText> _textsOcr = [];
  String val = "";

  int? _cameraFace = FlutterMobileVision.CAMERA_FRONT;
  bool _autoFocusFace = true;
  bool _torchFace = false;
  bool _multipleFace = true;
  bool _showTextFace = true;
  Size? _previewFace;
  List<Face> _faces = [];

  @override
  void initState() {
    super.initState();
    initPlatformState();
    FlutterMobileVision.start().then((previewSizes) => setState(() {
          if (previewSizes[_cameraBarcode] == null) {
            return;
          }
          _previewBarcode = previewSizes[_cameraBarcode]!.first;
          _previewOcr = previewSizes[_cameraOcr]!.first;
          _previewFace = previewSizes[_cameraFace]!.first;
        }));
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.lime,
        buttonColor: Colors.lime,
      ),
      home: DefaultTabController(
        length: 3,
        child: Scaffold(
          appBar: AppBar(
            bottom: TabBar(
              indicatorColor: Colors.black54,
              tabs: [
                Tab(text: 'Barcode'),
                Tab(text: 'OCR'),
                Tab(text: 'Face'),
              ],
            ),
            title: Text('ICON TEST Mobile Vision'),
            actions: [
              MaterialButton(
                color: Colors.blue,
                onPressed: () {
                  Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => ocr_read()));
                },
                child: Text(
                  "teserract thai",
                  style: TextStyle(color: Colors.white),
                ),
              )
            ],
          ),
          body: TabBarView(children: [
            _getBarcodeScreen(context),
            _getOcrScreen(context),
            _getFaceScreen(context),
            //ocr_read()
          ]),
        ),
      ),
    );
  }

  ///
  /// Scan formats
  ///
  List<DropdownMenuItem<int>> _getFormats() {
    List<DropdownMenuItem<int>> formatItems = [];

    Barcode.mapFormat.forEach((key, value) {
      formatItems.add(
        DropdownMenuItem(
          child: Text(value),
          value: key,
        ),
      );
    });

    return formatItems;
  }

  ///
  /// Camera list
  ///
  List<DropdownMenuItem<int>> _getCameras() {
    List<DropdownMenuItem<int>> cameraItems = [];

    cameraItems.add(DropdownMenuItem(
      child: Text('BACK'),
      value: FlutterMobileVision.CAMERA_BACK,
    ));

    cameraItems.add(DropdownMenuItem(
      child: Text('FRONT'),
      value: FlutterMobileVision.CAMERA_FRONT,
    ));

    return cameraItems;
  }

  ///
  /// Preview sizes list
  ///
  List<DropdownMenuItem<Size>> _getPreviewSizes(int facing) {
    List<DropdownMenuItem<Size>> previewItems = [];

    List<Size>? sizes = FlutterMobileVision.getPreviewSizes(facing);

    if (sizes != null) {
      sizes.forEach((size) {
        previewItems.add(
          DropdownMenuItem(
            child: Text(size.toString()),
            value: size,
          ),
        );
      });
    } else {
      previewItems.add(
        DropdownMenuItem(
          child: Text('Empty'),
          value: null,
        ),
      );
    }

    return previewItems;
  }

  ///
  /// Barcode Screen
  ///
  Widget _getBarcodeScreen(BuildContext context) {
    List<Widget> items = [];

    items.add(Padding(
      padding: const EdgeInsets.only(
        top: 8.0,
        left: 18.0,
        right: 18.0,
      ),
      child: const Text('Camera:'),
    ));

    items.add(Padding(
      padding: const EdgeInsets.only(
        left: 18.0,
        right: 18.0,
      ),
      child: DropdownButton<int>(
        items: _getCameras(),
        onChanged: (value) {
          _previewBarcode = null;
          setState(() => _cameraBarcode = value);
        },
        value: _cameraBarcode,
      ),
    ));

    items.add(Padding(
      padding: const EdgeInsets.only(
        top: 8.0,
        left: 18.0,
        right: 18.0,
      ),
      child: const Text('Preview size:'),
    ));

    items.add(Padding(
      padding: const EdgeInsets.only(
        left: 18.0,
        right: 18.0,
      ),
      child: DropdownButton<Size>(
        items: _getPreviewSizes(_cameraBarcode ?? 0),
        onChanged: (value) {
          setState(() => _previewBarcode = value);
        },
        value: _previewBarcode,
      ),
    ));

    items.add(Padding(
      padding: const EdgeInsets.only(
        top: 8.0,
        left: 18.0,
        right: 18.0,
      ),
      child: const Text('Scan format only:'),
    ));

    items.add(Padding(
      padding: const EdgeInsets.only(
        left: 18.0,
        right: 18.0,
      ),
      child: DropdownButton<int>(
        items: _getFormats(),
        onChanged: (value) => setState(
          () => _onlyFormatBarcode = value,
        ),
        value: _onlyFormatBarcode,
      ),
    ));

    items.add(SwitchListTile(
      title: const Text('Auto focus:'),
      value: _autoFocusBarcode,
      onChanged: (value) => setState(() => _autoFocusBarcode = value),
    ));

    items.add(SwitchListTile(
      title: const Text('Torch:'),
      value: _torchBarcode,
      onChanged: (value) => setState(() => _torchBarcode = value),
    ));

    items.add(SwitchListTile(
      title: const Text('Multiple Scan:'),
      value: _multipleBarcode,
      onChanged: (value) => setState(() {
        _multipleBarcode = value;
        if (value) _waitTapBarcode = true;
      }),
    ));

    items.add(SwitchListTile(
      title: const Text('Wait a tap to capture:'),
      value: _waitTapBarcode,
      onChanged: (value) => setState(() {
        _waitTapBarcode = value;
        if (!value) _multipleBarcode = false;
      }),
    ));

    items.add(SwitchListTile(
      title: const Text('Show text:'),
      value: _showTextBarcode,
      onChanged: (value) => setState(() => _showTextBarcode = value),
    ));

    items.add(
      Padding(
        padding: const EdgeInsets.only(
          left: 18.0,
          right: 18.0,
          bottom: 12.0,
        ),
        child: ElevatedButton(
          onPressed: _scan,
          child: Text('SCAN!'),
        ),
      ),
    );

    items.addAll(
      ListTile.divideTiles(
        context: context,
        tiles: _barcodes
            .map(
              (barcode) => BarcodeWidget(barcode),
            )
            .toList(),
      ),
    );

    return ListView(
      padding: const EdgeInsets.only(
        top: 12.0,
      ),
      children: items,
    );
  }

  ///
  /// Barcode Method
  ///
  Future<Null> _scan() async {
    List<Barcode> barcodes = [];
    Size _scanpreviewOcr = _previewOcr ?? FlutterMobileVision.PREVIEW;
    try {
      barcodes = await FlutterMobileVision.scan(
        flash: _torchBarcode,
        autoFocus: _autoFocusBarcode,
        formats: _onlyFormatBarcode ?? Barcode.ALL_FORMATS,
        multiple: _multipleBarcode,
        waitTap: _waitTapBarcode,
        showText: _showTextBarcode,
        preview: _previewBarcode ?? FlutterMobileVision.PREVIEW,
        scanArea: Size(_scanpreviewOcr.width - 20, _scanpreviewOcr.height - 20),
        camera: _cameraBarcode ?? FlutterMobileVision.CAMERA_BACK,
        fps: 15.0,
      );
    } on Exception {
      barcodes.add(Barcode('Failed to get barcode.'));
    }

    if (!mounted) return;

    setState(() => _barcodes = barcodes);
  }

  ///
  /// OCR Screen
  ///
  Widget _getOcrScreen(BuildContext context) {
    List<Widget> items = [];

    items.add(Padding(
      padding: const EdgeInsets.only(
        top: 8.0,
        left: 18.0,
        right: 18.0,
      ),
      child: const Text('Camera:'),
    ));

    items.add(Padding(
      padding: const EdgeInsets.only(
        left: 18.0,
        right: 18.0,
      ),
      child: DropdownButton<int>(
        items: _getCameras(),
        onChanged: (value) {
          _previewOcr = null;
          setState(() => _cameraOcr = value);
        },
        value: _cameraOcr,
      ),
    ));

    items.add(Padding(
      padding: const EdgeInsets.only(
        top: 8.0,
        left: 18.0,
        right: 18.0,
      ),
      child: const Text('Preview size:'),
    ));

    items.add(Padding(
      padding: const EdgeInsets.only(
        left: 18.0,
        right: 18.0,
      ),
      child: DropdownButton<Size>(
        items: _getPreviewSizes(_cameraOcr ?? 0),
        onChanged: (value) {
          setState(() => _previewOcr = value);
        },
        value: _previewOcr,
      ),
    ));

    items.add(SwitchListTile(
      title: const Text('Auto focus:'),
      value: _autoFocusOcr,
      onChanged: (value) => setState(() => _autoFocusOcr = value),
    ));

    items.add(SwitchListTile(
      title: const Text('Torch:'),
      value: _torchOcr,
      onChanged: (value) => setState(() => _torchOcr = value),
    ));

    items.add(SwitchListTile(
      title: const Text('Return all texts:'),
      value: _multipleOcr,
      onChanged: (value) => setState(() => _multipleOcr = value),
    ));

    items.add(SwitchListTile(
      title: const Text('Capture when tap screen:'),
      value: _waitTapOcr,
      onChanged: (value) => setState(() => _waitTapOcr = value),
    ));

    items.add(SwitchListTile(
      title: const Text('Show text:'),
      value: _showTextOcr,
      onChanged: (value) => setState(() => _showTextOcr = value),
    ));

    items.add(
      Padding(
        padding: const EdgeInsets.only(
          left: 18.0,
          right: 18.0,
          bottom: 12.0,
        ),
        child: ElevatedButton(
          onPressed: _read,
          child: Text('READ!'),
        ),
      ),
    );

    items.addAll(
      ListTile.divideTiles(
        context: context,
        tiles: _textsOcr
            .map(
              (ocrText) => OcrTextWidget(ocrText),
            )
            .toList(),
      ),
    );

    return ListView(
      padding: const EdgeInsets.only(
        top: 12.0,
      ),
      children: items,
    );
  }

  ///
  /// OCR Method
  ///
  Future<Null> _read() async {
    List<OcrText> texts = [];
    Size _scanpreviewOcr = _previewOcr ?? FlutterMobileVision.PREVIEW;
    try {
      texts = await FlutterMobileVision.read(
        flash: _torchOcr,
        autoFocus: _autoFocusOcr,
        multiple: _multipleOcr,
        waitTap: _waitTapOcr,
        showText: _showTextOcr,
        preview: _previewOcr ?? FlutterMobileVision.PREVIEW,
        scanArea: Size(_scanpreviewOcr.width - 10, _scanpreviewOcr.height - 10),
        camera: _cameraOcr ?? FlutterMobileVision.CAMERA_BACK,
        fps: 2.0,
      );
    } on Exception {
      texts.add(OcrText('Failed to recognize text.'));
    }

    if (!mounted) return;

    setState(() => _textsOcr = texts);
  }

  ///
  /// Face Screen
  ///
  Widget _getFaceScreen(BuildContext context) {
    List<Widget> items = [];

    items.add(Padding(
      padding: const EdgeInsets.only(
        top: 8.0,
        left: 18.0,
        right: 18.0,
      ),
      child: const Text('Camera:'),
    ));

    items.add(Padding(
      padding: const EdgeInsets.only(
        left: 18.0,
        right: 18.0,
      ),
      child: DropdownButton<int>(
        items: _getCameras(),
        onChanged: (value) {
          _previewFace = null;
          setState(() => _cameraFace = value);
        },
        value: _cameraFace,
      ),
    ));

    items.add(Padding(
      padding: const EdgeInsets.only(
        top: 8.0,
        left: 18.0,
        right: 18.0,
      ),
      child: const Text('Preview size:'),
    ));

    items.add(Padding(
      padding: const EdgeInsets.only(
        left: 18.0,
        right: 18.0,
      ),
      child: DropdownButton<Size>(
        items: _getPreviewSizes(_cameraFace ?? 0),
        onChanged: (value) {
          setState(() => _previewFace = value);
        },
        value: _previewFace,
      ),
    ));

    items.add(SwitchListTile(
      title: const Text('Auto focus:'),
      value: _autoFocusFace,
      onChanged: (value) => setState(() => _autoFocusFace = value),
    ));

    items.add(SwitchListTile(
      title: const Text('Torch:'),
      value: _torchFace,
      onChanged: (value) => setState(() => _torchFace = value),
    ));

    items.add(SwitchListTile(
      title: const Text('Multiple:'),
      value: _multipleFace,
      onChanged: (value) => setState(() => _multipleFace = value),
    ));

    items.add(SwitchListTile(
      title: const Text('Show text:'),
      value: _showTextFace,
      onChanged: (value) => setState(() => _showTextFace = value),
    ));

    items.add(
      Padding(
        padding: const EdgeInsets.only(
          left: 18.0,
          right: 18.0,
          bottom: 12.0,
        ),
        child: ElevatedButton(
          onPressed: _face,
          child: Text('DETECT!'),
        ),
      ),
    );

    items.addAll(
      ListTile.divideTiles(
        context: context,
        tiles: _faces.map((face) => FaceWidget(face)).toList(),
      ),
    );

    return ListView(
      padding: const EdgeInsets.only(top: 12.0),
      children: items,
    );
  }

  ///
  /// Face Method
  ///
  Future<Null> _face() async {
    Size _scanpreviewOcr = _previewOcr ?? FlutterMobileVision.PREVIEW;
    List<Face> faces = [];
    try {
      faces = await FlutterMobileVision.face(
        flash: _torchFace,
        autoFocus: _autoFocusFace,
        multiple: _multipleFace,
        showText: _showTextFace,
        preview: _previewFace ?? FlutterMobileVision.PREVIEW,
        scanArea: Size(_scanpreviewOcr.width - 20, _scanpreviewOcr.height - 20),
        camera: _cameraFace ?? FlutterMobileVision.CAMERA_BACK,
        fps: 15.0,
      );
    } on Exception {
      faces.add(Face(-1));
    }

    if (!mounted) return;

    setState(() => _faces = faces);
  }
}

///
/// BarcodeWidget
///
class BarcodeWidget extends StatelessWidget {
  final Barcode barcode;

  BarcodeWidget(this.barcode);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.star),
      title: Text(barcode.displayValue),
      subtitle: Text('${barcode.getFormatString()} (${barcode.format}) - '
          '${barcode.getValueFormatString()} (${barcode.valueFormat})'),
      trailing: const Icon(Icons.arrow_forward),
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => BarcodeDetail(barcode),
        ),
      ),
    );
  }
}

///
/// OcrTextWidget
///
class OcrTextWidget extends StatelessWidget {
  final OcrText ocrText;

  OcrTextWidget(this.ocrText);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.title),
      title: Text(ocrText.value),
      subtitle: Text(ocrText.language),
      trailing: const Icon(Icons.arrow_forward),
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => OcrTextDetail(ocrText),
        ),
      ),
    );
  }
}

///
/// FaceWidget
///
class FaceWidget extends StatelessWidget {
  final Face face;

  FaceWidget(this.face);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.face),
      title: Text(face.id.toString()),
      trailing: const Icon(Icons.arrow_forward),
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => FaceDetail(face),
        ),
      ),
    );
  }
}
