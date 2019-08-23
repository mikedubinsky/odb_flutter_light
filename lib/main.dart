import 'dart:async';
import 'dart:io';

import 'package:audioplayers/audio_cache.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:path_provider/path_provider.dart';

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
        Text(
          '8/18 ($kUrl1)',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        PlayerWidget(url: kUrl1),
        Text(
          '8/19 ($kUrl2)',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        PlayerWidget(url: kUrl2),
        Text(
          '8/20 ($kUrl3)',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        PlayerWidget(url: kUrl3),
        Text(
          '8/18 (Low Latency mode) ($kUrl1)',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        PlayerWidget(url: kUrl1, mode: PlayerMode.LOW_LATENCY),
      ]),
    );
  }

  Widget localFile() {
    return _tab([
      Text('Audio File URL: $kUrl1'),
      _btn('Download File to your Device', () => _loadFile()),
      Text('Current local file path: $localFilePath'),
      localFilePath == null ? Container() : PlayerWidget(url: localFilePath, isLocal: true),
    ]);
  }

  Future<int> _getDuration() async {
    File audiofile = await audioCache.load('audio2.mp3');
    await advancedPlayer.setUrl(
      audiofile.path,
      isLocal: true,
    );
    int duration = await Future.delayed(Duration(seconds: 2), () => advancedPlayer.getDuration());
    return duration;
  }

  getLocalFileDuration() {
    return FutureBuilder<int>(
      future: _getDuration(),
      builder: (BuildContext context, AsyncSnapshot<int> snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.none:
            return Text('No Connection...');
          case ConnectionState.active:
          case ConnectionState.waiting:
            return Text('Awaiting result...');
          case ConnectionState.done:
            if (snapshot.hasError) return Text('Error: ${snapshot.error}');
            return Text('Duration is: ${Duration(milliseconds: snapshot.data)}');
        }
        return null; // unreachable
      },
    );
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