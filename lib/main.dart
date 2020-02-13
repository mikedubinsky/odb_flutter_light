import 'dart:async';
import 'dart:io';
//import 'package:animated_splash/animated_splash.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import 'player_widget.dart';
import 'helpers.dart';

typedef void OnError(Exception exception);

// TODO: old testing data to be refactored and removed
const kUrl1 =
    'https://dzxuyknqkmi1e.cloudfront.net/odb/2020/02/odb-02-18-20.mp3';

// TODO: Remove Download tab and add download button to main page (download file is currently hard coded)
// TODO: Allow calendar to only go so many days in the future
void main() {
  runApp(new MaterialApp(
      debugShowCheckedModeBanner: false, home: new ExampleApp()));
}

class ExampleApp extends StatefulWidget {
  @override
  _ExampleAppState createState() => new _ExampleAppState();
}

class _ExampleAppState extends State<ExampleApp> {
  String localFilePath = '';
  String audioUrl;
  String imageUrl;
  DateTime selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    audioUrl = generateAudioUrl(selectedDate);
    imageUrl = generateImageUrl(selectedDate);
  }

  // Resource: https://stackoverflow.com/questions/52727535/what-is-the-correct-way-to-add-date-picker-in-flutter-app
  Future<Null> _selectDate(BuildContext context) async {
    final DateTime picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2010),
      lastDate: DateTime(2030),
      builder: (BuildContext context, Widget child) {
        return Theme(
          data: ThemeData(
            brightness: Brightness.light,
            primaryColor: const Color(0xFFFAB431),
            accentColor: Colors.cyan[600],
          ),
          child: child,
        );
      },
    );

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
        color: const Color(0xFFFAB431),
        width: double.infinity,
        height: 800,
        // padding: EdgeInsets.all(16.0),
        child: Column(
          children: children
              .map((w) => Container(child: w, padding: EdgeInsets.all(0.0)))
              .toList(),
        ),
      ),
    );
  }

  Widget _btn(String txt, VoidCallback onPressed) {
    return ButtonTheme(
        minWidth: 48.0,
        child: RaisedButton(child: Text(txt), onPressed: onPressed));
  }

  Widget remoteUrl() {
    return SingleChildScrollView(
      child: _tab([
        Center(
            child: Container(
          padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
          child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                new Text(
                  DateFormat('MMMM dd, yyyy').format(selectedDate),
                  style: new TextStyle(
                    color: Colors.white,
                    fontSize: 22.0,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2.0,
                    height: 1.5,
                  ),
                ),
                new IconButton(
                  icon: new Icon(
                    Icons.calendar_today,
                    color: Colors.white,
                    size: 30.0,
                  ),
                  onPressed: () => _selectDate(context),
                ),
              ]),
        )),
        //player widget
        new PlayerWidget(
            url: audioUrl, imgUrl: imageUrl, devoDate: selectedDate),
      ]),
    );
  }

  Widget localFile() {
    return _tab([
      //Text('Audio URL: $kUrl1'),
      // _btn('Download File', () => _loadFile()),
      //Text('Current local file path: $localFilePath'),
      localFilePath == null
          ? Container()
          : PlayerWidget(
              url: localFilePath,
              imgUrl: imageUrl,
              devoDate: selectedDate,
              isLocal: true),
      _btn('Download File', () => _loadFile()),
      //Text('Current local file path: $localFilePath'),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xFFFAB431),
          elevation: 0.0,
          title: new Center(
            child: new Text("Our Daily Drive"),
          ),
          leading: new IconButton(
            //menu back button
            icon: new Icon(
              Icons.arrow_back_ios,
            ),
            color: const Color(0xFFDDDDDD),
            onPressed: () {},
          ),
          actions: <Widget>[
            //hamburger menu  button
            new IconButton(
              icon: new Icon(
                Icons.menu,
              ),
              color: const Color(0xFFDDDDDD),
              onPressed: () {},
            )
          ],
          bottom: TabBar(
            tabs: [
              Tab(text: 'Stream Audio'),
              Tab(text: 'Download Audio'),
              Tab(icon: Icon(Icons.monetization_on)),
            ],
          ),
        ),
        body: TabBarView(
          children: [remoteUrl(), localFile(), localFile()],
        ),
      ),
    );
  }
}
