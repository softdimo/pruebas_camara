import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  File? _image;
  ImageProvider? _imageProvider;

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await ImagePicker().pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
        _imageProvider = FileImage(_image!);
      });

      if (_imageProvider != null) {
        // Llama a la función para guardar la imagen
        await saveImage(_imageProvider!);
      }
    }
  }

  Future<void> saveImage(ImageProvider imageProvider) async {
    ImageStream stream = imageProvider.resolve(const ImageConfiguration());
    Completer<ImageInfo> completer = Completer<ImageInfo>();

    stream.addListener(ImageStreamListener(
      (ImageInfo info, bool _) {
        completer.complete(info);
      },
    ));

    ImageInfo imageInfo = await completer.future;

    ByteData? byteData = await imageInfo.image.toByteData(format: ui.ImageByteFormat.png);
    Uint8List pngBytes = byteData!.buffer.asUint8List();

    // Obtén el directorio de documentos
    String dir = (await getApplicationDocumentsDirectory()).path;

    // Crea un nombre de archivo único
    String filePath = '$dir/imagen_guardada.png';
    print('Ruta de la imagen: $filePath');

    // Guarda la imagen en el directorio de documentos
    await File(filePath).writeAsBytes(pngBytes);

    // Guarda la imagen en la galería de fotos
    await ImageGallerySaver.saveFile(filePath);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Flutter Demo Home Page'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            CircleAvatar(
              radius: 150,
              backgroundImage: _imageProvider != null
                  ? _imageProvider
                  : AssetImage('assets/images/perfil.png'),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                ElevatedButton(
                  onPressed: () => _pickImage(ImageSource.camera),
                  child: Text('Tomar foto'),
                ),
                ElevatedButton(
                  onPressed: () => _pickImage(ImageSource.gallery),
                  child: Text('Seleccionar de la galería'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
