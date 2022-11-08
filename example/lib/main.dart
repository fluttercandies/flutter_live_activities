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
  final FlutterLiveActivities _liveActivitiesPlugin = FlutterLiveActivities();
  String? _latestActivityId;
  bool? _enabled;

  StreamSubscription<String?>? _subscription;

  String _info = '';

  @override
  void initState() {
    super.initState();
    _subscription ??= _liveActivitiesPlugin.uriStream().listen((String? uri) {
      dev.log('deeplink uri: $uri');
      if (uri != null) _setInfo(uri);
    });
    _getInitUri();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _subscription = null;
    super.dispose();
  }

  Future<void> _getInitUri() async {
    _setInfo('initUri : ${(await _liveActivitiesPlugin.getInitUri()) ?? ''}');
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
                  _enabled = await _liveActivitiesPlugin.areActivitiesEnabled();
                  setState(() {});
                },
                child: Text('Enabled: $_enabled'),
              ),
              if (_enabled == true)
                ElevatedButton(
                  onPressed: () async {
                    _setInfo((await _liveActivitiesPlugin.getAllActivities()).toString());
                  },
                  child: const Text('getAllActivities'),
                ),
              if (_enabled == true)
                ElevatedButton(
                  onPressed: () async {
                    await _liveActivitiesPlugin.endAllActivities();
                  },
                  child: const Text('endAllActivities'),
                ),
              if (_enabled == true)
                ElevatedButton(
                  onPressed: () async {
                    _setInfo((await _liveActivitiesPlugin.getInitUri()).toString());
                  },
                  child: const Text('getInitUri'),
                ),
              if (_enabled == true && _latestActivityId == null)
                ElevatedButton(
                  onPressed: () async {
                    _latestActivityId =
                        await _liveActivitiesPlugin.createActivity(<String, String>{'text': 'Hello World'});

                    setState(() {});
                  },
                  child: const Text('Create live activity'),
                ),
              if (_latestActivityId != null)
                ElevatedButton(
                  onPressed: () {
                    _liveActivitiesPlugin
                        .updateActivity(_latestActivityId!, <String, String>{'text': 'Update Hello World'});
                  },
                  child: Text(
                    'Update live activity $_latestActivityId',
                    textAlign: TextAlign.center,
                  ),
                ),
              if (_latestActivityId != null)
                ElevatedButton(
                  onPressed: () {
                    _liveActivitiesPlugin.endActivity(_latestActivityId!);
                    _latestActivityId = null;
                    _info = '';
                    setState(() {});
                  },
                  child: Text(
                    'End live activity $_latestActivityId',
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
