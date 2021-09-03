import 'dart:io';

import 'package:flutter/material.dart';
//import 'package:flutter_mobile_vision/flutter_mobile_vision.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_tesseract_ocr/flutter_tesseract_ocr.dart';

class ocr_read extends StatefulWidget {
  const ocr_read({Key? key}) : super(key: key);

  @override
  _ocr_readState createState() => _ocr_readState();
}

class _ocr_readState extends State<ocr_read> {
  bool _scanning = false;
  String _extractText = '';
  File _pickedImage = File("");
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.green,
        title: Text('Tesseract thai OCR'),
      ),
      body: ListView(
        children: [
          _pickedImage == null
              ? Container(
                  height: 300,
                  color: Colors.grey[300],
                  child: Icon(
                    Icons.image,
                    size: 100,
                  ),
                )
              : Container(
                  height: 300,
                  decoration: BoxDecoration(
                      color: Colors.grey[300],
                      image: DecorationImage(
                        image: FileImage(_pickedImage),
                        //fit: BoxFit.fill,
                      )),
                ),
          Container(
            height: 50,
            margin: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
            child: RaisedButton(
              color: Colors.green,
              child: Text(
                'เลือกรูป',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
              onPressed: () async {
                setState(() {
                  _scanning = true;
                });
                _pickedImage =
                    await ImagePicker.pickImage(source: ImageSource.camera);
                _extractText = await FlutterTesseractOcr.extractText(
                    _pickedImage.path,
                    language: "tha"); //ภาษาไทย
                setState(() {
                  _scanning = false;

                  print("Extract : ${_extractText}");
                });
              },
            ),
          ),
          SizedBox(height: 20),
          _scanning
              ? Center(
                  child: Column(
                  children: [
                    Text("โปรดรอซักครู่ กำลังจัดการ"),
                    CircularProgressIndicator()
                  ],
                ))
              : Icon(
                  Icons.done,
                  size: 40,
                  color: Colors.green,
                ),
          SizedBox(height: 20),
          Center(
            child: Text(
              _extractText,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            ),
          )
        ],
      ),
    );
  }
}
