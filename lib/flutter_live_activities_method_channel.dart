import 'package:flutter/services.dart';

import 'flutter_live_activities_platform_interface.dart';
import 'src/live_activities_status.dart';

/// An implementation of [FlutterLiveActivitiesPlatform] that uses method channels.
class MethodChannelFlutterLiveActivities extends FlutterLiveActivitiesPlatform {
  /// The method channel used to interact with the native platform.
  final MethodChannel _methodChannel = const MethodChannel('flutter_live_activities');
  final EventChannel _eventChannel = const EventChannel('flutter_live_activities/event');

  @override
  void init(String urlScheme) {
    _methodChannel.invokeMethod<void>('init', <String, String>{
      'urlScheme': urlScheme,
    });
  }

  @override
  Future<Uri?> getInitUri() async {
    try {
      return Uri.tryParse(await _methodChannel.invokeMethod<String?>('getInitUri') ?? '');
    } catch (e) {
      return null;
    }
  }

  @override
  Future<List<String>> getAllActivities() async {
    try {
      final String? data = await _methodChannel.invokeMethod<String>('getAllActivities');
      if (data == null) return <String>[];
      return data.split(',');
    } catch (e) {
      return <String>[];
    }
  }

  @override
  Future<String?> createActivity(Map<String, String> data) async {
    return _methodChannel.invokeMethod<String>('createActivity', <String, dynamic>{'data': data});
  }

  @override
  Future<bool> updateActivity(String liveId, Map<String, String> data) async {
    return await _methodChannel
            .invokeMethod<bool>('updateActivity', <String, dynamic>{'liveId': liveId, 'data': data}) ??
        false;
  }

  @override
  Future<bool> endActivity(String liveId) async {
    return await _methodChannel.invokeMethod<bool>('endActivity', <String, String>{
          'liveId': liveId,
        }) ??
        false;
  }

  @override
  Future<LiveActivitiesState> getActivityState(String liveId) async {
    try {
      final int? data = await _methodChannel.invokeMethod<int>('getActivityState', <String, String>{
        'liveId': liveId,
      });

      return LiveActivitiesState.values[data ?? 3];
    } catch (e) {
      return LiveActivitiesState.unknown;
    }
  }

  @override
  Future<bool> endAllActivities() async {
    return await _methodChannel.invokeMethod<bool>('endAllActivities') ?? false;
  }

  @override
  Future<bool> areActivitiesEnabled() async {
    try {
      return (await _methodChannel.invokeMethod<bool>('areActivitiesEnabled')) ?? false;
    } catch (e) {
      return false;
    }
  }

  @override
  Stream<Uri?> uriStream() {
    return _eventChannel.receiveBroadcastStream().map((dynamic eve) {
      return Uri.tryParse(eve.toString());
    });
  }

  @override
  Future<bool> sendImageToGroup({
    required String id,
    required String filePath,
    required String groupId,
  }) async {
    return await _methodChannel.invokeMethod<bool>('sendImageToGroup', <String, String>{
          'id': id,
          'filePath': filePath,
          'groupId': groupId,
        }) ??
        false;
  }
}
