import 'package:flutter/services.dart';

import 'flutter_live_activities_platform_interface.dart';

/// An implementation of [FlutterLiveActivitiesPlatform] that uses method channels.
class MethodChannelFlutterLiveActivities extends FlutterLiveActivitiesPlatform {
  /// The method channel used to interact with the native platform.
  final MethodChannel _methodChannel =
      const MethodChannel('flutter_live_activities');
  final EventChannel _eventChannel =
      const EventChannel('flutter_live_activities/event');

  @override
  Future<String?> getInitUri() async {
    try {
      return await _methodChannel.invokeMethod<String?>('getInitUri');
    } catch (e) {
      return null;
    }
  }

  @override
  Future<List<String>> getAllActivities() async {
    try {
      final String? data =
          await _methodChannel.invokeMethod<String>('getAllActivities');
      if (data == null) return <String>[];
      return data.split(',');
    } catch (e) {
      return <String>[];
    }
  }

  @override
  Future<String?> createActivity(Map<String, String> data) async {
    return _methodChannel.invokeMethod<String>(
        'createActivity', <String, dynamic>{'data': data});
  }

  @override
  Future<void> updateActivity(String liveId, Map<String, String> data) async {
    return _methodChannel.invokeMethod('updateActivity', <String, dynamic>{
      'liveId': liveId,
      'data': data,
    });
  }

  @override
  Future<void> endActivity(String liveId) async {
    return _methodChannel.invokeMethod('endActivity', <String, String>{
      'liveId': liveId,
    });
  }

  @override
  Future<void> endAllActivities() {
    return _methodChannel.invokeMethod('endAllActivities');
  }

  @override
  Future<bool> areActivitiesEnabled() async {
    try {
      return (await _methodChannel
              .invokeMethod<bool>('areActivitiesEnabled')) ??
          false;
    } catch (e) {
      return false;
    }
  }

  @override
  Stream<String?> uriStream({String urlScheme = 'FLA'}) {
    return _eventChannel
        .receiveBroadcastStream(urlScheme)
        .map((dynamic eve) => eve?.toString());
  }
}
