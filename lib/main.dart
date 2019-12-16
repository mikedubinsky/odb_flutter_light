import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import 'player_widget.dart';

typedef void OnError(Exception exception);

// old testing data to be refactored and removed
const kUrl1 = 'https://dzxuyknqkmi1e.cloudfront.net/odb/2019/08/odb-08-18-19.mp3';

// TODO: Remove Download tab and add download button to main page (download file is currently hard coded)

void main() {
  runApp(new MaterialApp(
      debugShowCheckedModeBanner: false,
      home: new ExampleApp()));
}

class ExampleApp extends StatefulWidget {
  @override
  _ExampleAppState createState() => new _ExampleAppState();
}

class _ExampleAppState extends State<ExampleApp> {
  String localFilePath = '';
  final dateFormat = DateFormat("MMMM-dd-yyyy");
  DateTime selectedDate = DateTime.now();
  var audioUrl = 'https://dzxuyknqkmi1e.cloudfront.net/odb/2019/12/odb-12-13-19.mp3';
  var imageUrl = 'https://d626yq9e83zk1.cloudfront.net/files/2019/12/odb20191212.jpg';

  // function to return the audio URL
  String generateAudioUrl(DateTime picked) {
    String month = twoDigit(picked.month.toString());
    String day = twoDigit(picked.day.toString());
    String year = twoDigit(picked.year.toString());
    String fullYear = picked.year.toString();

    return 'https://dzxuyknqkmi1e.cloudfront.net/odb/$fullYear/$month/odb-$month-$day-$year.mp3';
  }

  ////  todo return the image URL
  String generateImageUrl(DateTime picked) {
    String month = twoDigit(picked.month.toString());
    String day = twoDigit(picked.day.toString());
    String year = picked.year.toString();
    String fullYear = picked.year.toString();
    return 'https://d626yq9e83zk1.cloudfront.net/files/$fullYear/$month/odb$year$month$day.jpg';
  }
  
  // function to return 2 digits month or day
  String twoDigit(String temp) {
    if (temp.length==1) {
      return "0" + temp;
    } else if (temp.length==4) {
      return temp.substring(temp.length - 2);
    }  else {
      return temp;
    }
  }

  // Resource: https://stackoverflow.com/questions/52727535/what-is-the-correct-way-to-add-date-picker-in-flutter-app
  Future<Null> _selectDate(BuildContext context) async {
    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: selectedDate,
        firstDate: DateTime(2010),
        lastDate: DateTime(2030));

    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
        audioUrl = generateAudioUrl(picked);
        imageUrl = generateImageUrl(picked);
      });
    }
  }

  Future _loadFile() async {
    final bytes = await readBytes(kUrl1);
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/audio.mp3');

    await file.writeAsBytes(bytes);
    if (await file.exists()) {
      setState(() {
        localFilePath = file.path;
      });
    }
  }

  Widget _tab(List<Widget> children) {
    return Center(
      child: Container(
        width: double.infinity,
       // padding: EdgeInsets.all(16.0),
        child: Column(
          children: children.map((w) => Container(child: w, padding: EdgeInsets.all(0.0))).toList(),
        ),
      ),
    );
  }

  Widget _btn(String txt, VoidCallback onPressed) {
    return ButtonTheme(minWidth: 48.0, child: RaisedButton(child: Text(txt), onPressed: onPressed));
  }

  Widget remoteUrl() {
      // if (audioUrl == '') {
      //   setState(() {
      //     audioUrl = generateAudioUrl(selectedDate);
      //   });
      // }

    return SingleChildScrollView(

      child: _tab([
        
        //player widget
         new PlayerWidget(url: audioUrl, imgUrl: imageUrl),

         //select date widget area
          SizedBox(height: 20.0,),
          RaisedButton(
            onPressed: () => _selectDate(context),
            child: Text('Select date'),
          ),
        Text(
            "${dateFormat.format(selectedDate.toLocal())}",
            style: TextStyle(fontWeight: FontWeight.bold)
        ),
       /* Text(
            "Audio URL: $audioUrl",
            style: TextStyle(fontWeight: FontWeight.bold)
        ),*/
       // new PlayerWidget(url: audioUrl, imgUrl: imageUrl),
      ]),
    );

  }

  Widget localFile() {
    return _tab([
      //Text('Audio URL: $kUrl1'),
     // _btn('Download File', () => _loadFile()),
      //Text('Current local file path: $localFilePath'),
      localFilePath == null ? Container() : PlayerWidget(url: localFilePath, imgUrl: imageUrl, isLocal: true),
     _btn('Download File', () => _loadFile()),
      //Text('Current local file path: $localFilePath'),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xFFFAB431),
          elevation: 0.0,
          title: new Center(child: new Text("Our Daily Drive"),),
          leading: new IconButton(
            //menu back button
          icon:new Icon(
            Icons.arrow_back_ios,
          ),
          color: const Color (0xFFDDDDDD),
          onPressed: (){},
          ),
          actions: <Widget>[
             //hamburger menu  button
            new IconButton(
              icon:new Icon(
              Icons.menu,
            ),
                      color: const Color (0xFFDDDDDD),
          onPressed: (){},
            )
            ],
          bottom: TabBar(
            tabs: [
              Tab(text: 'Streaming Audio'),
              Tab(text: 'Downloaded Audio'),
            ],
          ),

        ),
        body: TabBarView(
          children: [remoteUrl(), localFile()],
          
        ),

      ),
    );
  }
}