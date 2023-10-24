import 'dart:io';

import 'flutter_live_activities_platform_interface.dart';

bool _isAndroid = Platform.isAndroid;

class FlutterLiveActivities {
  FlutterLiveActivities({this.urlScheme = 'fla'}) {
    if (!_isAndroid) FlutterLiveActivitiesPlatform.instance.init(urlScheme);
  }

  /// The url scheme used to interact with the native platform.
  final String urlScheme;

  /// Get launch uri
  Future<Uri?> getInitUri() async {
    if (_isAndroid) return null;

    final Uri? url = await FlutterLiveActivitiesPlatform.instance.getInitUri();
    if (url?.isScheme(urlScheme) ?? false) return url;
    return null;
  }

  /// Get all activities id
  Future<List<String>> getAllActivities() async {
    if (_isAndroid) return <String>[];

    return FlutterLiveActivitiesPlatform.instance.getAllActivities();
  }

  /// Create an iOS 16.1+ live activity.
  /// When the activity is created, an activity id is returned.
  /// Data is a map of key/value pairs that will be transmitted to your iOS extension widget.
  /// Map is limited to String keys and values for now.
  Future<String?> createActivity(
    Map<String, String> data, {
    bool removeWhenAppIsKilled = false,
  }) async {
    if (_isAndroid) return null;

    return FlutterLiveActivitiesPlatform.instance.createActivity(
      data,
      removeWhenAppIsKilled: removeWhenAppIsKilled,
    );
  }

  /// Update an iOS 16.1+ live activity.
  /// You can get an activity id by calling [createActivity].
  /// Data is a map of key/value pairs that will be transmitted to your iOS extension widget.
  /// Map is limited to String keys and values for now.
  Future<bool> updateActivity(String liveId, Map<String, String> data) async {
    if (_isAndroid) return false;

    return FlutterLiveActivitiesPlatform.instance.updateActivity(liveId, data);
  }

  /// End an iOS 16.1+ live activity.
  /// You can get an activity id by calling [createActivity].
  Future<bool> endActivity(String liveId) async {
    if (_isAndroid) return false;

    return FlutterLiveActivitiesPlatform.instance.endActivity(liveId);
  }

  /// End an iOS 16.1+ live activity.
  /// You can get an activity id by calling [createActivity].
  Future<bool> endAllActivities() async {
    if (_isAndroid) return false;

    return FlutterLiveActivitiesPlatform.instance.endAllActivities();
  }

  /// Check if iOS 16.1+ live activities are enabled.
  /// If they are not enabled, you will not be able to create activities.
  Future<bool> areActivitiesEnabled() async {
    if (_isAndroid) return false;

    return FlutterLiveActivitiesPlatform.instance.areActivitiesEnabled();
  }

  /// Get the state of an iOS 16.1+ live activity.
  Stream<Uri?> uriStream() {
    if (_isAndroid) return const Stream<Uri?>.empty();

    return FlutterLiveActivitiesPlatform.instance.uriStream();
  }

  /// Send to Group space
  Future<bool> sendImageToGroup({
    required String id,
    required String filePath,
    required String groupId,
  }) async {
    if (_isAndroid) return false;

    return FlutterLiveActivitiesPlatform.instance.sendImageToGroup(
      id: id,
      filePath: filePath,
      groupId: groupId,
    );
  }
}
