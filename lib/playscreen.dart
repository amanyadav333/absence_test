import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import 'package:just_audio/just_audio.dart';
import 'package:rxdart/rxdart.dart';

class PlayScreen extends StatefulWidget {

  late XFile image;
  late File song;
  PlayScreen(this.song,this.image);

  @override
  _PlayScreenState createState() => _PlayScreenState();
}

class _PlayScreenState extends State<PlayScreen> {
  final _player = AudioPlayer();
  late Stream<DurationState> _durationState;
  String songName="";

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setAudio();
    setState(() {
      songName=widget.song.path.split('/').last.toString();
    });
  }

  @override
  void dispose() {
    super.dispose();
    _player.stop();
  }

  setAudio() async {
  try {
    _durationState = Rx.combineLatest2<Duration, PlaybackEvent, DurationState>(
        _player.positionStream,
        _player.playbackEventStream,
            (position, playbackEvent) => DurationState(
          progress: position,
          buffered: playbackEvent.bufferedPosition,
          total: playbackEvent.duration,
        ));

    _player.playbackEventStream.listen((event) {},
      onError: (Object e, StackTrace stackTrace) {
      print('A stream error occurred: $e');
    });
    await _player.setFilePath(widget.song.path.toString());
    _player.load();
    _player.play();
    } catch (e) {
      print("Error loading audio source: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HexColor("#1e1e1e"),
      body: SingleChildScrollView(
        child: Container(
           padding: EdgeInsets.only(bottom: 20,top: 50),
           child: Center(
             child: Column(
               mainAxisAlignment: MainAxisAlignment.spaceBetween,
               children: [
                 Column(
                   children: [
                     Row(
                       children: [
                         SizedBox(width: 20,),
                         Icon(Icons.music_note_outlined,color: Colors.white,),
                         SizedBox(width: 5,),
                         Text(songName,style:
                         TextStyle(color: Colors.white,fontSize: 18,fontWeight: FontWeight.w500),)
                       ],
                     ),
                     SizedBox(height: 20,),

                     Container(
                         height: MediaQuery.of(context).size.height-250,
                         child: Image.file(File(widget.image.path),)
                     ),
                   ],
                 ),

                 Column(
                   children: [
                     Container(
                       margin: EdgeInsets.only(left: 20,right: 20,top: 50),
                         child: _progressBar()
                     ),
                     _playButton(),
                   ],
                 ),
               ],
             ),
           ),
        ),
      ),
    );
  }

  StreamBuilder<DurationState> _progressBar() {
    return StreamBuilder<DurationState>(
      stream: _durationState,
      builder: (context, snapshot) {
        final durationState = snapshot.data;
        final progress = durationState?.progress ?? Duration.zero;
        final buffered = durationState?.buffered ?? Duration.zero;
        final total = durationState?.total ?? Duration.zero;
        return ProgressBar(
          progress: progress,
          buffered: buffered,
          total: total,
          onSeek: (duration) {
            _player.seek(duration);
          },
          onDragUpdate: (details) {
            debugPrint('${details.timeStamp}, ${details.localPosition}');
          },
          barHeight: 5,
          baseBarColor: Colors.white,
          progressBarColor: Colors.deepOrange,
          bufferedBarColor: Colors.deepOrangeAccent,
          thumbColor: Colors.deepOrange,
          barCapShape:  BarCapShape.round,
          thumbRadius: 10,
          timeLabelLocation:  TimeLabelLocation.below,
          timeLabelTextStyle: TextStyle(color: Colors.white),
        );
      },
    );
  }

  StreamBuilder<PlayerState> _playButton() {
    return StreamBuilder<PlayerState>(
      stream: _player.playerStateStream,
      builder: (context, snapshot) {
        final playerState = snapshot.data;
        final processingState = playerState?.processingState;
        final playing = playerState?.playing;
        if (processingState == ProcessingState.loading ||
            processingState == ProcessingState.buffering) {
          return Container(
            margin: const EdgeInsets.all(8.0),
            width: 32.0,
            height: 32.0,
            child: const CircularProgressIndicator(color: Colors.white,),
          );
        } else if (playing != true) {
          return CircleAvatar(
            maxRadius: 25,
            backgroundColor: Colors.white,
            child: IconButton(
              icon: const Icon(Icons.play_arrow,color: Colors.black),
              iconSize: 32.0,
              onPressed: _player.play,
            ),
          );
        } else if (processingState != ProcessingState.completed) {
          return CircleAvatar(
            maxRadius: 25,
            backgroundColor: Colors.white,
            child: IconButton(
              icon: const Icon(Icons.pause,color: Colors.black,),
              iconSize: 32.0,
              onPressed: _player.pause,
            ),
          );
        } else {
          return CircleAvatar(
            maxRadius: 25,
            backgroundColor: Colors.white,
            child: IconButton(
              icon: const Icon(Icons.replay,color: Colors.black,),
              iconSize: 32.0,
              onPressed: () => _player.seek(Duration.zero),
            ),
          );
        }
      },
    );
  }
}

class DurationState {
  final Duration progress;
  final Duration buffered;
  final Duration? total;

  const DurationState({
    required this.progress,
    required this.buffered,
    this.total,
  });
}
