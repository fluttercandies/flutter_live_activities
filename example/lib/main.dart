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
  bool? _hasPermission;

  StreamSubscription<String?>? _subscription;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _subscription = null;
    super.dispose();
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
              ElevatedButton(
                onPressed: () async {
                  _hasPermission = await _liveActivitiesPlugin.areActivitiesEnabled();
                  if (_hasPermission == true) {
                    _subscription ??= _liveActivitiesPlugin.uriStream().listen((String? uri) {
                      dev.log('deeplink uri: $uri');
                    });
                  }
                  setState(() {});
                },
                child: Text('Has permission: $_hasPermission'),
              ),
              if (_hasPermission == true)
                ElevatedButton(
                  onPressed: () async {
                    dev.log((await _liveActivitiesPlugin.getAllActivities()).toString());
                  },
                  child: const Text('getAllActivities'),
                ),
              if (_hasPermission == true)
                ElevatedButton(
                  onPressed: () async {
                    await _liveActivitiesPlugin.endAllActivities();
                  },
                  child: const Text('endAllActivities'),
                ),
              if (_hasPermission == true)
                ElevatedButton(
                  onPressed: () async {
                    dev.log((await _liveActivitiesPlugin.getInitUri()).toString());
                  },
                  child: const Text('getInitUri'),
                ),
              if (_hasPermission == true && _latestActivityId == null)
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
