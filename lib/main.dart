import 'dart:async';
import 'dart:io';

import 'package:audioplayers/audio_cache.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'player_widget.dart';

typedef void OnError(Exception exception);

const kUrl1 = 'https://dzxuyknqkmi1e.cloudfront.net/odb/2019/08/odb-08-18-19.mp3';
const kUrl2 = 'https://dzxuyknqkmi1e.cloudfront.net/odb/2019/08/odb-08-19-19.mp3';
const kUrl3 = 'https://dzxuyknqkmi1e.cloudfront.net/odb/2019/08/odb-08-20-19.mp3';

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
  String datePicked;
  DateTime date;
  TimeOfDay time;
  final dateFormat = DateFormat("MMMM-dd-yyyy");

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
        DateTimeForm(),
                Text(
         'Date: 8/18\n$kUrl1',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        PlayerWidget(url: kUrl1),
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


class DateTimeForm extends StatefulWidget {
  @override
  _DateTimeFormState createState() => _DateTimeFormState();
}

class _DateTimeFormState extends State<DateTimeForm> {
  final formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          BasicDateField(),
          SizedBox(height: 24),
//          RaisedButton(
//            child: Text('Save'),
//            onPressed: () => formKey.currentState.save(),
//          ),
//          RaisedButton(
//            child: Text('Reset'),
//            onPressed: () => formKey.currentState.reset(),
//          ),
//          RaisedButton(
//            child: Text('Validate'),
//            onPressed: () => formKey.currentState.validate(),
//          ),
        ],
      ),
    );
  }
}

class BasicDateField extends StatelessWidget {

  final format = DateFormat("yyyy-MM-dd");
  @override
  Widget build(BuildContext context) {
    return Column(children: <Widget>[
      Align(
        alignment: Alignment.center,
        child: Text("Basic date field"),
      ),
      DateTimeField(
        format: format,
        onShowPicker: (context, currentValue) {
          return showDatePicker(
              context: context,
              firstDate: DateTime(1900),
              initialDate: currentValue ?? DateTime.now(),
              lastDate: DateTime(2100));
        },
      ),
    ]);
  }
}