import 'dart:async';
import 'dart:developer' as dev;

import 'package:flutter/material.dart';
import 'package:flutter_live_activities/flutter_live_activities.dart';

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

  StreamSubscription<String?>? _subscription;

  String _info = '';

  @override
  void initState() {
    super.initState();
    _initStream();
    _getInitUri();
  }

  Future<void> _initStream() async {
    _subscription ??= _liveActivities.uriStream().listen((String? uri) {
      dev.log('deeplink uri: $uri');
      if (uri != null) _setInfo(uri);
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
              Text(
                'Info: $_info',
                textAlign: TextAlign.center,
              ),
              ElevatedButton(
                onPressed: () async {
                  _enabled = await _liveActivities.areActivitiesEnabled();
                  setState(() {});
                },
                child: Text('Enabled: $_enabled'),
              ),
              if (_enabled == true)
                ElevatedButton(
                  onPressed: () async {
                    _setInfo(
                        (await _liveActivities.getAllActivities()).toString());
                  },
                  child: const Text('getAllActivities'),
                ),
              if (_enabled == true)
                ElevatedButton(
                  onPressed: () async {
                    await _liveActivities.endAllActivities();
                  },
                  child: const Text('endAllActivities'),
                ),
              if (_enabled == true)
                ElevatedButton(
                  onPressed: () async {
                    _setInfo((await _liveActivities.getInitUri()).toString());
                  },
                  child: const Text('getInitUri'),
                ),
              if (_enabled == true && _activityId == null)
                ElevatedButton(
                  onPressed: () async {
                    _initStream();

                    _activityId = await _liveActivities.createActivity(
                        <String, String>{'text': 'Hello World'});

                    setState(() {});
                  },
                  child: const Text('Create live activity'),
                ),
              if (_activityId != null)
                ElevatedButton(
                  onPressed: () {
                    _liveActivities.updateActivity(_activityId!,
                        <String, String>{'text': 'Update Hello World'});
                  },
                  child: Text(
                    'Update live activity $_activityId',
                    textAlign: TextAlign.center,
                  ),
                ),
              if (_activityId != null)
                ElevatedButton(
                  onPressed: () {
                    _cancelStream();
                    _liveActivities.endActivity(_activityId!);
                    _activityId = null;
                    _info = '';
                    setState(() {});
                  },
                  child: Text(
                    'End live activity $_activityId',
                    textAlign: TextAlign.center,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
