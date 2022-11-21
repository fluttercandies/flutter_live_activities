import 'dart:async';
import 'dart:developer' as dev;

import 'package:flutter/material.dart';
import 'package:flutter_live_activities/flutter_live_activities.dart';
import 'package:flutter_live_activities_example/helper/image_helper.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Flutter Demo',
      home: Home(),
    );
  }
}

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final FlutterLiveActivities _liveActivities = FlutterLiveActivities();
  String? _activityId;
  bool? _enabled;

  StreamSubscription<Uri?>? _subscription;

  String _info = '';

  @override
  void initState() {
    super.initState();
    _initStream();
    _getInitUri();
  }

  Future<void> _initStream() async {
    _subscription ??= _liveActivities.uriStream().listen((Uri? uri) {
      dev.log('deeplink uri: $uri');
      if (uri != null) _setInfo(uri.toString());
    });
  }

  void _cancelStream() {
    _subscription?.cancel();
    _subscription = null;
  }

  @override
  void dispose() {
    _cancelStream();
    super.dispose();
  }

  Future<void> _getInitUri() async {
    _setInfo('initUri : ${(await _liveActivities.getInitUri()) ?? ''}');
  }

  void _setInfo(String info) {
    setState(() {
      _info = info;
    });
  }

  Future<void> _checkEnabled() async {
    _enabled = await _liveActivities.areActivitiesEnabled();
    setState(() {});
  }

  Future<void> _getAllActivities() async {
    _setInfo((await _liveActivities.getAllActivities()).toString());
  }

  Future<void> _endAllActivities() async {
    await _liveActivities.endAllActivities();
  }

  Future<void> _createActivity() async {
    _initStream();

    _activityId = await _liveActivities
        .createActivity(<String, String>{'text': 'Hello World'});

    setState(() {});
  }

  Future<void> _updateActivity() async {
    _liveActivities.updateActivity(
        _activityId!, <String, String>{'text': 'Update Hello World'});
  }

  Future<void> _endActivity() async {
    _cancelStream();
    _liveActivities.endActivity(_activityId!);
    _activityId = null;
    _setInfo('');
  }

  Future<void> _sendImageToGroup() async {
    const String url =
        'https://cdn.iconscout.com/icon/free/png-256/flutter-2752187-2285004.png';
    final String? path = await ImageHelper.getFilePathFromUrl(url);

    if (path != null) {
      _liveActivities.sendImageToGroup(
        id: 'test-img',
        filePath: path,
        groupId: 'group.live_example',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter Live Activities'),
      ),
      body: SizedBox.expand(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text('Info: $_info', textAlign: TextAlign.center),
              ElevatedButton(
                onPressed: _checkEnabled,
                child: Text('Enabled: $_enabled'),
              ),
              if (_enabled == true)
                ElevatedButton(
                  onPressed: _getAllActivities,
                  child: const Text('getAllActivities'),
                ),
              if (_enabled == true)
                ElevatedButton(
                  onPressed: _getInitUri,
                  child: const Text('getInitUri'),
                ),
              ElevatedButton(
                onPressed: _sendImageToGroup,
                child: const Text('Send image to group'),
              ),
              if (_enabled == true && _activityId == null)
                ElevatedButton(
                  onPressed: _createActivity,
                  child: const Text('Create live activity'),
                ),
              if (_activityId != null)
                ElevatedButton(
                  onPressed: _updateActivity,
                  child: Text(
                    'Update live activity $_activityId',
                    textAlign: TextAlign.center,
                  ),
                ),
              if (_activityId != null)
                ElevatedButton(
                  onPressed: _endActivity,
                  child: Text(
                    'End live activity $_activityId',
                    textAlign: TextAlign.center,
                  ),
                ),
              if (_enabled == true)
                ElevatedButton(
                  onPressed: _endAllActivities,
                  child: const Text('endAllActivities'),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
