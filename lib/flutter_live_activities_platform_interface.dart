import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'flutter_live_activities_method_channel.dart';

abstract class FlutterLiveActivitiesPlatform extends PlatformInterface {
  /// Constructs a FlutterLiveActivitiesPlatform.
  FlutterLiveActivitiesPlatform() : super(token: _token);

  static final Object _token = Object();

  static FlutterLiveActivitiesPlatform _instance = MethodChannelFlutterLiveActivities();

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

  Future<String?> getInitUri() {
    throw UnimplementedError('getInitUri() has not been implemented.');
  }

  Future<List<String>> getAllActivities() {
    throw UnimplementedError('getAllActivities() has not been implemented.');
  }

  Future<String?> createActivity(Map<String, String> data) {
    throw UnimplementedError('createActivity() has not been implemented.');
  }

  Future<void> updateActivity(String liveId, Map<String, String> data) {
    throw UnimplementedError('updateActivity() has not been implemented.');
  }

  Future<void> endActivity(String liveId) {
    throw UnimplementedError('endActivity() has not been implemented.');
  }

  Future<void> endAllActivities() {
    throw UnimplementedError('endAllActivity() has not been implemented.');
  }

  Future<bool> areActivitiesEnabled() {
    throw UnimplementedError('areActivitiesEnabled() has not been implemented.');
  }

  Stream<String?> uriStream() {
    throw UnimplementedError('uriStream() has not been implemented.');
  }
}
