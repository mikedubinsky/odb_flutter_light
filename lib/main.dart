import 'dart:async';
import 'dart:io';

import 'package:audioplayers/audio_cache.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import 'player_widget.dart';

typedef void OnError(Exception exception);

const kUrl1 = 'https://dzxuyknqkmi1e.cloudfront.net/odb/2019/08/odb-08-18-19.mp3';
const kUrl2 = 'https://dzxuyknqkmi1e.cloudfront.net/odb/2019/08/odb-08-19-19.mp3';
const kUrl3 = 'https://dzxuyknqkmi1e.cloudfront.net/odb/2019/08/odb-08-20-19.mp3';

// TODO: Bug: Need to select a date, change tabs, and return for audio player to work
// TODO: Remove Download tab and add download button to main page

void main() {
  runApp(new MaterialApp(home: new ExampleApp()));
}

class ExampleApp extends StatefulWidget {
  @override
  _ExampleAppState createState() => new _ExampleAppState();
}

class _ExampleAppState extends State<ExampleApp> {
  AudioCache audioCache = AudioCache();
  AudioPlayer advancedPlayer = AudioPlayer();
  String localFilePath;
  final dateFormat = DateFormat("MMMM-dd-yyyy");
  DateTime selectedDate = DateTime.now();
  String audioUrl = '';

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
      String month = twoDigit(picked.month.toString());
      String day = twoDigit(picked.day.toString());
      String year = twoDigit(picked.year.toString());
      String fullYear = picked.year.toString();
      setState(() {
        selectedDate = picked;
        audioUrl =
        'https://dzxuyknqkmi1e.cloudfront.net/odb/$fullYear/$month/odb-$month-$day-$year.mp3';
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
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: children.map((w) => Container(child: w, padding: EdgeInsets.all(6.0))).toList(),
        ),
      ),
    );
  }

  Widget _btn(String txt, VoidCallback onPressed) {
    return ButtonTheme(minWidth: 48.0, child: RaisedButton(child: Text(txt), onPressed: onPressed));
  }

  Widget remoteUrl() {
    return SingleChildScrollView(
      child: _tab([
          SizedBox(height: 20.0,),
          RaisedButton(
            onPressed: () => _selectDate(context),
            child: Text('Select date'),
          ),
        Text(
            "${dateFormat.format(selectedDate.toLocal())}",
            style: TextStyle(fontWeight: FontWeight.bold)
        ),
        Text(
            "Audio URL: $audioUrl",
            style: TextStyle(fontWeight: FontWeight.bold)
        ),
        PlayerWidget(url: audioUrl),
      ]),
    );

  }

  Widget localFile() {
    return _tab([
      Text('Audio URL: $kUrl1'),
      _btn('Download File', () => _loadFile()),
      Text('Current local file path: $localFilePath'),
      localFilePath == null ? Container() : PlayerWidget(url: localFilePath, isLocal: true),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          bottom: TabBar(
            tabs: [
              Tab(text: 'Remote File'),
              Tab(text: 'Download File'),
            ],
          ),
          title: new Center(child: new Text("Our Daily Bread  |  Audio Player"),),
        ),
        body: TabBarView(
          children: [remoteUrl(), localFile()],
        ),
      ),
    );
  }
}