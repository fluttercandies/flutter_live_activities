<img src="https://raw.githubusercontent.com/fluttercandies/flutter_live_activities/main/pre/live_activities.png" height=100>

# Flutter Live Activities

[![pub package](https://img.shields.io/pub/v/flutter_live_activities?logo=dart&label=stable&style=flat-square)](https://pub.dev/packages/flutter_live_activities)
[![GitHub stars](https://img.shields.io/github/stars/fluttercandies/flutter_live_activities?logo=github&style=flat-square)](https://github.com/fluttercandies/flutter_live_activities/stargazers)
[![GitHub forks](https://img.shields.io/github/forks/fluttercandies/flutter_live_activities?logo=github&style=flat-square)](https://github.com/fluttercandies/flutter_live_activities/network/members)
<a target="_blank" href="https://jq.qq.com/?_wv=1027&k=5bcc0gy"><img border="0" src="https://pub.idqqimg.com/wpa/images/group.png" alt="FlutterCandies" title="FlutterCandies"></a>

#### 1. Add a Widget to the iOS project
<br/>

<img src="https://raw.githubusercontent.com/fluttercandies/flutter_live_activities/main/pre/new.png" height=400>

<img src="https://raw.githubusercontent.com/fluttercandies/flutter_live_activities/main/pre/we.png" height=300>

<img src="https://raw.githubusercontent.com/fluttercandies/flutter_live_activities/main/pre/config.png" height=300> 

* Directory structure

<br/>

<img src="https://raw.githubusercontent.com/fluttercandies/flutter_live_activities/main/pre/finish.png" height=300>

<br/>

#### 2. Edit `Runner/Info.plist` and `live_activity_test/Info.plist`

<br/>

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

<br/>

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

final FlutterLiveActivities _liveActivitiesPlugin = FlutterLiveActivities();

String? _latestActivityId;
```

* Check if the liveActivities function is enabled
```dart
await _liveActivitiesPlugin.areActivitiesEnabled();
```

* Get launch url
```dart
await _liveActivitiesPlugin.getInitUri()
```

* Create a live activity
```dart
_latestActivityId = await _liveActivitiesPlugin.createActivity(<String, String>{'text': 'Hello World'});
```

* Update a live activity
```dart
if(_latestActivityId != null) {
    await _liveActivitiesPlugin.updateActivity(_latestActivityId!, <String, String>{'text': 'Update Hello World'});
}
```

* End a live activity
```dart
if(_latestActivityId != null) {
    await _liveActivitiesPlugin.endActivity(_latestActivityId!);
}
```

* End all live activities
```dart
await _liveActivitiesPlugin.endAllActivities();
```

* Get all live activities id
```dart
await _liveActivitiesPlugin.getAllActivities()
```

<br/>

#### 5. Deeplink

* The default urlScheme is `FLA`

* Edit urlScheme in your project

<img src="https://raw.githubusercontent.com/fluttercandies/flutter_live_activities/main/pre/url.png" height=300>

* Swift code:

```swift
@available(iOSApplicationExtension 16.1, *)
struct live_activity_testLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: FlutterLiveActivities.self) { context in
            ...
        } dynamicIsland: { context in

            let data = TestData(JSONData: context.state.data)

            return DynamicIsland {
                ...
                DynamicIslandExpandedRegion(.bottom) {
                    // Create an action via `Link`
                    Link(destination: URL(string: "FLA://xxxxxxx.xxxxxx")!) {
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
            .widgetURL(URL(string: "FLA://www.apple.com")) // or use widgetURL
            .keylineTint(Color.red)
        }
    }
}
```

* Dart code:

```dart
_subscription ??= _liveActivitiesPlugin.uriStream(urlScheme: 'FLA').listen((String? uri) {
    dev.log('deeplink uri: $uri');
});
```