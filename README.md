<img src="https://raw.githubusercontent.com/xSILENCEx/project_images/main/flutter_live_activities/live_activities.png" height=100>

# Flutter Live Activities

Flutter plugin for Live Activities. Use to create, update and handling action for [DynamicIsland UI] and [Lock screen/banner UI]

English | [中文说明](README-ZH.md)

[![pub package](https://img.shields.io/pub/v/flutter_live_activities?logo=dart&label=stable&style=flat-square)](https://pub.dev/packages/flutter_live_activities)
[![GitHub stars](https://img.shields.io/github/stars/fluttercandies/flutter_live_activities?logo=github&style=flat-square)](https://github.com/fluttercandies/flutter_live_activities/stargazers)
[![GitHub forks](https://img.shields.io/github/forks/fluttercandies/flutter_live_activities?logo=github&style=flat-square)](https://github.com/fluttercandies/flutter_live_activities/network/members)
<a target="_blank" href="https://jq.qq.com/?_wv=1027&k=5bcc0gy"><img border="0" src="https://pub.idqqimg.com/wpa/images/group.png" alt="FlutterCandies" title="FlutterCandies"></a>

> This plugin requires notification permission

<img src="https://raw.githubusercontent.com/xSILENCEx/project_images/main/flutter_live_activities/pre.gif" width=200><img src="https://raw.githubusercontent.com/xSILENCEx/project_images/main/flutter_live_activities/pre2.gif" width=200><img src="https://raw.githubusercontent.com/xSILENCEx/project_images/main/flutter_live_activities/img.png" width=200>

#### 1. Add a Widget to the iOS project


<img src="https://raw.githubusercontent.com/xSILENCEx/project_images/main/flutter_live_activities/new.png" height=400>

<img src="https://raw.githubusercontent.com/xSILENCEx/project_images/main/flutter_live_activities/we.png" height=300>

<img src="https://raw.githubusercontent.com/xSILENCEx/project_images/main/flutter_live_activities/config.png" height=300> 

* Directory structure

<img src="https://raw.githubusercontent.com/xSILENCEx/project_images/main/flutter_live_activities/finish.png" height=400>

#### 2. Edit `Runner/Info.plist` and `live_activity_test/Info.plist`

both add:
```xml
<plist version="1.0">
<dict>
    ...
	<key>NSSupportsLiveActivities</key>
	<true/>
    ...
</dict>
</plist>
```

#### 3. Create a data channel in widget swift file

[live_activity_test/live_activity_testLiveActivity.swift](https://github.com/fluttercandies/flutter_live_activities/blob/main/example/ios/live_activity_test/live_activity_testLiveActivity.swift)

```swift
import ActivityKit
import SwiftUI
import WidgetKit

// Custom data model
struct TestData {
    var text: String

    init?(JSONData data: [String: String]) {
        self.text = data["text"] ?? ""
    }

    init(text: String) {
        self.text = text
    }
}

// Data channel  <-  Must!
struct FlutterLiveActivities: ActivityAttributes, Identifiable {
    public typealias LiveData = ContentState

    public struct ContentState: Codable, Hashable {
        var data: [String: String]
    }

    var id = UUID()
}

@available(iOSApplicationExtension 16.1, *)
struct live_activity_testLiveActivity: Widget {
    var body: some WidgetConfiguration {
        // Binding
        ActivityConfiguration(for: FlutterLiveActivities.self) { context in

            // Lock screen/banner UI goes here

            // Json to model
            let data = TestData(JSONData: context.state.data)

            // UI
            VStack {
                Text(data?.text ?? "")
            }
            .activityBackgroundTint(Color.cyan)
            .activitySystemActionForegroundColor(Color.black)
        } dynamicIsland: { context in
            // Json to model
            let data = TestData(JSONData: context.state.data)

            // DynamicIsland
            return DynamicIsland {
                // Expanded UI goes here.  Compose the expanded UI through
                // various regions, like leading/trailing/center/bottom
                DynamicIslandExpandedRegion(.leading) {
                    Text("Leading")
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text("Trailing")
                }
                DynamicIslandExpandedRegion(.bottom) {
                    // Show data from flutter
                    Text(data?.text ?? "")
                }
            } compactLeading: {
                Text("L")
            } compactTrailing: {
                Text("T")
            } minimal: {
                Text("Min")
            }
            .keylineTint(Color.red)
        }
    }
}
```

For more layout information, please refer to: [live activities](https://developer.apple.com/documentation/activitykit/displaying-live-data-with-live-activities)

#### 4. APIs

```dart
import 'package:flutter_live_activities/flutter_live_activities.dart';

...

final FlutterLiveActivities _liveActivities = FlutterLiveActivities();

String? _activityId;
```

* Check if the Live Activities function is enabled
```dart
await _liveActivities.areActivitiesEnabled();
```

* Get launch url
```dart
await _liveActivities.getInitUri()
```

* Create a Live Activity
```dart
_activityId = await _liveActivities.createActivity(<String, String>{'text': 'Hello World'});
```

* To dismiss the live activity when app terminated
```dart
_activityId = await _liveActivities.createActivity(
      <String, String>{'text': 'Hello World'}
      removeWhenAppIsKilled: true,
    );
```

* Update a Live Activity
```dart
if(_activityId != null) {
    await _liveActivities.updateActivity(_activityId!, <String, String>{'text': 'Update Hello World'});
}
```

> The updated dynamic data for both ActivityKit updates and remote push notification updates can’t exceed 4KB in size.  [doc](https://developer.apple.com/documentation/activitykit/displaying-live-data-with-live-activities)

<img src="https://raw.githubusercontent.com/xSILENCEx/project_images/main/flutter_live_activities/4k.png" height=300>

> For more solutions, please refer to [live_activities](https://pub.dev/packages/live_activities)

* End a Live Activity
```dart
if(_activityId != null) {
    await _liveActivities.endActivity(_activityId!);
}
```

* End all Live Activities
```dart
await _liveActivities.endAllActivities();
```

* Get all Live Activities id
```dart
await _liveActivities.getAllActivities()
```

#### 5. Deeplink

* The default urlScheme is `fla`

> `FlutterLiveActivities({this.urlScheme = 'fla'})`

* Add urlScheme in your project

<img src="https://raw.githubusercontent.com/xSILENCEx/project_images/main/flutter_live_activities/scheme.png" height=400>

* Swift code:

```swift
@available(iOSApplicationExtension 16.1, *)
struct live_activity_testLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: FlutterLiveActivities.self) { context in
            let data = TestData(JSONData: context.state.data)

            // Lock screen/banner UI goes here

            VStack(alignment: .leading) {
                Text(data?.text ?? "")
                HStack {
                    // Create an action via `Link`
                    Link(destination: URL(string: "fla://xx.xx/tap/A")!) {
                        Text("A")
                            .frame(width: 40, height: 40)
                            .background(.blue)
                    }
                    // Create an action via `Link`
                    Link(destination: URL(string: "fla://xx.xx/tap/B")!) {
                        Text("B")
                            .frame(width: 40, height: 40)
                            .background(.blue)
                    }
                    // Create an action via `Link`
                    Link(destination: URL(string: "fla://xx.xx/tap/C")!) {
                        Text("C")
                            .frame(width: 40, height: 40)
                            .background(.blue)
                    }
                }
                .frame(width: .infinity, height: .infinity)
            }
            .padding(20)
            .activityBackgroundTint(Color.cyan)
            .activitySystemActionForegroundColor(Color.black)

        } dynamicIsland: { context in

            let data = TestData(JSONData: context.state.data)

            return DynamicIsland {
                DynamicIslandExpandedRegion(.bottom) {
                    // Create an action via `Link`
                    Link(destination: URL(string: "fla://xxxxxxx.xxxxxx")!) {
                        Text(data?.text ?? "")
                            .background(.red)
                    }
                }
            } compactLeading: {
                Text("L")
            } compactTrailing: {
                Text("T")
            } minimal: {
                Text("Min")
            }
            .widgetURL(URL(string: "fla://www.apple.com")) // or use widgetURL
            .keylineTint(Color.red)
        }
    }
}
```

* Dart code:

```dart
_subscription ??= _liveActivities.uriStream().listen((String? uri) {
    dev.log('deeplink uri: $uri');
});
```

#### 6. Display image

> Due to block size limitations. We can't send metadata to LiveActivities  

> LiveActivities does not support async loading, so we can't use AsyncImage or read local file

> Solution from Developer Forums: [716902](https://developer.apple.com/forums/thread/716902)

* Add group config (Paid account required)

<img src="https://raw.githubusercontent.com/xSILENCEx/project_images/main/flutter_live_activities/group.png" height=300>

* Add group id both Runner and Widget

<img src="https://raw.githubusercontent.com/xSILENCEx/project_images/main/flutter_live_activities/groupId.png" height=300>

* Send image to group:

Dart code:
```dart
Future<void> _sendImageToGroup() async {
    const String url = 'https://cdn.iconscout.com/icon/free/png-256/flutter-2752187-2285004.png';

    final String? path = await ImageHelper.getFilePathFromUrl(url);

    if (path != null) {
        _liveActivities.sendImageToGroup(
            id: 'test-img',
            filePath: path,
            groupId: 'group.live_example',
        );
    }
}
```

Swift code:
```swift
DynamicIslandExpandedRegion(.leading) {
    if let imageContainer = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.live_example")?.appendingPathComponent("test-img"), /// Use id here
        let uiImage = UIImage(contentsOfFile: imageContainer.path())
    {
        Image(uiImage: uiImage)
            .resizable()
            .frame(width: 53, height: 53)
            .cornerRadius(13)
    } else {
        Text("Leading")
    }
}
```