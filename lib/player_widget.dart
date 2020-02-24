import 'dart:async';
import 'dart:convert';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:odb_flutter_light/theme.dart';
import 'package:http/http.dart' as http;
import 'helpers.dart';

enum PlayerState { stopped, playing, paused }

class PlayerWidget extends StatefulWidget {
  final String url;
  final String imgUrl;
  final DateTime devoDate;
  final String title;
  final String author;
  final bool isLocal;
  final PlayerMode mode;

  PlayerWidget({
    @required this.url,
    @required this.imgUrl,
    @required this.devoDate,
    this.title = "Daily Devotional",
    this.author = "Our Daily Bread",
    this.isLocal = false,
    this.mode = PlayerMode.MEDIA_PLAYER,
  });

  @override
  State<StatefulWidget> createState() {
    return new _PlayerWidgetState(
        url, imgUrl, devoDate, title, author, isLocal, mode);
  }
}

class _PlayerWidgetState extends State<PlayerWidget> {
  String stateUrl;
  String imageUrl;
  DateTime devoDateState;
  String devoTitle;
  String authorName;
  bool isLocal;
  PlayerMode mode;

  AudioPlayer _audioPlayer;
  AudioPlayerState _audioPlayerState;
  Duration _duration;
  Duration _position;

  PlayerState _playerState = PlayerState.stopped;
  StreamSubscription _durationSubscription;
  StreamSubscription _positionSubscription;
  StreamSubscription _playerCompleteSubscription;
  StreamSubscription _playerErrorSubscription;
  StreamSubscription _playerStateSubscription;

  get _isPlaying => _playerState == PlayerState.playing;
  get _isPaused => _playerState == PlayerState.paused;
  get _durationText => _duration?.toString()?.split('.')?.first ?? '';
  get _positionText => _position?.toString()?.split('.')?.first ?? '';

  _PlayerWidgetState(this.stateUrl, this.imageUrl, this.devoDateState,
      this.devoTitle, this.authorName, this.isLocal, this.mode);

  @override
  void initState() {
    super.initState();
    fetchPost(devoDateState);
    _initAudioPlayer();
  }

  @override
  void didUpdateWidget(Widget oldWidget) {
    fetchPost(widget.devoDate);

    setState(() {
      stateUrl = widget.url;
      imageUrl = widget.imgUrl;
      devoDateState = widget.devoDate;
    });
    _audioPlayer.setUrl(widget.url);
  }

  @override
  void dispose() {
    _audioPlayer.stop();
    _durationSubscription?.cancel();
    _positionSubscription?.cancel();
    _playerCompleteSubscription?.cancel();
    _playerErrorSubscription?.cancel();
    _playerStateSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return new Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        new Container(
          color: Colors.orangeAccent[300],
          width: double.infinity,
          height: 330.0,
          child: Image.network(
            imageUrl,
            fit: BoxFit.fitHeight,
          ),
        ),
        new Container(
            color: accentColor,
            child: new Padding(
              padding: const EdgeInsets.all(5.0),
              child: new Column(
                children: <Widget>[
                  new RichText(
                      text: new TextSpan(text: '', children: [
                    const TextSpan(
                      text: '\n',
                    ),
                    new TextSpan(
                      text: devoTitle,
                      style: new TextStyle(
                        color: Colors.white,
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 3.0,
                        height: 1.5,
                      ),
                    ),
                    const TextSpan(
                      text: '\n',
                    ),
                    new TextSpan(
                        text: authorName,
                        style: new TextStyle(
                          color: Colors.white.withOpacity(0.65),
                          fontSize: 14.0,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2.0,
                          height: 1.5,
                        ))
                  ])),
                  /////duration info
                  Container(
                    padding: EdgeInsets.fromLTRB(0, 15, 0, 5),
                    child: Align(
                      child: Text(
                        _position != null
                            ? '${_positionText ?? ''} / ${_durationText ?? ''}'
                            : _duration != null ? _durationText : '',
                        style: new TextStyle(
                            color: Colors.white.withOpacity(0.95),
                            fontSize: 20.0),
                      ),
                      alignment: Alignment.topCenter,
                    ),
                  ),
                  ////progress indicator
                  ///////todo add a circle to the progress
                  /*new FractionallySizedBox(
                    //height: 9.0,
                    widthFactor: 0.9,
                    child: new LinearProgressIndicator(
                      value: (_position != null &&
                              _duration != null &&
                              _position.inMilliseconds > 0 &&
                              _position.inMilliseconds <
                                  _duration.inMilliseconds)
                          ? _position.inMilliseconds / _duration.inMilliseconds
                          : 0.0,
                      valueColor: new AlwaysStoppedAnimation(Colors.cyan),
                    ),
                  ),*/

                  ////slider
                  Padding(
                      padding: EdgeInsets.all(0.0),
                      child: Stack(children: [
                        Slider(
                          onChanged: (v) {
                            final Position = v * _duration.inMilliseconds;
                            _audioPlayer
                                .seek(Duration(milliseconds: Position.round()));
                          },
                          value: (_position != null &&
                                  _duration != null &&
                                  _position.inMilliseconds > 0 &&
                                  _position.inMilliseconds <
                                      _duration.inMilliseconds)
                              ? _position.inMilliseconds /
                                  _duration.inMilliseconds
                              : 0.0,
                        ),
                      ])),

                  ///////todo find a better way formatting the player controls
                  Padding(
                    padding: const EdgeInsets.only(
                        left: 0.0, top: 35.0, right: 0.0, bottom: 0.0),
                    child: new Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Expanded(child: Container(
                          //color: Colors.blue,
                          child: new IconButton(
                          icon: new Icon(
                            Icons.skip_previous,
                            color: Colors.white,
                            size: 50.0,
                          ),
                          onPressed: () {
                            _changeDay(-1);
                          },
                        ),
                        
                        )),
                        //////new Expanded(child: new Container()),

                        //////go to previous day
                        
                        //new Expanded(child: new Container()),
                        Expanded(child: Container(
                          //color: Colors.red,
                          child: new IconButton(
                          icon: new Icon(
                            Icons.replay_10,
                            color: Colors.white,
                            size: 50.0,
                          ),
                          onPressed: _isPlaying || _isPaused
                              ? () => _seek(adjust: -10)
                              : null,
                        ),
                        
                        )),
                        ////rewind 10 secs
                        
                       
                        ////////new Expanded(child: new Container()),

                        ///play audio button
                        ///
                        Expanded(child: Container(
                          height:100,
                          //color: Colors.blue,
                          child:  new RawMaterialButton(
                          shape: new CircleBorder(),
                          fillColor: Colors.white,
                          splashColor: lightAccentColor,
                          highlightColor: lightAccentColor.withOpacity(0.5),
                          elevation: 15.0,
                          highlightElevation: 0.5,
                          onPressed: () {
                            if (_isPlaying) {
                              _pause();
                            } else {
                              _play();
                            }
                          },
                          child: new Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: new Icon(
                              _isPlaying ? Icons.pause : Icons.play_arrow,
                              color: darkAccentColor,
                              size: 50,
                            ),
                          ),
                        ),
                        
                        )),
                       
                       

                        ///////fforward 10 secs
                        ///
                        Expanded(child: Container(
                          //color: Colors.red,
                          child: new IconButton(
                          icon: new Icon(
                            Icons.forward_10,
                            color: Colors.white,
                            size: 50.0,
                          ),
                          onPressed: _isPlaying || _isPaused
                              ? () => _seek(adjust: 10)
                              : null,
                        ),
                        
                        )),
                        
                       

                        //////go to next day
                        Expanded(child: Container(
                          //color: Colors.blue,
                          child: new IconButton(
                          icon: new Icon(
                            Icons.skip_next,
                            color: Colors.white,
                            size: 50.0,
                          ),
                          onPressed: () {
                            _changeDay(1);
                          },
                        ),
                        
                        )),
                        
                      ],
                    ),
                  ),
                ],
              ),
            )),
      ],
    );
  }

  void _initAudioPlayer() {
    _audioPlayer = AudioPlayer(
        playerId: 'odb_light',
        mode: mode); // playerId can be removed to allow multiple audio players

    _durationSubscription =
        _audioPlayer.onDurationChanged.listen((duration) => setState(() {
              _duration = duration;
            }));

    _positionSubscription =
        _audioPlayer.onAudioPositionChanged.listen((p) => setState(() {
              _position = p;
            }));

    _playerCompleteSubscription =
        _audioPlayer.onPlayerCompletion.listen((event) {
      _onComplete();
      setState(() {
        _position = _duration;
      });
    });

    _playerErrorSubscription = _audioPlayer.onPlayerError.listen((msg) {
      print('audioPlayer error : $msg');
      setState(() {
        _playerState = PlayerState.stopped;
        _duration = Duration(seconds: 0);
        _position = Duration(seconds: 0);
      });
    });

    _audioPlayer.onPlayerStateChanged.listen((state) {
      if (!mounted) return;
      setState(() {
        _audioPlayerState = state;
      });
    });
  }

  Future<int> _play() async {
    final playPosition = (_position != null &&
            _duration != null &&
            _position.inMilliseconds > 0 &&
            _position.inMilliseconds < _duration.inMilliseconds)
        ? _position
        : null;
    final result = await _audioPlayer.play(stateUrl,
        isLocal: isLocal, position: playPosition);
    if (result == 1) setState(() => _playerState = PlayerState.playing);
    return result;
  }

  Future<int> _pause() async {
    final result = await _audioPlayer.pause();
    if (result == 1) setState(() => _playerState = PlayerState.paused);
    return result;
  }

  Future<int> _stop() async {
    final result = await _audioPlayer.stop();
    if (result == 1) {
      setState(() {
        _playerState = PlayerState.stopped;
        _position = Duration();
      });
    }
    return result;
  }

  Future<int> _seek({adjust = 10}) async {
    final _newPosition = _position.inSeconds + adjust;
    final result = await _audioPlayer.play(stateUrl,
        isLocal: isLocal, position: Duration(seconds: _newPosition));
    return result;
  }

  void _onComplete() {
    setState(() => _playerState = PlayerState.stopped);
  }

  // call this function from the track skip buttons
// expects 1 or -1 to change the devo by 1 day
  Future<Null> _changeDay(int day) async {
    DateTime newDate = devoDateState;

    if (day != null) {
      if (day == 1) {
        newDate = devoDateState.add(new Duration(days: 1)); // +1 day;
      } else if (day == -1) {
        newDate = devoDateState.add(new Duration(days: -1)); // -1 day;
      }

      await _pause();
      await fetchPost(newDate);

      setState(() {
        devoDateState = newDate;
        stateUrl = generateAudioUrl(newDate);
        imageUrl = generateImageUrl(newDate);
        _duration = Duration(seconds: 0);
       _position = Duration(seconds: 0);
      });
      await _play();
    }
  }

  Future<Null> fetchPost(DateTime dvDate) async {
    String url = 'https://api.experience.odb.org/devotionals?on=';
    url = url +
        twoDigit(dvDate.month.toString()) +
        '-' +
        twoDigit(dvDate.day.toString()) +
        '-' +
        dvDate.year.toString();
    final response = await http.get(url);

    if (response.statusCode == 200) {
      // If the call to the server was successful, parse the JSON
      List<dynamic> values = new List<dynamic>();
      values = json.decode(response.body);
      if (values.length == 1) {
        if (values[0] != null) {
          Map<String, dynamic> map = values[0];
          setState(() {
            devoTitle = map['title'];
            authorName = 'By: ' + map['author_name'];
          });
          // debugPrint('Title: ${map['title']}');
          // debugPrint('Author: ${map['author_name']}');
        }
      } else {
        debugPrint('Received ${values.length} devos, expected 1');
      }
    } else {
      // If that call was not successful, throw an error.
      throw Exception('Failed to load devo from microservice');
    }
  }
}
