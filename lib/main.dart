import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'solarize.dart';
import 'package:image/image.dart' as imagem;
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'dart:typed_data';
import 'package:rflutter_alert/rflutter_alert.dart';

void main() => runApp(const Maragram());

class Maragram extends StatelessWidget {
  const Maragram({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: '/',
      routes: <String, WidgetBuilder>{
        '/': (BuildContext context) => const MainPage(),
        '/details': (BuildContext context) => const DetailsPage(),
      },
      title: 'Maragram Generator',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.grey,
          brightness: Brightness.dark,
        ).copyWith(
          primaryContainer: Colors.grey,
          onPrimaryContainer: Colors.black,
          secondaryContainer: Colors.grey,
          onSecondaryContainer: Colors.black,
          error: Colors.yellow,
          onError: Colors.black,
        ),
      ),
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  MainPageState createState() => MainPageState();
}

class MainPageState extends State<MainPage> {
  double _value = 127.0;
  String mode = "";
  String imagePath = '';

  /// Assuming this is defined at class level
  XFile? chosen;
  List<bool> isSelected = [true, false];

  Future<void> selectImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    setState(() {
      chosen = pickedFile;
      imagePath = pickedFile!.path;
    });
  }

  Future<void> applyMaragram() async {
    if (chosen != null) {
      if (isSelected[0] == true) {
        mode = '';
      } else {
        mode = 'shadows';
      }
      final File file = File(chosen!.path);
      final img = imagem.decodeImage(await file.readAsBytes());
      if (img != null) {
        final imagem.Image modifiedImage =
            await solarize(img, threshold: _value.toInt(), mode: mode);
        final Uint8List modifiedImageBytes =
            await imagem.encodeJpg(modifiedImage);
        final result = await ImageGallerySaver.saveImage(modifiedImageBytes);
        if (result != null) {
          Alert(
            context: context,
            type: AlertType.success,
            title: "Maragram SAVED!!!",
            desc: "Close this alert to generate another.",
            buttons: [
              DialogButton(
                child: const Text(
                  "CLOSE",
                  style: TextStyle(color: Colors.white, fontSize: 20),
                ),
                onPressed: () => Navigator.pop(context),
                width: 120,
              )
            ],
          ).show();
        }
      }
    } else {
      Alert(
        context: context,
        type: AlertType.error,
        title: "Error",
        desc: "Close this alert to try again.",
        buttons: [
          DialogButton(
            child: const Text(
              "CLOSE",
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
            onPressed: () => Navigator.pop(context),
            width: 120,
          )
        ],
      ).show();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: 90,
          backgroundColor: Colors.grey[600],
          centerTitle: true,
          title: const Text('Maragram Generator',
              style: TextStyle(
                  fontFamily: 'KodeMono', color: Colors.grey, fontSize: 32.0)),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              CupertinoButton.filled(
                onPressed: selectImage,
                child: const Text(
                  'Select Image',
                  style: TextStyle(
                      fontFamily: 'SourceCodePro',
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.black),
                ),
              ),
              const SizedBox(height: 50),
              imagePath != ''
                  ? Image.file(
                      File(imagePath),
                      height: 200,
                    )
                  : const SizedBox(),
              const SizedBox(height: 20),
              Slider(
                value: _value,
                min: 1,
                max: 254,
                divisions: 254,
                label: '${_value.round()}',
                onChanged: (value) {
                  setState(() {
                    _value = value;
                    print(_value);
                  });
                },
              ),
              const SizedBox(height: 20),
              ToggleButtons(
                  isSelected: isSelected,
                  children: [
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 30),
                      child: Text('Highlights',
                          style:
                              TextStyle(fontFamily: 'KodeMono', fontSize: 21)),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 30),
                      child: Text('Shadows',
                          style:
                              TextStyle(fontFamily: 'KodeMono', fontSize: 21)),
                    )
                  ],
                  onPressed: (int newIndex) {
                    setState(() {
                      for (int index = 0; index < isSelected.length; index++) {
                        if (index == newIndex) {
                          isSelected[index] = true;
                        } else {
                          isSelected[index] = false;
                        }
                      }
                    });
                  }),
              const SizedBox(height: 50),
              CupertinoButton.filled(
                onPressed: applyMaragram,
                child: const Text(
                  'Apply Maragram',
                  style: TextStyle(
                      fontFamily: 'SourceCodePro',
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.black),
                ),
              ),
              const SizedBox(height: 50),

              GestureDetector(
                onTap: () {
                  // This moves from the personal info page to the credentials page,
                  // replacing this page with that one.
                  Navigator.of(context).pushReplacementNamed('/details');
                },
                child: Container(
                  alignment: Alignment.center,
                  child: const Text('Details', style: TextStyle(
                      fontFamily: 'SourceCodePro',
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DetailsPage extends StatelessWidget {
  const DetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: 90,
          backgroundColor: Colors.grey[600],
          centerTitle: true,
          title: const Text('Maragram Generator',
              style: TextStyle(
                  fontFamily: 'KodeMono', color: Colors.grey, fontSize: 32.0)),
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 50),
            const Center(
              child: Text(
                'Simple solarization app to apply the Dart Image Package solarization filter I designed.\n\nSolarization is the partial inversion if an image.\n\nHighlights and Shadows refer to where the solarization will take place. Threshold defines the pixels value up to where the effect will take place.\n\nBuilt by Guilherme Maranhao. Check out my other experimental projects at refotografia.wordpress.com',
                style: TextStyle(
                    fontFamily: 'SourceCodePro',
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
            ),
            const SizedBox(height: 50),
            Center(
              child: GestureDetector(
                onTap: () {
                  Navigator.of(context).pushReplacementNamed('/');
                },
                child: Container(
                  alignment: Alignment.center,
                  child: const Text('Back', style: TextStyle(
            fontFamily: 'SourceCodePro',
            fontSize: 20.0,
            fontWeight: FontWeight.bold,
            color: Colors.white),),
                ),
              ),
            ),
          ],
        ),
      ),
      );

  }
}
