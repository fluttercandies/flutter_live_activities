import 'package:flutter_live_activities/src/live_activities_status.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'flutter_live_activities_method_channel.dart';

abstract class FlutterLiveActivitiesPlatform extends PlatformInterface {
  /// Constructs a FlutterLiveActivitiesPlatform.
  FlutterLiveActivitiesPlatform() : super(token: _token);

  static final Object _token = Object();

  static FlutterLiveActivitiesPlatform _instance =
      MethodChannelFlutterLiveActivities();

  /// The default instance of [FlutterLiveActivitiesPlatform] to use.
  ///
  /// Defaults to [MethodChannelFlutterLiveActivities].
  static FlutterLiveActivitiesPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [FlutterLiveActivitiesPlatform] when
  /// they register themselves.
  static set instance(FlutterLiveActivitiesPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  void init(String urlScheme) {
    throw UnimplementedError('init() has not been implemented.');
  }

  Future<Uri?> getInitUri() {
    throw UnimplementedError('getInitUri() has not been implemented.');
  }

  Future<List<String>> getAllActivities() {
    throw UnimplementedError('getAllActivities() has not been implemented.');
  }

  Future<String?> createActivity(
    Map<String, String> data, {
    bool removeWhenAppIsKilled = false,
  }) {
    throw UnimplementedError('createActivity() has not been implemented.');
  }

  Future<bool> updateActivity(String liveId, Map<String, String> data) {
    throw UnimplementedError('updateActivity() has not been implemented.');
  }

  Future<bool> endActivity(String liveId) {
    throw UnimplementedError('endActivity() has not been implemented.');
  }

  Future<LiveActivitiesState> getActivityState(String liveId) async {
    throw UnimplementedError('getActivityState() has not been implemented.');
  }

  Future<bool> endAllActivities() {
    throw UnimplementedError('endAllActivity() has not been implemented.');
  }

  Future<bool> areActivitiesEnabled() {
    throw UnimplementedError(
        'areActivitiesEnabled() has not been implemented.');
  }

  Stream<Uri?> uriStream() {
    throw UnimplementedError('uriStream() has not been implemented.');
  }

  Future<bool> sendImageToGroup({
    required String id,
    required String filePath,
    required String groupId,
  }) {
    throw UnimplementedError('sendImageToGroup() has not been implemented.');
  }
}
