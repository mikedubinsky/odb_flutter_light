import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:odb_flutter_light/theme.dart';

enum PlayerState { stopped, playing, paused }

class PlayerWidget extends StatefulWidget {
  final String url;
  final bool isLocal;
  final PlayerMode mode;

  PlayerWidget(
      {@required this.url,
        this.isLocal = false,
        this.mode = PlayerMode.MEDIA_PLAYER});

  @override
  State<StatefulWidget> createState() {
    return new _PlayerWidgetState(url, isLocal, mode);
  }
}

class _PlayerWidgetState extends State<PlayerWidget> {
  String url;
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

  _PlayerWidgetState(this.url, this.isLocal, this.mode);

  @override
  void initState() {
    super.initState();
    _initAudioPlayer();
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
                   
        new Row(
          mainAxisSize: MainAxisSize.min,
          children: [
                    // Display the correct icon depending on the state of the player.
        //Icon(
          //_controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
        //),
            new IconButton(
                onPressed: _isPlaying ? null : () => _play(),
                iconSize: 64.0,
                icon: new Icon(Icons.play_arrow),
                color: Colors.cyan),
            new IconButton(
                onPressed: _isPlaying ? () => _pause() : null,
                iconSize: 64.0,
                icon: new Icon(Icons.pause),
                color: Colors.cyan),
            new IconButton(
                onPressed: _isPlaying || _isPaused ? () => _stop() : null,
                iconSize: 64.0,
                icon: new Icon(Icons.stop),
                color: Colors.cyan),
          ],
        ),
        new Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            new Padding(
              padding: new EdgeInsets.all(12.0),
              child: new Stack(
                children: [
                  new CircularProgressIndicator(
                    value: 1.0,
                    valueColor: new AlwaysStoppedAnimation(Colors.grey[300]),
                  ),
                  new CircularProgressIndicator(
                    value: (_position != null &&
                        _duration != null &&
                        _position.inMilliseconds > 0 &&
                        _position.inMilliseconds < _duration.inMilliseconds)
                        ? _position.inMilliseconds / _duration.inMilliseconds
                        : 0.0,
                    valueColor: new AlwaysStoppedAnimation(Colors.cyan),
                  ),
                ],
              ),
            ),
            new Text(
              _position != null
                  ? '${_positionText ?? ''} / ${_durationText ?? ''}'
                  : _duration != null ? _durationText : '',
              style: new TextStyle(fontSize: 24.0),
            ),
          ],
        ),
        new Text("State: $_audioPlayerState"),
         //song title, artist name and controls
            new Container(
                color: accentColor,
                child: new Padding(
                  padding: const EdgeInsets.only(top: 40.0, bottom: 160.0),
                  child: new Column(
                    children: <Widget>[
                      new RichText(
                          text: new TextSpan(text: '', children: [
                        new TextSpan(
                          text: 'Devo Title\n',
                          style: new TextStyle(
                            color: Colors.white,
                            fontSize: 14.0,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 4.0,
                            height: 1.5,
                          ),
                        ),
                        new TextSpan(
                            text: 'Authors Name\n',
                            style: new TextStyle(
                              color: Colors.white.withOpacity(0.65),
                              fontSize: 12.0,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 3.0,
                              height: 1.5,
                            ))
                      ])),
                      Padding(
                        padding: const EdgeInsets.only(top: 30.0, bottom: 50.0),
                        child: new Row(
                          children: <Widget>[
                            new Expanded(child: new Container()),
                            /*new IconButton(
                              icon: new Icon(
                                //previous button
                                Icons.skip_previous,
                                color: Colors.white,
                                size: 50.0,
                              ),
                              onPressed: () {
                                //todo
                              },
                            ),*/
                            new Expanded(child: new Container()),
                            new RawMaterialButton(
                              shape: new CircleBorder(),
                              fillColor: Colors.white,
                              splashColor: lightAccentColor,
                              highlightColor: lightAccentColor.withOpacity(0.5),
                              elevation: 15.0,
                              highlightElevation: 0.5,
                             // onPressed: _isPlaying ? null:()=>_play(),
                              onPressed: (){
                                if  (_isPlaying )
                                {
                                  _pause();
                                }
                                else {
                                  _play();}
                              },
                              child: new Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: new Icon(
                                  //play  button
                                  _isPlaying ? Icons.pause : Icons.play_arrow,
                                 // Icons.play_arrow,
                                  color: darkAccentColor,
                                  size: 90,
                                ),
                              ),
                            ),
                            new Expanded(child: new Container()),
                           /* new IconButton(
                              icon: new Icon(
                                //next button
                                Icons.skip_next,
                                color: Colors.white,
                                size: 50.0,
                              ),
                              onPressed: () {
                                //todo
                              },
                            ),*/
                            new Expanded(child: new Container()),
                          ],
                        ),
                      )
                    ],
                  ),
                )),
      ],
    );
  }

  void _initAudioPlayer() {
    _audioPlayer = AudioPlayer(mode: mode);

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
    final result =
    await _audioPlayer.play(url, isLocal: isLocal, position: playPosition);
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

  void _onComplete() {
    setState(() => _playerState = PlayerState.stopped);
  }
}