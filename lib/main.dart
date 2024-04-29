import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // Initialisez Firebase
  runApp(MaterialApp(
    home: ImageUploader(),
  ));
}

class ImageUploader extends StatefulWidget {
  @override
  _ImageUploaderState createState() => _ImageUploaderState();
}

class _ImageUploaderState extends State<ImageUploader> {
  File? _image;
  String? _imageName;

  Future<void> _uploadImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.getImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<void> _sendImageToStorage() async {
    if (_image != null && _imageName != null) {
      firebase_storage.Reference ref = firebase_storage.FirebaseStorage.instance
          .ref()
          .child('images')
          .child('$_imageName.png');

      await ref.putFile(_image!);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('L\'image a été envoyée avec succès avec le nom: $_imageName')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Veuillez sélectionner une image et entrer un nom avant d\'envoyer')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Image Uploader'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            _image == null
                ? Text('Aucune image sélectionnée.')
                : Image.file(
              _image!,
              height: 200,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _uploadImage,
              child: Text('Sélectionner une image'),
            ),
            SizedBox(height: 20),
            TextField(
              onChanged: (value) {
                setState(() {
                  _imageName = value;
                });
              },
              decoration: InputDecoration(
                labelText: 'Entrez le nom de l\'image',
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _sendImageToStorage,
              child: Text('Envoyer l\'image'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ImageFromStorage()),
                );
              },
              child: Text('Voir l\'image depuis Firebase Storage'),
            ),
          ],
        ),
      ),
    );
  }
}

class ImageFromStorage extends StatefulWidget {
  @override
  _ImageFromStorageState createState() => _ImageFromStorageState();
}

class _ImageFromStorageState extends State<ImageFromStorage> {
  String? _imageName;
  String? _imageUrl;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Image From Firebase Storage'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextField(
              onChanged: (value) {
                setState(() {
                  _imageName = value;
                });
              },
              decoration: InputDecoration(
                labelText: 'Entrez le nom de l\'image',
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                if (_imageName != null) {
                  firebase_storage.Reference ref = firebase_storage.FirebaseStorage.instance
                      .ref()
                      .child('images')
                      .child('$_imageName.png');
                  String downloadUrl = await ref.getDownloadURL();
                  setState(() {
                    _imageUrl = downloadUrl;
                  });
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Veuillez entrer un nom d\'image')),
                  );
                }
              },
              child: Text('Récupérer l\'image'),
            ),
            SizedBox(height: 20),
            _imageUrl != null
                ? Image.network(
              _imageUrl!,
              height: 200,
            )
                : SizedBox(), // Afficher l'image si l'URL est disponible
          ],
        ),
      ),
    );
  }
}
