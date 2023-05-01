import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class UploadImage extends StatefulWidget {
  const UploadImage({super.key});

  @override
  State<UploadImage> createState() => _UploadImageState();
}

class _UploadImageState extends State<UploadImage> {

  final _addFormKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  File? _image;
  final picker = ImagePicker();

  Future getImage() async {
    final pickedFile = await picker.getImage(source: ImageSource.gallery);
    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      } else {
        print('No image selected.');
      }
    });
  }

  Future<void> addImage(Map<String, String> body, String filepath) async {
    // String addimageUrl = '<domain-name>/api/imageadd';
    Map<String, String> headers = {
      'Content-Type': 'multipart/form-data',
    };
    
    var uri = Uri.https('creativeparkingsolutions.com', 'admin/upload_image_app');

    var request = http.MultipartRequest('POST', uri)
      ..fields.addAll(body)
      ..headers.addAll(headers)
      ..files.add(await http.MultipartFile.fromPath('image', filepath));

    // var response = await request.send();
    request.send().then((result) async {
      http.Response.fromStream(result).then((response) {
        print(response.statusCode);
        var jsonData = jsonDecode(response.body);
        print(jsonData);
      });
    });
    // print(response.statusCode);
    
    // print(response);
    // if (response.statusCode == 201) {
    //   return true;
    // } else {
    //   return false;
    // }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Image'),
      ),
      body: Form(
        key: _addFormKey,
        child: SingleChildScrollView(
          child: Container(
            child: Column(
              children: [
                Text('Image Title'),
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(hintText: 'Enter Title',),
                ),
                Container(
                  child: OutlinedButton(
                    onPressed: getImage,
                    child: _buildImage()
                  ),
                ),
                Container(
                  child: ElevatedButton(
                    onPressed: (){
                        _addFormKey.currentState!.save();
                        Map<String, String> body = {
                        'title': _titleController.text};
                        addImage(body, _image!.path);
                    },
                    child: Text('Save')
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImage() {
    if (_image == null) {
      return Padding(
        padding: EdgeInsets.all(10),
        child: Icon(
          Icons.add,
          color: Colors.grey,
        ),
      );
    } else {
      return Text(_image!.path);
    }
  }
}