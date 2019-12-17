import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:odb_flutter_light/theme.dart';

enum PlayerState { stopped, playing, paused }

class PlayerWidget extends StatefulWidget {
  final String url;
  final String imgUrl;
  final bool isLocal;
  final PlayerMode mode;

  PlayerWidget({
    @required this.url,
    @required this.imgUrl,
    this.isLocal = false,
    this.mode = PlayerMode.MEDIA_PLAYER,
  });

  @override
  State<StatefulWidget> createState() {
    return new _PlayerWidgetState(url, imgUrl, isLocal, mode);
  }
}

class _PlayerWidgetState extends State<PlayerWidget> {
  String stateUrl;
  String imageUrl;
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

  _PlayerWidgetState(this.stateUrl, this.imageUrl, this.isLocal, this.mode);

  @override
  void initState() {
    super.initState();
    _initAudioPlayer();
  }

  @override
  void didUpdateWidget(Widget oldWidget) {
    setState(() {
      stateUrl = widget.url;
      imageUrl = widget.imgUrl;
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
          color: Colors.tealAccent,
          width: double.infinity,
          height: 320.0,
          child: Image.network(
            imageUrl,
            fit: BoxFit.fitHeight,
          ),
        ),
                  ////progress indicator
                  new FractionallySizedBox(
                    //height: 9.0,
                    widthFactor: 1,
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
                  ),
        //progress indicator, song title, artist name and controls
        new Container(
            color: accentColor,
            child: new Padding(
              padding: const EdgeInsets.all(5.0),
              child: new Column(
                children: <Widget>[
                  
                  ////devo info
                  new RichText(
                      text: new TextSpan(text: '', children: [
                    new TextSpan(
                      text: 'Devo Title\n',
                      style: new TextStyle(
                        color: Colors.white,
                        fontSize: 16.0,
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
                  
                  /////duration info
                   Align(
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
              child: Stack(
                children: [
                  Slider(
                    onChanged: (v) {
                      final Position = v * _duration.inMilliseconds;
                      _audioPlayer
                          .seek(Duration(milliseconds: Position.round()));
                    },
                    value: (_position != null &&
                            _duration != null &&
                            _position.inMilliseconds > 0 &&
                            _position.inMilliseconds < _duration.inMilliseconds)
                        ? _position.inMilliseconds / _duration.inMilliseconds
                        : 0.0,
                  ),])),

                  ///////todo find a better way formatting the player controls
                  Padding(
                    padding: const EdgeInsets.only(left: 0.0, top: 5.0, right: 20.0, bottom: 0.0),
                    child: new Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        //////new Expanded(child: new Container()),
                        
                        //////go to previous day
                        new IconButton(
                          icon: new Icon(
                            Icons.skip_previous,
                            color: Colors.white,
                            size: 50.0,
                          ),
                          onPressed: () {
                            //todo next button
                          },
                        ),
                        SizedBox(width: 10.0,),
                        //new Expanded(child: new Container()),

                        ////rewind 10 secs
                        new IconButton(
                          icon: new Icon(
                            Icons.replay_10,
                            color: Colors.white,
                            size: 50.0,
                          ),
                          onPressed: 
                          _isPlaying || _isPaused ? () => _seek(adjust: -10) : null , 

                          
                        ),
                        SizedBox(width: 20.0,),
                        ////////new Expanded(child: new Container()),

                        ///play audio button
                        new RawMaterialButton(
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
                              size: 90,
                            ),
                          ),
                        ),
                        SizedBox(width: 0.0,),
                        
                        ///////fforward 10 secs 
                        new IconButton(
                          icon: new Icon(
                            Icons.forward_10,
                            color: Colors.white,
                            size: 50.0,
                          ),
                          onPressed: 
                          _isPlaying || _isPaused ? () => _seek(adjust: 10) : null , 
                        ),
                        SizedBox(width: 10.0,),
                        
                        //////go to next day
                        new IconButton(
                          icon: new Icon(
                            Icons.skip_next,
                            color: Colors.white,
                            size: 50.0,
                          ),
                          onPressed: () {
                            //todo next day button
                          },
                        ),
                       ////////////// new Expanded(child: new Container()),
                       ////////////// new Expanded(child: new Container()),
                        
                      ],
                    ),
                  ),
                  
                  ////temporary stop button, remove this
                  Padding(
                     padding: const EdgeInsets.only(top: 0.0, bottom: 0.0),
                    child: new Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                          new Container(
                          child: IconButton(
                              onPressed: _isPlaying || _isPaused
                                  ? () => _stop()
                                  : null,
                              iconSize: 64.0,
                              icon: new Icon(Icons.stop),
                              color: Colors.cyan),
                        ),
                      ]
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
}
