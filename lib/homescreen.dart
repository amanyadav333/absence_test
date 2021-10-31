import 'dart:io';

import 'package:absen_test/playscreen.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  late XFile _image;
  late File song;
  bool imgFlag=false,songFlag=false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Test"),
      ),
      body: Container(
        margin: EdgeInsets.symmetric(vertical: 10,horizontal: 15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 20,),
            buildImage(),

            SizedBox(height: 20,),
            buildSong(),


            SizedBox(height: 50,),
            buildSave()
          ],
        ),
      ),
    );
  }

  buildImage(){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Select Image:",style:
        TextStyle(fontSize: 20,fontWeight: FontWeight.w500),),
        SizedBox(height: 20,),
        imgFlag?Container(
          alignment: Alignment.centerLeft,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(_image.name.toString().
                substring(0,_image.name.toString().length<30?_image.name.toString().length:30)
                  ,style: TextStyle(fontSize: 18),),
              ),
              InkWell(
                onTap: (){
                  setState(() {
                    imgFlag=false;
                  });
                },
                child: Icon(
                    Icons.clear
                ),
              )
            ],
          ),
        ):RaisedButton(onPressed: (){
          _showPicker(context);
        },
          child: Text("Choose Image",style: TextStyle(color: Colors.white),)
          ,color: Colors.deepOrangeAccent,),
      ],
    );
  }

  buildSong(){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Select Songs:",style: TextStyle(fontSize: 20,fontWeight: FontWeight.w500),),
        SizedBox(height: 20,),
        songFlag?Container(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Expanded(child: Text(song.path.split('/').last.toString()        ,             style: TextStyle(fontSize: 18),)),
              SizedBox(width: 50,),
              InkWell(
                onTap: (){
                  setState(() {
                    songFlag=false;
                  });
                },
                child: Icon(
                    Icons.clear
                ),
              )
            ],
          ),
        ):RaisedButton(onPressed: () async {
          FilePickerResult? result = await FilePicker.platform.pickFiles(
            type: FileType.custom,
            allowedExtensions: ['mp3'],
          );
          if(result!=null){
            setState(() {
              song=File(result.files.first.path.toString());
              songFlag=true;
            });
          }
        },color: Colors.deepOrangeAccent,
          child: Text("Choose Songs",style: TextStyle(color: Colors.white),),),
      ],
    );
  }

  buildSave(){
    return Container(
      width: MediaQuery.of(context).size.width,
      child: RaisedButton(
        onPressed: (){
          if(!imgFlag){
            Fluttertoast.showToast(
                msg: "Please Select the Image",
                toastLength: Toast.LENGTH_SHORT,
            );
          }else if(!songFlag){
            Fluttertoast.showToast(
              msg: "Please Select the Song",
              toastLength: Toast.LENGTH_SHORT,
            );
          }else{
            Navigator.push(context, MaterialPageRoute(builder:
                (context) => PlayScreen(song,_image),));
          }
        },color: Colors.deepOrangeAccent,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Go",style: TextStyle(fontSize:20,color: Colors.white)),
            SizedBox(width: 5,),
            Icon(Icons.arrow_forward_sharp,color: Colors.white,size: 20,)
          ],
        ),
      ),
    );
  }

  _imgFromCamera() async {
    XFile? image = await ImagePicker.platform.getImage(
        source: ImageSource.camera, imageQuality: 50
    );

    setState(() {
      _image = image!;
      imgFlag=true;
    });
  }

  _imgFromGallery() async {
    XFile? image = await  ImagePicker.platform.getImage(
        source: ImageSource.gallery, imageQuality: 50
    );

    setState(() {
      _image = image!;
      imgFlag=true;
    });
  }

  void _showPicker(context) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return SafeArea(
            child: Container(
              child: new Wrap(
                children: <Widget>[
                  new ListTile(
                      leading: new Icon(Icons.photo_library),
                      title: new Text('Photo Library'),
                      onTap: () {
                        _imgFromGallery();
                        Navigator.of(context).pop();
                      }),
                  new ListTile(
                    leading: new Icon(Icons.photo_camera),
                    title: new Text('Camera'),
                    onTap: () {
                      _imgFromCamera();
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            ),
          );
        }
    );
  }
}
